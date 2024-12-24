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
    private static final boolean DEBUG = true;


    public static void main(String[] args)
    throws IOException
    {
        // Compress and write out the patterns.
        String nameOutputFileName     = args[args.length - 4];
        String indexOutputFileName    = args[args.length - 3];
        String positionOutputFileName = args[args.length - 2];
        String patternOutputFileName  = args[args.length - 1];

        try (PrintWriter nameWriter =
                new PrintWriter(
                new BufferedWriter(
                new FileWriter(nameOutputFileName))))
        {
        try (DataOutputStream indexOutputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(indexOutputFileName))))
        {
        try (DataOutputStream positionOutputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(positionOutputFileName))))
        {
        try (DataOutputStream patternOutputStream =
                 new DataOutputStream(
                 new BufferedOutputStream(
                 new FileOutputStream(patternOutputFileName))))
        {
            // Options.
            int    color            = 15;
            int    shiftX           = 0;
            int    shiftY           = 0;
            int    explosionCount   = 0;
            double explosionSpeed   = 1;
            double explosionGravity = 0.;
            String appendFileName   = null;
            int    appendShiftX     = 0;
            int    appendShiftY     = 0;
            int    appendColor      = 0;

            // Keep a map of file names to supersprite definitions.
            Map<String,SpriteImage> nameImageMap = new HashMap<>();

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
                        case "-color"            -> color            = Integer.parseInt(args[argIndex++]);
                        case "-shiftx"           -> shiftX           = Integer.parseInt(args[argIndex++]);
                        case "-shifty"           -> shiftY           = Integer.parseInt(args[argIndex++]);
                        case "-explosioncount"   -> explosionCount   = Integer.parseInt(args[argIndex++]);
                        case "-explosionspeed"   -> explosionSpeed   = Double.parseDouble(args[argIndex++]);
                        case "-explosiongravity" -> explosionGravity = Double.parseDouble(args[argIndex++]);
                        case "-name"             ->
                        {
                            String name = args[argIndex++];

                            int superSpriteIndex = indexOutputStream.size() / 2;

                            nameWriter.println(String.format("%-16s equ %d", name, superSpriteIndex));

                            appendFileName = null;
                        }
                        case "-append" ->
                        {
                            appendFileName  = args[argIndex++];
                            appendColor     = color;
                            appendShiftX    = shiftX;
                            appendShiftY    = shiftY;
                        }
                        default -> throw new IllegalArgumentException("Unknown option [" + arg + "]");
                    }
                }
                else
                {
                    // Read the image.
                    if (DEBUG)
                    {
                        System.out.println("#"+(indexOutputStream.size()/2)+" ["+arg+"]:");
                    }

                    appendSprite(arg,
                                 color,
                                 shiftX,
                                 shiftY,
                                 explosionCount,
                                 explosionSpeed,
                                 explosionGravity,
                                 appendFileName,
                                 appendColor,
                                 appendShiftX,
                                 appendShiftY,
                                 indexOutputStream,
                                 positionOutputStream,
                                 patternOutputStream,
                                 nameImageMap);
                }
            }

            // Write the sentinel.
            indexOutputStream.writeChar(positionOutputStream.size() / 8);
        }
        }
        }
        }
    }


    /**
     * Appends a named sprite to the sprite that is currently being defined.
     */
    private static void appendSprite(String                  fileName,
                                     int                     color,
                                     int                     shiftX,
                                     int                     shiftY,
                                     int                     explosionCount,
                                     double                  explosionSpeed,
                                     double                  explosionGravity,
                                     String                  appendFileName,
                                     int                     appendColor,
                                     int                     appendShiftX,
                                     int                     appendShiftY,
                                     DataOutputStream        indexOutputStream,
                                     DataOutputStream        positionOutputStream,
                                     DataOutputStream        patternOutputStream,
                                     Map<String,SpriteImage> nameImageMap)
    throws IOException
    {
        // Get the earlier defined sprite image, or create a new one
        // (writing  out the sprite patterns).
        // Note that computeIfAbsent can't handle the declared IOException.
        SpriteImage spriteImage = nameImageMap.get(fileName);
        if (spriteImage == null)
        {
            spriteImage = createSpriteImage(fileName, patternOutputStream);

            nameImageMap.put(fileName, spriteImage);
        }

        // Write out the sprite indices and positions, pointing to the above
        // patterns.
        appendSprite(spriteImage,
                     color,
                     shiftX,
                     shiftY,
                     explosionCount,
                     explosionSpeed,
                     explosionGravity,
                     appendFileName,
                     appendColor,
                     appendShiftX,
                     appendShiftY,
                     indexOutputStream,
                     positionOutputStream,
                     patternOutputStream,
                     nameImageMap);
    }


    /**
     * Creates and returns a new supersprite based on the specified image file,
     * writing out the quadsprite patterns (but not yet any indices or positions).
     */
    private static SpriteImage createSpriteImage(String           fileName,
                                                 DataOutputStream patternOutputStream)
    throws IOException
    {
        BufferedImage image          = ImageIO.read(new File(fileName));
        Raster        originalRaster = image.getRaster();

        // Create a working copy of the raster.
        WritableRaster raster = originalRaster.createCompatibleWritableRaster();
        raster.setRect(originalRaster);

        int width  = raster.getWidth();
        int height = raster.getHeight();

        // Find the global crop bounds of the supersprite.
        Rectangle cropBounds =
            computeCropBounds(originalRaster,
                              new Rectangle(0, 0, width, height));

        if (DEBUG)
        {
            System.out.println("  Creating quadsprite image from [" + fileName +
                               "] (" + width + "x" + height +
                               " pixels) (" + cropBounds.x + ", " + cropBounds.y +
                               ", " + cropBounds.width + "x" + cropBounds.height + " covered):");
        }

        // Collect the quadsprite positions.
        List<Point>     positions = new ArrayList<>();
        List<Rectangle> bounds    = new ArrayList<>();

        // Mark the quadsprite coverage with bits in a bitraster
        // for the image.
        int[][] bitraster = new int[width][height];

        for (int positionIndex = 0;; positionIndex++)
        {
            Point position = findBestCornerSprite(raster);
            if (position == null)
            {
                break;
            }

            positions.add(position);

            // Find the crop bounds of the quadsprite.
            Rectangle spriteBounds =
                computeCropBounds(raster,
                                  new Rectangle(position.x, position.y, 16, 16));

            bounds.add(spriteBounds);

            // Clear the created quadsprite in the raster.
            clearSprite(raster, position.x, position.y);

            // Copy the quadsprite from the raster to the bitraster.
            copySprite(originalRaster,
                       position.x,
                       position.y,
                       1 << positionIndex,
                       bitraster);
        }

        // Remember the index of the first pattern.
        int firstPatternIndex = patternOutputStream.size() / 32;

        if (DEBUG)
        {
            System.out.println("  Extracting corresponding patterns, starting at #"+firstPatternIndex+":");
        }

        int positionCount = positions.size();

        // Write the quadsprite patterns.
        for (int positionIndex = 0; positionIndex < positionCount; positionIndex++)
        {
            Point position = positions.get(positionIndex);

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
                System.out.print("    #" + positionIndex +
                                 ": (" + spriteX + ", " + spriteY + ") 0x");

                for (int index = 0; index < spritePattern.length; index++)
                {
                    System.out.printf("%02x", spritePattern[index]);
                }
                System.out.println();
            }
        }

        return new SpriteImage(cropBounds, positions, bounds, firstPatternIndex);
    }


    /**
     * Creates or appends a given supersprite (depending on indexOutputStream
     * not being null).
     * @return the number of quad sprite positions that were added.
     */
    private static void appendSprite(SpriteImage             spriteImage,
                                     int                     color,
                                     int                     shiftX,
                                     int                     shiftY,
                                     int                     explosionCount,
                                     double                  explosionSpeed,
                                     double                  explosionGravity,
                                     String                  appendFileName,
                                     int                     appendColor,
                                     int                     appendShiftX,
                                     int                     appendShiftY,
                                     DataOutputStream        indexOutputStream,
                                     DataOutputStream        positionOutputStream,
                                     DataOutputStream        patternOutputStream,
                                     Map<String,SpriteImage> nameImageMap)
    throws IOException
    {
        // Compute the center of the (optional) explosion.
        Rectangle imageBounds = spriteImage.imageBounds;

        int explosionCenterX = imageBounds.x + imageBounds.width  / 2;
        int explosionCenterY = imageBounds.y + imageBounds.height / 2;

        List<Point>     positions = spriteImage.spritePositions;
        List<Rectangle> bounds    = spriteImage.spriteBounds;

        int positionCount = positions.size();

        // Write the quadsprite positions, including exploded ones.
        for (int explosionCounter = 0; explosionCounter <= explosionCount; explosionCounter++)
        {
            // Optionally write the quadsprite start index for this explosion
            // supersprite.
            if (indexOutputStream != null)
            {
                indexOutputStream.writeChar(positionOutputStream.size() / 8);
            }

            double explosionFraction = (double)explosionCounter / explosionCount;

            if (DEBUG && explosionCount > 1)
            {
                System.out.println("  Explosion #"+explosionCounter+":");
            }

            for (int positionCounter = 0; positionCounter < positionCount; positionCounter++)
            {
                Point     position     = positions.get(positionCounter);
                Rectangle spriteBounds = bounds.get(positionCounter);

                // Compute the deltas for the exploding explosionsprite.
                int spriteCenterX = spriteBounds.x + spriteBounds.width  / 2;
                int spriteCenterY = spriteBounds.y + spriteBounds.height / 2;

                int deltaX = spriteCenterX - explosionCenterX;
                int deltaY = spriteCenterY - explosionCenterY;

                int explosionX = (int)Math.round(explosionFraction *  deltaX * explosionSpeed);
                int explosionY = (int)Math.round(explosionFraction * (deltaY * explosionSpeed + explosionFraction * explosionGravity) / Math.sqrt(2));

                int positionX = position.x + explosionX + shiftX;
                int positionY = position.y + explosionY + shiftY;

                if (DEBUG)
                {
                    System.out.println("    #" + (positionOutputStream.size() / 8) +
                                       ": (x("+position.x+"+"+explosionX+"+"+shiftX+") = " + positionX +
                                       ", y = " + positionY +
                                       ", color = " + color +
                                       ", pattern = " + (spriteImage.firstPatternIndex + positionCounter) + ")");
                }

                positionOutputStream.writeChar(positionX);
                positionOutputStream.writeChar(positionY);
                positionOutputStream.writeChar(color);
                positionOutputStream.writeChar(spriteImage.firstPatternIndex + positionCounter);

                //ImageIO.write(image, "png", new File("/tmp/image"+spriteIndex+".png"));
            }

            // Append a sprite, if specified, without giving it its own index
            // in the index output stream.
            if (appendFileName != null)
            {
                appendSprite(appendFileName,
                             appendColor,
                             appendShiftX,
                             appendShiftY,
                             0,
                             0.0,
                             0.0,
                             null,
                             0,
                             0,
                             0,
                             null,
                             positionOutputStream,
                             patternOutputStream,
                             nameImageMap);
            }
        }
    }


    /**
     * Finds the position of the 16x16 quadsprite near the corners of the given
     * raster that covers the most pixels (roughly).
     */
    private static Point findBestCornerSprite(Raster raster)
    {
        int width  = raster.getWidth();
        int height = raster.getHeight();

        Rectangle bounds =
                computeCropBounds(raster,
                                  new Rectangle(0, 0, width, height));

        if (bounds.x == Integer.MAX_VALUE)
        {
            return null;
        }

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

        if (DEBUG)
        {
            System.out.println("    Sprite @ (" + spriteX + ", " + spriteY +
                               ") from (" + minX + ", " + minY +
                               ", " + width + "x" + height + " pixels)");
        }

        return new Point(spriteX, spriteY);
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
     * An image represented by quadsprites.
     */
    private static class SpriteImage
    {
        public final Rectangle       imageBounds;
        public final List<Point>     spritePositions;
        public final List<Rectangle> spriteBounds;
        public final int             firstPatternIndex;


        /**
         * Creates a new instance.
         * @param imageBounds       The crop bounds of the original image.
         * @param spritePositions   The quadsprite positions relative to the
         *                          original image.
         * @param spriteBounds      The quadsprite crop bounds relative to
         *                          the original image.
         * @param firstPatternIndex The first index of the quadsprite patterns
         *                          in an external array.
         */
        public SpriteImage(Rectangle           imageBounds,
                               List<Point>     spritePositions,
                               List<Rectangle> spriteBounds,
                               int             firstPatternIndex)
        {
            this.imageBounds       = imageBounds;
            this.spritePositions   = spritePositions;
            this.spriteBounds      = spriteBounds;
            this.firstPatternIndex = firstPatternIndex;
        }
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
