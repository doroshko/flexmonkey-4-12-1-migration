/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.utils.FMLogger;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    /**
     * AIR API dependencies
     */
    public class LogFileController implements IFMController {

        private var logFileStream:FileStream;

        public function register(hub:FMHub):void {
            //file opts
            hub.listen(ApplicationEvent.PURGE_LOG_FILE, purgeLogFile, this);
            hub.listen(ApplicationEvent.LOAD_LOG_FILE, loadLogFile, this);
        }

        private function loadLogFile(event:Event):void {
            var currentFile:File = FMLogger.instance.log;
            ApplicationModel.instance.logFileLocation = currentFile.nativePath;
            logFileStream = new FileStream();
            logFileStream.openAsync(currentFile, FileMode.READ);
            logFileStream.addEventListener(Event.COMPLETE, logFileReadHandler);
            logFileStream.addEventListener(IOErrorEvent.IO_ERROR, logFileReadIOErrorHandler);
        }

        private function logFileReadHandler(event:Event):void {
            ApplicationModel.instance.logFileData = logFileStream.readUTFBytes(logFileStream.bytesAvailable);
            logFileStream.close();
        }

        private function logFileReadIOErrorHandler(event:IOErrorEvent):void {
            ApplicationModel.instance.logFileData = "Failed to load file: " + event.text;
        }

        private function purgeLogFile(event:Event):void {
            ApplicationModel.instance.logFileData = "File Purged";
            var currentFile:File = FMLogger.instance.log;

            if (currentFile.exists) {
                currentFile.deleteFile();
            }

            FMLogger.instance.info("Log file purged");
        }

    }
}
