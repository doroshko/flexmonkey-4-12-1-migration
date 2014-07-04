/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.core {

    import com.gorillalogic.flexmonkey.vo.SnapshotVO;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import mx.events.PropertyChangeEvent;

    [Bindable]
    public class MonkeyRunnable extends EventDispatcher {

		public static const DEFAULT_THINK_TIME:int = 250;
        public static const DEFAULT_DELAY:int = 500;
        public static const DEFAULT_ATTEMPTS:int = 20;

        public function get runState():String {
            return _runState;
        }

        public function set runState(value:String):void {
            _runState = value;

            if (_runState == "none") {
                runSuccess = false;
                runTestFailureMsg = null;
                runTestErrorMsg = null;
                runExecutionTime = 0;
            }
        }

        //
        // run state props
        //

        private var _runState:String = "none";
        public var runSuccess:Boolean;
        public var runTestFailureMsg:String;
        public var runTestErrorMsg:String;
        public var runTestConsoleMsg:String;
        public var runExecutionTime:int;
        public var runActualSnapshot:SnapshotVO;
        public var runNestedCount:int;
        public var runnerQueuePos:int;

        public var runCompleted:Boolean;
        public var nextTick:uint;
        public var runIgnore:Boolean = false;

        //
        // share props
        //

        public var description:String;
        public var parent:Object;
        public var value:String;
        public var _prop:String;
        public var containerValue:String;
        public var containerProp:String;

        public var retryOnlyOnResponse:Boolean = false;
        public var currentlyRetrying:Boolean;
        public var currentRetryCount:int;
        private var _delay:Number = DEFAULT_DELAY;
        private var _attempts:Number = DEFAULT_ATTEMPTS;
        private var _timeOut:String;
        private var _isRetryable:Boolean = true;

        public var startItemRendererExpanded:Boolean = false;

        public var error:String;

        public function MonkeyRunnable(target:IEventDispatcher = null,
                                       isRetryable:Boolean = true,
                                       delay:String = null,
                                       attempts:String = null,
                                       description:String = null,
                                       value:String = null,
                                       prop:String = null,
                                       containerValue:String = null,
                                       containerProp:String = null) {
            super(target);

            currentRetryCount = 0;
            this.isRetryable = isRetryable;
            this.description = description;
            this.value = value;
            this.prop = prop;
            this.containerValue = containerValue;
            this.containerProp = containerProp;

            if (isRetryable) {
                if (delay) {
                    this.delay = delay;
                } else {
                    this._delay = DEFAULT_DELAY;
                }

                if (attempts) {
                    this.attempts = attempts;
                } else {
                    this._attempts = DEFAULT_ATTEMPTS;
                }
            } else {
                this._delay = 0;
                this._attempts = 1;
            }
            setTimeOut();

            this.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler);
        }

        private function propertyChangeHandler(event:Event):void {
            this.dispatchEvent(new Event("updateRunnableLabel"));
        }

        public function get isRetryAvailable():Boolean {
            if (isRetryable && currentRetryCount < getAttemptsInt()) {
                return true;
            }
            return false;
        }
		
		public function set prop(val:String):void {
			this._prop = val;
		}
		
		public function get prop():String {
			return _prop ? _prop : "automationName";
		}		

        public function isEqualTo(item:Object):Boolean {
            return false;
        }

        public function get thinkTime():uint {
            return MonkeyRunnable.DEFAULT_THINK_TIME;
        }

        public function get shortDescription():String {
			if (this.description!=null && this.description.length>0) {
				return this.description;
			}
			return typeDesc + ": "  + labelDesc; 
        }

        //
        // properties
        //

        /**
         * The execute timer's delay between attempts.
         */
        public function get delay():String {
            return _delay.toString();
        }

        public function set delay(val:String):void {
            var __delay:Number = parseInt(val);

            if (!isNaN(__delay) && __delay >= 0) {
                _delay = __delay;
                setTimeOut();
            }
        }

        public function getDelayTime():int {
            return parseInt(delay);
        }

        /**
         * The number of times the command will be tried unless isPause is true.
         */
        public function get attempts():String {
            return _attempts.toString();
        }

        public function set attempts(val:String):void {
            var __attempts:Number = parseInt(val);

            if (!isNaN(__attempts) && __attempts >= 0) {
                _attempts = __attempts;
                setTimeOut();
            }
        }

        public function getAttemptsInt():int {
            return parseInt(attempts);
        }

        [Bindable("timeOutChanged")] public function get timeOut():String {
            return _timeOut;
        }

        private function setTimeOut():void {
            _timeOut = (this._attempts * this._delay).toString();
            dispatchEvent(new Event("timeOutChanged"));
        }

        public function get isRetryable():Boolean {
            return _isRetryable;
        }

        public function set isRetryable(val:Boolean):void {
            _isRetryable = val;
            setTimeOut();
        }

        //
        // clone utils
        //

        protected function setParentCloneProps(copy:MonkeyRunnable):void {
            copy.description = description;
            copy.attempts = attempts;
            copy.delay = delay;
            copy.isRetryable = isRetryable;
            copy.currentRetryCount = currentRetryCount;
            copy.parent = parent;
        }

        public function getLabel(includeDesc:Boolean = true):String {
            //create label
            var text:String = "";

            if (includeDesc) {
                text = typeDesc;
            }

            var labelValue:String = labelDesc;
            var additionalInfo:String = labelAdditionalInfo;

            if (labelValue != null) {
                if (includeDesc) {
                    text = text + ": '" + labelValue + "'";
                } else {
                    text = labelValue;
                }
            }

            if (additionalInfo != null && additionalInfo.length > 0) {
                if (includeDesc) {
                    text += " (" + additionalInfo + ")";
                } else {
                    text += ": " + additionalInfo;
                }
            }
            return text;
        }

        public function get typeDesc():String {
            throw new Error("Please implement typeDesc for MonkeyRunnable");
        }

        public function get labelDesc():String {
            return this.value;
        }

        public function get labelAdditionalInfo():String {
            return "";
        }

		override public function toString():String {
			return this.shortDescription;
		}
		
   }
}