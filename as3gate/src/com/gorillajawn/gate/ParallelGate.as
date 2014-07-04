package com.gorillajawn.gate {

    /**
     * Extend for Parellel execution
     */
    public class ParallelGate extends GateAbstract {

        private var resultsCount:int;
        public var resultsMap:Object = {};

        public function ParallelGate() {
            super();
        }

        override public function run():void {
            register();

            if (commands != null && commands.length > 0) {
                resultsCount = 0;

                for each (var cmdObj:Object in commands) {
                    var cmd:GateCommand = getCommand(cmdObj);
                    cmd.gate = this;
                    cmd.execute();
                }
            } else {
                notifySuccess();
            }
        }

        override public function proceed(lastCmd:GateCommand = null):void {
            resultsMap[lastCmd] = null;
            resultsCount++;
            checkStatus();
        }

        override public function fault(cmd:GateCommand = null, msg:String = null):void {
            if (proceedOnFault) {
                resultsMap[cmd] = msg;
                resultsCount++;
                checkStatus();
            } else {
                notifyFault(cmd, msg);
            }
        }

        private function checkStatus():void {
            if (resultsCount == commands.length) {
                notifySuccess();
            }
        }

    }
}
