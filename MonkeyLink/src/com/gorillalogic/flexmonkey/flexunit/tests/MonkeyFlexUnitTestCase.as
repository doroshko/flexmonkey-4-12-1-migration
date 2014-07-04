package com.gorillalogic.flexmonkey.flexunit.tests
{
	/** Provides backward compatibility for basic 4.1.x generated tests
	 * 
	*/
	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
	
	public class MonkeyFlexUnitTestCase extends FlexMonkeyCustomTestBase
	{
		public function MonkeyFlexUnitTestCase() {
			super();
		}
		
		public function startTest(node:MonkeyNode, completeHandler:Function, timeoutTime:int, timeoutHandler:Function):void {
			super.runFlexMonkeyCommands(node.children,
										function ():void{
											completeHandler(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE),null);
										}, 
										node.thinkTime, 
										node.name);
		}
		
		public function checkCommandResults(monkeyTest:MonkeyTest):void{
			finishTest(null, null, false);
		}
		public function commandErrorHandler(event:MonkeyCommandRunnerEvent):void{
			
		}
		public function defaultTimeoutHandler(passThroughData:Object):void{
			finishTest(new Error("MonkeyFlexUnitTestCase:defaultTimeoutHandler(): old-style test timed out"), null, false);
		}
		
	}
}