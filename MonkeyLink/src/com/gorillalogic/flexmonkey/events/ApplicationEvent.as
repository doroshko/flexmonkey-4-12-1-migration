/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import flash.events.Event;

    public class ApplicationEvent extends Event {

        public static const WINDOW_LOADED:String = "ApplicationEvent.windowLoaded";
        public static const CLOSE_APPLICATION:String = "ApplicationEvent.closeApplication";
        public static const MONKEY_EXIT:String = "ApplicationEvent.monkeyExit";

        public static const UPDATE_SUMMARY:String = "ApplicationEvent.updateSummary";

        public static const HELP_ABOUT:String = "ApplicationEvent.helpAbout";
        public static const OPEN_HOW_TO_VIDEOS:String = "MonkeyFileEvent.openHowToVideos";

        public static const PURGE_LOG_FILE:String = "ApplicationEvent.purgeLogFile";
        public static const LOAD_LOG_FILE:String = "ApplicationEvent.loadLogFile";
        public static const OPEN_LOG_FILE_VIEW:String = "ApplicationEvent.openLogFileView";

        public static const OPEN_ENV_FILE_VIEW:String = "ApplicationEvent.openEvnFileView";
        public static const GET_ENV_FILE:String = "ApplicationEvent.getEnvFile";

        public static const OPEN_APPLICATION_AUTOMATION_TREE_VIEW:String = "ApplicationEvent.openApplicationAutomationTreeView";
        public static const GET_APPLICATION_AUTOMATION_TREE:String = "ApplicationEvent.getApplicationAutomationTree";

		public static const OPEN_RECORD_WINDOW_VIEW:String = "ApplicationEvent.openRecordWindowView";
		public static const CLOSE_RECORD_WINDOW_VIEW:String = "ApplicationEvent.closeRecordWindowView";
		public static const RECORD_WINDOW_VIEW_CLOSED:String = "ApplicationEvent.recordWindowViewClosed";
		
        public static const CHECK_LIBRARY_VERSION:String = "ApplicationEvent.projectCheckLibraryVersion";

        public var item:Object;

        public function ApplicationEvent(type:String,
                                         item:Object = null,
                                         bubbles:Boolean = false,
                                         cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.item = item;
        }

        override public function clone():Event {
            return new ApplicationEvent(type, item, bubbles, cancelable);
        }

    }
}
