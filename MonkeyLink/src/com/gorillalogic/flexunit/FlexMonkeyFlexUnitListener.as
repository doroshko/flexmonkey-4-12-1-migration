/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexunit {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.events.RecordEvent;
    import com.gorillalogic.flexmonkey.model.RunnerModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.framework.FMHub;
    
    import org.flexunit.runner.IDescription;
    import org.flexunit.runner.Result;
    import org.flexunit.runner.notification.Failure;
    import org.flexunit.runner.notification.ITemporalRunListener;

    public class FlexMonkeyFlexUnitListener implements ITemporalRunListener {

        public var model:RunnerModel;
        public var startDesc:IDescription;
        [Bindable] public var result:Result;

        public function FlexMonkeyFlexUnitListener() {
            model = RunnerModel.instance;
        }

        public function testRunStarted(description:IDescription):void {
            model.start();
        }

        public function testRunFinished(result:Result):void {
            model.finish(result);
			if(model.wasRecording){
				FMHub.instance.dispatchEvent(new RecordEvent(RecordEvent.START_RECORDING));
			}
        }

        public function testStarted(description:IDescription):void {
            model.currentItem(getMonkeyRunnable(description));

            if (getMonkeyRunnable(description) is PauseMonkeyCommand) {
                getMonkeyRunnable(description).runState = "pausing";
            } else {
                getMonkeyRunnable(description).runState = "running";
            }
        }

        public function testFinished(description:IDescription):void {
            var r:MonkeyRunnable = getMonkeyRunnable(description);

            if (r is MonkeyNode) {
                var node:MonkeyNode = r as MonkeyNode;
                trace("finished: " + (r as MonkeyNode).name);

                var errorCount:int = 0;
                var failureCount:int = 0;
                var runTime:int = 0;

                for each (var child:MonkeyRunnable in node.children) {
                    runTime += child.runExecutionTime;

                    if (child.runState == "failure") {
                        failureCount++;
                    }

                    if (child.runState == "error") {
                        errorCount++;
                    }
                }

                if (failureCount > 0) {
                    r.runState = "failure";
                } else if (errorCount > 0) {
                    r.runState = "error";
                }

                    //r.runExecutionTime = runTime + r.runExecutionTime;
            }

            if (r.runState != "failure" && r.runState != "error") {
                r.runSuccess = true;
                r.runState = "success";
            }
			model.itemFinished(r);
        }

        public function testFailure(failure:Failure):void {
            model.errorCount++;
			var r:MonkeyRunnable = getMonkeyRunnable(failure.description);
			if (r!=null) {
            	r.runSuccess = false;
            	r.runState = "error";
            	r.runTestErrorMsg = failure.message;
			}
        }

        public function testAssumptionFailure(failure:Failure):void {
            model.failureCount++;
            getMonkeyRunnable(failure.description).runSuccess = false;
            getMonkeyRunnable(failure.description).runState = "failure";
            getMonkeyRunnable(failure.description).runTestFailureMsg = failure.message;
        }

        public function testIgnored(description:IDescription):void {
            getMonkeyRunnable(description).runState = "ignored";
        }

        public function testTimed(description:IDescription, runTime:Number):void {
			var r:MonkeyRunnable = this.getMonkeyRunnable(description);
			if (r!=null) {
            	r.runExecutionTime = runTime;
			}
        }

        private function getMonkeyRunnable(description:IDescription):MonkeyRunnable {
			if (description !=null) {
				if (description.getAllMetadata()!=null) {
					if (description.getAllMetadata().length>0) {
						return description.getAllMetadata()[0] as MonkeyRunnable;
					}
				}
			} 
			return null;
        }
    }
}
