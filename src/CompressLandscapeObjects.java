import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.*;
import java.util.*;

/**
 * Converts a landscape image to a file with object positions.
 *
 * Usage:
 *   java CompressLandscapeObjects [options] <input_file> <output_file>
 * where options are
 *   -shiftx <s>     the horizontal shift added to the object positions, expressed in pixels.
 *   -shifty <s>     the vertical shift added to the object positions, expressed in pixels.
 *
 * The landscape has the same width but half the height as the image.
 *
 * The object positions are compressed as -1 terminated lists of (x,y)
 * ordinates (words).
 */
public class CompressLandscapeObjects
{
    private static final int[] COLORS =
    {
        0x000000, //  0, transparent
        0x000000, //  1, black
        0x21c842, //  2, green
        0x5edc78, //  3, light_green
        0x5455ed, //  4, blue
        0x7d76fc, //  5, light_blue
        0xd4524d, //  6, dark_red
        0x42ebf5, //  7, cyan
        0xfc5554, //  8, red
        0xff7978, //  9, light_red
        0xd4c154, // 10, dark_yellow
        0xe6ce80, // 11, light_yellow
        0x21b03b, // 12, dark_green
        0xc95bba, // 13, magenta
        0xcccccc, // 14, gray
        0xffffff, // 15, white
    };

    private static final int rgb(int type)
    {
        int rgbDelta = type >>> 8;

        type = type & 0xff;

        return (COLORS[type] + rgbDelta) & 0xffffff;
    }

    // Each pair of two vertical pixels corresponds to one character
    // (8x8 pixels in the game).
    private static final int MAX_WIDTH    = 0x1fff;
    private static final int MAX_HEIGHT   = 512;
    private static final int STRIP_HEIGHT = 128 * 2 / 8;

    // Main color palette indices.
    private static final int EMPTY     =  1;
    private static final int LANDSCAPE =  3;
    private static final int PLAYER    =  4;
    private static final int TARGET    = 11;
    private static final int STONE     =  6;
    private static final int BATTERY   =  2;
    private static final int GRENADE   = 14;
    private static final int MINE      =  8;
    private static final int DRONE     =  7;
    private static final int LAUNCHER  =  9;
    private static final int TURRET    = 15;

    // Background color palette indices (same color palette in the game, but
    // slightly different colors in the landscape image, so we can identify
    // them here).
    private static final int GRASS     =  2 | 0xfefeff00;
    private static final int BUSH      = 12 | 0xfefeff00;
    private static final int TREE      =  9 | 0xfefeff00;
    private static final int ROCK      = 14 | 0xfefeff00;
    private static final int PUDDLE    =  7 | 0xfefeff00;
    private static final int WOOD      =  6 | 0xfefeff00;
    private static final int FENCE     = 10 | 0xfefeff00;
    private static final int TRIPOD    =  6 | 0xfef0ff00;
    private static final int BARREL    = 13 | 0xfefeff00;
    private static final int BRICKS    =  9 | 0xfef0ff00;
    private static final int MANHOLE   =  8 | 0xfefeff00;
    private static final int PYLON     =  4 | 0xfefeff00;

    private static final int[] COLLECTIBLES =
    {
         STONE,
         BATTERY,
         GRENADE,
    };

    private static final int[] BACKGROUND_OBJECTS =
    {
        GRASS,
        BUSH,
        TREE,
        ROCK,
        PUDDLE,
        WOOD,
        FENCE,
        TRIPOD,
        BARREL,
        BRICKS,
        MANHOLE,
        PYLON,
    };

    private final BufferedImage image;
    private final int           width;
    private final int           height;
    private final int           shiftX;
    private final int           shiftY;


