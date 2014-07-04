package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyUtils;
    import com.gorillalogic.utils.AttributeFinder;
    import com.gorillalogic.utils.FMPropertyUtil;
    import com.gorillalogic.utils.StoredValueLookup;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    
    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;
    import org.hamcrest.collection.hasItem;
    import org.hamcrest.core.not;
    import org.hamcrest.number.greaterThan;
    import org.hamcrest.number.lessThan;
    import org.hamcrest.text.containsString;

    [RemoteClass]
    [Bindable]
    public class VerifyPropertyMonkeyCommand extends MonkeyRunnable implements IVerifyCommand {

        public static var DEFAULT_EQUALS_TYPE:String = "equals";
        public static var NOT_EQUALS:String = "notEquals";
        public static var LESS_THAN_TYPE:String = "lessThan";
        public static var GREATER_THAN_TYPE:String = "greaterThan";
        public static var CONTAINS_TYPE:String = "contains";

        public var propertyType:String = DEFAULT_EQUALS_TYPE;
        public var propertyString:String;
        public var expectedValue:String;
        public var failureMessage:String;
        public var finalExpectedValue:Object;

        public function VerifyPropertyMonkeyCommand(description:String = null,
                                                    value:String = null,
                                                    prop:String = null,
                                                    containerValue:String = null,
                                                    containerProp:String = null,
                                                    isRetryable:Boolean = true,
                                                    delay:String = null,
                                                    attempts:String = null,
                                                    propertyString:String = "",
                                                    expectedValue:String = "",
                                                    propertyType:String = "equals") {

            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);

            this.propertyString = propertyString;
            this.expectedValue = expectedValue;
            this.propertyType = propertyType;
        }

        public function getVerifyPropertyValue(toss:Boolean=true):Object {
            var errorMessage:String;
            var actualValue:Object;

            try {
                var target:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

                if (target == null) {
                    throw new Error("Target Component Not Found");
                } else {
					try {
                    	actualValue = FMPropertyUtil.findPropertyValue(target, propertyString);
					} catch (error:Error) {
						try {
							actualValue = AttributeFinder.getStyleValue(target, propertyString);
						} catch (error:Error) {
							throw new Error("Unable to find property or style named " + propertyString);
						}
					}
                }

            } catch (error:Error) {
                errorMessage = "MonkeyLink Error: " + error.message;
				if (toss) {
					throw new Error(errorMessage);
				}
                return errorMessage;
            }

            return actualValue;
        }

        public function verify(actualValue:Object):void {
            if (finalExpectedValue == null) {
                loadFinalExpectedValue();
            }

            if (this.propertyType == NOT_EQUALS) {
                assertFalse(actualValue + " should be Not Equal to " + finalExpectedValue, actualValue == finalExpectedValue);
            } else if (this.propertyType == LESS_THAN_TYPE) {
                assertThat(actualValue, lessThan(new Number(finalExpectedValue)));
            } else if (this.propertyType == GREATER_THAN_TYPE) {
                assertThat(actualValue, greaterThan(new Number(finalExpectedValue)));
            } else if (this.propertyType == CONTAINS_TYPE) {

                if (actualValue is String) {
                    assertThat(actualValue, containsString(finalExpectedValue as String));
                } else if (actualValue is ArrayCollection) {
                    assertThat(actualValue, hasItem(finalExpectedValue));
                } else {
                    throw new Error("Unable to contains Verify Expression on selected type.");
                }
            } else {
                assertEquals(finalExpectedValue, actualValue.toString());
            }
        }
		
		// Called by FlexMonkium
		public function isTrue():Boolean {
			var actualValue:Object = getVerifyPropertyValue();
			if (finalExpectedValue == null) {
				loadFinalExpectedValue();
			}
			
			if (this.propertyType == NOT_EQUALS) {
				return actualValue != finalExpectedValue;  
			} else if (this.propertyType == LESS_THAN_TYPE) {
				return actualValue < new Number(finalExpectedValue);
			} else if (this.propertyType == GREATER_THAN_TYPE) {
				return actualValue > new Number(finalExpectedValue);
			} else if (this.propertyType == CONTAINS_TYPE) {
				
				if (actualValue is String) {
					return String(actualValue).indexOf(finalExpectedValue as String) > 0;
				} else if (actualValue is ArrayCollection) {
					return ArrayCollection(actualValue).contains(finalExpectedValue);
				} else {
					throw new Error("Unable to contains Verify Expression on selected type.");
				}
			} else {
				return finalExpectedValue == actualValue.toString();
			}
		}		

        public function loadFinalExpectedValue():void {
            finalExpectedValue = StoredValueLookup.instance.getExpectedValue(expectedValue);
        }

        override public function isEqualTo(that:Object):Boolean {
            if (that != null && that is VerifyPropertyMonkeyCommand) {
                return (
                    (this.description == that.description) &&
                    (this.value == that.value) &&
                    (this.prop == that.prop) &&
                    (this.delay == that.delay) &&
                    (this.isRetryable = that.isRetryable) &&
                    (this.attempts = that.attempts) &&
                    (this.propertyString = that.propertyString) &&
                    (this.expectedValue == that.expectedValue) &&
                    (this.containerValue == that.containerValue) &&
                    (this.containerProp == that.containerProp)
                    );
            }
            return false;
        }

        public function clone():VerifyPropertyMonkeyCommand {
            var copy:VerifyPropertyMonkeyCommand = new VerifyPropertyMonkeyCommand();
            setParentCloneProps(copy);

            copy.propertyString = this.propertyString;
            copy.expectedValue = this.expectedValue;
            copy.value = value;
            copy.prop = prop;
            copy.containerValue = containerValue;
            copy.containerProp = containerProp;
            copy.propertyType = propertyType;

            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Verify Expression";
        }

        override public function get labelAdditionalInfo():String {
            return propertyString + ' ' + propertyType + ' "' + expectedValue + '"';
        }

    }
}

