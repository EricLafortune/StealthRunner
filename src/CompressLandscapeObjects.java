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
    private static final int MAX_WIDTH  = 0x1fff;
    private static final int MAX_HEIGHT = 512;

    private static final int LANDSCAPE =  3;
    private static final int PLAYER    =  4;
    private static final int TARGET    = 11;
    private static final int BATTERY   =  2;
    private static final int MINE      =  8;
    private static final int DRONE     =  7;
    private static final int TURRET    = 14;

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
        writeObjectPositions(outputStream, PLAYER);
        writeObjectPositions(outputStream, TARGET);
        writeObjectPositions(outputStream, BATTERY);
        writeObjectPositions(outputStream, MINE);
        writeObjectPositions(outputStream, DRONE);
        writeObjectPositions(outputStream, TURRET);

        int size = outputStream.size();
        if (size > 8 * 1024)
        {
            throw new IllegalArgumentException("Landscape objects ("+size+" bytes) exceed single memory bank");
        }

        // Skip to the next memory bank.
        //outputStream.write(new byte[8 * 1024 - size]);
    }


    private void writeObjectPositions(DataOutputStream outputStream,
                                      int              objectValue)
    throws IOException
    {
        // The landscape height is half the raster height.
        // We're scanning all rows anyway.
        for (int y = 0; y < height; y++)
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
