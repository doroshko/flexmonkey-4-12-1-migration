package com.gorillalogic.tests.newTestSuite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=1)]
	public class MyTest extends FlexMonkeyCustomTestBase {

	    public function MyTest() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createmyTestCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupmyTestCommandList(arr);
            return arr;
        }

        private function setupmyTestCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('SelectText', 'textArea', 'automationName', ['0', '0'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Input', 'textArea', 'automationName', ['Hello World!'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Copy', 'automationName', [null], '', '', '11', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'textArea2', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Hello World!')
                    ]), 'v', 'p', true, '500', '20', 0);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Clear', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('SelectText', 'textArea', 'automationName', ['0', '0'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'Copy', 'automationName', false, null, null, null, true, '1000', '5', 0);
            arr.addItem(theRunnable);

            theRunnable=new PauseMonkeyCommand(2000);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=12500)]
        public function myTestTest():void {
        	this.monkeyTestCaseName = "MyTest";
        	this.monkeyTestName = "myTestTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createmyTestCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}