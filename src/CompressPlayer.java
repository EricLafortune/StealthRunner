import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.*;
import java.util.*;

/**
 * Converts PBM image animations to a file in our own compressed format.
 *
 * Usage:
 *   java CompressPlayer [options] <type> ... <output_file>
 * where options are
 *   -inputdirectory the directory with input directories and image files.
 *                   <dir>/<type>/<direction>/<frame>.png,
 *                   for example
 *                   inputfiles/Walk/05/010.pbm
 *   -charoffset     the required offset for characters assigned in the
 *                   screens.
 *   -outputmaskfile the optional output monochrome PNG file containing the
 *                   character mask.
 */
public class CompressPlayer
{
    private static final int SCREEN_WIDTH  = 32;
    private static final int SCREEN_HEIGHT = 24;


    public static void main(String[] args)
    throws IOException
    {
        File inputDirectory = null;
        int  charOffset     = 1;
        File outputMaskFile = null;

        int[]   currentAdjacentTypes      = { -1, 0, 1 };
        int[]   currentAdjacentDirections = { -1, 0, 1 };
        boolean currentLandscapeMaskFlag  = true;

        List<String>  collectedTypes              = new ArrayList<>();
        List<int[]>   collectedAdjacentTypes      = new ArrayList<>();
        List<int[]>   collectedAdjacentDirections = new ArrayList<>();
        List<Boolean> collectedLandscapeMaskFlags = new ArrayList<>();

        // Parse the options and input types.
        int argIndex = 0;

        while (argIndex < args.length - 1)
        {
            String arg = args[argIndex++];
            if (arg.startsWith("-"))
            {
                // All options have an argument.
                String optionArg = args[argIndex++];

                switch (arg)
                {
                    case "-inputdirectory"     -> inputDirectory = new File(optionArg);
                    case "-charoffset"         -> charOffset     = Integer.parseInt(optionArg);
                    case "-outputmaskfile"     -> outputMaskFile = new File(optionArg);
                    case "-adjacenttypes"      -> currentAdjacentTypes = optionArg.isEmpty() ?
                        new int[] { 0 } :
                        Arrays.stream(optionArg.split(","))
                            .mapToInt(Integer::parseInt)
                            .toArray();
                    case "-adjacentdirections" -> currentAdjacentDirections = optionArg.isEmpty() ?
                        new int[] { 0 } :
                        Arrays.stream(optionArg.split(","))
                            .mapToInt(Integer::parseInt)
                            .toArray();
                    case "-landscapemask"      -> currentLandscapeMaskFlag = Boolean.valueOf(optionArg);
                    default                    -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
                }
            }
            else
            {
                collectedTypes.add(arg);
                collectedAdjacentTypes.add(currentAdjacentTypes);
                collectedAdjacentDirections.add(currentAdjacentDirections);
                collectedLandscapeMaskFlags.add(currentLandscapeMaskFlag);
            }
        }

        int typeCount = collectedTypes.size();

        // Read the frames for all types, directions, and animations.
        byte[][][][] frames = new byte[typeCount][][][];

        String[]  types              = collectedTypes.toArray(new String[typeCount]);
        int[][]   adjacentTypes      = collectedAdjacentTypes.toArray(new int[typeCount][]);
        int[][]   adjacentDirections = collectedAdjacentDirections.toArray(new int[typeCount][]);
        Boolean[] landscapeMaskFlags = collectedLandscapeMaskFlags.toArray(new Boolean[typeCount]);

        int width  = -1;
        int height = -1;

        for (int typeIndex = 0; typeIndex < typeCount; typeIndex++)
        {
            String type = types[typeIndex];

            File typeDirectory = new File(inputDirectory, type);

            File[] directionDirectories = typeDirectory.listFiles();
            int    directionCount       = directionDirectories.length;

            Arrays.sort(directionDirectories);

            frames[typeIndex] = new byte[directionCount][][];

            for (int directionIndex = 0; directionIndex < directionCount; directionIndex++)
            {
                File directionDirectory = directionDirectories[directionIndex];

                File[] frameFiles = directionDirectory.listFiles();
                int    frameCount = frameFiles.length;

                Arrays.sort(frameFiles);

                frames[typeIndex][directionIndex] = new byte[frameCount][];

                for (int frameIndex = 0; frameIndex < frameCount; frameIndex++)
                {
                    File inputFile = frameFiles[frameIndex];

                    BufferedImage  image  = ImageIO.read(inputFile);
                    WritableRaster raster = image.getRaster();

                    width  = raster.getWidth();
                    height = raster.getHeight();

                    byte[] pixels = ((DataBufferByte)raster.getDataBuffer()).getData();

                    // Transpose the bytes, so we'll work with columns of
                    // 8 pixels each.
                    frames[typeIndex][directionIndex][frameIndex] =
                        transpose(pixels, width, height);
                }
            }
        }

        // Create screens for these frames, shared across animations.
        byte[][][] screens = new byte[typeCount][][];

        for (int typeIndex = 0; typeIndex < typeCount; typeIndex++)
        {
            int directionCount = frames[typeIndex].length;
            screens[typeIndex] = new byte[directionCount][];

            for (int directionIndex = 0; directionIndex < directionCount; directionIndex++)
            {
                int frameCount = frames[typeIndex][directionIndex].length;

                // Create an empty screen.
                // We can truncate it to the height of the frames.
                byte[] screen = new byte[SCREEN_WIDTH * SCREEN_HEIGHT];
                Arrays.fill(screen, (byte)-1);

                // Mark the used (non-blank) characters in the screen.
                for (int frameIndex = 0; frameIndex < frameCount; frameIndex++)
                {
                    markScreen(frames[typeIndex][directionIndex][frameIndex],
                               width,
                               height,
                               screen,
                               charOffset);
                }

                screens[typeIndex][directionIndex] = screen;
            }
        }

        // Mark the used characters of adjacent screens (adjacent in type and
        // in direction), so their non-blank characters are properly cleared
        // when changing type or direction.
        for (int typeIndex = 0; typeIndex < typeCount; typeIndex++)
        {
            int directionCount = frames[typeIndex].length;

            int[] fromTypes      = adjacentTypes[typeIndex];
            int[] fromDirections = adjacentDirections[typeIndex];

            for (int directionIndex = 0; directionIndex < directionCount; directionIndex++)
            {
                byte[] screen = screens[typeIndex][directionIndex];

                // Mark from screens of adjacent types and directions.
                for (int fromTypeindex = 0; fromTypeindex < fromTypes.length; fromTypeindex++)
                {
                    int adjacentTypeIndex = typeIndex + fromTypes[fromTypeindex];
                    if (adjacentTypeIndex >= 0 &&
                        adjacentTypeIndex <  typeCount)
                    {
                        for (int fromDirectionIndex = 0; fromDirectionIndex < fromDirections.length; fromDirectionIndex++)
                        {
                            int adjacentDirectionIndex =
                                (directionIndex + fromDirections[fromDirectionIndex] + directionCount) % directionCount;

                            if (adjacentTypeIndex      != typeIndex ||
                                adjacentDirectionIndex != directionIndex)
                            {
                                markAdjacentScreen(screens[adjacentTypeIndex][adjacentDirectionIndex],
                                                   screen);
                            }
                        }
                    }
                }

            }
        }

        // Compress and write out the screens and patterns.
        byte[] emptyScreen = new byte[SCREEN_WIDTH * SCREEN_HEIGHT];
        Arrays.fill(emptyScreen, (byte)-1);

        String outputFileName = args[argIndex];

        try (OutputStream outputStream =
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName)))
        {
            for (int typeIndex = 0; typeIndex < typeCount; typeIndex++)
            {
                int directionCount = frames[typeIndex].length;

                for (int directionIndex = 0; directionIndex < directionCount; directionIndex++)
                {
                    int frameCount = frames[typeIndex][directionIndex].length;

                    // Assign subsequent characters to marked non-blank characters in the screen.
                    byte[] screen = screens[typeIndex][directionIndex];

                    int charCount = assignScreenCharacters(screen,
                                                           charOffset);

                    // Remap the patterns of all frames accordingly.
                    byte[][] patterns = new byte[frameCount][];

                    for (int frameIndex = 0; frameIndex < frameCount; frameIndex++)
                    {
                        byte[] frame = frames[typeIndex][directionIndex][frameIndex];

                        patterns[frameIndex] =
                            remapPatterns(frame,
                                          width,
                                          height,
                                          screen,
                                          charOffset,
                                          charCount);
                    }

                    // Compress and write out the patterns.
                    ByteArrayOutputStream offsetOutputStream =
                        new ByteArrayOutputStream(32 * 2);

                    ByteArrayOutputStream frameOutputStream =
                        new ByteArrayOutputStream(8 * 1024);

                    // Precompute the length of the table with offsets,
                    // so we can adjust the offsets properly.
                    int offsetsLength = 2 + frameCount * 2 + 2;

                    // Write the characters shared between all frames,
                    // compressed as spans.
                    writeSpans(emptyScreen,
                               screen,
                               (byte)-1,
                               offsetOutputStream,
                               offsetsLength,
                               frameOutputStream);

                    // Write the patterns of all subsequent frames
                    // (wrapping around), also compressed as spans.
                    for (int frameIndex = 0; frameIndex < frameCount; frameIndex++)
                    {
                        writeSpans(patterns[(frameIndex - 1 + frameCount) % frameCount],
                                   patterns[frameIndex],
                                   (byte)0,
                                   offsetOutputStream,
                                   offsetsLength,
                                   frameOutputStream);
                    }

                    // Write a final null offset.
                    offsetOutputStream.write(0);
                    offsetOutputStream.write(0);

                    int size = offsetOutputStream.size() + frameOutputStream.size();

                    // Concatenate the offset table and the compressed frame data.
                    outputStream.write(offsetOutputStream.toByteArray());
                    outputStream.write(frameOutputStream.toByteArray());

                    if (size > 8 * 1024)
                    {
                        throw new IllegalArgumentException("Animation exceeds single memory bank (type #"+typeIndex+", direction #"+directionIndex+")");
                    }

                    // Skip to the next memory bank.
                    outputStream.write(new byte[8 * 1024 - size]);
                }
            }
        }

        if (outputMaskFile != null)
        {
            byte[] playerMaskBytes = computeGlobalMask(landscapeMaskFlags,
                                                       screens);

            BufferedImage playerMask =
                new BufferedImage(SCREEN_WIDTH,
                                  SCREEN_HEIGHT,
                                  BufferedImage.TYPE_BYTE_BINARY);

            playerMask.getRaster().setDataElements(0,
                                                   0,
                                                   SCREEN_WIDTH,
                                                   SCREEN_HEIGHT,
                                                   playerMaskBytes);

            ImageIO.write(playerMask,
                          "png",
                          outputMaskFile);
        }
    }


    /**
     * Returns a transposed copy of the given array of bytes (not pixels).
     */
    private static byte[] transpose(byte[] bytes, int width, int height)
    {
        width /= 8;

        byte[] transposedBytes = new byte[bytes.length];

        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                transposedBytes[x * height + y] = bytes[y * width + x];
            }
        }

        return transposedBytes;
    }


    /**
     * Marks the used characters of the given frame, in the given screens.
     */
    private static void markScreen(byte[] frame,
                                   int    width,
                                   int    height,
                                   byte[] screen,
                                   int    charOffset)
    {
        width  /= 8;
        height /= 8;

        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                int patternIndex = (x * height + y) * 8;

                if (!isBlank(frame, patternIndex))
                {
                    int characterIndex = y * SCREEN_WIDTH + x;

                    screen[characterIndex] = 1;
                }
            }
        }
    }


    private static void markAdjacentScreen(byte[] fromScreen,
                                           byte[] toScreen)
    {
        for (int index = 0; index < fromScreen.length; index++)
        {
            if (fromScreen[index] > 0 &&
                toScreen[index] < 0)
            {
                toScreen[index] = 0;
            }
        }
    }


    /**
     * Assigns unique, vertically sequential characters to the marked
     * characters in the given screen.
     */
    private static int assignScreenCharacters(byte[] screen,
                                              int    charOffset)
    {
        int charCount = 0;

        for (int x = 0; x < SCREEN_WIDTH; x++)
        {
            for (int y = 0; y < SCREEN_HEIGHT; y++)
            {
                int screenIndex = y * SCREEN_WIDTH + x;

                if (screen[screenIndex] > 0)
                {
                    screen[screenIndex] = (byte)(charOffset + charCount++);
                }

            }
        }

        return charCount;
    }


    private static void replace(byte[] bytes, byte from, byte to)
    {
        for (int index = 0; index < bytes.length; index++)
        {
            if (bytes[index] == from)
            {
                bytes[index] = to;
            }
        }
    }


    /**
     * Maps patterns from a screen with regular character columns
     * to patterns that match the given screen of unique characters.
     */
    private static byte[] remapPatterns(byte[] patterns,
                                        int    width,
                                        int    height,
                                        byte[] screen,
                                        int    charOffset,
                                        int    charCount)
    {
        width  /= 8;
        height /= 8;

        byte[] remappedPatterns = new byte[charCount * 8];
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                int screenIndex = y * SCREEN_WIDTH + x;

                int character = screen[screenIndex] & 0xff;

                if (character >= charOffset &&
                    character < 255)
                {
                    int sourceOffset      = (x * height + y) * 8;
                    int destinationOffset = (character - charOffset) * 8;

                    System.arraycopy(patterns, sourceOffset,
                                     remappedPatterns, destinationOffset,
                                     8);
                }
            }
        }

        return remappedPatterns;
    }


    private static boolean isAllBlank(byte[][] patterns, int patternIndex)
    {
        for (int index = 0; index < patterns.length; index++)
        {
            if (!isBlank(patterns[index], patternIndex))
            {
                return false;
            }
        }

        return true;
    }


    private static boolean isBlank(byte[] patterns, int patternIndex)
    {
        return patterns[patternIndex    ] == 0 &&
               patterns[patternIndex + 1] == 0 &&
               patterns[patternIndex + 2] == 0 &&
               patterns[patternIndex + 3] == 0 &&
               patterns[patternIndex + 4] == 0 &&
               patterns[patternIndex + 5] == 0 &&
               patterns[patternIndex + 6] == 0 &&
               patterns[patternIndex + 7] == 0;
    }


    private static void writeSpans(byte[]                previousData,
                                   byte[]                currentData,
                                   byte                  blank,
                                   OutputStream          offsetOutputStream,
                                   int                   offsetOffset,
                                   ByteArrayOutputStream frameOutputStream)
    throws IOException
    {
        int offset = frameOutputStream.size() + offsetOffset;
        offsetOutputStream.write(offset >>> 8);
        offsetOutputStream.write(offset & 0xff);

        int previousIndex = 0;
        while (true)
        {
            // Compute the indices of the next span.
            int startIndex = firstNonBlankIndex(previousData,
                                                currentData,
                                                blank,
                                                previousIndex);
            if (startIndex == currentData.length)
            {
                break;
            }

            // Make sure the delta will fit in a byte, by adding a dummy span
            // if necessary.
            if (startIndex > previousIndex + 255)
            {
                startIndex = previousIndex + 255;
            }

            int endIndex = firstBlankIndex(previousData,
                                           currentData,
                                           blank,
                                           startIndex + 1);

            int delta  = startIndex - previousIndex;
            int length = endIndex - startIndex;

            if (delta > 255)
            {
                throw new IllegalStateException("Delta ["+delta+"] does not fit in a byte");
            }

            if (length > 255)
            {
                throw new IllegalStateException("Length ["+length+"] does not fit in a byte");
            }

            // Write the span: destination delta, length, and data.
            frameOutputStream.write(delta);
            frameOutputStream.write(length);
            frameOutputStream.write(currentData, startIndex, length);

            previousIndex = endIndex;
        }

        // Write the terminator.
        frameOutputStream.write(currentData.length - previousIndex);
        frameOutputStream.write(0x00);
    }


    private static int firstNonBlankIndex(byte[] previousData,
                                          byte[] currentData,
                                          byte   blank,
                                          int    index)
    {
        while (index < currentData.length && (currentData[index] == blank && previousData[index] == blank))
        {
            index++;
        }

        return index;
    }


    private static int firstBlankIndex(byte[] previousData,
                                       byte[] currentData,
                                       byte   blank,
                                       int    index)
    {
        while (index < currentData.length   && (currentData[index  ] != blank || previousData[index  ] != blank) ||
               index < currentData.length-1 && (currentData[index+1] != blank || previousData[index+1] != blank) ||
               index < currentData.length-2 && (currentData[index+2] != blank || previousData[index+2] != blank) ||
               index < currentData.length-3 && (currentData[index+3] != blank || previousData[index+3] != blank))
        {
            index++;
        }

        return index;
    }


    /**
     * Computes a mask screen of zeros and ones, marking non-empty characters
     * (characters that are larger than 0) in any of the given screens.
     */
    private static byte[] computeGlobalMask(Boolean[]  landscapeMaskFlags,
                                            byte[][][] screens)
    {
        byte[] mask = new byte[SCREEN_WIDTH * SCREEN_HEIGHT];

        for (int typeIndex = 0; typeIndex < screens.length; typeIndex++)
        {
            if (landscapeMaskFlags[typeIndex])
            {
                byte[][] typeScreens    = screens[typeIndex];
                int      directionCount = typeScreens.length;

                for (int directionIndex = 0; directionIndex < directionCount; directionIndex++)
                {
                    byte[] screen = typeScreens[directionIndex];

                    for (int screenIndex = 0; screenIndex < screen.length; screenIndex++)
                    {
                        if (screen[screenIndex] > 0)
                        {
                            mask[screenIndex] = 1;
                        }
                    }
                }
            }
        }

        return mask;
    }
}
