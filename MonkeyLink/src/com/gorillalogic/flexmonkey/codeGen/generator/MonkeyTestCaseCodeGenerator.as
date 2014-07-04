/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
    import com.gorillalogic.utils.FMStringUtil;

    public class MonkeyTestCaseCodeGenerator {

        public static function getAS3(testCase:MonkeyTestCase,
                                      collector:AS3FileCollector,
                                      count:int,
                                      ignored:Boolean):void {

            if (!ignored) {
                ignored = testCase.ignore;
            }

            var i:uint;
            var j:uint;
            var className:String = FMStringUtil.testNameToClassName(testCase.name);
            var fileName:String = className;
            var testCasePackageName:String = collector.packageName;
            var addTests:Array = [];
            var monkeyCommandVar:String;

            // we're actually going to generate another FlexUnit Suite to represent our FM TestCase
            var suiteDefiniton:String = "\n    [Suite (order=" + count + ")]\n";
            suiteDefiniton += "    [RunWith(\"org.flexunit.runners.Suite\")]\n";
            suiteDefiniton += ("    public class " + className + " implements IFlexMonkeyTestCase {\n\n");

            var fileContents:String = "package ";
            fileContents += (testCasePackageName + " {\n\n");
            fileContents += "	import com.gorillalogic.flexunit.IFlexMonkeyTestCase\n";

            for (i = 0; i < testCase.children.length; i++) {
                var testName:String = FMStringUtil.testNameToClassName(testCase.children[i].name);
                fileContents += ("    import " + testCasePackageName + ".tests." + testName + ";\n");
                var addTestLine:String = "        public var test" + (i + 1) + ":" + testName + ";\n";
                addTests.push(addTestLine);
            }

            fileContents += suiteDefiniton;

            for (i = 0; i < addTests.length; i++) {
                fileContents += addTests[i];
            }

            fileContents += ("\n");
            fileContents += ("    }\n}");

            var fileRecord:AS3FileVO = new AS3FileVO(fileName, fileContents);
            collector.addItem(fileRecord);

            if (testCase.children.length > 0) {
                fileRecord.children = new AS3FileCollector(testCasePackageName + ".tests");

                var testCount:int = 1;

                for each (var mtest:MonkeyTest in testCase.children) {
                    MonkeyTestCodeGenerator.getAS3(mtest, fileRecord.children, testCount, ignored);
                    testCount++;
                }
            }

        }
    }
}