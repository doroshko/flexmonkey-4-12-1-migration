/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;

    import flash.events.Event;

    public class SnapshotEvent extends Event {

        public static const REMOVE_UNUSED_SNAPSHOTS:String = "MonkeyFileEvent.removeUnusedSnapshots";
        public static const DISPLAY_SNAPSHOT:String = "ApplicationEvent.displaySnapshot";

        public static const SAVE_SNAPSHOT:String = "MonkeyFileEvent.saveSnapshot";
        public static const DELETE_SNAPSHOT:String = "MonkeyFileEvent.deleteSnapshot";

        public var verify:VerifyMonkeyCommand;
        public var url:String;
        public var fileData:Object;

        public function SnapshotEvent(type:String,
                                      verify:VerifyMonkeyCommand = null,
                                      bubbles:Boolean = false,
                                      cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.verify = verify;
        }

        override public function clone():Event {
            var event:SnapshotEvent = new SnapshotEvent(type, verify, bubbles, cancelable);
            event.url = this.url;
            event.fileData = this.fileData;
            return event;
        }

        public static function saveSnapshot(url:String, fileData:Object):SnapshotEvent {
            var event:SnapshotEvent = new SnapshotEvent(SAVE_SNAPSHOT);
            event.url = url;
            event.fileData = fileData;
            return event;
        }

        public static function deleteSnapshot(url:String, fileData:Object):SnapshotEvent {
            var event:SnapshotEvent = new SnapshotEvent(DELETE_SNAPSHOT);
            event.url = url;
            event.fileData = fileData;
            return event;
        }

    }
}
