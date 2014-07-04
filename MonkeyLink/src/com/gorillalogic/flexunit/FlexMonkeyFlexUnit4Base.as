/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexunit {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.IVerifyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.utils.StoredValueLookup;
    
    import flash.utils.setTimeout;

    public class FlexMonkeyFlexUnit4Base {

        public var thinkTime:int = MonkeyRunnable.DEFAULT_THINK_TIME;
        private var monkeyRunnable:MonkeyRunnable;
        private var runError:Error;

        [Rule]
        public var fmRule:FlexMonkeyFlexUnitRule = new FlexMonkeyFlexUnitRule();

        public function FlexMonkeyFlexUnit4Base(thinkTime:int = MonkeyRunnable.DEFAULT_THINK_TIME) {
            this.thinkTime = thinkTime;
        }

        protected function runFlexMonkeyCommand(r:MonkeyRunnable):void {
            monkeyRunnable = r;
            runError = null;
            run();
        }

        private function run():void {
            var isError:Boolean = false;

            try {
                if (monkeyRunnable is UIEventMonkeyCommand) {
                    runCommand(monkeyRunnable as UIEventMonkeyCommand);
                } else if (monkeyRunnable is VerifyMonkeyCommand) {
                    runVerify(monkeyRunnable as VerifyMonkeyCommand);
                } else if (monkeyRunnable is VerifyGridMonkeyCommand) {
                    runVerifyGrid(monkeyRunnable as VerifyGridMonkeyCommand);
                } else if (monkeyRunnable is VerifyPropertyMonkeyCommand) {
                    runVerifyProperty(monkeyRunnable as VerifyPropertyMonkeyCommand);
                } else if (monkeyRunnable is StoreValueMonkeyCommand) {
                    runStoreValueCommand(monkeyRunnable as StoreValueMonkeyCommand);
                } else if (monkeyRunnable is SetPropertyMonkeyCommand) {
                    runSetPropertyCommand(monkeyRunnable as SetPropertyMonkeyCommand);
                } else if (monkeyRunnable is CallFunctionMonkeyCommand) {
                    runCallFunction(monkeyRunnable as CallFunctionMonkeyCommand);
                } else if (monkeyRunnable is PauseMonkeyCommand) {
                    runPause(monkeyRunnable as PauseMonkeyCommand);
                }
            } catch (e:Error) {
                if (monkeyRunnable.isRetryAvailable) {
                    retry();
                } else {
                    isError = true;
                    runError = e;
                    finish();
                }
            }
        }

        private function runCommand(cmd:UIEventMonkeyCommand):void {
            fmRule.asyncApply(cmd.run);

            if (cmd.error != null) {
                throw new Error(cmd.error);
            }

            finish();
        }

        private function runCallFunction(cmd:CallFunctionMonkeyCommand):void {
            fmRule.asyncApply(cmd.run);

            if (cmd.error != null) {
                throw new Error(cmd.error);
            }

            finish();
        }

        private function runVerify(verify:VerifyMonkeyCommand):void {
            verifyReturn(fmRule.asyncApply(verify.loadTarget));
        }

        private function runVerifyGrid(verify:VerifyGridMonkeyCommand):void {
            verifyReturn(fmRule.asyncApply(verify.getCellValue));
        }

        private function runVerifyProperty(verify:VerifyPropertyMonkeyCommand):void {
            verifyReturn(fmRule.asyncApply(verify.getVerifyPropertyValue));
        }

        private function verifyReturn(actualValue:Object, errorMessage:String = null):void {
            if (errorMessage != null && errorMessage.length > 0) {
                throw new Error(errorMessage);
            }

            (monkeyRunnable as IVerifyCommand).verify(actualValue);
            finish();
        }

        private function runStoreValueCommand(cmd:StoreValueMonkeyCommand):void {
            fmRule.asyncApply(cmd.load);

            if (cmd.error != null) {
                throw new Error(cmd.error);
            } else {
                StoredValueLookup.instance.addCommand(cmd);
            }

            finish();
        }

        private function runSetPropertyCommand(cmd:SetPropertyMonkeyCommand):void {
            fmRule.asyncApply(cmd.run);

            if (cmd.error != null) {
                throw new Error(cmd.error);
            }

            finish();
        }

        private function runPause(pause:PauseMonkeyCommand):void {
            finish(pause.duration);
        }

        //
        // finish logic
        //

        private function finish(waitTime:int = -1):void {
            waitTime = (waitTime == -1) ? thinkTime : waitTime;
            setTimeout(fmRule.finish, waitTime, runError);
        }

        //
        // retry logic
        //

        private function retry():void {
            monkeyRunnable.currentRetryCount++;
            setTimeout(retryHandleTimerComplete, monkeyRunnable.getDelayTime());
        }

        private function retryHandleTimerComplete(data:Object = null):void {
            run()
        }

    }
}
