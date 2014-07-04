/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexunit {

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.flexunit.internals.runners.statements.FailOnTimeout;
    import org.flexunit.internals.runners.statements.IAsyncStatement;
    import org.flexunit.internals.runners.statements.MethodRuleBase;
    import org.flexunit.rules.IMethodRule;
    import org.flexunit.runners.model.FrameworkMethod;
    import org.flexunit.token.AsyncTestToken;
    import org.flexunit.token.ChildResult;

    /**
     * Basic FlexUnit Rule for FlexMonkey Code Gen Execution
     */
    public class FlexMonkeyFlexUnitRule extends MethodRuleBase implements IMethodRule {

        private var cmdFinished:Boolean = false;
        private var myError:Error;
        private var timeoutTimer:Timer;
        private var methodTimeout:String;

        /**
         * Call when command completed
         */
        public function finish(error:Error):void {
            if (!cmdFinished) {
                cmdFinished = true;

                //turn off timeout timer
                if (timeoutTimer != null) {
                    timeoutTimer.stop();
                }

                // complete test method
                super.handleStatementComplete(new ChildResult(myToken, error));
            }
        }

        /**
         * Method for async function calls in base class
         */
        public function asyncApply(func:Function, args:Array = null):* {
            if (!cmdFinished) {
                return func.apply(args);
            }

            return null;
        }

        // before next
        override public function evaluate(parentToken:AsyncTestToken):void {
            super.evaluate(parentToken);

            cmdFinished = false;

            if (methodTimeout != null) {
                timeoutTimer = new Timer(new Number(methodTimeout), 1);
                timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeoutCompleteHandler);
                timeoutTimer.start();
            } else {
                if (timeoutTimer != null) {
                    timeoutTimer.stop();
                }
                timeoutTimer = null;
            }

            this.proceedToNextStatement();
        }

        // after next
        override protected function handleStatementComplete(result:ChildResult):void {
            // handled manually outside of this method
        }

        override public function apply(base:IAsyncStatement, method:FrameworkMethod, test:Object):IAsyncStatement {
            methodTimeout = FailOnTimeout.hasTimeout(method);
            return super.apply(base, method, test);
        }

        private function timeoutCompleteHandler(event:TimerEvent):void {
            if (!cmdFinished) {
                cmdFinished = true;
                super.handleStatementComplete(new ChildResult(myToken, new Error("Test did not complete within specified timeout " + event.currentTarget.delay + "ms")));
            }
        }
    }

}
