/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
    import com.gorillalogic.utils.FMStringUtil;

    public class MonkeyTestSuiteCodeGenerator {

        public static function getAS3(suite:MonkeyTestSuite, collector:AS3FileCollector, order:int):void {

            // loop over kids to get their vitals, create the fileRecord and add it to the collector,
            //  then pass the collector to each of the kids in turn...
            var i:uint;
            var className:String = FMStringUtil.testNameToClassName(suite.name);
            var fileName:String = className;
            var addTestCases:Array = [];
            var suitePackageName:String = collector.packageName + "." + FMStringUtil.fileNameToPackageName(fileName);

            var suiteDefiniton:String = "\n    [Suite(order=" + order + ")]\n";
            suiteDefiniton += "    [RunWith(\"org.flexunit.runners.Suite\")]\n";
            suiteDefiniton += ("    public class " + className + " implements IFlexMonkeyTestSuite {\n\n");

            var fileContents:String = "package ";
            fileContents += (suitePackageName + " {\n\n");
            fileContents += "	import com.gorillalogic.flexunit.IFlexMonkeyTestSuite\n";

            for (i = 0; i < suite.children.length; i++) {
                var testCaseName:String = FMStringUtil.testNameToClassName(suite.children[i].name);
                fileContents += ("    import " + suitePackageName + ".testCases." + testCaseName + ";\n");
                var addTestCaseLine:String = "        public var test" + (i + 1) + ":" + testCaseName + ";\n";
                addTestCases.push(addTestCaseLine);
            }

            fileContents += suiteDefiniton;

            for (i = 0; i < addTestCases.length; i++) {
                fileContents += addTestCases[i];
            }

            fileContents += ("\n");
            fileContents += ("    }\n}");

            var fileRecord:AS3FileVO = new AS3FileVO(fileName, fileContents);
            collector.addItem(fileRecord);

            if (suite.children.length > 0) {
                fileRecord.children = new AS3FileCollector(suitePackageName + ".testCases");

                var caseCount:int = 1;

                for each (var testCase:MonkeyTestCase in suite.children) {
                    MonkeyTestCaseCodeGenerator.getAS3(testCase, fileRecord.children, caseCount, suite.ignore);
                    caseCount++;
                }
            }

        }

    }
}