/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen {

    import com.gorillalogic.utils.FMStringUtil;
	import com.gorillalogic.flexmonkey.model.ProjectTestModel;

    import mx.utils.StringUtil;

    public class FlexMonkeyTestControllerCodeGen {

        public static function getAS3(packageName:String,
                                      suiteNames:Array):String {

            var suite:String;
            var s:String = "package {";
            s += "\n";
            s += "\n";
            s += "	import com.gorillalogic.monkeylink.MonkeyLinkTestLauncher";
            s += "\n";
            s += "\n";
            s += "	import flash.display.DisplayObject;";
			s += "\n";
            s += "	import mx.events.FlexEvent;";
            s += "\n";

            for each (suite in suiteNames) {
                s += StringUtil.substitute("	import {0}.{1}.{2};", packageName, FMStringUtil.fileNameToPackageName(suite), suite);
                s += "\n";
            }

            s += "\n";
            s += "	[Mixin]";
            s += "\n";
            s += "	public class FlexMonkeyTestController {";
            s += "\n";
            s += "\n";
            // s += "		private static const antRun:Boolean = FLEXMONKEY::antRun;";
            // s += "\n";
            s += "		private static const snapshotDirectory:String = \"" + ProjectTestModel.SNAPSHOT_DIR + "\";"; // FLEXMONKEY::snapshotDirectory;";
            s += "\n";
            s += "\n";
            s += "		public static function init(root:DisplayObject):void {";
            s += "\n";
            s += "			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {";
            s += "\n";
			s += "				var suiteArray : Array = new Array();";
			s += "\n";
			
			for each (suite in suiteNames) {
				s += StringUtil.substitute("				suiteArray.push(new {0}());", suite);
				s += "\n";
			}
			s += "\n";
            s += "				MonkeyLinkTestLauncher.monkeyLinkTestLauncher.startTestLauncher(suiteArray, snapshotDirectory);";
            s += "\n";
            s += "			});";
            s += "\n";
            s += "		}";
            s += "\n";
            s += "\n";
            s += "	}";
            s += "\n";
            s += "}";
            s += "\n";

            return s;

        }

    }

}
