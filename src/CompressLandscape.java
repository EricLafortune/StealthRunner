import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.*;

/**
 * Converts a landscape image to a landscape file in our own compressed
 * format.
 *
 * The landscape image is mostly binary, except for colored object pixels,
 * which are ignored here.
 *
 * Usage:
 *   java CompressLandscape [options] <input_file> <output_file>
 * where options are
 *   -charoffset <c> the required offset for characters assigned in the
 *                   screens.
 *   -shiftx <s>     the horizontal shift of the first dot.
 *   -shifty <s>     the vertical shift of the first dot.
 *
 * Interpretation:
 *
 *   Image      Landscape
 *   (bits):    (bytes):
 *   x x x x    . . . .
 *   x x x x ->  . . . .
 *   x x x x    . . . .
 *   x x x x     . . . .
 *
 * Typical shifts:
 *
 *   (0, 0)
 *   1 x x x    1 . . .
 *   2 x x x ->  2 . . .
 *   x x x x    . . . .
 *   x x x x     . . . .
 *
 *   (1, 0)
 *   x 1 x x      1 . . .
 *   2 x x x ->  2 . . .
 *   x x x x    . . . . .
 *   x x x x     . . . .
 *
 *   (0, 1)
 *   x x x x    . . . .
 *   2 x x x ->  2 . . .
 *   1 x x x    1 . . .
 *   x x x x     . . . .
 *
 *   (1, 1)
 *   x x x x      . . . .
 *   2 x x x ->  2 . . .
 *   x 1 x x      1 . . .
 *   x x x x     . . . .
 *
 * where the char gets these 8 bits: 0000 0021.
 *
 * The landscape has the same width but half the height as the image.
 *
 * The landscape bytes are compressed as horizontal runs of non-zero bytes.
 */
public class CompressLandscape
{
    private static final int MAX_WIDTH  = 0x1fff;
    private static final int MAX_HEIGHT = 512;

    private static final int EMPTY     = 0x000000;
    private static final int LANDSCAPE = 0x5edc78;

    private static final boolean DEBUG = false;


    private final BufferedImage image;
    private final int           width;
    private final int           height;

    private int deltaIndex; // For debug printing.

