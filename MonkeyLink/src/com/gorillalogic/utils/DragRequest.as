/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;

    import mx.events.DragEvent;

    public class DragRequest {

        private static const SUITE:String = "suite";
        private static const CASE:String = "case";
        private static const TEST:String = "test";

        public static const DATA:String = "dragData";
        public static const TYPE:String = "dragType";

        public static const MOVE_MONKEY_RUNNABLE:String = "moveMonkeyRunnable";
        public static const MOVE_MONKEY_SUITE:String = "moveMonkeySuite";
        public static const MOVE_MONKEY_CASE:String = "moveMonkeyCase";
        public static const MOVE_MONKEY_TEST:String = "moveMonkeyTest";

        public static const COPY_MONKEY_RUNNABLE:String = "copyMonkeyRunnable";
        public static const COPY_MONKEY_NODE:String = "copyMonkeyNode";

        public static const NEW_SUITE:String = "newSuite";
        public static const NEW_CASE:String = "newCase";
        public static const NEW_TEST:String = "newTest";

        public static const NEW_PAUSE:String = "newPause";
        public static const NEW_VERIFY:String = "newVerify";
        public static const NEW_VERIFY_GRID:String = "newVerifyGrid";
        public static const NEW_VERIFY_PROP:String = "newVerifyProp";
        public static const NEW_SET_PROPERTY_CMD:String = "newSetPropertyCmd";
        public static const NEW_STORE_VALUE_CMD:String = "newStoreValueCmd";
        public static const NEW_FUNCTION_CMD:String = "functionCmd";

        public static const MOVE_ALL_RECORDED_ITEMS:String = "moveAllRecordedItems";
        public static const MOVE_ALL_RECORDED_ITEMS_TO_TEST:String = "moveAllRecordedItemsToTest";
        public static const MOVE_ALL_RECORDED_ITEMS_TO_CASE:String = "moveAllRecordedItemsToCase";
        public static const MOVE_ALL_RECORDED_ITEMS_TO_SUITE:String = "moveAllRecordedItemsToSuite";

        public static function isRunnableDrag(dragType:String):Boolean {
            if (dragType != null &&
                (dragType == MOVE_MONKEY_RUNNABLE ||
                dragType == NEW_PAUSE ||
                dragType == NEW_VERIFY ||
                dragType == NEW_VERIFY_GRID ||
                dragType == NEW_VERIFY_PROP ||
                dragType == NEW_SET_PROPERTY_CMD ||
                dragType == NEW_STORE_VALUE_CMD ||
                dragType == NEW_FUNCTION_CMD ||
                dragType == COPY_MONKEY_RUNNABLE ||
                dragType == MOVE_ALL_RECORDED_ITEMS)) {
                return true;
            }
            return false;
        }

		public static function isNewCommandDrag(dragType:String):Boolean {
			if (dragType != null &&
				(dragType == NEW_PAUSE ||
					dragType == NEW_VERIFY ||
					dragType == NEW_VERIFY_GRID ||
					dragType == NEW_VERIFY_PROP ||
					dragType == NEW_SET_PROPERTY_CMD ||
					dragType == NEW_STORE_VALUE_CMD ||
					dragType == NEW_FUNCTION_CMD)) {
				return true;
			}
			return false;
		}

		public static function isMonkeyNodeValidDrag(dragType:String, myState:String, dragMonkeyNode:MonkeyNode = null):Boolean {
            if (dragType != null) {
                if (myState == SUITE) {
                    if (dragType == MOVE_MONKEY_SUITE ||
                        dragType == NEW_SUITE ||
                        dragType == MOVE_ALL_RECORDED_ITEMS_TO_SUITE ||
                        (dragMonkeyNode != null && dragMonkeyNode is MonkeyTestSuite && dragType == COPY_MONKEY_NODE)) {
                        return true;
                    }
                } else if (myState == CASE) {
                    if (dragType == MOVE_MONKEY_CASE ||
                        dragType == NEW_CASE ||
                        dragType == MOVE_ALL_RECORDED_ITEMS_TO_CASE ||
                        (dragMonkeyNode != null && dragMonkeyNode is MonkeyTestCase && dragType == COPY_MONKEY_NODE)) {
                        return true;
                    }
                } else if (myState == TEST) {
                    if (dragType == MOVE_MONKEY_TEST ||
                        dragType == NEW_TEST ||
                        dragType == MOVE_ALL_RECORDED_ITEMS_TO_TEST ||
                        (dragMonkeyNode != null && dragMonkeyNode is MonkeyTest && dragType == COPY_MONKEY_NODE)) {
                        return true;
                    }

                }
            }
            return false;
        }

        public static function isPlayable(event:DragEvent):Boolean {
            var dragData:Object = event.dragSource.dataForFormat(DragRequest.DATA);

            if (dragData is MonkeyRunnable) {
                return true;
            }
            return false;
        }

    }

}
