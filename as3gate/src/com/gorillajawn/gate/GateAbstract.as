package com.gorillajawn.gate {

    /**
     * Base class for Gate implementations
     */
    public class GateAbstract {

        protected var proceedOnFault:Boolean = false;
        protected var commands:Array;
        protected var timeout:int = -1;

        public var successHandler:Function;
        public var faultHandler:Function;

        protected function register():void {
            throw new Error("Please Implment in your gate implementation.");
        }

        public function fault(errorCmd:GateCommand = null, msg:String = null):void {
            throw new Error("Please Implment in your gate implementation.");
        }

        public function proceed(lastCmd:GateCommand = null):void {
            throw new Error("Please Implment in your gate implementation.");
        }

        public function run():void {
            throw new Error("Please Implment in your gate implementation.");
        }

        protected function notifyFault(errorCmd:GateCommand = null, msg:String = null):void {
            faultHandler(errorCmd, msg);
        }

        protected function notifySuccess():void {
            successHandler();
        }

        protected function getCommand(obj:Object):GateCommand {
            if (obj is Class) {
                var clz:Class = obj as Class;
                return new clz() as GateCommand;
            }
            return obj as GateCommand;
        }

    }
}
