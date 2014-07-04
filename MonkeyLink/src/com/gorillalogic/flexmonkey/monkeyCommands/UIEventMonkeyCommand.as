/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.aqadaptor.AQAdapter;
    import com.gorillalogic.flexmonkey.core.*;
    import com.gorillalogic.utils.MonkeyAutomationManager;
    
    import flash.display.DisplayObject;
    
    import mx.automation.IAutomationObject;

    [RemoteClass]
    [Bindable]
    public class UIEventMonkeyCommand extends MonkeyRunnable {

        public var command:String;
        public var args:Array;

        // NOTE: Currently the only place we actually use non-null values for this constructor's parameters is in the generated code.
        public function UIEventMonkeyCommand(command:String = null,
                                             value:String = null,
                                             prop:String = null,
                                             args:Array = null,
                                             containerValue:String = null,
                                             containerProp:String = null,
                                             attempts:String = "10",
                                             delay:String = "1000",
                                             retryOnlyOnResponse:Boolean = false) {

            super(null, true, delay, attempts, description, value, prop, containerValue, containerProp);

            this.command = command;
            this.args = args;
            this.retryOnlyOnResponse = retryOnlyOnResponse;

            error = null;
        }

        //
        // overrides
        //

        override public function get thinkTime():uint {
            if (parent != null) {
                return MonkeyTest(parent).defaultThinkTime;
            }
            return MonkeyRunnable.DEFAULT_THINK_TIME;
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item != null &&
                (item is UIEventMonkeyCommand)) {

                if ((item.command == this.command) &&
                    (item.value == this.value) &&
                    (item.prop == this.prop) &&
                    (item.containerValue == this.containerValue) &&
                    (item.containerProp == this.containerProp)) {

                    for (var i:uint = 0; i < args.length; i++) {
                        if (item.args[i] != this.args[i]) {
                            return false;
                        }
                    }

                    return true;
                }
            }
            return false;
        }

        //
        // public api
        //

		public function get target():IAutomationObject {
			return MonkeyUtils.findComponent(containerValue, containerProp, value, prop);
		}
		
        public function run(completionHandler:Function = null, respNumber:Number = -1):void {
            if (MonkeyAutomationManager.instance.isSynchronized(null)) {

                var target:IAutomationObject = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

                if (target != null) {
                    if (MonkeyAutomationManager.instance.isSynchronized(target)) {
                        if (MonkeyAutomationManager.instance.isVisible(target as DisplayObject)) {
                            try {
                                AQAdapter.aqAdapter.run(target, command, args);
                                error = null;
                            } catch (e:Error) {
                                error = "Error: " + e.message + "\n" + e.getStackTrace();
                            }
                        } else {
                            error = "Target " + value + " not visible.\nIt could be there is another component with the same identifer elswehere in your app. You might try further qualifying the target component by specifying a container.";
                        }
                    } else {
                        error = "AutomationManager not synchronized (with target " + value + ")\n. It could be that playback is too fast for your app. You might try enabling retry attempts, adding a Pause, or increasing the Think Time.";
                    }
                } else {
                    error = "Could not find target " + value;
                }
            } else {
                error = "AutomationManager not synchronized.\n It could be that playback is too fast for your app. You might try enabling retry attempts, adding a Pause, or increasing the Think Time.";
            }

            if (completionHandler != null) {
				if(respNumber > -1){
					completionHandler(null, error, respNumber);
				} else {
                completionHandler(null, error);
				}
            }
        }

        // This code below is the bare beginnings of dealing with something besides xml
        public function commandString():String {
            return this.command + stringVal(this.value) + stringVal(this.prop) +
                stringVal(this.containerValue) + stringVal(this.containerProp);
        }

        public function argString():String {
            var val:String;
            var s:String;

            for (s in this.args) {
                val += s + " ";
            }
            return val;
        }

        private function stringVal(s:String):String {
            return (s.search(/\s/) ? '"' + s + '"' : s) + " ";
        }

        //
        // clone
        //

        public function clone():UIEventMonkeyCommand {
            var copy:UIEventMonkeyCommand = new UIEventMonkeyCommand();
            setParentCloneProps(copy);

            copy.command = this.command;
            copy.value = this.value;
            copy.prop = this.prop;
            copy.containerValue = this.containerValue;
            copy.containerProp = this.containerProp;
            copy.args = this.args.concat();
            copy.retryOnlyOnResponse = this.retryOnlyOnResponse;

            return copy;
        }

        public function dump():String {
            var msg:String = "command: " + this.command
                + "\n" + "prop: " + this.prop
                + "\n" + "value: " + this.value
                + "\n" + "containerProp: " + this.containerProp
                + "\n" + "containerValue: " + this.containerValue
                + "\n" + "args: " + this.args
                + "\n" + "parent: " + this.parent
                + "\n" + "attempts: " + this.attempts
                + "\n" + "retries: " + this.currentRetryCount
                + "\n" + "delay: " + this.delay
                + "\n" + "thinkTime: " + this.thinkTime
                + "\n" + "timeOut: " + this.timeOut
                + "\n" + "shortDescription: " + this.shortDescription
                + "\n" + "toString: " + this.toString;
            return msg;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return this.command;
        }

        override public function get labelAdditionalInfo():String {
            return args.toString();
        }

    }
}