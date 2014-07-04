/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.events.FMRunnerEvent;
    import com.gorillalogic.flexmonkey.events.RecordEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.model.RunnerModel;
    import com.gorillalogic.flexunit.FlexMonkeyConnectionRunner;
    import com.gorillalogic.flexunit.FlexMonkeyConnectionRunnerTest;
    import com.gorillalogic.flexunit.FlexMonkeyFlexUnitListener;
    import com.gorillalogic.flexunit.FlexMonkeyInternalRunner;
    import com.gorillalogic.flexunit.FlexMonkeyInternalRunnerTest;
    import com.gorillalogic.flexunit.FlexMonkeyNestedRunner;
    import com.gorillalogic.flexunit.FlexMonkeyNestedRunnerTest;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    
    import org.flexunit.runner.FlexUnitCore;

    public class TestRunnerController implements IFMController {

        private var model:RunnerModel;
        private var testModel:ProjectTestModel;
        private var core:FlexUnitCore;

        public function register(hub:FMHub):void {
            var runner:FlexMonkeyInternalRunner; //here to force flex to compile it in...

            model = RunnerModel.instance;
            testModel = ProjectTestModel.instance;

            hub.listen(FMRunnerEvent.SETUP_TEST_RUNNER, launchConnectionTestRunner, this);
			hub.listen(FMRunnerEvent.SETUP_NESTED_TEST_RUNNER, launchNestedTestRunner, this);
            hub.listen(FMRunnerEvent.START_RUNNER, startTestRunner, this);
            hub.listen(FMRunnerEvent.ABORT_RUNNER, abortTestRunner, this);
            hub.listen(FMRunnerEvent.CLEAR_RUNNER_RESULTS, clearTestResults, this);
        }

		private function launchConnectionTestRunner(event:FMRunnerEvent):void {
			model.runnerClazz=FlexMonkeyConnectionRunner;
			model.testClazz=FlexMonkeyConnectionRunnerTest;
			launchTestRunner(event);
		}
		private function launchNestedTestRunner(event:FMRunnerEvent):void {
			model.runnerClazz=FlexMonkeyNestedRunner;
			model.testClazz=FlexMonkeyNestedRunnerTest;
			launchTestRunner(event);
		}
        private function launchTestRunner(event:FMRunnerEvent):void {
            if (ApplicationModel.instance.isRecording) {
                model.wasRecording = true;
                FMHub.instance.dispatchEvent(new RecordEvent(RecordEvent.STOP_RECORDING));
            }

            if (event.isPlayRecordItems) {
                model.setRunnerItems(testModel.recordItems, "Current Record Items");
            } else {
                var item:MonkeyRunnable = event.item;

                if (item != null) {
                    model.setRunnerItem(item);
                } else {
                    model.setRunnerItems(testModel.suites, "All Tests");
                }
            }

            if (ApplicationModel.instance.isConnected) {
                FMHub.instance.dispatchEvent(new FMRunnerEvent(FMRunnerEvent.START_RUNNER, 
																event.item, 
																event.isPlayRecordItems));
            }
        }

        private function startTestRunner(event:FMRunnerEvent):void {
            if (!model.isRunning) {
                model.clearResults();
                model.clearItemResults();

                core = new FlexUnitCore();
                core.addListener(new FlexMonkeyFlexUnitListener());
                core.run(model.testClazz);
            }
        }

        private function abortTestRunner(event:FMRunnerEvent):void {
            if (model.isRunning) {
                core.pleaseStop();
                model.isRunning = false;
            }
        }

        private function clearTestResults(event:FMRunnerEvent):void {
            if (!model.isRunning) {
                model.clearResults();
                model.clearItemResults();
            }
        }

    }

}
