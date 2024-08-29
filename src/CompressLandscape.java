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

    private static final int EMPTY     = 0;
    private static final int LANDSCAPE = 3;

    private final Raster raster;
    private final int    width;
    private final int    height;
    private final int    shiftX;
    private final int    shiftY;


    public static void main(String[] args)
    throws IOException
    {
        int charOffset = 1;
        int shiftX     = 0;
        int shiftY     = 0;

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
                case "-shiftx"     -> shiftX      = Integer.parseInt(args[argIndex++]);
                case "-shifty"     -> shiftY      = Integer.parseInt(args[argIndex++]);
                default            -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
            }
        }

        String inputFileName  = args[argIndex++];
        String outputFileName = args[argIndex++];

        BufferedImage image = ImageIO.read(new File(inputFileName));

        CompressLandscape landscape =
            new CompressLandscape(image.getRaster(), shiftX, shiftY);

        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    public CompressLandscape(Raster raster,
                             int    shiftX,
                             int    shiftY)
    {
        this.raster = raster;
        this.width  = Math.min(MAX_WIDTH,  raster.getWidth());
        this.height = Math.min(MAX_HEIGHT, raster.getHeight());
        this.shiftX = shiftX;
        this.shiftY = shiftY;
    }


    private void write(DataOutputStream outputStream)
    throws IOException
    {
        // Compress and write out the patterns.
        ByteArrayOutputStream offsetOutputStream =
            new ByteArrayOutputStream(height);

        ByteArrayOutputStream frameOutputStream =
            new ByteArrayOutputStream(8 * 1024);

        // Precompute the length of the table with offsets,
        // so we can adjust the offsets properly.
        // The landscape height is half the raster height.
        int offsetsLength = height;

        // Write the characters compressed as spans.
        writeSpans(offsetsLength,
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
        //outputStream.write(new byte[8 * 1024 - size]);
    }


    private void writeSpans(int              offsetOffset,
                            DataOutputStream offsetOutputStream,
                            DataOutputStream frameOutputStream)
    throws IOException
    {
        // The landscape height is half the raster height.
        // Scan all landscape rows.
        for (int y = 0; y < height; y += 2)
        {
            // Write the offset to the spans.
            offsetOutputStream.writeChar(offsetOffset + frameOutputStream.size());

            // Write the spans of this row.
            writeSpans(y, frameOutputStream);
        }
    }


    private void writeSpans(int y, DataOutputStream frameOutputStream)
    throws IOException
    {
        int endX = -1;
        while (true)
        {
            // Compute the start and end of the next span.
            int startX = spanStart(endX + 1, y);
            if (startX == width)
            {
                break;
            }

            endX = spanEnd(startX + 1, y);

            int length = endX - startX;
            if (length > 255)
            {
                throw new IllegalArgumentException("Span longer than 255 bytes ("+length+" bytes)");
            }

            // Write the span: destination (little-endian), length, and data.
            frameOutputStream.write(startX);
            frameOutputStream.write(startX >> 8);
            frameOutputStream.write(length);

            for (int x = startX; x < endX; x++)
            {
                frameOutputStream.write(landscapeCharacter(x, y));
            }
        }

        // Write the terminator: large destination (little-endian).
        frameOutputStream.write(0xff);
        frameOutputStream.write(0x7f);
    }


    private int spanStart(int x, int y)
    {
        for (; x < width; x++)
        {
            if (isEdge(x, y))
            {
                break;
            }
        }

        return x;
    }


    private int spanEnd(int x, int y)
    {
        for (; x < width; x++)
        {
            if (                   !isEdge(x,     y)  &&
                (x >= width + 1 || !isEdge(x + 1, y)) &&
                (x >= width + 2 || !isEdge(x + 2, y)))
            {
                break;
            }
        }

        return x;
    }


    private boolean isEdge(int x, int y)
    {
        // The base coordinates of pixel 1 for the pixels 2 surrounding it.
        int x1 = x + shiftX;
        int y1 = y + 2 * shiftY;

        boolean p1 = landscapePixel(x, y);
        boolean p2 = landscapePixel(x1 - 1, y1 - 1);

        return
            landscapePixel(x, y + 2 )      != p1 ||
            landscapePixel(x + 1, y     )  != p1 ||
            landscapePixel(x + 1, y + 2 )  != p1 ||
            landscapePixel(x1, y1 - 1)     != p2 ||
            landscapePixel(x1 - 1, y1 + 1) != p2 ||
            landscapePixel(x1, y1 + 1)     != p2;
    }


    private int landscapeCharacter(int x, int y)
    {
        // The coordinates of pixel 1 depend on the shifts.
        int x1 = x + shiftX;
        int y1 = y + 2 * shiftY;

        // The coordinates of pixel 2 are fixed.
        int x2 = x;
        int y2 = y + 1;

        return (landscapePixel(x1, y1) ? 1 : 0) |
               (landscapePixel(x2, y2) ? 2 : 0);
    }


    private boolean landscapePixel(int x, int y)
    {
        if (x < 0)           x = 0;
        if (x >= width - 1)  x = width - 1;

        if (y < 0)           y = 0;
        if (y >= height - 1) y = height - 1;

        int sample = raster.getSample(x, y, 0);
        if (sample != EMPTY && sample != LANDSCAPE)
        {
            sample = raster.getSample(x, y+1, 0);
        }

        return sample == LANDSCAPE;
    }
}
