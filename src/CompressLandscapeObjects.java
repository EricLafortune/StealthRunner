import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.*;

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
    // Each pair of two vertical pixels corresponds to one character
    // (8x8 pixels in the game).
    private static final int MAX_WIDTH    = 0x1fff;
    private static final int MAX_HEIGHT   = 512;
    private static final int STRIP_HEIGHT = 128 * 2 / 8;

    private static final int LANDSCAPE =  3;
    private static final int PLAYER    =  4;
    private static final int TARGET    = 11;
    private static final int BUSH      = 12;
    private static final int TREE      =  9;
    private static final int STONE     =  6;
    private static final int BATTERY   =  2;
    private static final int MINE      =  8;
    private static final int DRONE     =  7;
    private static final int LAUNCHER  = 14;
    private static final int TURRET    = 15;

    private final Raster raster;
    private final int    width;
    private final int    height;
    private final int    shiftX;
    private final int    shiftY;


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
            new CompressLandscapeObjects(image.getRaster(), shiftX, shiftY);

        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    public CompressLandscapeObjects(Raster raster,
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
        writeObjectPositions(0, height, outputStream, PLAYER);

        for (int startY = 0; startY < height; startY += STRIP_HEIGHT)
        {
            int endY = Math.min(height, startY + STRIP_HEIGHT);

            writeObjectPositions(startY, endY, outputStream, TARGET);
            writeObjectPositions(startY, endY, outputStream, BUSH);
            writeObjectPositions(startY, endY, outputStream, TREE);
            writeObjectPositions(startY, endY, outputStream, STONE);
            writeObjectPositions(startY, endY, outputStream, BATTERY);
            writeObjectPositions(startY, endY, outputStream, MINE);
            writeObjectPositions(startY, endY, outputStream, DRONE);
            writeObjectPositions(startY, endY, outputStream, LAUNCHER);
            writeObjectPositions(startY, endY, outputStream, TURRET);
        }

        int size = outputStream.size();
        if (size > 8 * 1024)
        {
            throw new IllegalArgumentException("Landscape objects ("+size+" bytes) exceed single memory bank");
        }

        // Skip to the next memory bank.
        //outputStream.write(new byte[8 * 1024 - size]);
    }


    private void writeObjectPositions(int              startY,
                                      int              endY,
                                      DataOutputStream outputStream,
                                      int              objectValue)
    throws IOException
    {
        // The landscape height is half the raster height.
        // We're scanning all rows anyway.
        for (int y = startY; y < endY; y++)
        {
            for (int x = 0; x < width; x++)
            {
                if (raster.getSample(x, y, 0) == objectValue)
                {
                    outputStream.writeChar(x     * 8 + shiftX + 4);
                    outputStream.writeChar(y / 2 * 8 + shiftY + 4);
                }
            }
        }

        outputStream.writeChar(-1);
    }
}
