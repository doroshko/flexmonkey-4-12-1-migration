/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;

    import flash.events.Event;

    public class CommandRecordedEvent extends Event {

        public static const COMMAND_RECORDED:String = "CommandRecordedEvent.CommandRecorded";

        public var command:UIEventMonkeyCommand;

        public function CommandRecordedEvent(cmd:UIEventMonkeyCommand) {
            super(COMMAND_RECORDED);
            command = cmd;
        }

    }
}
