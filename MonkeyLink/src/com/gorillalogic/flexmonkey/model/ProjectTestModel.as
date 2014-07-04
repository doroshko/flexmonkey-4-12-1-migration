/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.model {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.utils.FMPathUtil;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import mx.collections.ArrayCollection;

    [Bindable]
    public class ProjectTestModel extends EventDispatcher {

        public static var instance:ProjectTestModel = new ProjectTestModel();

        public static const PROJECT_FILE_NAME:String = "monkeyTestProject.xml";
        public static const PROJECT_SUITE_FILE_NAME:String = "monkeyTestSuites.xml";
        public static const SNAPSHOT_DIR:String = "snapshots";

        public var selectedItem:MonkeyRunnable;
        public var suites:ArrayCollection;
        public var preferencesXML:XML = <preferences/>;

        // count properties
        public var suiteCount:int;
        public var caseCount:int;
        public var testCount:int;
        public var commandCount:int;

        // project config
        private var _projectUrl:String;
		private var _generatedCodeUrl:String = "tests/src";
        public var preferencesUrl:String;
        public var projectXML:XML;
        public var generatedCodeSuitesPackageName:String;
		public var generatedCodeTestCaseBaseClass:String;
        public var useMultipleSuiteFiles:Boolean = true;
        public var codeGenTimeoutPadding:int = 2000;

        // suite xml parsing var
        public var suiteChildFileDataReturn:Object;
        public var suiteChildFileData:ArrayCollection;
        public var suiteXml:XML;

        // record properties
        public var recordItems:ArrayCollection;

		[Bindable("projectURLUpdated")]
		public function get projectFileUrl():String {
			if (!_projectUrl) {
				return null;
			}
			return _projectUrl + "/" + PROJECT_FILE_NAME;
		}
		
		[Bindable("projectURLUpdated")]
		public function get monkeyTestFileUrl():String {
			if (!_projectUrl) {
				return null;
			}
			return _projectUrl + "/" + PROJECT_SUITE_FILE_NAME;
		}
		
		public function get snapshotsDirUrl():String {
			return generatedCodeUrl + "/" + SNAPSHOT_DIR;
		}
		
        public function get projectUrl():String {
            return _projectUrl;
        }

        public function set projectUrl(value:String):void {
            _projectUrl = value;
			checkForRelativeGeneratedCodePath();
			dispatchEvent(new Event("projectURLUpdated"));
        }
		
		[Bindable("projectURLUpdated")]
		public function get generatedCodeUrl():String {
			return FMPathUtil.getFullURL(_projectUrl, _generatedCodeUrl);
		}

		[Bindable("projectURLUpdated")]
		public function get generatedCodeUrlRelative():String {
			return _generatedCodeUrl;
		}
		
		public function set generatedCodeUrl(url:String):void {
			_generatedCodeUrl = url;
			checkForRelativeGeneratedCodePath();
		}
		
		private function checkForRelativeGeneratedCodePath(): void {
			if (_generatedCodeUrl!=null) {
				if (_generatedCodeUrl.indexOf(projectUrl)==0) {
					_generatedCodeUrl=_generatedCodeUrl.substr(projectUrl.length);
					while (_generatedCodeUrl.length>0 && _generatedCodeUrl.charAt(0)=='/') {
						_generatedCodeUrl=_generatedCodeUrl.substring(1);
					}
				}
			}
		} 
		
        public function recordUiEvent(uiEventCommand:UIEventMonkeyCommand):void {
            if (recordItems == null) {
                recordItems = new ArrayCollection();
            }

            recordItems.addItem(uiEventCommand);
        }

        public function isRunnableInRecording(r:MonkeyRunnable):Boolean {
            if (recordItems != null && recordItems.contains(r)) {
                return true;
            }
            return false
        }

        public function moveAllRecordedItems(test:MonkeyTest, startPos:int):void {
            var col:ArrayCollection = test.children;

            for each (var i:MonkeyRunnable in recordItems) {
                i.parent = test;
                col.addItemAt(i, startPos);
                startPos++;
            }
            recordItems = null;
        }

    }
}
