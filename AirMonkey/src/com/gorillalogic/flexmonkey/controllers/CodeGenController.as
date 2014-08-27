/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
    import com.gorillalogic.flexmonkey.codeGen.FlexMonkeyTestControllerCodeGen;
    import com.gorillalogic.flexmonkey.codeGen.TestAS3Convertor;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.utils.FMErrorUtil;
    import com.gorillalogic.utils.FMStringUtil;
    
    import flash.errors.IOError;
    import flash.events.Event;
    import flash.filesystem.File;
    
    import mx.controls.Alert;

    /**
     * AIR API dependencies
     */
    public class CodeGenController implements IFMController {

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var testAS3Convertor:TestAS3Convertor;
        private var generateAS3Success:Boolean;
        private var generateAS3PackageDir:String;

        public function CodeGenController() {
            testAS3Convertor = new TestAS3Convertor();
        }

        public function register(hub:FMHub):void {
            // code gen
            hub.listen(ProjectFilesEvent.GENERATE_AS3_FLEXUNIT_TESTS, saveTestFilesAsAS3, this);
			//hub.listen(ProjectFilesEvent.GENERATE_JS_TESTS, saveTestFilesAsJS, this);
        }
		
		/*
        private function saveTestFilesAsJS(event:Event):void{
			FMHub.instance.dispatchEvent(new FMAlertEvent(
				FMAlertEvent.Alert,
				"JavaScript Code Generation Finshed!" + "JavaScript tests saved MonkeyTests.js.",
				false,
				false
			));
		}
		*/
		
        private function saveTestFilesAsAS3(event:Event):void {
            var as3Files:AS3FileCollector = new AS3FileCollector(model.generatedCodeSuitesPackageName);
            testAS3Convertor.generateAS3(model.suites, as3Files);
            var package2DirPattern:RegExp = /\./g;
            var genCodeURL:String = FMFileUtils.getFullURL(model.projectUrl, model.generatedCodeUrl);
            generateAS3PackageDir = genCodeURL + "/" + as3Files.packageName.replace(package2DirPattern, "/");

            //check that output directory exists
            var dir:File = new File(genCodeURL);

            if (!dir.exists) {
                // var dirErrorMsg:String = "FlexUnit Code Generation Error:" + "Output directory does NOT exist: " + generateAS3PackageDir;
                // FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, dirErrorMsg));
				var dirErrorMsg:String;
				try {
					dir.createDirectory();
				} catch (e:IOError) {
					dirErrorMsg = "FlexUnit Code Generation Error:" + "Error attempting to create generated code directory " 
								+ "'" + generateAS3PackageDir + "': " + e.message;
					FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, dirErrorMsg));
					return;
				}
				if (!dir.exists) {
					dirErrorMsg = "FlexUnit Code Generation Error:" + "Could not create generated code directory " 
								+ "'" + generateAS3PackageDir + "'";
					FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, dirErrorMsg));
					return;
				}
            } 
			
            generateAS3Success = true;
            var testSuiteNames:Array = [];

            for each (var testSuite:AS3FileVO in as3Files.as3Files) {
                testSuiteNames.push(testSuite.fileName);
                var testSuitePackageName:String = FMStringUtil.fileNameToPackageName(testSuite.fileName);
                var testSuiteFilePath:String = generateAS3PackageDir + "/" + testSuitePackageName + "/" + testSuite.fileName + ".as";
                var testCaseDirPath:String = generateAS3PackageDir + "/" + testSuitePackageName + "/testCases/";
                var testDirPath:String = testCaseDirPath + "tests/";

                generateAS3Success = FMFileUtils.saveFile(testSuiteFilePath,
                                                          testSuite.fileContents,
                                                          as3FileWriteIOErrorHandler);

                for each (var testCase:AS3FileVO in testSuite.children.as3Files) {
                    if (!generateAS3Success) {
                        break;
                    }
                    var testCaseFilePath:String = testCaseDirPath + testCase.fileName + ".as";
                    generateAS3Success = FMFileUtils.saveFile(testCaseFilePath,
                                                              testCase.fileContents,
                                                              as3FileWriteIOErrorHandler);

                    for each (var test:AS3FileVO in testCase.children.as3Files) {
                        var testFilePath:String = testDirPath + test.fileName + ".as";
                        generateAS3Success = FMFileUtils.saveFile(testFilePath,
                                                                  test.fileContents,
                                                                  as3FileWriteIOErrorHandler);
                    }
                }

                if (generateAS3Success) {
                    generateAS3Success = FMFileUtils.saveFile(genCodeURL + "/" + "FlexMonkeyTestController.as",
                                                              FlexMonkeyTestControllerCodeGen.getAS3(as3Files.packageName, testSuiteNames),
                                                              as3FileWriteIOErrorHandler);
                }
            }

            if (generateAS3Success) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.Alert,
                                                              "FlexUnit Code Generation Finshed!",
                                                              "FlexUnit tests saved to " + generateAS3PackageDir));
            }
        }

        private function as3FileWriteIOErrorHandler(e:Object):void {
            var msg:String = FMErrorUtil.getErrorMessage(e);
            generateAS3Success = false;
            FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, msg));
        }

    }
}
