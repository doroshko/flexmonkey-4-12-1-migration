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
     * A MonkeyTestSuite is a top-level test containter.  It contains other MonkeyTestSuites, as well as
     * MonkeyTestCases.
     */
    public class MonkeyTestSuite extends MonkeyNode implements ICloneable {

        private var currentCaseIndex:uint;

        public function MonkeyTestSuite(parent:Object = null,
                                        name:String = null,
                                        result:String = null,
                                        children:ArrayCollection = null) {
            super(null, parent, name, result, children);
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item == null || !(item is MonkeyTestSuite)) {
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
         * Returns a copy of this MonkeyTestSuite.
         *
         * @return A new MonkeyTestSuite with this MonkeyTestSuite's name, children, and result.
         */
        public function clone():* {
            var copy:MonkeyTestSuite = new MonkeyTestSuite();
            setParentCloneProps(copy);

            if (this.parent == this) {
                copy.parent = copy;
            } else {
                copy.parent = this.parent;
            }

            copy.children = this.children;
            copy.name = this.name;
            copy.ignore = this.ignore;
            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Suite";
        }

    }
}
