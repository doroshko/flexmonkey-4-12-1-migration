/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.model {

	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.runner.Result;

	[Bindable]
	public class RunnerModel {

		public static var instance:RunnerModel = new RunnerModel();

		public var isRunning:Boolean;
		public var wasRecording:Boolean;
		public var testRunDesc:String;
		public var resultItem:MonkeyRunnable;
		public var rootTestCol:ArrayCollection;
		public var testItemQueue:ArrayCollection;
		public var runnerConsoleMessage:String;

		public var total:int;
		public var errorCount:int;
		public var failureCount:int;
		public var currentItemCount:int;
		public var finishedItemCount:int;
		public var runnerClazz:Class;
		public var testClazz:Class;

		public function clearResults():void {
			isRunning = false;
			runnerConsoleMessage = "";
			errorCount = 0;
			failureCount = 0;
			currentItemCount = 0;
			finishedItemCount = 0;
			resultItem = null;
		}

		public function clearItemResults():void {
			//make sure filter is not applied
			removeErrorFailureFilter();

			for each (var r:MonkeyRunnable in testItemQueue) {
				r.runState = "none";
				r.runSuccess = false;
				r.runTestConsoleMsg = null;
				r.runTestErrorMsg = null;
				r.runTestFailureMsg = null;
				r.runExecutionTime = 0;
			}

		}

		public function currentItem(r:MonkeyRunnable):void {
			resultItem = r;
			currentItemCount = testItemQueue.getItemIndex(r) + 1;
		}

		public function itemFinished(r:MonkeyRunnable):void {
			resultItem = r;
			finishedItemCount = testItemQueue.getItemIndex(r) + 1;
		}
		
		public function start():void {
			isRunning = true;
		}

		public function finish(result:Result):void {
			isRunning = false;
		}

		public function applyErrorFailureFilter():void {
			if (testItemQueue != null) {
				testItemQueue.filterFunction = errorFailureFilterFunc;
				testItemQueue.refresh();
			}
		}

		public function removeErrorFailureFilter():void {
			if (testItemQueue != null) {
				testItemQueue.filterFunction = null;
				testItemQueue.refresh();
			}
		}

		private function errorFailureFilterFunc(item:Object):Boolean {
			var r:MonkeyRunnable = item as MonkeyRunnable;

			if (!r.runSuccess) {
				return true;
			}
			return false;
		}

		public function setRunnerItem(runnable:MonkeyRunnable):void {
			clearResults();

			//set desc
			if (runnable is MonkeyTestSuite) {
				testRunDesc = (runnable as MonkeyNode).name + " (Suite)";
			} else if (runnable is MonkeyTestCase) {
				testRunDesc = (runnable as MonkeyNode).name + " (Case)";
			} else if (runnable is MonkeyTest) {
				testRunDesc = (runnable as MonkeyNode).name + " (Test)";
			} else {
				testRunDesc = runnable.getLabel();
			}

			//set up queue
			testItemQueue = null;
			rootTestCol = new ArrayCollection([ runnable ]);
			setupTestItemQueue(rootTestCol);
			total = testItemQueue.length;

			clearItemResults();
		}

		public function setRunnerItems(col:ArrayCollection, desc:String):void {
			clearResults();

			//set up queue
			testItemQueue = null;
			rootTestCol = col;
			testRunDesc = desc;
			setupTestItemQueue(rootTestCol);
			total = testItemQueue.length;

			clearItemResults();
		}

		private function setupTestItemQueue(col:ArrayCollection, nestCount:int=0):void {
			if (testItemQueue == null) {
				testItemQueue = new ArrayCollection();
			}

			for each (var r:MonkeyRunnable in col) {
				r.runState = "none";
				r.runTestFailureMsg = "";
				r.runTestErrorMsg = "";
				r.runTestConsoleMsg = "";
				r.currentRetryCount = 0;
				r.runExecutionTime = 0;
				r.runNestedCount = nestCount;

				testItemQueue.addItem(r);

				if (r is MonkeyNode) {
					setupTestItemQueue((r as MonkeyNode).children, nestCount + 1);
				}
			}
		}
	}

}
