package com.gorillalogic.flexunit {

	import com.gorillalogic.flexmonkey.controllers.TestRunnerController;
	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.events.FMRunnerEvent;
	import com.gorillalogic.flexmonkey.model.ApplicationModel;
	import com.gorillalogic.flexmonkey.model.RunnerModel;
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.vo.AttributeVO;
	import com.gorillalogic.flexunit.FlexMonkeyFlexUnit4Base;
	import com.gorillalogic.flexunit.FlexMonkeyNestedRunner;
	import com.gorillalogic.flexunit.IFlexMonkeyTest;
	import com.gorillalogic.framework.FMHub;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	
	import org.flexunit.asserts.fail;
	
	public class FlexMonkeyCustomTestBase extends FlexMonkeyFlexUnit4Base implements IFlexMonkeyTest {

		public var doTrace:Boolean = false;
		protected var nestedtestCompletionCallback:Function; 
		private static var testRunnerController:TestRunnerController;
		private var watchers:ArrayCollection = new ArrayCollection();
		public var monkeyTestCaseName:String = "FlexMonkeyCustomTestBase";
		public var monkeyTestName:String = "defaultTest";
		
	    public function FlexMonkeyCustomTestBase() {
			super(0); //the Flex Monkey test's defaultThinkTime
    	}

		protected function runFlexMonkeyCommands(commands:ArrayCollection, 
												 callbackMethod:Function = null, 
												 thinkTime:Number = 200, 
												 testName:String = null):void {
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: runFlexMonkeyCommands()");
			}
			assureEventInitialization();
			if (testName==null) {
				testName="Custom Test";
			}
			this.nestedtestCompletionCallback = callbackMethod;
			var monkeyTest:MonkeyTest = new MonkeyTest(testName, thinkTime, commands);
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: calling asyncApply");
			}
			fmRule.asyncApply(function():void {
				if (doTrace) {
					trace("FlexMonkeyCustomTestBase: inside AsyncApply callback");				
				}
				unwatchModel(); // just in case of unanticipated abnormal end to a previous test
				FMHub.instance.dispatchEvent(new FMRunnerEvent(FMRunnerEvent.SETUP_NESTED_TEST_RUNNER, monkeyTest));
				watchModel();
				if (doTrace) {
					trace("FlexMonkeyCustomTestBase: AsyncApply callback return");				
				}
			});
		}
		
		protected function watchModel():void {
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: watchModel()");			
			}
			_watchModel("currentItemCount", currentItemHandler);
			_watchModel("finishedItemCount", finishedItemHandler);
			_watchModel("isRunning", runningChangeHandler);
		}
		protected function _watchModel(prop:String, handler:Function):void {
			var cw:ChangeWatcher;
			var model:RunnerModel = RunnerModel.instance;			
			cw=ChangeWatcher.watch(model, prop, handler);
			// cw.useWeakReference=true; // not uspported in Flex 3, not really needed
			watchers.addItem(cw);
		}
		
		protected function unwatchModel():void {
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: unwatchModel() - " + watchers.length + " watchers");			
			}
			var wndx:int;
			for (wndx=0; wndx<watchers.length; wndx++) {
				var cw:ChangeWatcher = watchers.getItemAt(wndx) as ChangeWatcher;
				cw.unwatch();
			}
			watchers.removeAll();
		}
		
		
		private function assureEventInitialization():void {
			// required to assure propagation of TestRunnerController messaging thru FMHub
			ApplicationModel.instance.isConnected=true;
			if (!(FMHub.instance.hasEventListener(FMRunnerEvent.SETUP_TEST_RUNNER))) {
				testRunnerController = new TestRunnerController();
				FMHub.instance.init([testRunnerController]);
			}			
		}
	
		private function currentItemHandler(event:Event):void {
			var currentItem:MonkeyRunnable = this.getCurrentRunnerModelItem();
			if (currentItem != null && !(currentItem is MonkeyNode)) {  // skip MonkeyTest notification
				var currentCommand:MonkeyRunnable = this.getCurrentCommand();
				if (currentCommand!=null) {
					trace(flash.utils.getQualifiedClassName(this) + " (" + currentCommand + ")");
				}
			}
		}
		
		private function finishedItemHandler(event:Event):void {
			var completedCommand:MonkeyRunnable = this.getCompletedCommand();
			if (completedCommand != null) {
				if (doTrace) {
					trace("FlexMonkeyCustomTestBase: finished command handler, completedCommand is: " + completedCommand);
				}
				checkCommandResult(completedCommand);
			} else {
				if (doTrace) {
					trace("FlexMonkeyCustomTestBase: finished command handler, but no completed command, test.state is " + this.getMonkeyTest().runState);
				}
			}
		}
		
		private function runningChangeHandler(event:Event):void {
			var model:RunnerModel = RunnerModel.instance;			
			if (model.isRunning) {
			} else {
				var monkeyTest:MonkeyTest = this.getMonkeyTest();
				if (monkeyTest!=null) {
					trace("FlexMonkeyCustomTestBase: nested test ended");
					this.unwatchModel();
					if (doTrace) {
						traceRunState(monkeyTest);
					}
					if (this.nestedtestCompletionCallback!=null) {
						var callback:Function = this.nestedtestCompletionCallback;
						this.nestedtestCompletionCallback = null;
						callback();
					} else {
						nocallback();
					}
				}
			}
		}
		
		/** called at end of test, if there is no callback
		 */
		protected function nocallback():void {
			var monkeyTest:MonkeyTest = this.getMonkeyTest();
			if (monkeyTest.runSuccess) {
				finishTest(null); // no error
			}
		}
		
		protected function getCurrentCommand():MonkeyRunnable {
			var currentCommand:MonkeyRunnable = null;
			var ndx:int = this.getCurrentCommandIndex();
			if (ndx>=0) {
				var monkeyCommands:ArrayCollection = getMonkeyCommands();
				if (monkeyCommands!=null) {
					currentCommand = monkeyCommands.getItemAt(ndx) as MonkeyRunnable;					
				}
			}
			return currentCommand;
		}
		protected function getCurrentRunnerModelItem():MonkeyRunnable {
			var currentCommand:MonkeyRunnable = null;
			var model:RunnerModel = RunnerModel.instance;
			var ti:ArrayCollection = model.testItemQueue;
			if (ti!=null) {
				var tindx:int = model.currentItemCount - 1;
				if (tindx>=0 && tindx<ti.length) {
					currentCommand = ti.getItemAt(tindx) as MonkeyRunnable;
				}
			}
			return currentCommand;
		}
		protected function getCompletedCommand():MonkeyRunnable {
			var completedCommand:MonkeyRunnable = null;
			var ndx:int = this.getCurrentCommandIndex();
			if (ndx>0) {
				var monkeyCommands:ArrayCollection = getMonkeyCommands();
				if (monkeyCommands!=null) {
					completedCommand = monkeyCommands.getItemAt(ndx-1) as MonkeyRunnable;					
				} 
			} else {
				trace("looking for completed command, but current command index is" + ndx);
			}
			return completedCommand;
		}
		protected function getCurrentCommandIndex():int {
			var completedCommand:MonkeyRunnable = null;
			var monkeyCommands:ArrayCollection = getMonkeyCommands();
			var i:int = -2;
			if (monkeyCommands.length>0) {
				for (i=0; i<monkeyCommands.length; i++) {
					var currentCommand:MonkeyRunnable = monkeyCommands.getItemAt(i) as MonkeyRunnable;
					if (currentCommand !=null) {
						if (currentCommand.runCompleted) {
							completedCommand = currentCommand;
						} else {
							return i;
						}
					} else {
						throw new Error("FlexMonkeyCustomTestBase.getCompletedCommand(): getMonkeyCommands().getItemAt("+i+") is not a MonkeyRunnable: " + currentCommand);	
					}
				}
			} else {
				throw new Error("FlexMonkeyCustomTestBase.getCompletedCommand(): getMonkeyCommands() is empty");	
			}
			return i;
		}
		
		protected function getMonkeyTest():MonkeyTest {
			var model:RunnerModel = RunnerModel.instance;			
			if (model.rootTestCol != null) {
				if (model.rootTestCol.length>0) {
					var monkeyTest:MonkeyTest = model.rootTestCol.getItemAt(0) as MonkeyTest;
					if (monkeyTest!=null) {
						return monkeyTest;
					} else {
						throw new Error("FlexMonkeyCustomTestBase.getMonkeyTest(): RunnerModel.instance.rooTestCol is not a MonkeyTest - it is: " +  model.rootTestCol.getItemAt(0));	
					}
				} else {
					throw new Error("FlexMonkeyCustomTestBase.getMonkeyTest(): RunnerModel.instance.rootTestCol is empty");	
				}
			} else {
				throw new Error("FlexMonkeyCustomTestBase.getMonkeyTest(): RunnerModel.instance.rooTestCol is null");	
			}
			return null; /// never
		}
		
		protected function getMonkeyCommands():ArrayCollection {
			var monkeyCommands:ArrayCollection;
			var monkeyTest:MonkeyTest = this.getMonkeyTest();
			if (monkeyTest!=null) {
				monkeyCommands = monkeyTest.children;
				if (monkeyCommands!=null) {
					return monkeyCommands;
				} else {
					throw new Error("FlexMonkeyCustomTestBase.getMonkeyCommands(): getMonkeyTest().children is null");	
				}
			}
			return null;
		}
		
		protected function checkCommandResult(command:MonkeyRunnable):void {
			var msg:String = "";
			if (command!=null) {
				if (command.runState == "error") {
					msg += "Error at MonkeyCommand " + command + ": ";
					msg += command.runTestErrorMsg;
					finishTest(new Error(msg), command);
				} else if (command.runState == "failure") {
					var failError:Error = null;
					msg = "Failure at MonkeyCommand " + command + ": ";
					msg += command.runTestFailureMsg;
					failTest(msg, command);
				}
			}
		}
		
		protected function failTest(msg:String, command:MonkeyRunnable=null):void {
			var failError:Error;
			try {
				fail(msg);
			} catch (e:Error) {
				failError=e;
			}
			//If you want test cases to continue even though one test has failed set this to false
			if(true)
			finishTest(failError, command);
		}
		
		protected function finishTest(error:Error=null, command:MonkeyRunnable = null, callAfter:Boolean=true):void {
			try {
				fmRule.finish(error);
				if (error!=null) {
					FMHub.instance.dispatchEvent(new FMRunnerEvent(FMRunnerEvent.ABORT_RUNNER));
				}
				if (command!=null) {
					traceRunState(command);
				}
			} finally {
				if (callAfter) {
					afterTest(monkeyTestCaseName, monkeyTestName);
				}
			}
		}
		
		/**
		 * called befoe each test
		 * meant to to be overridden by custom test case base classes
		 */
		public function beforeTest(testCaseName:String, testName:String):void {
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: beforeTest(\"" + testCaseName + "\",\"" + testName + "\")");
			}
		}
		
		/**
		 * called after completion of each test
		 * meant to to be overridden by custom test case base classes
		 */
		public function afterTest(testCaseName:String, testName:String):void {
			if (doTrace) {
				trace("FlexMonkeyCustomTestBase: afterTest(\"" + testCaseName + "\",\"" + testName + "\")");
			}
		}                
		
		protected function traceRunState(r:MonkeyRunnable):void {
			trace("trace run state for MonkeyRunnable=" + r);
			trace("  shortDescription=" + r.shortDescription);
			trace("  runCompleted=" + r.runCompleted);
			trace("  runState=" + r.runState);
			trace("  runExecutionTime=" + r.runExecutionTime);
			trace("  runSuccess=" + r.runSuccess);
			trace("  runTestConsoleMsg=" + r.runTestConsoleMsg);
			trace("  runTestErrorMsg=" + r.runTestErrorMsg);
			trace("  runTestFailureMsg=" + r.runTestFailureMsg);
		}
    }
}