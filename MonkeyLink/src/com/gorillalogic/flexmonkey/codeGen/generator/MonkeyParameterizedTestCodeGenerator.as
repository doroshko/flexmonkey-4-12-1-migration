/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.codeGen.MonkeyCommandCodeGeneratorFactory;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
    import com.gorillalogic.utils.FMStringUtil;
    
    import org.as3commons.lang.StringBuffer;

    public class MonkeyParameterizedTestCodeGenerator {

        private static const iFlexMonkeyImport:String = "	import com.gorillalogic.flexunit.IFlexMonkeyTest\n";
        private static const flexUnitBaseImport:String = "    import com.gorillalogic.flexunit.FlexMonkeyFlexUnit4Base;\n";
		private static const monkeyRunnableImport:String = "    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;\n";

        public static function getAS3(test:MonkeyTest,
                                      collector:AS3FileCollector,
                                      count:int,
                                      ignored:Boolean):void {

            if (!ignored) {
                ignored = test.ignore;
            }

            var className:String = FMStringUtil.testNameToClassName(test.name);
            var fileName:String = className;

            var commandImports:Array = new Array(iFlexMonkeyImport, flexUnitBaseImport, monkeyRunnableImport);
			var commandListSetupCode:String = getCommandListSetupCode(test, commandImports, ignored);
            var testCode:String = getTestMethodCode(test, commandImports, ignored);

            commandImports.sort();
            var cmdImportStr:StringBuffer = new StringBuffer();

            for each (var commandImport:String in commandImports) {
                cmdImportStr.append(commandImport);
            }

            var fileContents:String = "package ";
            fileContents += collector.packageName + "{\n\n";

            //test code imports
            fileContents += cmdImportStr.toString();

            fileContents += "\n";

            fileContents += "	[TestCase(order=" + count + ")]";
            fileContents += "\n";
			fileContents += "	[RunWith(\"org.flexunit.runners.Parameterized\")]";
			fileContents += "\n";
            fileContents += "	public class " + className + " extends FlexMonkeyFlexUnit4Base implements IFlexMonkeyTest {\n\n";
            fileContents += "	    public function " + className + "() {\n";
            fileContents += "			super(" + test.defaultThinkTime + "); //the Flex Monkey test's defaultThinkTime\n";
            fileContents += "    	}\n\n";

            fileContents += "		[Before]\n";
            fileContents += "		public function setUp():void {\n";
            fileContents += "		}\n\n";

            //test code here
			fileContents += commandListSetupCode;
            fileContents += testCode;

            fileContents += "\n";
            fileContents += "    }\n}";

            var fileRecord:AS3FileVO = new AS3FileVO(fileName, fileContents);
            collector.addItem(fileRecord);
        }

        private static function getTestMethodCode(test:MonkeyTest,
                                                  cmdImports:Array,
                                                  ignored:Boolean):String {
            var separator:String = "\n                ";
            var testName:String = FMStringUtil.classNameToVarName(
			                FMStringUtil.testNameToClassName(test.name));

            var testMethodIndx:int = 1;
            var methodString:String = "";
			var maxTimeout:Number = -1;

            for each (var cmd:MonkeyRunnable in test.children) {
                var retryTime:int = (cmd.isRetryable) ? cmd.getAttemptsInt() * cmd.getDelayTime() : 0;
                var methodTimeout:int = retryTime + test.defaultThinkTime;

                if (cmd is PauseMonkeyCommand) {
                    methodTimeout = (cmd as PauseMonkeyCommand).duration;
                }

                methodTimeout += ProjectTestModel.instance.codeGenTimeoutPadding; // add padding
				if (methodTimeout>maxTimeout) {
					maxTimeout=methodTimeout;
				}
				testMethodIndx++;
			}
			methodTimeout=maxTimeout * test.children.length;

            methodString += "		[Test(" 
										 	+ "async"
										 	+ ", timeout=" + methodTimeout
							 				+ ", dataProvider=\"" + testName + "CommandArray\"" 
											+ ")]\n";
            methodString += "        public function " + testName + "Test(command:MonkeyRunnable):void {\n";
            methodString += "        	trace(\"Running command \" + command);\n";
            methodString += "        	runFlexMonkeyCommand(command);\n"; 
			methodString += "        }\n\n";
            return methodString;
        }
		private static function getCommandListSetupCode(test:MonkeyTest,
												  cmdImports:Array,
												  ignored:Boolean):String {
			var separator:String = "\n                ";
			var testName:String = FMStringUtil.classNameToVarName(
									FMStringUtil.testNameToClassName(test.name));
			
			var testMethodIndx:int = 1;
			var methodString:String = "";
			
			methodString =  "        public static var " + testName + "CommandArray:Array = create" + testName + "CommandArray();"
			methodString += "\n";
			methodString += "        private static function create" + testName + "CommandArray():Array {\n";
			methodString += "            var arr:Array = new Array();\n";
			methodString += "            setup" + testName + "CommandArray(arr);\n";
			methodString += "            return arr;\n";
			methodString += "        }\n\n";
			methodString += "        private static function setup" + testName + "CommandArray(arr:Array):void {\n";
			methodString += "            var theRunnable:MonkeyRunnable=null;\n";		
			
			
			for each (var cmd:MonkeyRunnable in test.children) {
				var retryTime:int = (cmd.isRetryable) ? cmd.getAttemptsInt() * cmd.getDelayTime() : 0;
				var methodTimeout:int = retryTime + test.defaultThinkTime;
				
				if (cmd is PauseMonkeyCommand) {
					methodTimeout = (cmd as PauseMonkeyCommand).duration;
				}
				
				methodTimeout += ProjectTestModel.instance.codeGenTimeoutPadding; // add padding
				
				//trace(dumpRunnable(theRunnable));
				methodString += "            ";
				if (ignored) {methodString += "/*";}
				methodString += "theRunnable=";
				methodString += MonkeyCommandCodeGeneratorFactory.generateCode(cmd, cmdImports);
				methodString += ";";
				if (ignored) {methodString += "*/";}
				methodString += "\n";
				methodString += "            ";
				if (ignored) {methodString += "//";}
				methodString += "arr.push([theRunnable]);\n";
				methodString += "\n";

				testMethodIndx++;
			}
			
			methodString += "        }\n";
			return methodString;
		}
	}
}