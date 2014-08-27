package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=2)]
	public class Button extends FlexMonkeyCustomTestBase {

	    public function Button() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createbuttonCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupbuttonCommandList(arr);
            return arr;
        }

        private function setupbuttonCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>Button'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Standard Button', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'repeatText', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Standard Button pressed!\n')
                    ]), null, null, true, '500', '0', 0);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=37500)]
        public function buttonTest():void {
        	this.monkeyTestCaseName = "Button";
        	this.monkeyTestName = "buttonTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createbuttonCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}