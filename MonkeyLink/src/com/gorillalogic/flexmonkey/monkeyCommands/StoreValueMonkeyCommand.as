package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyUtils;
    import com.gorillalogic.utils.FMPropertyUtil;

    import mx.core.UIComponent;

    [RemoteClass]
    [Bindable]
    public class StoreValueMonkeyCommand extends MonkeyRunnable {

        public var keyName:String;
        public var propertyString:String;

        public var runtimeValue:Object;
        public var isValueLoaded:Boolean = false;

        public function StoreValueMonkeyCommand(description:String = null,
                                                value:String = null,
                                                prop:String = null,
                                                containerValue:String = null,
                                                containerProp:String = null,
                                                isRetryable:Boolean = true,
                                                delay:String = null,
                                                attempts:String = null,
                                                propertyString:String = "",
                                                keyName:String = "") {

            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);

            this.keyName = keyName;
            this.propertyString = propertyString;
        }

        public function load(completionHandler:Function = null):void {
            try {
                var targetComp:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

                if (targetComp == null) {
                    error = "Target Component Not Found";
                } else {
                    runtimeValue = FMPropertyUtil.findPropertyValue(targetComp, propertyString);

                    if (runtimeValue == null) {
                        error = "NULL value returned for: " + propertyString;
                    }
                }
            } catch (e:Error) {
                error = "MonkeyLink Error: " + e.message;
            }


            if (completionHandler != null) {
                completionHandler(this, runtimeValue, error);
            }
        }

        public function setValue(actualValue:Object):void {
            this.runtimeValue = actualValue;
            this.isValueLoaded = true;
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
                    (this.keyName == that.keyName) &&
                    (this.containerValue == that.containerValue) &&
                    (this.containerProp == that.containerProp)
                    );
            }
            return false;
        }

        public function clone():StoreValueMonkeyCommand {
            var copy:StoreValueMonkeyCommand = new StoreValueMonkeyCommand();
            setParentCloneProps(copy);

            copy.propertyString = this.propertyString;
            copy.keyName = this.keyName;
            copy.value = value;
            copy.prop = prop;
            copy.containerValue = containerValue;
            copy.containerProp = containerProp;

            return copy;
        }


        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Store Value";
        }

        override public function get labelDesc():String {
            return keyName + ': "' + propertyString + '"';
        }


    }
}