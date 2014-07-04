/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import flash.events.Event;

    public class FMAlertEvent extends Event {

        public static const Alert:String = "FMErrorEvent.alert";
        public static const ERROR:String = "FMErrorEvent.error";

        public var alertMessage:String;

        public function FMAlertEvent(type:String,
                                     alertMessage:String,
                                     bubbles:Boolean = false,
                                     cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.alertMessage = alertMessage;
        }

        override public function clone():Event {
            return new FMAlertEvent(type, alertMessage, bubbles, cancelable);
        }
    }

}
