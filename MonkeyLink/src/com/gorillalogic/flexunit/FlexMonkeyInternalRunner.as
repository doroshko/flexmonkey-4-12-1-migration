/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexunit {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.model.RunnerModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    
    import mx.collections.HierarchicalData;
    
    import org.flexunit.runner.Description;
    import org.flexunit.runner.IDescription;

    /**
     * Main Internal Console Runner
     */
    public class FlexMonkeyInternalRunner extends FlexMonkeyRunnerBaseClass {

        public function FlexMonkeyInternalRunner(clazz:Class) {
            super(clazz);
        }

        /**
         * hierarchical description of tests
         */
        override public function get description():IDescription {
            if (cachedDescription == null) {
                cachedDescription = Description.createSuiteDescription("FlexMonkey Test Suite");

                for each (var item:MonkeyRunnable in RunnerModel.instance.rootTestCol) {
                    loadItems(item, cachedDescription);
                }
            }

            return cachedDescription;
        }

        private function loadItems(r:MonkeyRunnable,
                                   parentDesc:IDescription,
                                   ignore:Boolean = false):void {
            if (r is MonkeyNode) {
                var node:MonkeyNode = r as MonkeyNode;

                if (!ignore) {
                    ignore = node.ignore;
                }

                node.runIgnore = ignore;

                var nodeDesc:IDescription = Description.createSuiteDescription(node.name, [ node ]);
                parentDesc.addChild(nodeDesc);

                for each (var childItem:MonkeyRunnable in node.children) {
                    loadItems(childItem, nodeDesc, ignore);
                }

            } else {
				// it's a Command
                var runnableDesc:String;

                if (r is UIEventMonkeyCommand) {
                    runnableDesc = (r as UIEventMonkeyCommand).command;
                } else if (r is PauseMonkeyCommand) {
                    runnableDesc = "Pause";
                } else if (r is VerifyPropertyMonkeyCommand) {
                    runnableDesc = "Verify Expression";
                } else if (r is VerifyMonkeyCommand) {
                    runnableDesc = "Verify Component";
                } else if (r is VerifyGridMonkeyCommand) {
                    runnableDesc = "Verify Grid";
                } else if (r is SetPropertyMonkeyCommand) {
                    runnableDesc = "Set Property";
                } else if (r is CallFunctionMonkeyCommand) {
                    runnableDesc = "Call Function";
                } else if (r is StoreValueMonkeyCommand) {
                    runnableDesc = "Store Value";
                }

                r.runIgnore = ignore;
				var desc:IDescription = Description.createTestDescription(clazz, runnableDesc, [ r ]);

                if (parentDesc == cachedDescription) {
					// this is a top-level entry in the cachedDecription
                    var test:MonkeyTest = r.parent as MonkeyTest;

                    if (test != null) {
						// this Command is not contained in a <code>MonkeyTest</code> - it's ome kind of copy? or recorded?
						// typically this happens during a single-command execution
                        var testDesc:IDescription = Description.createSuiteDescription(test.name, [ test ]);
                        testDesc.addChild(desc);
                        testDesc = Description.createTestDescription(clazz, runnableDesc, [ r ]);
                        parentDesc.addChild(testDesc);
                    } else {
                        parentDesc.addChild(desc);
                    }
                } else {
                    parentDesc.addChild(desc);
                }
            }
        }
		
    }

}

