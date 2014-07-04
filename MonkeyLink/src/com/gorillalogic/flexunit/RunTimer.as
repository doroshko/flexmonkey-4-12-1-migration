package com.gorillalogic.flexunit {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;

    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getQualifiedClassName;

    import mx.binding.utils.ChangeWatcher;

    public class RunTimer extends Timer {

        private var cmd:MonkeyRunnable;

        private var retryFunc:Function;
        private var runCommandFunc:Function;
        private var finishFunc:Function;

        private var thinkTime:uint = MonkeyRunnable.DEFAULT_THINK_TIME;

        public function RunTimer(cmd:MonkeyRunnable,
                                 runCommandFunc:Function,
                                 finishFunc:Function,
                                 retryFunc:Function) {

            super(1, 0);

            this.cmd = cmd;
            this.retryFunc = retryFunc;
            this.runCommandFunc = runCommandFunc;
            this.finishFunc = finishFunc;

            addEventListener(TimerEvent.TIMER, timerRunning, false, 1, true);
        }

        private function timerRunning(event:Event):void {
            var currentTime:uint = new Date().time;

            runCommandFunc();

            if (currentTime > cmd.nextTick
                && !cmd.runCompleted
                && (!cmd.retryOnlyOnResponse)) {
                if (cmd.isRetryAvailable) {
                    retryFunc();
                } else {
                    finishFunc((!(cmd is PauseMonkeyCommand)) ? "Timeout: exhausted attempts without success" : null);
                }
            }

        }
    }
}