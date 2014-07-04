/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.SnapshotVO;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;

    import mx.controls.Alert;

    import org.as3commons.lang.StringUtils;

    public class SnapshotLoader {

        private var verifyCommand:VerifyMonkeyCommand;
        private var snapshotDirUrl:String;
        private var snapshotFileUrl:String;
        private var snapshotLoader:URLLoader;

        public function SnapshotLoader(snapshotDirURL:String) {
            this.snapshotDirUrl = snapshotDirURL;
        }

        public function getSnapshot(name:String, verifyCommand:VerifyMonkeyCommand):void {
            this.verifyCommand = verifyCommand;

            if (!StringUtils.endsWith(snapshotDirUrl, "/")) {
                snapshotDirUrl = snapshotDirUrl + "/"
            }
            snapshotFileUrl = snapshotDirUrl + name;

            var urlRequest:URLRequest = new URLRequest(snapshotFileUrl);
            snapshotLoader = new URLLoader();
            snapshotLoader.dataFormat = URLLoaderDataFormat.BINARY;
            snapshotLoader.addEventListener(Event.COMPLETE, urlStreamCompleteHandler);
            snapshotLoader.addEventListener(IOErrorEvent.IO_ERROR, urlStreamIOErrorHandler);
            snapshotLoader.load(urlRequest);
        }

        private function urlStreamCompleteHandler(event:Event):void {
            var o:Object = event.target.data.readObject();
            verifyCommand.expectedSnapshot = new SnapshotVO(o);

            snapshotLoader.removeEventListener(Event.COMPLETE, urlStreamCompleteHandler);
            snapshotLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlStreamIOErrorHandler);
        }

        private function urlStreamIOErrorHandler(event:IOErrorEvent):void {
            trace('error....... ');
            trace(event + "\n" + new Error().getStackTrace());
            Alert.show("Could not load snapshot " + snapshotFileUrl);

            snapshotLoader.removeEventListener(Event.COMPLETE, urlStreamCompleteHandler);
            snapshotLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlStreamIOErrorHandler);
        }

    }
}