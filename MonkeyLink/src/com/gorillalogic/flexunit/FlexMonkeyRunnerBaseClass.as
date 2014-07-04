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
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.IVerifyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    
    import flash.utils.Timer;
    import flash.utils.setTimeout;
    
    import flexunit.framework.AssertionFailedError;
    
    import org.flexunit.runner.IDescription;
    import org.flexunit.runner.IRunner;
    import org.flexunit.runner.notification.Failure;
    import org.flexunit.runner.notification.IRunNotifier;
    import org.flexunit.token.IAsyncTestToken;
    import org.hamcrest.AssertionError;

    /**
     * Base runner class for running in IDE or AIR Console
     */
    public class FlexMonkeyRunnerBaseClass implements IRunner {

        protected var clazz:Class;
        protected var cachedDescription:IDescription;

		protected var currentCommand:MonkeyRunnable;
        private var isCommandRunning:Boolean = false;

        private var notifier:IRunNotifier;
        private var token:IAsyncTestToken;

        private var timer:Timer;

        private var queue:Array
        private var queuePos:int

        private var currentTest:MonkeyTest;
        private var currentSuiteDesc:IDescription;
        private var currentCaseDesc:IDescription;
        private var currentTestDesc:IDescription;
        private var currentRunnableDesc:IDescription;

		public var doTrace:Boolean = false;
		
        public function FlexMonkeyRunnerBaseClass(clazz:Class) {
            this.clazz = clazz;
        }

        /**
         * run method implementation
         *
         * builds a simple queue from the description hierarchy built in the description function
         * and then runs the queue retrying commands and verifies and needed
         */
        public function run(notifier:IRunNotifier, previousToken:IAsyncTestToken):void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.run()");
			}
            this.notifier = notifier;
            this.token = previousToken;

            notifier.fireTestRunStarted(description);
            queue = [];
            buildQueue(description, queue);
            queuePos = 0;
            runNext();
        }

        /**
         * buildQueue crawls through the desc tree to add all items to the queue
         */
        private function buildQueue(desc:IDescription, queue:Array):void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.buildQueue");			
			}
            queue.push(desc);

            if (desc.getAllMetadata() != null && desc.getAllMetadata().length > 0) {
                (desc.getAllMetadata()[0] as MonkeyRunnable).runnerQueuePos = queue.length - 1;
            }

            if (desc.children != null && desc.children.length > 0) {
                for each (var childDesc:IDescription in desc.children) {
                    buildQueue(childDesc, queue);
                }
            }
        }

        /**
         * runNext moves through the queue until it is out of items
         */
        private function runNext():void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.runNext: queuePos=" + queuePos + ", queue.length=" + queue.length);			
			}			
            if (queuePos < queue.length) {
                var desc:IDescription = queue[queuePos] as IDescription;
                var data:Object = {};

                if (desc.getAllMetadata() != null && desc.getAllMetadata().length > 0) {
                    data = desc.getAllMetadata()[0];
                } else {
                    queuePos++;
                    runNext();
                    return;
                }

                if (data is MonkeyNode) {
                    currentRunnableDesc = null;

                    if (data is MonkeyTest) {
                        if (currentTestDesc != null) {
                            if (currentTest.runIgnore) {
                                notifier.fireTestIgnored(currentTestDesc);
                            } else {
                                notifier.fireTestFinished(currentTestDesc);
                            }
                        }

                        currentTestDesc = desc;
                        notifier.fireTestStarted(currentTestDesc);
                        currentTest = data as MonkeyTest;
                    } else if (data is MonkeyTestCase) {
                        if (currentCaseDesc != null) {
                            if ((currentCaseDesc.getAllMetadata()[0] as MonkeyTestCase).runIgnore) {
                                notifier.fireTestIgnored(currentCaseDesc);
                            } else {
                                notifier.fireTestFinished(currentCaseDesc);
                            }
                        }

                        currentCaseDesc = desc;
                        notifier.fireTestStarted(currentCaseDesc);
                    } else if (data is MonkeyTestSuite) {
                        if (currentSuiteDesc != null) {
                            if ((currentSuiteDesc.getAllMetadata()[0] as MonkeyTestSuite).runIgnore) {
                                notifier.fireTestIgnored(currentSuiteDesc);
                            } else {
                                notifier.fireTestFinished(currentSuiteDesc);
                            }
                        }

                        currentSuiteDesc = desc;
                        notifier.fireTestStarted(currentSuiteDesc);
                    }
					if (doTrace) {
						trace("FlexMonkeyRunnerBase incrementing queuePos");			
					}			
                    queuePos++;
                    runNext();
                } else {
                    currentRunnableDesc = desc;
					if (doTrace) {
						trace("FlexMonkeyRunnerBase.runNext: command found: " + desc);			
					}			

                    try {
                        currentCommand = currentRunnableDesc.getAllMetadata()[0] as MonkeyRunnable;
                        currentCommand.runTestConsoleMsg = "Starting command";
                        currentCommand.runCompleted = false;

                        if (currentCommand is StoreValueMonkeyCommand) {
                            (currentCommand as StoreValueMonkeyCommand).isValueLoaded = false;
                        }

                        timer = new RunTimer(currentCommand, runCommandTimer, finishTimer, retryCommand);
                        isCommandRunning = false;
                        timer.reset();
                        timer.start();
                    } catch (error:Error) {
                        currentCommand.runTestConsoleMsg += "\nError: " + error.message;
                        currentCommand.runTestConsoleMsg += "\n" + error.getStackTrace();
                        notifier.fireTestFailure(new Failure(currentRunnableDesc, error));
                    }
                }
            } else {
                if (currentTestDesc != null) {
                    if (currentTest.runIgnore) {
                        notifier.fireTestIgnored(currentTestDesc);
                    } else {
                        notifier.fireTestFinished(currentTestDesc);
                    }
                }

                if (currentCaseDesc != null) {
                    if ((currentCaseDesc.getAllMetadata()[0] as MonkeyTestCase).runIgnore) {
                        notifier.fireTestIgnored(currentCaseDesc);
                    } else {
                        notifier.fireTestFinished(currentCaseDesc);
                    }
                }

                if (currentSuiteDesc != null) {
                    if ((currentSuiteDesc.getAllMetadata()[0] as MonkeyTestSuite).runIgnore) {
                        notifier.fireTestIgnored(currentSuiteDesc);
                    } else {
                        notifier.fireTestFinished(currentSuiteDesc);
                    }
                }

                finishCommand(true);

                //Notify the framework testing is complete, passing the token back.
				if (doTrace) {
					trace("FlexMonkeyRunnerBase token.sendResult()");			
				}			
                token.sendResult();
            }
        }

        /**
         * main run timer to see if there is a new command ready to run from the queue
         */
        private function runCommandTimer():void {
            if (queuePos >= queue.length) {
                runNext();
            } else if (currentRunnableDesc != null) {
                if (!isCommandRunning) {
                    notifier.fireTestStarted(currentRunnableDesc);
                    isCommandRunning = true;
                    currentCommand = currentRunnableDesc.getAllMetadata()[0] as MonkeyRunnable;

                    if (currentCommand is PauseMonkeyCommand) {
                        currentCommand.nextTick = new Date().time + uint((currentCommand as PauseMonkeyCommand).getPauseTime());
                    } else {
                        currentCommand.nextTick = new Date().time + uint(currentCommand.getDelayTime());
                    }

                    runCommand();
                }
            }
        }

        /**
         * runs the selected command and assigns async handlers for processing results
         */
        protected function runCommand():void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.runCommand, currentCommand= \"" + currentCommand + "\"");			
			}			
        }

        /**
         * Handler store value returns
         */
		protected function storeValueReturn(commandProvided:MonkeyRunnable, actualValue:Object, errorMessage:String = null):void {
            if (queuePos == currentCommand.runnerQueuePos &&
                commandProvided == currentCommand) {

                if (checkErrorMessage(errorMessage, currentCommand, currentRunnableDesc)) {
                    var storeValueCommand:StoreValueMonkeyCommand = currentCommand as StoreValueMonkeyCommand;
                    storeValueCommand.setValue(actualValue);
                    printErrorToConsole(storeValueCommand, "Loaded value: " + storeValueCommand.runtimeValue.toString());
                    finishCommand();
                }
            }
        }

        /**
         * Handler command returns
         */
        protected function commandReturn(commandProvided:MonkeyRunnable, errorMessage:String = null):void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.commandReturn");			
			}			
            if (queuePos == currentCommand.runnerQueuePos &&
                commandProvided == currentCommand) {

                if (checkErrorMessage(errorMessage, currentCommand, currentRunnableDesc)) {
                    finishCommand();
                } else if (currentCommand is UIEventMonkeyCommand && (currentCommand as UIEventMonkeyCommand).retryOnlyOnResponse) {
                    retryCommand();
                }
            }
        }

        /**
         * Handler for verifies returning
         */
		protected function verifyReturn(actualValue:Object, commandProvided:MonkeyRunnable, errorMessage:String = null):void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.verifyReturn");			
			}			
            if (queuePos == currentCommand.runnerQueuePos &&
                currentCommand is IVerifyCommand &&
                commandProvided == currentCommand) {

                var verify:IVerifyCommand = currentCommand as IVerifyCommand;

                if (checkErrorMessage(errorMessage, currentCommand, currentRunnableDesc)) {
                    try {
                        verify.verify(actualValue);
                        finishCommand();
                    } catch (e:Error) {
                        printErrorToConsole(verify as MonkeyRunnable, e.message);

                        if (!(e is AssertionFailedError) && !(e is AssertionError)) {
                            currentCommand.runTestConsoleMsg += "\n" + e.getStackTrace();
                        }

                        if (!currentCommand.isRetryAvailable) {
                            if (e is AssertionFailedError) {
                                notifier.fireTestAssumptionFailed(new Failure(currentRunnableDesc, e));
                            } else {
                                notifier.fireTestFailure(new Failure(currentRunnableDesc, e));
                            }

                            finishCommand();
                        }
                    }
                }
            }
        }

        /**
         * Setup the next retry after the given delay time for the current command
         */
        private function retryCommand():void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.retryCommand");			
			}			
            currentCommand.currentRetryCount++;
            currentCommand.currentlyRetrying = true;
            currentCommand.runTestConsoleMsg += "\nRetrying: " + currentCommand.currentRetryCount;
            currentCommand.nextTick = new Date().time + currentCommand.getDelayTime();
            runCommand();
        }

        /**
         * complete timer run and report any error message
         */
        private function finishTimer(errorMessage:String):void {
            if (errorMessage) {
                printErrorToConsole(currentCommand, errorMessage);
                notifyError(currentCommand, errorMessage, currentRunnableDesc);
            }
            finishCommand();
        }

        /**
         * Finishes a command run and cleans up
         */
		protected function finishCommand(finalCmd:Boolean = false, ignored:Boolean = false):void {
			if (doTrace) {
				trace("FlexMonkeyRunnerBase.finishCommand");			
			}			
            if (timer != null) {
                timer.stop();
            }

            currentCommand.runCompleted = true;
            currentCommand.currentRetryCount = 0;
            currentCommand.currentlyRetrying = false;
            isCommandRunning = false;

            if (!finalCmd) {
                currentCommand.runTestConsoleMsg += "\nDone running";

                if (ignored) {
                    notifier.fireTestIgnored(currentRunnableDesc);
                } else {
                    notifier.fireTestFinished(currentRunnableDesc);
                }
                queuePos++;

                if (!(currentCommand is MonkeyNode) && queuePos < queue.length) {
                    setTimeout(runNext, getThinkTime());
                } else {
                    runNext();
                }
            }
        }

        private function getThinkTime():int {
            var t:int = MonkeyRunnable.DEFAULT_THINK_TIME;

            if (currentTest != null) {
                t = currentTest.defaultThinkTime;
            }

            return t;
        }

        /**
         * Checks for returning error message string
         * returns true if error check is clean (i.e. no error message)
         */
        private function checkErrorMessage(errorMessage:String, cmd:MonkeyRunnable, desc:IDescription):Boolean {
            if (errorMessage != null || cmd.error != null) {
                printErrorToConsole(cmd, errorMessage);

                if (!cmd.isRetryAvailable) {
                    notifyError(cmd, errorMessage, desc);
                    finishCommand();
                }

                return false;
            }
            return true;
        }

        /**
         * Print error message to console
         */
        private function printErrorToConsole(cmd:MonkeyRunnable, errorMessage:String):void {
            if (errorMessage != null) {
                cmd.runTestConsoleMsg += "\n" + errorMessage;
            } else {
                cmd.runTestConsoleMsg += "\n" + cmd.error;
            }
        }

        /**
         * Notify FlexUnit of error message
         */
        private function notifyError(cmd:MonkeyRunnable, errorMessage:String, desc:IDescription):void {
            if (errorMessage != null) {
                notifier.fireTestFailure(new Failure(desc, new Error(errorMessage)));
            } else {
                notifier.fireTestFailure(new Failure(desc, new Error(cmd.error)));
            }

        }

        /**
         * Abstract: Please override with runner specific implementation
         */
        public function get description():IDescription {
            throw new Error("Please implement your own description method");
        }

        /**
         * pleaseStop implementation cleans stops run and retry timers
         */
        public function pleaseStop():void {
			if (!currentCommand.runCompleted) {
				this.finishCommand();
			}
            if (timer != null && timer.running) {
                timer.stop();
            }
			this.queuePos = this.queue.length;
			runNext();
        }

    }
}