    public static void main(String[] args)
    throws IOException
    {
        int charOffset = 1;

        // Parse any options.
        int argIndex = 0;

        while (true)
        {
            String arg = args[argIndex];
            if (!arg.startsWith("-"))
            {
                break;
            }

            argIndex++;

            switch (arg)
            {
                case "-charoffset" -> charOffset  = Integer.parseInt(args[argIndex++]);
                default            -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
            }
        }

        String inputFileName  = args[argIndex++];
        String outputFileName = args[argIndex++];

        BufferedImage image = ImageIO.read(new File(inputFileName));
        if (image == null)
        {
            throw new IOException("Unsupported image format ["+inputFileName+"]");
        }

        CompressLandscape landscape =
            new CompressLandscape(image);

        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    public CompressLandscape(BufferedImage image)
    {
        this.image  = image;
        this.width  = Math.min(MAX_WIDTH,  image.getWidth());
        this.height = Math.min(MAX_HEIGHT, image.getHeight());
    }


    private void write(DataOutputStream outputStream)
    throws IOException
    {
        // Write out the landscape deltas for each source quadrant to each of
        // its surrounding quadrants.
        for (int quadrantY = 0; quadrantY <= 1; quadrantY++)
        {
            for (int quadrantX = 0; quadrantX <= 1; quadrantX++)
            {
                for (int quadrantDeltaY = -1; quadrantDeltaY <= 1; quadrantDeltaY++)
                {
                    for (int quadrantDeltaX = -1; quadrantDeltaX <= 1; quadrantDeltaX++)
                    {
                        // We're skipping the zero shift, reducing the number
                        // of landscape deltas from 9 to 8 (for each of the
                        // 4 shifts).
                        if (quadrantDeltaX != 0 ||
                            quadrantDeltaY != 0)
                        {
                            writeLandscapeDelta(quadrantX,
                                                quadrantY,
                                                quadrantDeltaX,
                                                quadrantDeltaY,
                                                outputStream);
                        }
                    }
                }
            }
        }
    }


    private void writeLandscapeDelta(int              quadrantX,
                                     int              quadrantY,
                                     int              quadrantDeltaX,
                                     int              quadrantDeltaY,
                                     DataOutputStream outputStream)
    throws IOException
    {
        if (DEBUG)
        {
            System.out.printf("#0x%02X: Quadrant (%d, %d), delta (%d, %d)\n",
                              deltaIndex++,
                              quadrantX,
                              quadrantY,
                              quadrantDeltaX,
                              quadrantDeltaY);
            for (int charY = 0; charY < height / 2; charY++)
            {
                for (int charX = 0; charX < width; charX++)
                {
                    int character =
                        landscapeCharacter(quadrantX,
                                           quadrantY,
                                           charX,
                                           charY);

                    int oldCharacter =
                        landscapeCharacter(quadrantX,
                                           quadrantY,
                                           quadrantDeltaX,
                                           quadrantDeltaY,
                                           charX,
                                           charY);

                    System.out.print(character != oldCharacter ?
                                         "" + (char)('0' + character) + (char)('0' + oldCharacter):
                                         "" + (character == 0 ? '.' :
                                               character == 3 ? ':' :
                                                                '-') + ' ');
                }
                System.out.println();
            }
            System.out.println();
        }

        // Compress and write out the patterns.
        ByteArrayOutputStream offsetOutputStream =
            new ByteArrayOutputStream(height);

        ByteArrayOutputStream frameOutputStream =
            new ByteArrayOutputStream(8 * 1024);

        // Write the characters compressed as spans.
        writeCharacterSpans(quadrantX,
                            quadrantY,
                            quadrantDeltaX,
                            quadrantDeltaY,
                            new DataOutputStream(offsetOutputStream),
                            new DataOutputStream(frameOutputStream));

        int size = offsetOutputStream.size() +
                   frameOutputStream.size();

        if (size > 8 * 1024)
        {
            throw new IllegalArgumentException("Landscape exceeds single memory bank");
        }

        // Concatenate the offset table and the compressed frame data.
        outputStream.write(offsetOutputStream.toByteArray());
        outputStream.write(frameOutputStream.toByteArray());

        // Skip to the next memory bank.
        outputStream.write(new byte[8 * 1024 - size]);
    }


    private void writeCharacterSpans(int              quadrantX,
                                     int              quadrantY,
                                     int              quadrantDeltaX,
                                     int              quadrantDeltaY,
                                     DataOutputStream offsetOutputStream,
                                     DataOutputStream frameOutputStream)
    throws IOException
    {
        // The landscape height is half the image height.
        // Scan all landscape rows.
        for (int charY = 0; charY < height / 2; charY++)
        {
            // Write the offset to the spans (including the size of the list
            // of offsets in the same memory bank).
            offsetOutputStream.writeChar(height + frameOutputStream.size());

            // Write the spans of this row.
            writeCharacterSpans(quadrantX,
                                quadrantY,
                                quadrantDeltaX,
                                quadrantDeltaY,
                                charY,
                                frameOutputStream);
        }
    }


    private void writeCharacterSpans(int              quadrantX,
                                     int              quadrantY,
                                     int              quadrantDeltaX,
                                     int              quadrantDeltaY,
                                     int              charY,
                                     DataOutputStream frameOutputStream)
    throws IOException
    {
        int endX = -1;
        while (true)
        {
            // Compute the start and end of the next span.
            int startX = characterSpanStart(quadrantX,
                                            quadrantY,
                                            quadrantDeltaX,
                                            quadrantDeltaY,
                                            endX + 1,
                                            charY);
            if (startX == width)
            {
                break;
            }

            endX = characterSpanEnd(quadrantX,
                                    quadrantY,
                                    quadrantDeltaX,
                                    quadrantDeltaY,
                                    startX + 1,
                                    charY);

            int length = endX - startX;
            if (length > 255)
            {
                throw new IllegalArgumentException("Span longer than 255 bytes ("+length+" bytes)");
            }

            // Write the span: destination (little-endian), length, and data.
            frameOutputStream.write(startX);
            frameOutputStream.write(startX >> 8);
            frameOutputStream.write(length);

            for (int charX = startX; charX < endX; charX++)
            {
                frameOutputStream.write(landscapeCharacter(quadrantX,
                                                           quadrantY,
                                                           charX,
                                                           charY));
            }
        }

        // Write the terminator: large destination (little-endian).
        frameOutputStream.write(0xff);
        frameOutputStream.write(0x7f);
    }


    private int characterSpanStart(int quadrantX,
                                   int quadrantY,
                                   int quadrantDeltaX,
                                   int quadrantDeltaY,
                                   int charX,
                                   int charY)
    {
        for (; charX < width; charX++)
        {
            if (isDifferentLandscapeCharacter(quadrantX,
                                              quadrantY,
                                              quadrantDeltaX,
                                              quadrantDeltaY,
                                              charX,
                                              charY))
            {
                break;
            }
        }

        return charX;
    }


    private int characterSpanEnd(int quadrantX,
                                 int quadrantY,
                                 int quadrantDeltaX,
                                 int quadrantDeltaY,
                                 int charX,
                                 int charY)
    {
        for (; charX < width; charX++)
        {
            if (!isDifferentLandscapeCharacter(quadrantX,
                                               quadrantY,
                                               quadrantDeltaX,
                                               quadrantDeltaY,
                                               charX,
                                               charY))
            {
                break;
            }
        }

        return charX;
    }


    private boolean isDifferentLandscapeCharacter(int quadrantX,
                                                  int quadrantY,
                                                  int quadrantDeltaX,
                                                  int quadrantDeltaY,
                                                  int charX,
                                                  int charY)
    {
        return
            landscapeCharacter(quadrantX, quadrantY,                                 charX, charY) !=
            landscapeCharacter(quadrantX, quadrantY, quadrantDeltaX, quadrantDeltaY, charX, charY);
    }


    private int landscapeCharacter(int quadrantX,
                                   int quadrantY,
                                   int quadrantDeltaX,
                                   int quadrantDeltaY,
                                   int charX,
                                   int charY)
    {
        int oldQuadrantX = quadrantX - quadrantDeltaX;
        int oldQuadrantY = quadrantY - quadrantDeltaY;

        return landscapeCharacter(oldQuadrantX & 1,
                                  oldQuadrantY & 1,
                                  charX + (oldQuadrantX >> 1),
                                  charY + (oldQuadrantY >> 1));
    }


    private int landscapeCharacter(int quadrantX,
                                   int quadrantY,
                                   int charX,
                                   int charY)
    {
        // The coordinates of pixel 1 depend on the quadrant.
        int x1 =      charX + quadrantX;
        int y1 = 2 * (charY + quadrantY);

        // The coordinates of pixel 2 are fixed.
        int x2 =     charX;
        int y2 = 2 * charY + 1;

        return (landscapePixel(x1, y1) ? 1 : 0) |
               (landscapePixel(x2, y2) ? 2 : 0);
    }


    private boolean landscapePixel(int x,
                                   int y)
    {
        if (x < 0)           x = 0;
        if (x >= width - 1)  x = width - 1;

        if (y < 0)           y = 0;
        if (y >= height - 1) y = height - 1;

        int rgb = image.getRGB(x, y) & 0xffffff;
        if (rgb != EMPTY && rgb != LANDSCAPE)
        {
            rgb = image.getRGB(x, y+1) & 0xffffff;
        }

        return rgb == LANDSCAPE;
    }
}
