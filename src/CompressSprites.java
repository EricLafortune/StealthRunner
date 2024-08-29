import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.*;
import java.util.List;

/**
 * Compresses a series of monochrome images to supersprites (composites
 * of 16x16 pixel quadsprites).
 *
 * Usage:
 *   java CompressSprites [options] <input_file> ... <index_output_file> <position_output_file> <pattern_output_file>
 * where options are
 *   -shiftx <s>     the horizontal shift added to the object positions, expressed in pixels.
 *   -shifty <s>     the vertical shift added to the object positions, expressed in pixels.
 */
public class CompressSprites
{
    private static final boolean DEBUG = false;


    public static void main(String[] args)
    throws IOException
    {
        // Compress and write out the patterns.
        String nameOutputFileName     = args[args.length - 4];
        String indexOutputFileName    = args[args.length - 3];
        String positionOutputFileName = args[args.length - 2];
        String patternOutputFileName  = args[args.length - 1];

        ByteArrayOutputStream indexArrayOutputStream;
        ByteArrayOutputStream positionArrayOutputStream;

        try (PrintWriter nameWriter =
                new PrintWriter(
                new BufferedWriter(
                new FileWriter(nameOutputFileName))))
        {
        try (DataOutputStream indexOutputStream =
                 new DataOutputStream(
                 new TeeOutputStream(
                 indexArrayOutputStream = new ByteArrayOutputStream(),
                 new BufferedOutputStream(
                 new FileOutputStream(indexOutputFileName)))))
        {
        try (DataOutputStream positionOutputStream =
                 new DataOutputStream(
                 new TeeOutputStream(
                 positionArrayOutputStream = new ByteArrayOutputStream(),
                 new BufferedOutputStream(
                 new FileOutputStream(positionOutputFileName)))))
        {
        try (DataOutputStream patternOutputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(patternOutputFileName))))
        {
            // Options.
            int    shiftX                   = 0;
            int    shiftY                   = 0;
            int    color                    = 15;
            int    explosionCount           = 0;
            double explosionSpeed           = 1;
            double explosionGravity         = 0.;
            int    appendPositionStartIndex = 0;
            int    appendPositionCount      = 0;

            // Counters.
            int spritePositionIndex = 0;
            int spritePatternIndex  = 0;

            // Keep a map of supersprite names and their corresponding supersprite indices.
            Map<String,Integer> nameIndices = new HashMap<>();

            // Parse any options, also inbetween regular arguments.
            int argIndex = 0;

            while (argIndex < args.length - 4)
            {
                String arg = args[argIndex++];
                if (arg.startsWith("-"))
                {
                    // Parse the option.
                    switch (arg)
                    {
                        case "-shiftx"           -> shiftX           = Integer.parseInt(args[argIndex++]);
                        case "-shifty"           -> shiftY           = Integer.parseInt(args[argIndex++]);
                        case "-color"            -> color            = Integer.parseInt(args[argIndex++]);
                        case "-explosioncount"   -> explosionCount   = Integer.parseInt(args[argIndex++]);
                        case "-explosionspeed"   -> explosionSpeed   = Double.parseDouble(args[argIndex++]);
                        case "-explosiongravity" -> explosionGravity = Double.parseDouble(args[argIndex++]);
                        case "-name"             ->
                        {
                            String name = args[argIndex++];

                            int superSpriteIndex = indexOutputStream.size() / 2;

                            nameWriter.println(String.format("%-16s equ %d", name, superSpriteIndex));

                            nameIndices.put(name, superSpriteIndex);
                        }
                        case "-append" ->
                        {
                            String name = args[argIndex++];

                            if (name.equals("/"))
                            {
                                appendPositionStartIndex = 0;
                                appendPositionCount      = 0;
                            }
                            else
                            {
                                Integer index = nameIndices.get(name);
                                if (index == null)
                                {
                                    throw new IllegalArgumentException("Option \"-name "+name+"\" needed before option \"-append \""+name+"\"");
                                }

                                int offset = index * 2;

                                byte[] indices = indexArrayOutputStream.toByteArray();

                                appendPositionStartIndex =
                                    (indices[offset]   & 0xff) << 8 | (indices[offset+1] & 0xff);

                                int appendPositionEndIndex = offset+2 < indices.length ?
                                    (indices[offset+2] & 0xff) << 8 | (indices[offset+3] & 0xff) :
                                    spritePositionIndex;

                                appendPositionCount =
                                    appendPositionEndIndex - appendPositionStartIndex;
                            }
                        }
                        default -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
                    }
                }
                else
                {
                    // Read the image.
                    if (DEBUG)
                    {
                        System.out.println("["+arg+"]:");
                    }

                    BufferedImage image          = ImageIO.read(new File(arg));
                    Raster        originalRaster = image.getRaster();

                    // Create a working copy of the raster.
                    WritableRaster raster = originalRaster.createCompatibleWritableRaster();
                    raster.setRect(originalRaster);

                    int width  = raster.getWidth();
                    int height = raster.getHeight();

                    // Collect the sprite positions.
                    List<Point> spritePositions = new ArrayList<>();

                    // Mark the sprite coverage with bits in a bitraster.
                    int[][] bitraster = new int[width][height];

                    for (int positionIndex = 0;; positionIndex++)
                    {
                        Rectangle bounds =
                            computeCropBounds(raster, new Rectangle(0, 0, width, height));

                        if (bounds.x == Integer.MAX_VALUE)
                        {
                            break;
                        }

                        Point position =
                            findBestCornerSprite(raster, bounds);

                        if (DEBUG)
                        {
                            System.out.println("  #"+(spritePositionIndex+positionIndex)+
                                               ": ("+position.x+", "+position.y+
                                               ") from "+bounds.width+" x "+bounds.height+
                                               " @ ("+bounds.x+", "+bounds.y+")");
                        }

                        spritePositions.add(position);

                        // Clear the created quadsprite in the raster.
                        clearSprite(raster, position.x, position.y);

                        // Copy the sprite from the raster to the bitraster.
                        copySprite(originalRaster,
                                   position.x,
                                   position.y,
                                   1 << positionIndex,
                                   bitraster);
                    }

                    int positionCount = spritePositions.size();

                    if (DEBUG)
                    {
                        System.out.println("  -> "+positionCount+" patterns:");
                    }

                    // Write the quadsprite patterns.
                    for (int positionIndex = 0; positionIndex < positionCount; positionIndex++)
                    {
                        Point position = spritePositions.get(positionIndex);

                        int spriteX = position.x;
                        int spriteY = position.y;

                        // Extract the quadsprite from the supersprite bitraster,
                        // gradually clearing its pixels.
                        byte[] spritePattern = extractSprite(bitraster,
                                                             spriteX,
                                                             spriteY,
                                                             1 << positionIndex);

                        // Write the sprite pattern.
                        patternOutputStream.write(spritePattern);

                        if (DEBUG)
                        {
                            System.out.print("    #"+(spritePatternIndex+positionIndex)+
                                             ": ("+spriteX+", "+spriteY+") 0x");

                            for (int index = 0; index < spritePattern.length; index++)
                            {
                                System.out.printf("%02x", spritePattern[index]);
                            }
                            System.out.println();
                        }
                    }

                    // Find the global crop bounds of the supersprite.
                    Rectangle superBounds =
                        computeCropBounds(originalRaster, new Rectangle(0, 0, width, height));

                    int superCenterX = superBounds.x + superBounds.width  / 2;
                    int superCenterY = superBounds.y + superBounds.height / 2;

                    byte[] appendPositions = appendPositionCount <= 0 ? null :
                        positionArrayOutputStream.toByteArray();

                    // Write the quadsprite positions, including exploded ones.
                    for (int explosionIndex = 0; explosionIndex <= explosionCount; explosionIndex++)
                    {
                        // Write the quadsprite start index for this
                        // supersprite in the explosion.
                        indexOutputStream.writeChar(spritePositionIndex);

                        double explosionFraction = (double)explosionIndex / explosionCount;

                        for (int positionIndex = 0; positionIndex < positionCount; positionIndex++)
                        {
                            Point position = spritePositions.get(positionIndex);

                            // Find the local crop bounds of the quadsprite.
                            Rectangle spriteBounds =
                                computeCropBounds(originalRaster, new Rectangle(position.x, position.y, 16, 16));

                            // Compute the deltas for the exploding supersprite.
                            int spriteCenterX = spriteBounds.x + spriteBounds.width  / 2;
                            int spriteCenterY = spriteBounds.y + spriteBounds.height / 2;

                            int deltaX = spriteCenterX - superCenterX;
                            int deltaY = spriteCenterY - superCenterY;

                            int explosionX = (int)Math.round(explosionFraction *  deltaX * explosionSpeed);
                            int explosionY = (int)Math.round(explosionFraction * (deltaY * explosionSpeed + explosionFraction * explosionGravity) / Math.sqrt(2));

                            positionOutputStream.writeChar(position.x + explosionX + shiftX);
                            positionOutputStream.writeChar(position.y + explosionY + shiftY);
                            positionOutputStream.writeChar(color);
                            positionOutputStream.writeChar(spritePatternIndex + positionIndex);

                            //ImageIO.write(image, "png", new File("/tmp/image"+spriteIndex+".png"));
                        }

                        if (appendPositionCount > 0)
                        {
                            positionOutputStream.write(appendPositions,
                                                       appendPositionStartIndex * 8,
                                                       appendPositionCount      * 8);

                            spritePositionIndex += appendPositionCount;
                        }

                        spritePositionIndex += positionCount;
                    }

                    spritePatternIndex += positionCount;
                }
            }

            // Write the sentinel.
            indexOutputStream.writeChar(spritePositionIndex);
        }
        }
        }
        }
    }


    private static Rectangle computeCropBounds(Raster    raster,
                                               Rectangle bounds)
    {
        // Find the global crop bounds of the image.
        int minX = Integer.MAX_VALUE;
        int maxX = Integer.MIN_VALUE;
        int minY = Integer.MAX_VALUE;
        int maxY = Integer.MIN_VALUE;

        for (int y = bounds.y; y < bounds.y + bounds.height; y++)
        {
            for (int x = bounds.x; x < bounds.x + bounds.width; x++)
            {
                if (isSet(raster, x, y))
                {
                    if (minX > x)
                    {
                        minX = x;
                    }
                    if (maxX < x)
                    {
                        maxX = x;
                    }
                    if (minY > y)
                    {
                        minY = y;
                    }
                    if (maxY < y)
                    {
                        maxY = y;
                    }
                }
            }
        }

        return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
    }


    /**
     * Finds the position of the 16x16 quadsprite near the corners of the given
     * raster that covers the most pixels (roughly).
     */
    private static Point findBestCornerSprite(Raster    raster,
                                              Rectangle bounds)
    {
        int minX = bounds.x;
        int minY = bounds.y;
        int maxX = minX + bounds.width  - 1;
        int maxY = minY + bounds.height - 1;

        // Find the corner that has the closest set pixel along its edges.
        int minCornerDistance = Integer.MAX_VALUE;

        int spriteX = 0;
        int spriteY = 0;

        // The top-left corner?
        int cornerDistance = pixelDistance(raster, minX, minY, 1, 0, 0, 1);
        if (cornerDistance < minCornerDistance)
        {
            // Tighten up the corner for a 16x16 sprite.
            int spriteMinX = minX;
            int spriteMinY = minY;

            while (is16PixelColumnClear(raster, spriteMinX, spriteMinY)) spriteMinX++;
            while (is16PixelRowClear(raster, spriteMinX, spriteMinY))    spriteMinY++;

            // Remember the sprite coordinates.
            spriteX = spriteMinX;
            spriteY = spriteMinY;

            minCornerDistance = cornerDistance;
        }

        // The bottom-left corner?
        cornerDistance = pixelDistance(raster, minX, maxY, 1, 0, 0, -1);
        if (cornerDistance < minCornerDistance)
        {
            // Tighten up the corner for a 16x16 sprite.
            int spriteMinX = minX;
            int spriteMaxY = maxY;

            while (is16PixelColumnClear(raster, spriteMinX, spriteMaxY - 15)) spriteMinX++;
            while (is16PixelRowClear(raster, spriteMinX, spriteMaxY))         spriteMaxY--;

            // Remember the sprite coordinates.
            spriteX = spriteMinX;
            spriteY = spriteMaxY - 15;

            minCornerDistance = cornerDistance;
        }

        // The top-right corner?
        cornerDistance = pixelDistance(raster, maxX, minY, -1, 0, 0, 1);
        if (cornerDistance < minCornerDistance)
        {
            // Tighten up the corner for a 16x16 sprite.
            int spriteMaxX = maxX;
            int spriteMinY = minY;

            while (is16PixelColumnClear(raster, spriteMaxX, spriteMinY))   spriteMaxX--;
            while (is16PixelRowClear(raster, spriteMaxX - 15, spriteMinY)) spriteMinY++;

            // Remember the sprite coordinates.
            spriteX = spriteMaxX - 15;
            spriteY = spriteMinY;

            minCornerDistance = cornerDistance;
        }

        // The bottom-right corner?
        cornerDistance = pixelDistance(raster, maxX, maxY, -1, 0, 0, -1);
        if (cornerDistance < minCornerDistance)
        {
            // Tighten up the corner for a 16x16 sprite.
            int spriteMaxX = maxX;
            int spriteMaxY = maxY;

            while (is16PixelColumnClear(raster, spriteMaxX, spriteMaxY - 15)) spriteMaxX--;
            while (is16PixelRowClear(raster, spriteMaxX - 15, spriteMaxY))    spriteMaxY--;

            // Remember the sprite coordinates.
            spriteX = spriteMaxX - 15;
            spriteY = spriteMaxY - 15;

            minCornerDistance = cornerDistance;
        }

        return new Point(spriteX, spriteY);
    }


    /**
     * Scans for the closest set pixel, from the given point,
     * in the two given directions.
     */
    private static int pixelDistance(Raster raster,
                                     int    x,
                                     int    y,
                                     int    dx1,
                                     int    dy1,
                                     int    dx2,
                                     int    dy2)
    {
        return Math.min(
            pixelDistance(raster, x, y, dx1, dy1),
            pixelDistance(raster, x, y, dx2, dy2));
    }


    /**
     * Scans for the closest set pixel, from the given point,
     * in the given direction.
     */
    private static int pixelDistance(Raster raster,
                                     int    x,
                                     int    y,
                                     int    dx,
                                     int    dy)
    {
        int d = 0;

        while (x >= 0                &&
               x < raster.getWidth()  &&
               y >= 0                &&
               y < raster.getHeight())
        {
            if (isSet(raster, x, y))
            {
                return d;
            }

            x += dx;
            y += dy;

            d++;
        }

        return Integer.MAX_VALUE;
    }


    /**
     * Checks whether the vertical column of 16 pixels at the specified
     * position is clear.
     */
    private static boolean is16PixelColumnClear(Raster raster, int x, int y)
    {
        for (int delta = 0; delta < 16; delta++)
        {
            if (isSet(raster, x, y + delta))
            {
                return false;
            }
        }

        return true;
    }


    /**
     * Checks whether the horizontal row of 16 pixels at the specified
     * position is clear.
     */
    private static boolean is16PixelRowClear(Raster raster, int x, int y)
    {
        for (int delta = 0; delta < 16; delta++)
        {
            if (isSet(raster, x + delta, y))
            {
                return false;
            }
        }

        return true;
    }


    /**
     * Copies a rectangle of 16x16 pixels at the specified position from the
     * given raster to the given bitraster, with the specified bit.
     */
    private static void copySprite(Raster  raster,
                                   int     spriteX,
                                   int     spriteY,
                                   int     bit,
                                   int[][] bitraster)
    {
        for (int dx = 0; dx < 16; dx++)
        {
            for (int dy = 0; dy < 16; dy++)
            {
                int x = spriteX + dx;
                int y = spriteY + dy;

                if (isSet(raster, x, y))
                {
                    bitraster[x][y] |= bit;
                }
            }
        }
    }


    /**
     * Extracts and returns the pattern of 32 bytes of the 16x16 pixels
     * quadsprite at the specified position. Pixels that are covered by
     * multiple quadsprites are randomized.
     */
    private static byte[] extractSprite(int[][] bitraster,
                                        int     spriteX,
                                        int     spriteY,
                                        int     bit)
    {
        Random random = new Random();

        byte[] pattern = new byte[2*2*8];

        int patternOffset = 0;

        // Extract the 2x2 characters (=16x16 pixels).
        for (int cx = 0; cx < 16; cx += 8)
        {
            for (int dy = 0; dy < 16; dy++)
            {
                // Collect the row of 8 pixels.
                int pixels = 0;

                for (int rx = 0; rx < 8; rx++)
                {
                    int dx = cx + rx;

                    int x = spriteX + dx;
                    int y = spriteY + dy;

                    int bits = bitraster[x][y];
                    if ((bits & bit) != 0)
                    {
                        // Is the pixel covered by multiple sprites?
                        // We can then randomize the pixel, heuristically
                        // with a lower probability near the edges.
                        int coverage = Integer.bitCount(bits);
                        if (coverage == 1 ||
                            random.nextInt(coverage +
                                           (dx <= 2 || dx >= 13 ? 1 : 0) +
                                           (dy <= 2 || dy >= 13 ? 1 : 0)) == 0)
                        {
                            // Set the sprite pixel.
                            pixels |= 0x80 >>> rx;

                            // Clear the bitraster pixel.
                            // This sprite has it covered.
                            bitraster[x][y] = 0;
                        }
                        else
                        {
                            // Clear the bitraster bit.
                            // This sprite won't cover it.
                            bitraster[x][y] &= ~bit;
                        }
                    }
                }

                pattern[patternOffset++] = (byte)pixels;
            }
        }

        return pattern;
    }


    /**
     * Clears the 16x16 pixels at the specified position.
     */
    private static void clearSprite(WritableRaster raster, int x, int y)
    {
        for (int dx = 0; dx < 16; dx++)
        {
            for (int dy = 0; dy < 16; dy++)
            {
                raster.setSample(x + dx, y + dy, 0, 0);
            }
        }
    }


    /**
     * Returns whether the pixel at the specified position is set.
     */
    private static boolean isSet(Raster raster, int x, int y)
    {
        return raster.getSample(x, y, 0) != 0;
    }


    /**
     * An OutputStream that sends its output to two OutputStream instances.
     */
    private static class TeeOutputStream
    extends              OutputStream
    {
        private final OutputStream out1;
        private final OutputStream out2;


        public TeeOutputStream(OutputStream out1,
                               OutputStream out2)
        {
            this.out1 = out1;
            this.out2 = out2;
        }


        // Implementations for TeeOutputStream.

        public void write(int b)
        throws IOException
        {
            out1.write(b);
            out2.write(b);
        }


        public void write(byte[] b)
        throws IOException
        {
            out1.write(b);
            out2.write(b);
        }


        public void write(byte[] b, int off, int len)
        throws IOException
        {
            out1.write(b, off, len);
            out2.write(b, off, len);
        }


        public void flush()
        throws IOException
        {
            out1.flush();
            out2.flush();
        }


        public void close()
        throws IOException
        {
            out1.close();
            out2.close();
        }
    }
}
