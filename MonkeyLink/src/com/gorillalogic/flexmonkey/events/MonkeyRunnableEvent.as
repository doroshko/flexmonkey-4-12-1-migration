/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;

    public class MonkeyRunnableEvent extends Event {

        public static const NEW_VERIFY:String = "MonkeyRunnableEvent.addVerify";
        public static const NEW_VERIFY_GRID:String = "MonkeyRunnableEvent.addVerifyGrid";
        public static const NEW_VERIFY_PROP:String = "MonkeyRunnableEvent.addVerifyProp";
        public static const NEW_PAUSE:String = "MonkeyRunnableEvent.addPause";
        public static const NEW_SET_PROPERTY_CMD:String = "MonkeyRunnableEvent.newSetPropertyCmd";
        public static const NEW_STORE_VALUE_CMD:String = "MonkeyRunnableEvent.newStoreValueCmd";
        public static const NEW_FUNCTION_CMD:String = "MonkeyRunnableEvent.newFunctionCmd";

		public static const EDIT_MONKEY_RUNNABLE_RECORDVIEW:String = "MonkeyRunnableEvent.editMonkeyRunnableRecordView";
        public static const EDIT_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.editMonkeyRunnable";
        public static const EDIT_NEW_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.editNewMonkeyRunnable";
        public static const EDIT_VERIFY_SPY_WINDOW:String = "MonkeyRunnableEvent.editVerifySpyWindow";
        public static const CONFIRM_DELETE_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.confirmDeleteMonkeyRunnable";
        public static const DELETE_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.deleteMonkeyRunnable";

        public static const COPY_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.copyMonkeyRunnable";

        public static const MOVE_MONKEY_RUNNABLE:String = "MonkeyRunnableEvent.moveMonkeyRunnable";
        public static const MOVE_ALL_RECORDED_ITEMS:String = "MonkeyRunnableEvent.moveAllRecordedItems";

        public static const CANCEL_COMPONENT_SELECTION:String = "MonkeyRunnableEvent.cancelComponentSelection";
        public static const LOAD_COMPONENT_SELECTION:String = "MonkeyRunnableEvent.loadComponentSelection";

        public static const RETAKE_VERIFY_SNAPSHOT:String = "MonkeyRunnableEvent.retakeVerifySnapshot";
        public static const CANCEL_RETAKE_VERIFY_SNAPSHOT:String = "MonkeyRunnableEvent.cancelRetakeVerifySnapshot";
        public static const EDIT_VERIFY_SNAPSHOT_WINDOW:String = "MonkeyRunnableEvent.editVerifySnapshotWindow";
        public static const SHOW_VERIFY_SNAPSHOT_WINDOW:String = "MonkeyRunnableEvent.showVerifySnapshotWindow";
		
		public static const EXPLORE_APP:String = "MonkeyRunnableEvent.exploreApp";
		public static const EXPLORE_CHILDREN_POPUP:String = "MonkeyRunnableEvent.exploreAppDisplay";
		public static const EXPLORE_CHILDREN_POPUP_PROPVIEW:String = "MonkeyRunnableEvent.exploreAppDisplay.propview";

        public var monkeyTest:MonkeyTest;
        public var monkeyRunnable:MonkeyRunnable;
        public var position:int;
        public var parentNode:MonkeyNode;
        public var parentCollection:ArrayCollection;

        public function MonkeyRunnableEvent(type:String,
                                            bubbles:Boolean = false,
                                            cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.monkeyTest = monkeyTest;
        }

        public static function createAddEvent(type:String, parentNode:MonkeyNode, pos:int):MonkeyRunnableEvent {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(type);
            e.position = pos;
            e.parentNode = parentNode;
            return e;
        }

        public static function createMonkeyTestEvent(type:String, monkeyTest:MonkeyTest):MonkeyRunnableEvent {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(type);
            e.monkeyTest = monkeyTest;
            return e;
        }

        public static function createMonkeyRunnableEvent(type:String, monkeyRunnable:MonkeyRunnable):MonkeyRunnableEvent {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(type);
            e.monkeyRunnable = monkeyRunnable;
            return e;
        }

        public static function createMoveEvent(monkeyRunnable:MonkeyRunnable, parentNode:MonkeyNode, position:int):MonkeyRunnableEvent {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(MOVE_MONKEY_RUNNABLE);
            e.monkeyRunnable = monkeyRunnable;
            e.position = position;
            e.parentNode = parentNode;
            return e;
        }

        public static function createCopyEvent(monkeyRunnable:MonkeyRunnable, parentNode:MonkeyNode, position:int):MonkeyRunnableEvent {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(COPY_MONKEY_RUNNABLE);
            e.monkeyRunnable = monkeyRunnable;
            e.position = position;
            e.parentNode = parentNode;
            return e;
        }

        override public function clone():Event {
            var e:MonkeyRunnableEvent = new MonkeyRunnableEvent(type, bubbles, cancelable);
            e.monkeyTest = this.monkeyTest;
            e.monkeyRunnable = this.monkeyRunnable;
            e.parentNode = this.parentNode;
            e.position = this.position;
            e.parentCollection = this.parentCollection;
            return e;
        }

    }
}
