package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=3)]
	public class ButtonBar extends FlexMonkeyCustomTestBase {

	    public function ButtonBar() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createbuttonBarCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupbuttonBarCommandList(arr);
            return arr;
        }

        private function setupbuttonBarCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>ButtonBar'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Select', 'myButtonBar', 'automationName', ['Red'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'txtColor', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Red selected!')
                    ]), null, null, true, '500', '0', 0);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Select', 'myButtonBar', 'automationName', ['Blue'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'myTextArea', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Button Bar index clicked = 2\nButton Bar previous index = 0\nButton Bar label clicked = Blue')
                    ]), null, null, true, '500', '0', 0);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=62500)]
        public function buttonBarTest():void {
        	this.monkeyTestCaseName = "ButtonBar";
        	this.monkeyTestName = "buttonBarTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createbuttonBarCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}