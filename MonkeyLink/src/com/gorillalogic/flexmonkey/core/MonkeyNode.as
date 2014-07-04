/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.core {

    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;

    [Bindable]
    public class MonkeyNode extends MonkeyRunnable {

        public var name:String;
        public var children:ArrayCollection;
        public var empty:Boolean;
        public var ignore:Boolean = false;

        public function MonkeyNode(target:IEventDispatcher = null,
                                   parent:Object = null,
                                   name:String = null,
                                   result:String = null,
                                   children:ArrayCollection = null) {

            super(target);

            this.parent = parent;
            this.name = name;
            this.children = children;
        }

        override public function get labelDesc():String {
            return name;
        }
    }
}