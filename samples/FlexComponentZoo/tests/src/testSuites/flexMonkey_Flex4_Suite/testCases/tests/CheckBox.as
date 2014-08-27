package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=4)]
	public class CheckBox extends FlexMonkeyCustomTestBase {

	    public function CheckBox() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createcheckBoxCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupcheckBoxCommandList(arr);
            return arr;
        }

        private function setupcheckBoxCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>CheckBox'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Lettuce', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Mayonnaise', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Tomato', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'totalString', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', '$5.25')
                    ]), null, null, true, '500', '0', 0);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=62500)]
        public function checkBoxTest():void {
        	this.monkeyTestCaseName = "CheckBox";
        	this.monkeyTestName = "checkBoxTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createcheckBoxCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}