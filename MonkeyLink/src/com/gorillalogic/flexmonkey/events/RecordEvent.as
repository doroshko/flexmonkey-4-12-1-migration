/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;

    import flash.events.Event;

    public class RecordEvent extends Event {

        public static const START_RECORDING:String = "RecordEvent.startRecording";
        public static const STOP_RECORDING:String = "RecordEvent.recordEnd";
        public static const NEW_UI_EVENT:String = "RecordEvent.newUIEvent";
        public static const DELETE_ITEMS:String = "RecordEvent.deleteItems";
        public static const PLAY_ITEMS:String = "RecordEvent.playItems";
        public static const SELECT_APPLICATION_COMPONENT:String = "RecordEvent.selectApplicationComponent";

        public var uiEventCommand:UIEventMonkeyCommand;

        public function RecordEvent(type:String,
                                    uiEventCommand:UIEventMonkeyCommand = null,
                                    bubbles:Boolean = false,
                                    cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.uiEventCommand = uiEventCommand;
        }

    }

}
