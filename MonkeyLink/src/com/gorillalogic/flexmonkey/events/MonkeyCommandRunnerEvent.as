package com.gorillalogic.flexmonkey.events
{
	import flash.events.Event;
	
	/**
	 * For backward comatibility with 4.1.x generated code 
	 * 
	 */
	public class MonkeyCommandRunnerEvent extends Event
	{
		/**
		 * For a MonkeyCommandRunnerEvent.EXECUTE event, contains the currently executing MonkeyCommand.
		 */ 
		public var item:Object;
		
		/**
		 *  @eventType execute
		 */		
		public static const EXECUTE:String = "monkeyCommandRunnerExecute";
		
		/**
		 *  @eventType complete
		 */			
		public static const COMPLETE:String = "monkeyCommandRunnerComplete";
		
		/**
		 *  @eventType error
		 */			
		public static const ERROR:String = "monkeyCommandRunnerError";
		
		/**
		 *  Constructor.
		 *  @param type The event type; indicates the action that caused the event.
		 *  @param item For a MonkeyCommandRunnerEvent.EXECUTE event, contains the currently executing MonkeyCommand.
		 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 *  @param cancelable Specifies whether the behavior
		 *  associated with the event can be prevented.
		 */		
		public function MonkeyCommandRunnerEvent(type:String, item:Object = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
	}
}