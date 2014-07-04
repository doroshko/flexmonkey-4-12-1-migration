/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.events {

    import flash.events.Event;

    import mx.collections.ArrayCollection;

    public class StatusCheckEvent extends Event {

        public static const SHOW_STATUS_WINDOW:String = "StatusCheckEvent.showStatusWindow";
        public static const ACKNOWLEDGE_STATUSES:String = "StatusCheckEvent.acknowledged";

        public var installedVersion:String;
        public var latestVersion:String;
        public var newsItems:ArrayCollection;

        public function StatusCheckEvent(type:String,
                                         installedVersion:String = null,
                                         latestVersion:String = null,
                                         newsItems:ArrayCollection = null,
                                         bubbles:Boolean = false,
                                         cancelable:Boolean = false) {
            super(type, bubbles, cancelable);

            this.installedVersion = installedVersion;
            this.latestVersion = latestVersion;
            this.newsItems = newsItems;
        }

        override public function clone():Event {
            return new StatusCheckEvent(type, installedVersion, latestVersion, newsItems, bubbles, cancelable);
        }

    }
}
