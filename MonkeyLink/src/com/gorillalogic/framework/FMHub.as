/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.framework {

    import com.gorillalogic.flexmonkey.events.FMHubEvent;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getQualifiedClassName;
    
    import mx.binding.utils.BindingUtils;
    import mx.collections.ArrayCollection;

    /**
     * Worlds simplest bus and data externalizing framework
     *
     * This class was added to allow to remove Mate from the code base, replacing it with worlds simplest bus
     *
     */
    public class FMHub extends EventDispatcher {

        /**
         * Debugging property - set to true to receive debugging output from this class
         */
        private static const DEBUGGING:Boolean = false;

        /**
         * Static instance for accessing singleton instance this class
         */
        public static var instance:FMHub = new FMHub();

        /**
         * Cache of listeners that have been registered with the class
         */
        private var listenerCache:ArrayCollection;

        /**
         * Constructor ... Please use the static instance to access this class.
         */
        public function FMHub() {
            //setup debugging 
            if (DEBUGGING) {
                listenerCache = new ArrayCollection();
            }
        }

        public function unlisten(type:String, listener:Function, refObj:Object):void {
            if (DEBUGGING) {
                var index:int = 0;

                for each (var o:Object in listenerCache) {
                    if (o.type == type && o.listener == listener && o.refObj == refObj) {
                        listenerCache.removeItemAt(index);
                        index++;
                    }
                }
            }

            super.removeEventListener(type, listener);
        }


        /**
         * API method for adding event listener for bus events that happen on this class
         */
        public function listen(type:String, listener:Function, refObj:Object, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void {
            if (DEBUGGING) {
                listenerCache.addItem({ type: type, listener: listener, refObj: refObj });
            }

            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        /**
         * Override and disable addEventListener function to make sure listen API is used instead
         */
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            throw("Please use the listen function for bus events");
        }

        override public function dispatchEvent(event:Event):Boolean {
            if (DEBUGGING) {
                trace("Event Dispatch on type: '" + event.type + "'");

                for each (var o:Object in listenerCache) {
                    if (o.type == event.type) {
                        trace("---> Handler registered from class: " + getQualifiedClassName(o.refObj) + " ... " + (o.listener as Function));
                    }
                }
            }

            return super.dispatchEvent(event);
        }

		/**
		 * dispatch this event after allowing the rest of the event flow to proceed
		 * uses a timer to manage this
		 */
		public function dispatchEventAsync(e:Event, delay:Number = 100):Boolean {
			if (DEBUGGING) {
				trace("Asynch Event Dispatch on type: '" + e.type + "'");
			}
			
			var timer:Timer = new Timer(delay,0);
			timer.addEventListener(TimerEvent.TIMER, 
					function():void {
						timer.stop();  // just in case?
						FMHub.instance.dispatchEvent(e);
									});
			timer.start();
			return true;
		}
		
        /**
         *
         */
        public function init(controllers:Array):void {
            for each (var c:IFMController in controllers) {
                c.register(instance);
            }

            //notify that everythng is loaded
            FMHub.instance.dispatchEvent(new FMHubEvent(FMHubEvent.LOADED));
        }

    }
}
