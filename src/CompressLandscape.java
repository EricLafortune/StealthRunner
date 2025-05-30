import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

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
 *   -baseaddress <n> a base address added to addresses in the output.
 *   -charoffset  <c> an offset added to characters in the output.
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
 * The landscape is represented as deltas for 16 translation directions
 * (quadrants). Each of these is compressed as a list of horizontal spans
 * of changing bytes in the display.
 *
 * [0x6000] Address table : first span address (word) ->
 *          Span table: destination (word), length (byte), data offset (byte) ->
 * [0x7f00] Span data
 */
public class CompressLandscape
{
    private static final int MAX_WIDTH          = 0x1fff;
    private static final int MAX_HEIGHT         = 1024;
    private static final int MAX_SPAN_DATA_SIZE = 256;

    private static final int EMPTY     = 0x000000;
    private static final int LANDSCAPE = 0x5edc78;


    private static final boolean DEBUG = false;


    private final BufferedImage image;
    private final int           width;
    private final int           height;
    private final int           baseAddress;
    private final int           charOffset;

    private int deltaIndex; // For debug printing.


    public static void main(String[] args)
    throws IOException
    {
        int baseAddress = 0;
        int charOffset  = 0;

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
                case "-baseaddress" -> baseAddress = Integer.parseInt(args[argIndex++]);
                case "-charoffset"  -> charOffset  = Integer.parseInt(args[argIndex++]);
                default             -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
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
            new CompressLandscape(image,
                                  baseAddress,
                                  charOffset);

        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    public CompressLandscape(BufferedImage image,
                             int           baseAddress,
                             int           charOffset)
    {
        this.image       = image;
        this.width       = Math.min(MAX_WIDTH,  image.getWidth());
        this.height      = Math.min(MAX_HEIGHT, image.getHeight());
        this.baseAddress = baseAddress;
        this.charOffset  = charOffset;
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
        ByteArrayOutputStream addressOutputStream =
            new ByteArrayOutputStream(height + 2);

        ByteArrayOutputStream frameOutputStream =
            new ByteArrayOutputStream(8 * 1024);

        // Collect and merge the characters of all spans.
        String mergedSpans = collectCharacterSpans(quadrantX,
                                                   quadrantY,
                                                   quadrantDeltaX,
                                                   quadrantDeltaY);

        // Write the character spans as destination offsets, lengths, and
        // source offsets.
        writeCharacterSpans(quadrantX,
                            quadrantY,
                            quadrantDeltaX,
                            quadrantDeltaY,
                            mergedSpans,
                            new DataOutputStream(addressOutputStream),
                            new DataOutputStream(frameOutputStream));

        // Compute and check the total size.
        int size = addressOutputStream.size() +
                   frameOutputStream.size();

        if (size > 8 * 1024 - MAX_SPAN_DATA_SIZE)
        {
            throw new IllegalArgumentException("Landscape exceeds single 8K memory bank [" +
                                               addressOutputStream.size() + " + " +
                                               frameOutputStream.size() + " + " +
                                               MAX_SPAN_DATA_SIZE + " = " +
                                               size + MAX_SPAN_DATA_SIZE + "]");
        }

        // Concatenate the address table and the span table
        outputStream.write(addressOutputStream.toByteArray());
        outputStream.write(frameOutputStream.toByteArray());

        // Skip to the last 256 bytes of the memory bank.
        outputStream.write(new byte[8 * 1024 - MAX_SPAN_DATA_SIZE - size]);

        // Concatenate the span data.
        outputStream.write(mergedSpans.getBytes(StandardCharsets.US_ASCII));

        // Skip to the next memory bank.
        outputStream.write(new byte[MAX_SPAN_DATA_SIZE - mergedSpans.length()]);
    }


    private String collectCharacterSpans(int quadrantX,
                                         int quadrantY,
                                         int quadrantDeltaX,
                                         int quadrantDeltaY)
    {
        MultiCharacterSpan mergedSpans = new MultiCharacterSpan();

        // The landscape height is half the image height.
        // Scan all landscape rows.
        for (int charY = 0; charY < height / 2; charY++)
        {
            // Write the spans of this row.
            collectCharacterSpans(quadrantX,
                                  quadrantY,
                                  quadrantDeltaX,
                                  quadrantDeltaY,
                                  charY,
                                  mergedSpans);
        }

        return mergedSpans.toCharacterString();
    }


    private void collectCharacterSpans(int                quadrantX,
                                       int                quadrantY,
                                       int                quadrantDeltaX,
                                       int                quadrantDeltaY,
                                       int                charY,
                                       MultiCharacterSpan mergedSpans)
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

            MultiCharacterSpan span = new MultiCharacterSpan();

            for (int charX = startX; charX < endX; charX++)
            {
                span.append((char)landscapeCharacter(quadrantX,
                                                     quadrantY,
                                                     charX,
                                                     charY));
            }

            mergedSpans.mergeOptimally(span);

            if (DEBUG)
            {
                System.out.println("["+charY+"] " + mergedSpans + " " + mergedSpans.characterLength() + " (merged " + span + ")");
            }
        }
    }


    private void writeCharacterSpans(int              quadrantX,
                                     int              quadrantY,
                                     int              quadrantDeltaX,
                                     int              quadrantDeltaY,
                                     String           mergedSpans,
                                     DataOutputStream addressOutputStream,
                                     DataOutputStream spanOutputStream)
    throws IOException
    {
        // The span table starts right after the address table.
        int spanBaseAddress = baseAddress + height / 2 * 2;

        // The landscape height is half the image height.
        // Scan all landscape rows.
        for (int charY = 0; charY < height / 2; charY++)
        {
            if (DEBUG)
            {
                System.out.printf("#%d @ 0x%04x\n",
                                  charY,
                                  spanBaseAddress +
                                  spanOutputStream.size());
            }

            // Write the address of the spans of this row.
            addressOutputStream.writeShort(baseAddress +
                                           height / 2 * 2 +
                                           spanOutputStream.size());

            // Write the spans of this row.
            writeCharacterSpans(quadrantX,
                                quadrantY,
                                quadrantDeltaX,
                                quadrantDeltaY,
                                charY,
                                mergedSpans,
                                spanOutputStream);
        }
    }


    private void writeCharacterSpans(int              quadrantX,
                                     int              quadrantY,
                                     int              quadrantDeltaX,
                                     int              quadrantDeltaY,
                                     int              charY,
                                     String           mergedSpans,
                                     DataOutputStream spanOutputStream)
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

            StringBuilder span = new StringBuilder();

            for (int charX = startX; charX < endX; charX++)
            {
                span.append((char)landscapeCharacter(quadrantX,
                                                     quadrantY,
                                                     charX,
                                                     charY));
            }

            int spanOffset = mergedSpans.indexOf(span.toString());
            if (spanOffset < 0)
            {
                throw new IllegalArgumentException("Can't find span ["+span+"]");
            }

            if (spanOffset > 255)
            {
                throw new IllegalArgumentException("Span offset ["+span+"] larger than 255");
            }

            // Write the span: destination, length, and source offset.
            spanOutputStream.writeShort(startX);
            spanOutputStream.write(length);
            spanOutputStream.write(spanOffset);

            if (DEBUG)
            {
                System.out.printf("    %3d < %3d (%2d)", startX, spanOffset, length);
            }
        }

        if (DEBUG)
        {
            System.out.println();
        }
    }


    /**
     * Represents a sequence of repeated characters, for example AAABBAA.
     * Each repetition is marked to possibly be increased or not.
     * Other sequences can be merged in by, e.g. merging in AAAABBB can yield
     * AAAABBBAA.
     */
    private static class MultiCharacterSpan
    {
        List<SingleCharacterSpan> spans = new ArrayList<>();


        public int spanCount()
        {
            return spans.size();
        }


        public int characterLength()
        {
            return spans.stream().mapToInt(SingleCharacterSpan::length).sum();
        }


        public void append(char character)
        {
            int size = spans.size();

            if (size > 0 &&
                spans.get(size - 1).character == character)
            {
                spans.get(size - 1).append();
            }
            else
            {
                if (size > 1)
                {
                    spans.get(size - 1).mayBeLonger = false;
                }

                spans.add(new SingleCharacterSpan(character,
                                                  1,
                                                  true));
            }
        }


        public void mergeOptimally(MultiCharacterSpan other)
        {
            // Compute the overlapping part.
            int thisEnd = this.spanCount() - other.spanCount();

            // Try to merge the overlapping part.
            for (int index = 0; index <= thisEnd; index++)
            {
                if (this.allows(index, other))
                {
                    this.merge(index, other);

                    return;
                }
            }

            // Try to merge with a partial overlap at the end.
            for (int index = thisEnd + 1; index < this.spanCount(); index++)
            {
                if (this.allows(index, other))
                {
                    this.merge(index, other);

                    return;
                }
            }

            // Try to merge with a partial overlap at the start.
            for (int index = -1; index < -other.spanCount(); index--)
            {
                if (this.allows(index, other))
                {
                    this.merge(index, other);

                    return;
                }
            }

            // Append at the end.
            this.merge(this.spanCount(), other);
        }


        public boolean allows(int spanIndex, MultiCharacterSpan other)
        {
            // Compute the overlapping part.
            int otherStart = Math.max(0, -spanIndex);
            int otherEnd   = Math.min(other.spanCount(), this.spanCount() - spanIndex);

            // Check the overlapping part.
            for (int otherIndex = otherStart; otherIndex < otherEnd; otherIndex++)
            {
                int thisIndex = spanIndex + otherIndex;
                if (!this.spans.get(thisIndex).allows(other.spans.get(otherIndex)))
                {
                     return false;
                }
            }

            return true;
        }


        public void merge(int spanIndex, MultiCharacterSpan other)
        {
            // Compute the overlapping part.
            int otherStart = Math.max(0, -spanIndex);
            int otherEnd   = Math.min(other.spanCount(), this.spanCount() - spanIndex);

            // Merge the overlapping part.
            for (int otherIndex = otherStart; otherIndex < otherEnd; otherIndex++)
            {
                int thisIndex = spanIndex + otherIndex;

                this.spans.get(thisIndex).merge(other.spans.get(otherIndex));
            }

            // Append the trailing part.
            for (int otherIndex = otherEnd; otherIndex < other.spanCount(); otherIndex++)
            {
                this.spans.add(other.spans.get(otherIndex));
            }

            // Append the leading part.
            for (int otherIndex = 0; otherIndex < otherStart; otherIndex++)
            {
                // Note that the elements are shifted each time.
                this.spans.add(otherIndex, other.spans.get(otherIndex));
            }
        }


        public String toCharacterString()
        {
            return spans.stream().map(SingleCharacterSpan::toCharacterString).collect(Collectors.joining());
        }


        public String toString()
        {
            return spans.stream().map(SingleCharacterSpan::toString).collect(Collectors.joining());
        }
    }


    /**
     * Represents a sequence of a repeated character, for example AAA.
     * The repetition is marked to possibly be increased or not.
     */
    private static class SingleCharacterSpan
    {
        char    character;
        int     length;
        boolean mayBeLonger;


        public SingleCharacterSpan(char    character,
                                   int     length,
                                   boolean mayBeLonger)
        {
            this.character   = character;
            this.length      = length;
            this.mayBeLonger = mayBeLonger;
        }


        public int length()
        {
            return length;
        }


        public void append()
        {
            length++;
        }


        public boolean allows(SingleCharacterSpan other)
        {
            return this.character == other.character &&
                   (this.length == other.length ||
                    this.mayBeLonger  && this.length < other.length ||
                    other.mayBeLonger && this.length > other.length);
        }


        public void merge(SingleCharacterSpan other)
        {
            if (this.mayBeLonger)
            {
                if (this.length < other.length)
                {
                    this.length = other.length;
                }

                this.mayBeLonger = other.mayBeLonger;
            }
        }


        public String toCharacterString()
        {
            StringBuilder builder = new StringBuilder(length);
            for (int counter = 0; counter < length; counter++)
            {
                builder.append(character);
            }

            return builder.toString();
        }


        public String toString()
        {
            return new StringBuilder()
                       .append(character)
                       .append(length)
                       .append(mayBeLonger ? "+" : "")
                       .toString();
        }
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

        return charOffset +
               (landscapePixel(x1, y1) ? 1 : 0) |
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
