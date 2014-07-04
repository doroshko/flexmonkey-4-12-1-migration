/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import flash.events.Event;

    public class ProjectFilesEvent extends Event {

        public static const NEW_PROJECT:String = "ProjectFilesEvent.newProject";
        public static const OPEN_PROJECT:String = "ProjectFilesEvent.openProject";
        public static const FAILED_TO_OPEN_PROJECT:String = "ProjectFilesEvent.failedToOpenProject";
        public static const SAVE:String = "ProjectFilesEvent.save";
        public static const SAVE_CANCELLED:String = "ProjectFilesEvent.saveCancelled";
        public static const GENERATE_AS3_FLEXUNIT_TESTS:String = "ProjectFilesEvent.generateAS3FlexUnitTests";
		public static const GENERATE_JS_TESTS:String = "ProjectFilesEvent.generateJSTests";
        public static const OPEN_PROJECT_PROPERTIES_WINDOW:String = "ProjectFilesEvent.projectEditProperties";

        public static const PROMPT_FOR_NEW_PROJECT:String = "ProjectFilesEvent.promptForNewProject";
        public static const PROMPT_FOR_SAVE:String = "ProjectFilesEvent.promptForSave";

        public static const PROJECT_FILE_OPEN:String = "ProjectFilesEvent.projectFileOpen";
        public static const TEST_PROJECT_FILE_OPENED:String = "ProjectFilesEvent.testProjectFileOpen";
        public static const PROJECT_PROPERTIES_UPDATE:String = "ProjectFilesEvent.projectPropertiesUpdate";
        public static const OPENING_TEST_PROJECT_FILE:String = "ProjectFilesEvent.openingTestItems";

        public var item:Object;
        public var closeApplicationAfterSave:Boolean = false;

        public function ProjectFilesEvent(type:String, item:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.item = item;
        }

        override public function clone():Event {
            var event:ProjectFilesEvent = new ProjectFilesEvent(type, item, bubbles, cancelable);
            event.closeApplicationAfterSave = this.closeApplicationAfterSave;
            return event;
        }

    }
}
