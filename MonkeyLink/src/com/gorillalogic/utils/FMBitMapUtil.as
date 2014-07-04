package com.gorillalogic.utils {

    import flash.display.BitmapData;

    public class FMBitMapUtil {

        /**
         * Compare two images with a delta.  The given delta value is applied
         * uniformly across all color channels and optionally the alpha channel.
         * For example, a delta of 1 allows for red to vary by plus or minus 1,
         * green to vary by plus or minus 1, etc.
         */
        public static function pixelCompareBitmaps(img1:BitmapData, img2:BitmapData, delta:int = 0, compareAlpha:Boolean = true):Boolean {
            if (img1.height != img2.height) {
                return false;
            }

            if (img1.width != img2.width) {
                return false;
            }

            if (delta < 0) {
                delta = 0;
            }

            var a:int = 0;
            var r:int = 0;
            var g:int = 0;
            var b:int = 0;

            for (var x:int = 0; x < img1.width; x++) {
                for (var y:int = 0; y < img1.height; y++) {
                    var c1:uint = img1.getPixel32(x, y);
                    var c2:uint = img2.getPixel32(x, y);

                    if (c1 != c2) {
                        if (delta == 0) {
                            return false;
                        }

                        if (compareAlpha) {
                            a = (c1 >> 24 & 0xFF) - (c2 >> 24 & 0xFF);

                            if (a < 0) {
                                a = -a;
                            }

                            if (a > delta) {
                                return false;
                            }
                        }

                        r = (c1 >> 16 & 0xFF) - (c2 >> 16 & 0xFF);

                        if (r < 0) {
                            r = -r;
                        }

                        if (r > delta) {
                            return false;
                        }

                        g = (c1 >> 8 & 0xFF) - (c2 >> 8 & 0xFF);

                        if (g < 0) {
                            g = -g;
                        }

                        if (g > delta) {
                            return false;
                        }

                        b = (c1 & 0xFF) - (c2 & 0xFF);

                        if (b < 0) {
                            b = -b;
                        }

                        if (b > delta) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }

    }
}
