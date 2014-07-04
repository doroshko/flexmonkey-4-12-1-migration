package customTests {

	import MonkeyContacts;
	
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.monkeyCommands.*;
	import com.gorillalogic.flexmonkey.vo.AttributeVO;
	import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
	import com.gorillalogic.flexunit.IFlexMonkeyTest;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals; // default package
	
	[TestCase(order=3)]
	public class CustomTest extends FlexMonkeyCustomTestBase implements IFlexMonkeyTest {

	    public function CustomTest() {
			super(); //the Flex Monkey test's defaultThinkTime
    	}

		[Before]
		public function setUp():void {
			trace("CustomTest: " + "setup");
		}

		[Test(async, timeout=150000)]
        public function customTestTest():void {
			this.monkeyTestCaseName = "CustomTest";
			this.monkeyTestName = "customTestTest";
			beforeTest(monkeyTestCaseName, monkeyTestName);
			trace("customTestTest: " + "test method");
			
			var arr:ArrayCollection = this.setupCustomTestTest();

			runFlexMonkeyCommands(arr, customTestTContinuation1);
       }

		public function customTestTContinuation1():void {
			trace("customTestContinuation1: " + "continuation method 1");
			var arr:ArrayCollection = setupAddPersonCommands("Harvey", "Work", "981-601-4332",new Date("Thu Nov 2 1995"));
			arr.addAll(this.setupAddPersonCommands("Al", "Mobile", "987-909-2311",new Date("Fri Nov 3 1995")));
			
			runFlexMonkeyCommands(arr, customTestTContinuation2);			
		}
		
		public function customTestTContinuation2():void {
			trace("customTestContinuation2: " + "continuation method 2");
			var app:MonkeyContacts = FlexGlobals.topLevelApplication as MonkeyContacts;
			if (app!=null) {
				if (app.contacts.length>3) {
					trace("customTestContinuation2: more than three, adding one more contact");
					var arr:ArrayCollection = setupAddPersonCommands("Janet", "Work", "111-222-3331",new Date("Sat Nov 4 1995"));
					runFlexMonkeyCommands(arr);			
				} else {
					trace("customTestContinuation2: not more than three, failing");
					failTest("too many contacts: " + app.contacts.length);
				}
			} else {
				finishTest(new Error("app was not a MonkeyContacts"));
			}
		}
		
		private function setupCustomTestTest():ArrayCollection {
			var arr:ArrayCollection = this.setupAddPersonCommands("Celeste", "Home", "321-654-0987",new Date("Wed Jun 1 2011"));
			arr.addAll(this.setupAddPersonCommands("Joe", "Mobile", "987-909-2311",new Date("Wed Nov 1 1995")));
			return arr;
		}
	
		private function setupAddPersonCommands(name:String, contactType:String, 
												phoneNumber:String, birthday:Date, 
												forcePhonePopup:Boolean = false ):ArrayCollection {
			var arr:ArrayCollection = new ArrayCollection;
			var theRunnable:MonkeyRunnable=null;
			theRunnable=new UIEventMonkeyCommand('SelectText', 'inName', 'automationName', ['0', '100'], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Input', 'inName', 'automationName', [name], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Open', 'inType', 'automationName', [null], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Select', 'inType', 'automationName', [contactType], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Open', 'inDate', 'automationName', [null], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Change', 'inDate', 'automationName', [birthday.toDateString()], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			if (forcePhonePopup) {
				theRunnable=new UIEventMonkeyCommand('Click', 'Add', 'automationName', [null], '', '', '500', '10', false);
				arr.addItem(theRunnable);
				
				theRunnable=new VerifyMonkeyCommand('Must Specify Phone Verify', null, 'inPhone', 'automationName', false, 
					new ArrayCollection([
						new AttributeVO('errorString', null, 'property', 'You must specify a phone number.')
					]), null, null, true, '500', '20', 0);
				arr.addItem(theRunnable);
			}
			
			// theRunnable=new VerifyPropertyMonkeyCommand('DataProvider Length Verify Property', 'grid', 'automationName', null, null, true, '500', '20', 'dataProvider.length', '0', null);
			// arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Input', 'inPhone', 'automationName', [phoneNumber], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			theRunnable=new UIEventMonkeyCommand('Click', 'Add', 'automationName', [null], '', '', '500', '10', false);
			arr.addItem(theRunnable);
			
			return arr;
		}
	}
		
}
