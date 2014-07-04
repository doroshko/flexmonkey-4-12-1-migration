package com.gorillalogic.flexmonkey.utils {

    import flash.filesystem.File;

    import mx.logging.Log;
    import mx.logging.LogEventLevel;

    public class FMLogger {

        public static var instance:FMLogger = new FMLogger();
        public var target:LogFileTarget;

        public function FMLogger() {
            target = new LogFileTarget();
            target.filters = [ "*" ];
            target.level = LogEventLevel.ALL;

            target.includeDate = true;
            target.includeTime = true;
            target.includeCategory = true;
            target.includeLevel = true;

            Log.addTarget(target);
        }

        public function get log():File {
            return target.log;
        }

        public function debug(message:String, ... rest):void {
            Log.getLogger("FM").debug(message, rest);
        }

        public function info(message:String, ... rest):void {
            Log.getLogger("FM").info(message, rest);
        }

        public function error(message:String, ... rest):void {
            Log.getLogger("FM").error(message, rest);
        }

        public function printError(msg:String, error:Error):void {
            Log.getLogger("FM").error(msg + ": " + error.message);
            Log.getLogger("FM").error(error.getStackTrace());
        }
    }

}