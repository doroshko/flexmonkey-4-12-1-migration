/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import flash.events.Event;

    public class MonkeyNodeEvent extends Event {

        public static const NEW_TEST_SUITE:String = "MonkeyNodeEvent.newTestSuite";
        public static const NEW_TEST_CASE:String = "MonkeyNodeEvent.newTestCase";
        public static const NEW_TEST:String = "MonkeyNodeEvent.newTest";

        public static const NEW_TEST_FROM_RECORD_ITEMS:String = "MonkeyNodeEvent.newTestFromRecordItems";
        public static const NEW_CASE_FROM_RECORD_ITEMS:String = "MonkeyNodeEvent.newCaseFromRecordItems";
        public static const NEW_SUITE_FROM_RECORD_ITEMS:String = "MonkeyNodeEvent.newSuiteFromRecordItems";

        public static const EDIT_MONKEY_NODE:String = "MonkeyNodeEvent.editMonkeyNode";

        public var monkeyNode:MonkeyNode;
        public var newNodePosition:int;

        public function MonkeyNodeEvent(type:String,
                                        monkeyNode:MonkeyNode = null,
                                        bubbles:Boolean = false,
                                        cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.monkeyNode = monkeyNode;
        }

        public static function createNewNodeEvent(type:String, pos:int, node:MonkeyNode = null):MonkeyNodeEvent {
            var e:MonkeyNodeEvent = new MonkeyNodeEvent(type);
            e.monkeyNode = node;
            e.newNodePosition = pos;
            return e;
        }

        override public function clone():Event {
            var e:MonkeyNodeEvent = new MonkeyNodeEvent(type, monkeyNode, bubbles, cancelable);
            e.newNodePosition = this.newNodePosition;
            return e;
        }
    }

}
