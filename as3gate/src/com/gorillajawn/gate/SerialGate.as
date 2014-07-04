package com.gorillajawn.gate {

    /**
     * Extend for Serial execution
     */
    public class SerialGate extends GateAbstract {

        private var nextCommandCount:int;

        public function SerialGate() {
            super();
        }

        override public function run():void {
            register();
            nextCommandCount = 0;
            proceed();
        }

        override public function proceed(lastCmd:GateCommand = null):void {
            var nextCmd:GateCommand;

            try {
                if (commands != null && commands.length > nextCommandCount) {
                    nextCmd = getCommand(commands[nextCommandCount]);

                    nextCommandCount++;

                    nextCmd.gate = this;
                    nextCmd.execute();
                } else {
                    notifySuccess();
                }
            } catch (error:Error) {
                notifyFault(nextCmd, error.message);
            }
        }

        override public function fault(errorCmd:GateCommand = null, msg:String = null):void {
            if (proceedOnFault) {
                proceed(errorCmd);
            } else {
                notifyFault(errorCmd, msg);
            }
        }

    }
}
