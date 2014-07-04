/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;

    [Bindable]
    public class PauseMonkeyCommand extends MonkeyRunnable {

        public var duration:uint;

        public function PauseMonkeyCommand(duration:uint = 0) {
            super(null, false);
            this.duration = duration;
        }

        public function getPauseTime():uint {
            return duration;
        }

        //
        // overrides
        //

        override public function get thinkTime():uint {
            return duration;
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item == null || !item is PauseMonkeyCommand) {
                return false;
            } else {
                if (item.duration == this.duration) {
                    return true;
                }
                return false;
            }
        }

        //
        // clones
        //

        public function clone():PauseMonkeyCommand {
            var copy:PauseMonkeyCommand = new PauseMonkeyCommand();
            setParentCloneProps(copy);

            copy.duration = this.duration;
            return copy;
        }

		//
		// label fields
		//

		override public function get typeDesc():String {
			return "Pause";
		}

		override public function get labelDesc():String {
			return new String(duration);
		}

    }
}