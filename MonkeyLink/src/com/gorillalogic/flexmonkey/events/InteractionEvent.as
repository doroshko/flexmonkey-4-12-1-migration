/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import flash.events.Event;
    import mx.core.DragSource;

    public class InteractionEvent extends Event {

        public static const EXPAND:String = "InteractionEvent.expand";
        public static const COLLAPSE:String = "InteractionEvent.collapse";
        public static const TILE_LAYOUT:String = "InteractionEvent.tile";
        public static const VERTICAL_LAYOUT:String = "InteractionEvent.vertical";
        public static const DRAG_STARTED:String = "InteractionEvent.dragStarted";
        public static const DRAG_DONE:String = "InteractionEvent.dragDone";

        public var monkeyNodeTarget:MonkeyNode;
        public var dragSource:DragSource;

        public function InteractionEvent(type:String,
                                         monkeyNodeTarget:MonkeyNode = null,
                                         dragSource:DragSource = null,
                                         bubbles:Boolean = false,
                                         cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.monkeyNodeTarget = monkeyNodeTarget;
            this.dragSource = dragSource;
        }

        override public function clone():Event {
            return new InteractionEvent(type, monkeyNodeTarget, dragSource, bubbles, cancelable);
        }
    }

}
