package testSuites.exampleTestSuite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=1)]
	public class ExampleTest extends FlexMonkeyCustomTestBase {

	    public function ExampleTest() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createexampleTestCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupexampleTestCommandList(arr);
            return arr;
        }

        private function setupexampleTestCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('SelectText', 'inName', 'automationName', ['0', '0'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Input', 'inName', 'automationName', ['Fred'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Open', 'inType', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Select', 'inType', 'automationName', ['Work'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Open', 'inDate', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Change', 'inDate', 'automationName', ['Wed Dec 1 2010'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Add', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'inPhone', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('errorString', null, 'property', 'You must specify a phone number.')
                    ]), null, null, true, '500', '20', 0);
            arr.addItem(theRunnable);

            theRunnable=new VerifyPropertyMonkeyCommand('New Verify Property', 'grid', 'automationName', null, null, true, '500', '20', 'dataProvider.length', '0', null);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Input', 'inPhone', 'automationName', ['123-456-7890'], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Add', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyGridMonkeyCommand('New Verify Grid', 'grid', 'automationName', 0, 1, 'Fred', null, null, true, '10', '500');
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Delete', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=12500)]
        public function exampleTestTest():void {
        	this.monkeyTestCaseName = "ExampleTest";
        	this.monkeyTestName = "exampleTestTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createexampleTestCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}