    public static void main(String[] args)
    throws IOException
    {
        int shiftX = 0;
        int shiftY = 0;

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
                case "-shiftx" -> shiftX = Integer.parseInt(args[argIndex++]);
                case "-shifty" -> shiftY = Integer.parseInt(args[argIndex++]);
                default        -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
            }
        }

        String inputFileName  = args[argIndex++];
        String outputFileName = args[argIndex++];

        BufferedImage image = ImageIO.read(new File(inputFileName));
        if (image == null)
        {
            throw new IOException("Unsupported image format ["+inputFileName+"]");
        }

        CompressLandscapeObjects landscape =
            new CompressLandscapeObjects(image, shiftX, shiftY);

        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    /**
     * Creates a new instance for the given landscape image.
     */
    public CompressLandscapeObjects(BufferedImage image,
                                    int           shiftX,
                                    int           shiftY)
    {
        this.image  = image;
        this.width  = Math.min(MAX_WIDTH,  image.getWidth());
        this.height = Math.min(MAX_HEIGHT, image.getHeight());
        this.shiftX = shiftX;
        this.shiftY = shiftY;
    }


    /**
     * Writes out the various arrays with initial object positions.
     */
    private void write(DataOutputStream outputStream)
    throws IOException
    {
        // Put the collectibles in a map (RGB -> type).
        Map<Integer, Integer> collectibleRGBTypes = new HashMap<>();
        for (int index = 0; index < COLLECTIBLES.length; index++)
        {
            collectibleRGBTypes.put(
                rgb(COLLECTIBLES[index]),
                index);
        }

        // Put the background objects in a map (RGB -> type).
        Map<Integer, Integer> backgroundRGBTypes = new HashMap<>();
        for (int index = 0; index < BACKGROUND_OBJECTS.length; index++)
        {
            backgroundRGBTypes.put(
                rgb(BACKGROUND_OBJECTS[index]),
                index);
        }

        // Write out the (single) initial player position.
        writeObjectPositions(0, height, outputStream, PLAYER, 4, 4);

        // Write out all other object positions, per horizontal strip.
        for (int startY = 0; startY < height; startY += STRIP_HEIGHT)
        {
            int endY = Math.min(height, startY + STRIP_HEIGHT);

            writeObjectPositions(startY, endY, outputStream, TARGET,   0x10 - 2,  4);
            writeObjectPositions(startY, endY, outputStream, MINE,     0x40 - 2,  6);
            writeObjectPositions(startY, endY, outputStream, DRONE,    0x40 - 2, 10);
            writeObjectPositions(startY, endY, outputStream, LAUNCHER, 0x40 - 2,  6);
            writeObjectPositions(startY, endY, outputStream, TURRET,   0x40 - 2,  6);
            writeBackgroundObjectPositions(startY, endY, outputStream, collectibleRGBTypes, 0x70 - 2, 6);
            writeBackgroundObjectPositions(startY, endY, outputStream, backgroundRGBTypes,  0x80 - 2, 6);
        }

        int size = outputStream.size();
        if (size > 8 * 1024)
        {
            throw new IllegalArgumentException("Landscape objects ("+size+" bytes) exceed single memory bank");
        }

        // Skip to the next memory bank.
        //outputStream.write(new byte[8 * 1024 - size]);
    }


    /**
     * Writes out the array with initial object positions
     * of the given type, for a specified horizontal strip.
     */
    private void writeObjectPositions(int              startY,
                                      int              endY,
                                      DataOutputStream outputStream,
                                      int              objectType,
                                      int              maxSize,
                                      int              itemSize)
    throws IOException
    {
        int objectRGB = rgb(objectType);
        int size      = 0;

        // The landscape height is half the image height.
        // We're scanning all rows anyway.
        for (int y = startY; y < endY; y++)
        {
            for (int x = 0; x < width; x++)
            {
                int rgb = image.getRGB(x, y) & 0xffffff;
                if (rgb == objectRGB)
                {
                    outputStream.writeChar(x     * 8 + shiftX + 4);
                    outputStream.writeChar(y / 2 * 8 + shiftY + 4);

                    size += itemSize;
                }
            }
        }

        outputStream.writeChar(-1);

        if (size > maxSize)
        {
            throw new IllegalArgumentException("Maximum strip buffer size [0x"+Integer.toHexString(maxSize)+"] exceeded [0x"+Integer.toHexString(size)+"] for object type "+objectType+" in strip ["+startY+".."+endY+"]");
        }
    }


    /**
     * Writes out the array with initial object positions
     * of the given types, for a specified horizontal strip.
     */
    private void writeBackgroundObjectPositions(int                  startY,
                                                int                  endY,
                                                DataOutputStream     outputStream,
                                                Map<Integer,Integer> rgbTypes,
                                                int                  maxSize,
                                                int                  itemSize)
    throws IOException
    {
        int size = 0;

        // The landscape height is half the image height.
        // We're scanning all rows anyway.
        for (int y = startY; y < endY; y++)
        {
            for (int x = 0; x < width; x++)
            {
                int     rgb  = image.getRGB(x, y) & 0xffffff;
                Integer type = rgbTypes.get(rgb);
                if (type != null)
                {
                    outputStream.writeChar(x     * 8 + shiftX + 4);
                    outputStream.writeChar(y / 2 * 8 + shiftY + 4);
                    outputStream.writeChar(type);

                    size += itemSize;
                }
            }
        }

        outputStream.writeChar(-1);

        if (size > maxSize)
        {
            throw new IllegalArgumentException("Maximum strip buffer size [0x"+Integer.toHexString(maxSize)+"] exceeded [0x"+Integer.toHexString(size)+"] for background objects in strip ["+startY+".."+endY+"]");
        }
    }
}
