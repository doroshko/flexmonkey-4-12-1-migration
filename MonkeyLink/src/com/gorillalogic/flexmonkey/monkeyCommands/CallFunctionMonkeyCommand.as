/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.*;
    import com.gorillalogic.utils.FMPropertyUtil;

    import mx.core.UIComponent;

    import org.as3commons.lang.StringUtils;

    [RemoteClass]
    [Bindable]
    public class CallFunctionMonkeyCommand extends MonkeyRunnable {

        public var functionName:String;
        public var args:Array; // of String

        public function CallFunctionMonkeyCommand(description:String = null,
                                                  value:String = null,
                                                  prop:String = null,
                                                  containerValue:String = null,
                                                  containerProp:String = null,
                                                  isRetryable:Boolean = true,
                                                  delay:String = null,
                                                  attempts:String = null,
                                                  functionName:String = "",
                                                  args:Array = null,
                                                  retryOnlyOnResponse:Boolean = false) {
            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);
            this.functionName = functionName;
            this.args = args || [];
            this.retryOnlyOnResponse = retryOnlyOnResponse;
        }

        public function run(completionHandler:Function = null):void {
            try {
                var targetComp:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

                if (targetComp == null) {
                    error = "Target Component Not Found";
                } else {
                    var propertyString:String = functionName;
                    var func:String = functionName
                    var obj:Object;

                    if (functionName.indexOf(".") >= 0) {
                        propertyString = StringUtils.substringBeforeLast(propertyString, ".");
                        func = StringUtils.substringAfterLast(func, ".");
                        obj = FMPropertyUtil.findPropertyValue(targetComp, propertyString);
                    } else {
                        obj = targetComp;
                    }

                    if (func.indexOf("(")) {
                        func = StringUtils.substringBefore(func, "(");
                    }

                    var f:Function = obj[func];
                    f.apply(obj, args);
                }
            } catch (e:Error) {
                error = "Error Running Function: " + e.message;
            }

            if (completionHandler != null) {
                completionHandler(this, error);
            }
        }

        //
        // overrides
        //

        override public function get thinkTime():uint {
            return MonkeyTest(parent).defaultThinkTime;
        }

        override public function isEqualTo(that:Object):Boolean {
            if (that != null && that is CallFunctionMonkeyCommand) {
                return (
                    (this.description == that.description) &&
                    (this.value == that.value) &&
                    (this.prop == that.prop) &&
                    (this.delay == that.delay) &&
                    (this.isRetryable == that.isRetryable) &&
                    (this.attempts == that.attempts) &&
                    (this.functionName == that.functionName) &&
                    (this.containerValue == that.containerValue) &&
                    (this.containerProp == that.containerProp)
                    );
            }
            return false;
        }

        override public function get typeDesc():String {
            return "Call Function";
        }

        override public function get labelDesc():String {
            return this.value + "." + this.functionName;
        }

        //
        // clones
        //

        public function clone():CallFunctionMonkeyCommand {
            var copy:CallFunctionMonkeyCommand = new CallFunctionMonkeyCommand();
            setParentCloneProps(copy);

            copy.functionName = this.functionName;
            copy.args = this.args;
            copy.value = value;
            copy.prop = prop;
            copy.containerValue = containerValue;
            copy.containerProp = containerProp;

            return copy;
        }
    }
}