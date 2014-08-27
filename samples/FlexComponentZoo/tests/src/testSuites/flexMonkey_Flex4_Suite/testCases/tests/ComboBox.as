package testSuites.flexMonkey_Flex4_Suite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=5)]
	public class ComboBox extends FlexMonkeyCustomTestBase {

	    public function ComboBox() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createcomboBoxCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupcomboBoxCommandList(arr);
            return arr;
        }

        private function setupcomboBoxCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('Select', '_FlexComponentZoo_Tree1', 'automationName', ['Spark>ComboBox'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Open', '_ComboBoxView_ComboBox1', 'id', [''], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Select', '_ComboBoxView_ComboBox1', 'id', ['American Express'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new VerifyMonkeyCommand('New Verify', null, 'myData', 'automationName', false, 
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Data: 3')
                    ]), null, null, true, '500', '0', 0);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=50000)]
        public function comboBoxTest():void {
        	this.monkeyTestCaseName = "ComboBox";
        	this.monkeyTestName = "comboBoxTest";
        	trace(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createcomboBoxCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      500
        	                     ); 
        }


    }
}