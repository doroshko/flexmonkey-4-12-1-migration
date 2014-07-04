/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
    import com.gorillalogic.flexmonkey.codeGen.MonkeyCommandCodeGeneratorFactory;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.utils.FMStringUtil;
    
    import org.as3commons.lang.StringBuffer;

    public class MonkeyTestCodeGenerator {

		private static const iFlexMonkeyImport:String = "	import com.gorillalogic.flexunit.IFlexMonkeyTest\n";
		private static const monkeyRunnableImport:String = "    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;\n";
		private static const arrayCollectionImport:String = "    import mx.collections.ArrayCollection;\n";
		private static const defaultBaseClassName:String = "com.gorillalogic.flexunit.FlexMonkeyCustomTestBase";
		public static var baseClassName:String = defaultBaseClassName;

        public static function getAS3(test:MonkeyTest,
                                      collector:AS3FileCollector,
                                      count:int,
                                      ignored:Boolean):void {

            if (!ignored) {
                ignored = test.ignore;
            }
			
			var projectTestCaseBaseClass:String = ProjectTestModel.instance.generatedCodeTestCaseBaseClass;
			if (projectTestCaseBaseClass!=null && projectTestCaseBaseClass.length>0) {
				baseClassName = projectTestCaseBaseClass;
			} else {
				baseClassName = defaultBaseClassName;
			}
			
			var customTestBaseImport:String = "    import " + baseClassName + ";\n";

            var className:String = FMStringUtil.testNameToClassName(test.name);
            var fileName:String = className;

            var commandImports:Array = new Array(iFlexMonkeyImport, customTestBaseImport, monkeyRunnableImport, arrayCollectionImport);
			var commandListCode:String = getCommandListCode(test, commandImports, ignored);
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
            fileContents += "	public class " + className + " extends " + justTheClassNamePlease(baseClassName) + " {\n\n";
            fileContents += "	    public function " + className + "() {\n";
            fileContents += "			super()";
            fileContents += "    	}\n\n";

            fileContents += "		[Before]\n";
            fileContents += "		public function setUp():void {\n";
            fileContents += "		}\n\n";

            //test code here
			fileContents += commandListCode;
            fileContents += testCode;

            fileContents += "\n";
            fileContents += "    }\n}";

            var fileRecord:AS3FileVO = new AS3FileVO(fileName, fileContents);
            collector.addItem(fileRecord);
        }
		
		private static function justTheClassNamePlease(s:String):String {
			return s.substr(s.lastIndexOf(".")+1);
		}

		private static function getTestName(test:MonkeyTest):String {
			return FMStringUtil.classNameToVarName(getTestClassName(test));
		}
		
		private static function getTestClassName(test:MonkeyTest):String {
			return FMStringUtil.testNameToClassName(test.name);
		}
		
		private static function getTestMethodName(test:MonkeyTest):String {
			return getTestName(test) + "Test";
		}
		
        private static function getTestMethodCode(test:MonkeyTest,
                                                  cmdImports:Array,
                                                  ignored:Boolean):String {
            var separator:String = "\n                ";

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
											+ ")]\n";
            methodString += "        public function " + getTestMethodName(test) + "():void {\n";
			methodString += "        	this.monkeyTestCaseName = \"" + getTestClassName(test) + "\";\n";
			methodString += "        	this.monkeyTestName = \"" + getTestMethodName(test) + "\";\n";
            methodString += "        	trace(this.monkeyTestCaseName + \".\" + this.monkeyTestName);\n";
			methodString += "        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);\n";
			methodString += "        	var commandList:ArrayCollection = create" + getTestName(test) + "CommandList();\n"; 
            methodString += "        	runFlexMonkeyCommands(commandList, \n"; 
			methodString += "        	                      null,  // use default callback (will end test)\n"; 
			methodString += "        	                      " + test.thinkTime + "\n"; 
			methodString += "        	                     ); \n"; 
			methodString += "        }\n\n";
            return methodString;
        }
		
		private static function getCommandListCode(test:MonkeyTest,
												  cmdImports:Array,
												  ignored:Boolean):String {
			var separator:String = "\n                ";
			var testName:String = getTestName(test);
			
			var testMethodIndx:int = 1;
			var methodString:String = "";
			
			methodString += "        private function create" + testName + "CommandList():ArrayCollection {\n";
			methodString += "            var arr:ArrayCollection = new ArrayCollection();\n";
			methodString += "            setup" + testName + "CommandList(arr);\n";
			methodString += "            return arr;\n";
			methodString += "        }\n\n";
			methodString += "        private function setup" + testName + "CommandList(arr:ArrayCollection):void {\n";
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
				methodString += "arr.addItem(theRunnable);\n";
				methodString += "\n";

				testMethodIndx++;
			}
			
			methodString += "        }\n";
			return methodString;
		}
	}
}