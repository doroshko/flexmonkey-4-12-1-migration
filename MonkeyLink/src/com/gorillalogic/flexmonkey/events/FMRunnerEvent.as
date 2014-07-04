/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    
    import flash.events.Event;

    public class FMRunnerEvent extends Event {

        public static const SETUP_TEST_RUNNER:String = "FMRunnerEvent.setupTestRunner";
		public static const SETUP_NESTED_TEST_RUNNER:String = "FMRunnerEvent.setupNestedTestRunner";
        public static const START_RUNNER:String = "FMRunnerEvent.startRunner";
        public static const ABORT_RUNNER:String = "FMRunnerEvent.abortRunner";
        public static const CLEAR_RUNNER_RESULTS:String = "FMRunnerEvent.clearRunnerResults";

        public var item:MonkeyRunnable;
        public var isPlayRecordItems:Boolean;

        public function FMRunnerEvent(type:String,
                                      item:MonkeyRunnable = null,
                                      isPlayRecordItems:Boolean = false,
                                      bubbles:Boolean = false,
                                      cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.item = item;
            this.isPlayRecordItems = isPlayRecordItems;
        }

        override public function clone():Event {
            return new FMRunnerEvent(type, item, isPlayRecordItems, bubbles, cancelable);
        }
    }

}
