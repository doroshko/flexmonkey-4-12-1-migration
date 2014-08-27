package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=6)]
	public class List extends FlexMonkeyCustomTestBase {

	    public function List() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createlistCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setuplistCommandList(arr);
            return arr;
        }

        private function setuplistCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>List'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>List'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=25000)]
        public function listTest():void {
        	this.monkeyTestCaseName = "List";
        	this.monkeyTestName = "listTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createlistCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}