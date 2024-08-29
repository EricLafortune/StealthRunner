import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.*;

/**
 * Converts a landscape image with a monochrome player mask image to a
 * landscape accessibility mask file in our own compressed format.
 *
 * Usage:
 *   java CompressLandscapeMask [options] <input_landscape_file> <input_player_file> <output_mask_file>
 * where options are
 *   -shiftx <s> the horizontal shift of the player mask, expressed in characters.
 *   -shifty <s> the vertical shift of the player mask, expressed in characters.
 *
 * The landscape mask has the same width but half the height as the image.
 *
 * The landscape mask is compressed as horizontal runs of accessible area.
 */
public class CompressLandscapeMask
{
    private static final int MAX_WIDTH  = 0x1fff;
    private static final int MAX_HEIGHT = 512;

    private static final int EMPTY     = 0;
    private static final int LANDSCAPE = 3;

    private final Raster landscape;
    private final int    landscapeWidth;
    private final int    landscapeHeight;
    private final Raster player;
    private final int    playerShiftX;
    private final int    playerShiftY;


    public static void main(String[] args)
    throws IOException
    {
        int playerShiftX = 0;
        int playerShiftY = 0;

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
                case "-shiftx" -> playerShiftX = Integer.parseInt(args[argIndex++]);
                case "-shifty" -> playerShiftY = Integer.parseInt(args[argIndex++]);
                default        -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
            }
        }

        String inputLandscapeFileName = args[argIndex++];
        String inputPlayerFileName    = args[argIndex++];
        String outputFileName         = args[argIndex++];

        BufferedImage landscapeImage = ImageIO.read(new File(inputLandscapeFileName));
        BufferedImage playerImage    = ImageIO.read(new File(inputPlayerFileName));

        CompressLandscapeMask landscape =
            new CompressLandscapeMask(landscapeImage.getRaster(),
                                      playerImage.getRaster(),
                                      playerShiftX,
                                      playerShiftY);


        try (DataOutputStream outputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(outputFileName))))
        {
            landscape.write(outputStream);
        }
    }


    public CompressLandscapeMask(Raster landscape,
                                 Raster player,
                                 int    playerShiftX,
                                 int    playerShiftY)
    {
        this.landscape       = landscape;
        this.landscapeWidth  = Math.min(MAX_WIDTH,  landscape.getWidth());
        this.landscapeHeight = Math.min(MAX_HEIGHT, landscape.getHeight());
        this.player          = player;
        this.playerShiftX    = playerShiftX;
        this.playerShiftY    = playerShiftY;
    }


    private void write(DataOutputStream outputStream)
    throws IOException
    {
        int height = landscapeHeight / 2;

        for (int y = 0; y < height; y++)
        {
            // We are always writing exactly 2 (possibly empty) spans.
            int spanStart1 = spanStart(0, y);
            int spanEnd1   = spanEnd(spanStart1, y);

            int spanStart2 = spanStart(spanEnd1, y);
            int spanEnd2   = spanEnd(spanStart2, y);

            outputStream.writeChar(spanStart1);
            outputStream.writeChar(spanEnd1);

            outputStream.writeChar(spanStart2);
            outputStream.writeChar(spanEnd2);
        }
    }


    private int spanStart(int x, int y)
    {
        for (; x < landscapeWidth; x++)
        {
            if (mask(x, y) == 0)
            {
                break;
            }
        }

        return x;
    }


    private int spanEnd(int x, int y)
    {
        for (; x < landscapeWidth; x++)
        {
            if (mask(x, y) != 0)
            {
                break;
            }
        }

        return x;
    }


    private int mask(int x, int y)
    {
        // Check the player mask on the landscape.
        for (int playerY = 0; playerY < player.getHeight(); playerY++)
        {
            for (int playerX = 0; playerX < player.getWidth(); playerX++)
            {
                if (playerPixel(playerX, playerY) &&
                    landscapeCharacter(playerShiftX + x + playerX,
                                       playerShiftY + y + playerY))
                {
                    return 1;
                }
            }
        }

        return 0;
    }


    private boolean playerPixel(int x, int y)
    {
        return player.getSample(x, y, 0) != 0;
    }


    private boolean landscapeCharacter(int x, int y)
    {
        return landscapePixel(x, 2 * y) |
               landscapePixel(x, 2 * y + 1);
    }


    private boolean landscapePixel(int x, int y)
    {
        if (x < 0)                   x = 0;
        if (x >= landscapeWidth - 1) x = landscapeWidth - 1;

        if (y < 0)                    y = 0;
        if (y >= landscapeHeight - 1) y = landscapeHeight - 1;

        int sample = landscape.getSample(x, y, 0);
        if (sample != EMPTY && sample != LANDSCAPE)
        {
            sample = landscape.getSample(x, y+1, 0);
        }

        return sample == LANDSCAPE;
    }
}
