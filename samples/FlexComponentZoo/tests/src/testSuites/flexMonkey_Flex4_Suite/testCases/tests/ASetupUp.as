package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=1)]
	public class ASetupUp extends FlexMonkeyCustomTestBase {

	    public function ASetupUp() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createaSetupUpCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupaSetupUpCommandList(arr);
            return arr;
        }

        private function setupaSetupUpCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Open', '_FlexComponentZoo_Tree1', 'automationName', ['Spark'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=12500)]
        public function aSetupUpTest():void {
        	this.monkeyTestCaseName = "ASetupUp";
        	this.monkeyTestName = "aSetupUpTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createaSetupUpCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}