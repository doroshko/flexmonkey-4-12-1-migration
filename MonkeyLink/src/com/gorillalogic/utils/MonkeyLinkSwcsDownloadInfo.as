package com.gorillalogic.utils {

    import mx.utils.StringUtil;

    public class MonkeyLinkSwcsDownloadInfo {

        private static var flex3CompileArgs:String = "-include-libraries \"../libs/{0}\"" +
            " \"${flexlib}/libs/automation.swc\"" +
            " \"${flexlib}/libs/automation_agent.swc\"" +
            " \"${flexlib}/libs/automation_dmv.swc\"";

        private static var flex4CompileArgs:String = "-include-libraries \"../libs/{0}\"" +
            " \"${flexlib}/libs/automation/automation_spark.swc\"" +
            " \"${flexlib}/libs/automation/automation.swc\"" +
            " \"${flexlib}/libs/automation/automation_agent.swc\"" +
            " \"${flexlib}/libs/automation/automation_dmv.swc\"";

        private static var flex4AdobeAirCompileArgs:String = " \"${flexlib}/libs/automation/automation_air.swc\" " +
            "\"${flexlib}/libs/automation/automation_airspark.swc\"";

        private static var def:Array = [
            { version: "3.2", filename: "automation_monkey3.2.swc" },
            { version: "3.3", filename: "automation_monkey3.3.swc" },
            { version: "3.4", filename: "automation_monkey3.x.swc" },
            { version: "3.5", filename: "automation_monkey3.x.swc" },
            { version: "4.0", filename: "automation_monkey4.x.swc" },
            { version: "4.1", filename: "automation_monkey4.x.swc" },
			{ version: "4.5", filename: "automation_monkey4.x.swc" },
			{ version: "4.6", filename: "automation_monkey4.x.swc" },
			{ version: "4.12.1", filename: "automation_monkey4.x.swc" }];

        public static function get sdkVersions():Array {
            return def;
        }

        public static function getFilename(version:String):String {
            for (var i:int = 0; i < def.length; i++) {
                var row:Object = def[i];

                if (row.version == version) {
                    return row.filename;
                }
            }
            return null;
        }

        public static function getCompileArgs(version:String, usingAir:Boolean):String {
            if (version.indexOf("3") == 0) {
                return StringUtil.substitute(flex3CompileArgs, getFilename(version));
            }
            var arg:String = StringUtil.substitute(flex4CompileArgs, getFilename(version));

            if (usingAir) {
                arg += flex4AdobeAirCompileArgs;
            }
            return arg;
        }

    }
}