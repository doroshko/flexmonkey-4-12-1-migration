/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen {

    import com.gorillalogic.flexmonkey.codeGen.generator.MonkeyTestSuiteCodeGenerator;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    
    import mx.collections.ArrayCollection;
    
    import org.as3commons.lang.util.CloneUtils;

    public class TestAS3Convertor {

        public function generateAS3(input:ArrayCollection, collector:AS3FileCollector):void {

            var count:int = 1;
 	
			//Look through all the suites, cases, and test to make sure there will be
			//no name conflicts when the code is generated.  But we need to make a copy
			//or else the names will be permenately changed if the user saves the project after 
			//generating code.			
			var cleanedInput:Array = fixupNameConflicts(input);
            for each (var testSuite:MonkeyTestSuite in cleanedInput) {
                MonkeyTestSuiteCodeGenerator.getAS3(testSuite, collector, count);
                count++;
            }

        }
		
		private function fixupNameConflicts(input:ArrayCollection):Array {
			//clone the suites
			var inputCopy:Array = CloneUtils.cloneList(input.source);			
			
			//traverse the tree of suites, cases, and tests making sure there are no conflicting names
			var testSuiteNames:Object = new Object;
			for each (var testSuite:MonkeyTestSuite in inputCopy) {
				var testSuiteName:String = testSuite.name;
				if (testSuiteNames.propertyIsEnumerable(testSuiteName)) {
					//modify the name so there are no duplicates
					testSuite.name = testSuiteName.concat(testSuiteNames[testSuiteName]++);
				} else {
					testSuiteNames[testSuiteName] = 1;
				}					
				
				//clone the test cases
				testSuite.children = new ArrayCollection(CloneUtils.cloneList(testSuite.children.source));
				var testCaseNames:Object = new Object();
				var testNames:Object = new Object();
				for each (var testCase:MonkeyTestCase in testSuite.children) {
					var testCaseName:String = testCase.name; 
					if (testCaseNames.propertyIsEnumerable(testCaseName)) {
						//modify the name so there are no duplicates
						testCase.name = testCaseName.concat(testCaseNames[testCaseName]++);
					} else {
						testCaseNames[testCaseName] = 1;
					}

					//clone the tests
					testCase.children = new ArrayCollection(CloneUtils.cloneList(testCase.children.source));
					for each (var test:MonkeyTest in testCase.children) {
						var testName:String = test.name;
						if (testNames.propertyIsEnumerable(testName)) {
							//modify the name so there are no duplicates
							test.name = testName.concat(testNames[testName]++);							
						} else {
							testNames[testName] = 1;
						}	
					}
				}
			}		
			
			return inputCopy;
		}

    }
}