/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.vo {

    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;

    import mx.core.UIComponent;
    import mx.graphics.codec.PNGEncoder;


    /**
     * SnapshotVO holds the BitmapData for a Snapshot.
     *
     * <p>To serialize the bitmap when saving to persistent storage,
     * Snapshot also contains a ByteArray version of the BitmapData.</p>
     *
     */
    [RemoteClass]
    [Bindable]
    public class SnapshotVO {

        public var width:uint;
        public var height:uint;
        public var bitmapData:BitmapData;
        public var byteArray:ByteArray;
        public var displayPng:ByteArray;

        public function SnapshotVO(obj:Object = null) {
            if (obj != null) {
                this.width = obj.width;
                this.height = obj.height;
                this.byteArray = obj.byteArray;
                createBitmap();
            }
        }

        public static function createFromUiComponent(target:UIComponent):SnapshotVO {
            var s:SnapshotVO = new SnapshotVO();
            s.bitmapData = new BitmapData(target.width, target.height);
            s.bitmapData.draw(target);

            s.width = target.width;
            s.height = target.height;

            var rect:Rectangle = new Rectangle(0, 0, s.width, s.height);
            s.byteArray = s.bitmapData.getPixels(rect);

            var pngEncoder:PNGEncoder = new PNGEncoder();
            s.displayPng = pngEncoder.encode(s.bitmapData);

            return s;
        }

        public function createBitmap():void {
            var b:BitmapData = new BitmapData(this.width, this.height);
            var rect:Rectangle = new Rectangle(0, 0, this.width, this.height);
            byteArray.position = 0;
            b.setPixels(rect, byteArray);
            bitmapData = b;

            var pngEncoder:PNGEncoder = new PNGEncoder();
            displayPng = pngEncoder.encode(bitmapData);
        }

    }
}