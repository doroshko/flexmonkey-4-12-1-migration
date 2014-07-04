/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.core {

    import flash.events.IEventDispatcher;
    import flash.utils.Timer;

    import mx.collections.ArrayCollection;

    import org.as3commons.lang.ICloneable;

    [Bindable]
    /**
     * A MonkeyTest is a child element of a MonkeyTestCase. Its children are executable MonkeyCommands,
     * including UIEventMonkeyCommands, PauseMonkeyCommands and VerifyMonkeyCommands.
     */
    public class MonkeyTest extends MonkeyNode implements ICloneable {

        public var defaultThinkTime:uint;

        public function MonkeyTest(name:String = null,
                                   defaultThinkTime:uint = MonkeyRunnable.DEFAULT_THINK_TIME,
                                   children:ArrayCollection = null) {
            super(null, null, name, null, children);

            this.defaultThinkTime = defaultThinkTime;

            if (children != null) {
                for (var i:int = 0; i < children.length; i++) {
                    var child:MonkeyRunnable = MonkeyRunnable(children.getItemAt(i));
                    child.parent = this;
                }
            }
        }

        public function get timeoutTime():uint {
            var total:uint = 0;

            for (var i:uint = 0; i < children.length; i++) {
                var c:MonkeyRunnable = children[i] as MonkeyRunnable;
                var timePadding:int = 0;

                if (c.isRetryable) {
                    timePadding = c.getAttemptsInt() * c.getDelayTime();
                }
                total += c.thinkTime + timePadding;
            }
            return total;
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item == null || !(item is MonkeyTest)) {
                return false;
            } else {
                if ((item.name == this.name) &&
                    (item.description == this.description)) {
                    //&&
                    //(item.defaultThinkTime == this.defaultThinkTime)) {
                    return true;
                }
                return false;
            }
        }

        /**
         * Returns a copy of this MonkeyTest.
         *
         * @return A new MonkeyTest with this MonkeyTest's name, children, and result.
         */
        public function clone():* {
            var copy:MonkeyTest = new MonkeyTest();
            setParentCloneProps(copy);

            copy.children = this.children;
            copy.name = this.name;
            copy.defaultThinkTime = this.defaultThinkTime;
            copy.ignore = this.ignore;
            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Test";
        }
		
		override public function get thinkTime():uint {
			return defaultThinkTime;
		}

    }
}
