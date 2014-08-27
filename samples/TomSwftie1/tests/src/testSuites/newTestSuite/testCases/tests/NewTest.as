package testSuites.newTestSuite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=1)]
	public class NewTest extends FlexMonkeyCustomTestBase {

	    public function NewTest() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createnewTestCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupnewTestCommandList(arr);
            return arr;
        }

        private function setupnewTestCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Click', 'launch Quote-o-matic', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'Next Quote', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('label', null, 'property', 'Next Quote')
                    ]), null, null, true, '500', '20', 0);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, '_QuoteOMatic_TextArea1', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Double, double toil and trouble\nFire burn, and cauldron bubble.')
                    ]), null, null, true, '500', '20', 0);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Next Quote', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'unload Quote-o-matic', 'automationName', [null], '', '', '10', '500', false);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=120000)]
        public function newTestTest():void {
        	this.monkeyTestCaseName = "NewTest";
        	this.monkeyTestName = "newTestTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createnewTestCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      0
        	                     ); 
        }


    }
}