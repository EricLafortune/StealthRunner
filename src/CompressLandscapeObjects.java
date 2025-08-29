import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;

/**
 * Converts a landscape image to a file with object positions.
 *
 * Usage:
 *   java CompressLandscapeObjects [options] <input_file> <output_file>
 * where options are
 *   -shiftx <s> a horizontal shift added to the object positions, expressed in pixels.
 *   -shifty <s> a vertical shift added to the object positions, expressed in pixels.
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
    private static final int MAX_WIDTH    = 0x1fff;      // image pixels.
    private static final int MAX_HEIGHT   = 1024;        // image pixels.
    private static final int STRIP_HEIGHT = 128 * 2 / 8; // world pixels.
    private static final int STRIP_SIZE   = 256;         // bytes.

    // The maximum number of objects per strip.
    private static final int MAX_TARGET_COUNT      =  1;
    private static final int MAX_MINE_COUNT        =  4;
    private static final int MAX_DRONE_COUNT       =  4;
    private static final int MAX_LAUNCHER_COUNT    =  4;
    private static final int MAX_TURRET_COUNT      =  4;
    private static final int MAX_COLLECTIBLE_COUNT = 10;
    private static final int MAX_MESSAGE_COUNT     =  4;
    private static final int MAX_BACKGROUND_COUNT  =  6;

    // The object sizes, when unpacked in memory, expressed in bytes.
    private static final int TARGET_OBJECT_SIZE      =  4;
    private static final int MINE_OBJECT_SIZE        =  6;
    private static final int DRONE_OBJECT_SIZE       = 10;
    private static final int LAUNCHER_OBJECT_SIZE    =  6;
    private static final int TURRET_OBJECT_SIZE      =  6;
    private static final int COLLECTIBLE_OBJECT_SIZE =  6;
    private static final int MESSAGE_OBJECT_SIZE     =  6;
    private static final int BACKGROUND_OBJECT_SIZE  =  6;

    // Main color palette indices.
    private static final int EMPTY     =  1;
    private static final int LANDSCAPE =  3;
    private static final int PLAYER    =  4;
    private static final int TARGET    = 11;
    private static final int MEDKIT    = 12;
    private static final int STONE     =  6;
    private static final int BATTERY   =  2;
    private static final int GRENADE   = 14;
    private static final int MINE      =  8;
    private static final int DRONE     =  7;
    private static final int LAUNCHER  =  9;
    private static final int TURRET    = 15;

    // Popup messages with counters.
    private static final int MESSAGE   =  5;

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
        MEDKIT,
        STONE,
        BATTERY,
        GRENADE,
    };

    private static final int[] MESSAGE_OBJECTS =
    {
        MESSAGE,
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

        // Put the message objects in a map (RGB -> counter).
        Map<Integer, Integer> messageRGBCounters = new HashMap<>();
        for (int index = 0; index < MESSAGE_OBJECTS.length; index++)
        {
            messageRGBCounters.put(
                rgb(MESSAGE_OBJECTS[index]),
                0);
        }

        // Put the background objects in a map (RGB -> type).
        Map<Integer, Integer> backgroundRGBTypes = new HashMap<>();
        for (int index = 0; index < BACKGROUND_OBJECTS.length; index++)
        {
            backgroundRGBTypes.put(
                rgb(BACKGROUND_OBJECTS[index]),
                index);
        }

        int totalTargetCount      = 0;
        int totalMineCount        = 0;
        int totalDroneCount       = 0;
        int totalLauncherCount    = 0;
        int totalTurretCount      = 0;
        int totalCollectibleCount = 0;
        int totalMessageCount     = 0;
        int totalBackgroundCount  = 0;

        int maxTargetCount      = 0;
        int maxMineCount        = 0;
        int maxDroneCount       = 0;
        int maxLauncherCount    = 0;
        int maxTurretCount      = 0;
        int maxCollectibleCount = 0;
        int maxMessageCount     = 0;
        int maxBackgroundCount  = 0;

        // Write out the (single) initial player position.
        writeObjectPositions(0, height, outputStream, PLAYER, 1);

        // Write out all other object positions, per horizontal strip.
        for (int startY = 0; startY < height; startY += STRIP_HEIGHT)
        {
            int endY = Math.min(height, startY + STRIP_HEIGHT);

            int targetCount      = writeObjectPositions(          startY, endY, outputStream, TARGET,              MAX_TARGET_COUNT);
            int mineCount        = writeObjectPositions(          startY, endY, outputStream, MINE,                MAX_MINE_COUNT);
            int droneCount       = writeObjectPositions(          startY, endY, outputStream, DRONE,               MAX_DRONE_COUNT);
            int launcherCount    = writeObjectPositions(          startY, endY, outputStream, LAUNCHER,            MAX_LAUNCHER_COUNT);
            int turretCount      = writeObjectPositions(          startY, endY, outputStream, TURRET,              MAX_TURRET_COUNT);
            int collectibleCount = writeBackgroundObjectPositions(startY, endY, outputStream, collectibleRGBTypes, MAX_COLLECTIBLE_COUNT);
            int messageCount     = writeBackgroundObjectPositions(startY, endY, outputStream, messageRGBCounters,  MAX_MESSAGE_COUNT, 1);
            int backgroundCount  = writeBackgroundObjectPositions(startY, endY, outputStream, backgroundRGBTypes,  MAX_BACKGROUND_COUNT);

            totalTargetCount      += targetCount;
            totalMineCount        += mineCount;
            totalDroneCount       += droneCount;
            totalLauncherCount    += launcherCount;
            totalTurretCount      += turretCount;
            totalCollectibleCount += collectibleCount;
            totalMessageCount     += messageCount;
            totalBackgroundCount  += backgroundCount;

            if (maxTargetCount      < targetCount     ) maxTargetCount      = targetCount;
            if (maxMineCount        < mineCount       ) maxMineCount        = mineCount;
            if (maxDroneCount       < droneCount      ) maxDroneCount       = droneCount;
            if (maxLauncherCount    < launcherCount   ) maxLauncherCount    = launcherCount;
            if (maxTurretCount      < turretCount     ) maxTurretCount      = turretCount;
            if (maxCollectibleCount < collectibleCount) maxCollectibleCount = collectibleCount;
            if (maxMessageCount     < messageCount    ) maxMessageCount     = messageCount;
            if (maxBackgroundCount  < backgroundCount ) maxBackgroundCount  = backgroundCount;
        }

        System.out.printf("Total targets      = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalTargetCount,      maxTargetCount,      MAX_TARGET_COUNT,      maxTargetCount      * TARGET_OBJECT_SIZE      + 2, MAX_TARGET_COUNT      * TARGET_OBJECT_SIZE      + 2);
        System.out.printf("Total mines        = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalMineCount,        maxMineCount,        MAX_MINE_COUNT,        maxMineCount        * MINE_OBJECT_SIZE        + 2, MAX_MINE_COUNT        * MINE_OBJECT_SIZE        + 2);
        System.out.printf("Total drones       = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalDroneCount,       maxDroneCount,       MAX_DRONE_COUNT,       maxDroneCount       * DRONE_OBJECT_SIZE       + 2, MAX_DRONE_COUNT       * DRONE_OBJECT_SIZE       + 2);
        System.out.printf("Total launchers    = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalLauncherCount,    maxLauncherCount,    MAX_LAUNCHER_COUNT,    maxLauncherCount    * LAUNCHER_OBJECT_SIZE    + 2, MAX_LAUNCHER_COUNT    * LAUNCHER_OBJECT_SIZE    + 2);
        System.out.printf("Total turrets      = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalTurretCount,      maxTurretCount,      MAX_TURRET_COUNT,      maxTurretCount      * TURRET_OBJECT_SIZE      + 2, MAX_TURRET_COUNT      * TURRET_OBJECT_SIZE      + 2);
        System.out.printf("Total collectibles = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalCollectibleCount, maxCollectibleCount, MAX_COLLECTIBLE_COUNT, maxCollectibleCount * COLLECTIBLE_OBJECT_SIZE + 2, MAX_COLLECTIBLE_COUNT * COLLECTIBLE_OBJECT_SIZE + 2);
        System.out.printf("Total messages     = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalMessageCount,     maxMessageCount,     MAX_MESSAGE_COUNT,     maxMessageCount     * MESSAGE_OBJECT_SIZE     + 2, MAX_MESSAGE_COUNT     * MESSAGE_OBJECT_SIZE     + 2);
        System.out.printf("Total background   = %3d, max/strip = %2d / %2d (%2d / %2d bytes)\n", totalBackgroundCount,  maxBackgroundCount,  MAX_BACKGROUND_COUNT,  maxBackgroundCount  * BACKGROUND_OBJECT_SIZE  + 2, MAX_BACKGROUND_COUNT  * BACKGROUND_OBJECT_SIZE  + 2);

        int stripSize =
            maxTargetCount        * TARGET_OBJECT_SIZE      + 2 +
            maxMineCount          * MINE_OBJECT_SIZE        + 2 +
            maxDroneCount         * DRONE_OBJECT_SIZE       + 2 +
            maxLauncherCount      * LAUNCHER_OBJECT_SIZE    + 2 +
            maxTurretCount        * TURRET_OBJECT_SIZE      + 2 +
            maxCollectibleCount   * COLLECTIBLE_OBJECT_SIZE + 2 +
            maxMessageCount       * MESSAGE_OBJECT_SIZE     + 2 +
            maxBackgroundCount    * BACKGROUND_OBJECT_SIZE  + 2;

        int maxStripSize =
            MAX_TARGET_COUNT      * TARGET_OBJECT_SIZE      + 2 +
            MAX_MINE_COUNT        * MINE_OBJECT_SIZE        + 2 +
            MAX_DRONE_COUNT       * DRONE_OBJECT_SIZE       + 2 +
            MAX_LAUNCHER_COUNT    * LAUNCHER_OBJECT_SIZE    + 2 +
            MAX_TURRET_COUNT      * TURRET_OBJECT_SIZE      + 2 +
            MAX_COLLECTIBLE_COUNT * COLLECTIBLE_OBJECT_SIZE + 2 +
            MAX_MESSAGE_COUNT     * MESSAGE_OBJECT_SIZE     + 2 +
            MAX_BACKGROUND_COUNT  * BACKGROUND_OBJECT_SIZE  + 2;

        System.out.printf("Strip size: min %d bytes, max %d bytes\n", stripSize, maxStripSize);

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
    private int writeObjectPositions(int              startY,
                                     int              endY,
                                     DataOutputStream outputStream,
                                     int              objectType,
                                     int              maxCount)
    throws IOException
    {
        int objectRGB = rgb(objectType);
        int count     = 0;

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

                    count++;
                }
            }
        }

        outputStream.writeChar(-1);

        if (count > maxCount)
        {
            throw new IllegalArgumentException("Object count ["+count+"] exceeded maximum ["+maxCount+"] for object type "+objectType+" in strip ["+startY+".."+endY+"]");
        }

        return count;
    }


    /**
     * Writes out the array with initial object positions
     * of the given types, for a specified horizontal strip.
     */
    private int writeBackgroundObjectPositions(int                  startY,
                                               int                  endY,
                                               DataOutputStream     outputStream,
                                               Map<Integer,Integer> rgbTypes,
                                               int                  maxCount)
    throws IOException
    {
        return writeBackgroundObjectPositions(startY,
                                              endY,
                                              outputStream,
                                              rgbTypes,
                                              maxCount,
                                              0);
    }


    /**
     * Writes out the array with initial object positions
     * of the given types, for a specified horizontal strip.
     */
    private int writeBackgroundObjectPositions(int                  startY,
                                               int                  endY,
                                               DataOutputStream     outputStream,
                                               Map<Integer,Integer> rgbTypes,
                                               int                  maxCount,
                                               int                  typeIncrement)
    throws IOException
    {
        int count = 0;

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

                    count++;

                    if (typeIncrement != 0)
                    {
                        type += typeIncrement;

                        rgbTypes.put(rgb, type);
                    }
                }
            }
        }

        outputStream.writeChar(-1);

        if (count > maxCount)
        {
            throw new IllegalArgumentException("Object count ["+count+"] exceeded maximum ["+maxCount+"] for background objects [RGB 0x"+Integer.toHexString(rgbTypes.keySet().iterator().next())+"...] in strip ["+startY+".."+endY+"]");
        }

        return count;
    }
}
