package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyUtils;
    import com.gorillalogic.utils.FMPropertyUtil;
    import com.gorillalogic.utils.StoredValueLookup;

    import mx.core.UIComponent;

    [RemoteClass]
    [Bindable]
    public class SetPropertyMonkeyCommand extends MonkeyRunnable {

        public var propertyString:String;
        public var setToValue:String;
        public var failureMessage:String;
        public var finalSetToValue:String;

        public function SetPropertyMonkeyCommand(description:String = null,
                                                 value:String = null,
                                                 prop:String = null,
                                                 containerValue:String = null,
                                                 containerProp:String = null,
                                                 isRetryable:Boolean = true,
                                                 delay:String = null,
                                                 attempts:String = null,
                                                 propertyString:String = "",
                                                 setToValue:String = "") {

            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);

            this.propertyString = propertyString;
            this.setToValue = setToValue;
        }

        public function run(completionHandler:Function = null):void {
            if (finalSetToValue == null) {
                loadFinalSetToValue();
            }

            try {
                var targetComp:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

                if (targetComp == null) {
                    error = "Target Component Not Found";
                } else {
                    var updateError:String = FMPropertyUtil.updatePropertyValue(targetComp, propertyString, finalSetToValue);

                    if (updateError != null && updateError.length > 0) {
                        error = "Failed to set property: '" + propertyString + "' to: '" + finalSetToValue + "' -- " + updateError;
                    }
                }
            } catch (e:Error) {
                error = "MonkeyLink Error: " + e.message;
            }

            if (completionHandler != null) {
                completionHandler(this, error);
            }
        }

        public function loadFinalSetToValue():void {
            var v:Object = StoredValueLookup.instance.getExpectedValue(setToValue);

            if (v != null) {
                finalSetToValue = v.toString();
            }
        }

        override public function isEqualTo(that:Object):Boolean {
            if (that != null && that is SetPropertyMonkeyCommand) {
                return (
                    (this.description == that.description) &&
                    (this.value == that.value) &&
                    (this.prop == that.prop) &&
                    (this.delay == that.delay) &&
                    (this.isRetryable = that.isRetryable) &&
                    (this.attempts = that.attempts) &&
                    (this.propertyString = that.propertyString) &&
                    (this.setToValue == that.setToValue) &&
                    (this.containerValue == that.containerValue) &&
                    (this.containerProp == that.containerProp)
                    );
            }
            return false;
        }

        public function clone():SetPropertyMonkeyCommand {
            var copy:SetPropertyMonkeyCommand = new SetPropertyMonkeyCommand();
            setParentCloneProps(copy);

            copy.propertyString = this.propertyString;
            copy.setToValue = this.setToValue;
            copy.value = value;
            copy.prop = prop;
            copy.containerValue = containerValue;
            copy.containerProp = containerProp;
            copy.finalSetToValue = finalSetToValue;

            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Set Property";
        }

        override public function get labelAdditionalInfo():String {
            return propertyString + ': "' + setToValue + '"';
        }

    }
}