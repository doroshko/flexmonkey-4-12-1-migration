package com.gorillajawn.gate {

    import flash.utils.getQualifiedClassName;

    /**
     * Gate Command
     *
     * Implement for each step in a given gate.
     */
    public class GateCommand {

        public var gate:GateAbstract;

        public function execute():void {
        }

        public function proceed():void {
            if (gate == null) {
                trace("Warning: Gate is null on " + getQualifiedClassName(this) + ".  Cannot proceed.");
            } else {
                gate.proceed(this);
            }
        }

        public function error(msg:String = null):void {
            if (gate == null) {
                trace("Warning: Gate is null on " + getQualifiedClassName(this) + ".  Cannot error.");
            } else {
                gate.fault(this, msg);
            }
        }

    }
}
