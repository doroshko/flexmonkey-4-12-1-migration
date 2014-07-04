package com.gorillalogic.flexmonkey.events
{
	import flash.events.Event;
	
	public class PayloadEvent extends Event {
				
		public var data:Object;
		
		public function PayloadEvent(type:String,
									 data:Object,
									 bubbles:Boolean=false, 
									 cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}