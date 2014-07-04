/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.core {

    import com.gorillalogic.flexmonkey.core.*;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AS3FileVO;
    import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;

    import flash.events.IEventDispatcher;
    import flash.utils.Timer;

    import mx.collections.ArrayCollection;

    import org.as3commons.lang.ICloneable;

    [Bindable]
    /**
     * A MonkeyTestCase is a child element of a MonkeyTestCaseCase. Its children are executable MonkeyCommands,
     * including UIEventMonkeyCommands, PauseMonkeyCommands and VerifyMonkeyCommands.
     */
    public class MonkeyTestCase extends MonkeyNode implements ICloneable {

        private var currentTestIndex:uint;

        public function MonkeyTestCase(parent:Object = null,
                                       name:String = null,
                                       result:String = null,
                                       children:ArrayCollection = null) {
            super(null, parent, name, result, children);
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item == null || !(item is MonkeyTestCase)) {
                return false;
            } else {
                if ((item.name == this.name) &&
                    (item.description == this.description)) {
                    return true;
                }
                return false;
            }
        }


        /**
         * Returns a copy of this MonkeyTestCase.
         *
         * @return A new MonkeyTestCase with this MonkeyTestCase's name, children, and result.
         *
         */
        public function clone():* {
            var copy:MonkeyTestCase = new MonkeyTestCase();
            setParentCloneProps(copy);

            copy.children = this.children;
            copy.name = this.name;
            copy.ignore = this.ignore;
            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Case";
        }

    }
}
