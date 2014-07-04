/*
* FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
* FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
*/
package com.gorillalogic.monkeylink {
	
	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.core.MonkeyAutomationState;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.events.CommandRecordedEvent;
	import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
	import com.gorillalogic.flexmonkey.vo.TargetVO;
	import com.gorillalogic.flexmonkium.FlexMonkium;
	import com.gorillalogic.framework.FMHub;
	import com.gorillalogic.utils.ApplicationWrapper;
	import com.gorillalogic.utils.FMLibraryVersionUtil;
	import com.gorillalogic.utils.MonkeyAutomationManager;
	import com.gorillalogic.utils.MonkeyConnection;
	import com.gorillalogic.utils.MonkeyMagicAutomationDelegate;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationRecordEvent;
	import mx.controls.Alert;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	FLEXMONKEY::vfour{
		import mx.core.FlexGlobals;
		import spark.components.Application;
	}
	
	
	[Mixin]
	public class MonkeyLink extends MonkeyConnection {
		
		public static const monkeyLink:MonkeyLink = new MonkeyLink();
		
		private static var running:Boolean = false;
		private static var root:DisplayObject;
		private static var _verifySelector:ComponentSelector;
		
		public static function init(_root:Object):void {
			
			if (_root.currentLabel == null || (_root.currentLabel != "AirMonkey" && _root.currentLabel != "FlexMonkiumConsole")) {
				MonkeyLink.root = _root as DisplayObject;
				root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
					if (!running) { //tracking running status so we don't reload for modules
						
						MonkeyLink.monkeyLink.startLink();
					}
				});
			}
		}
		
		public function MonkeyLink() {
			super();
			txChannelName = "_flexMonkey";
			rxChannelName = "_agent";
			writeConsole = function(message:String):void {
				//trace(message);
			};
		}
		
		override public function disconnect():void {
			super.disconnect();
		}
		
		override public function initializeRXChannel():void {
			initializeRXChannel0();
			rxConnection.allowInsecureDomain('*');
			initializeRXChannel1();
		}
		
		public function startLink():void {
			trace("MonkeyLink version " + com.gorillalogic.utils.FMLibraryVersionUtil.libraryVersion);
			startConnection();
			
			MonkeyAutomationManager.instance.addEventListener(AutomationRecordEvent.RECORD, recordEventHandler, false, 0, true);
			pingTXTimer.start();
			
			addWindowToComponentSelector(ApplicationWrapper.instance.application as DisplayObject);
			
			//set running to true
			running = true;
		}
		
		public function addWindowToComponentSelector(application:DisplayObject):void {
			if (_verifySelector == null) {
				_verifySelector = new ComponentSelector(function(c:UIComponent):void {
					var event:AutomationRecordEvent = new AutomationRecordEvent("record", true, true, c);
					MonkeyLink.monkeyLink.recordEventHandler(event);
				}, application);
			} else {
				_verifySelector.addWindow(application);
			}
		}
		
		
		//Get component ID
		//Returns an object with the properties
		//propID which is the property for recording
		//id witch is the id for recording
		public function getComponentAutomationName(obj: IAutomationObject):Object{
			var id:String;
			var idProp:String;
			if (obj.automationName != null && obj.automationName != "" && (obj.automationName as String).charAt(0) != '_') {
				idProp = "automationName"
				id = obj.automationName;
			} else if (obj is UIComponent && UIComponent(obj).id != null && UIComponent(obj).id != "" && (UIComponent(obj).id as String).charAt(0) != '_') {
				idProp = "id";
				id = UIComponent(obj).id;
			} else {
				idProp = "monkeyID";
				if(obj is UIComponent){
					var objTyped:UIComponent = obj as UIComponent;
					var responcibleParent:UIComponent = findFirstParentWithAutomationName(objTyped);
					if(!responcibleParent){
						if(FLEXMONKEY::vfour){
							var app4:spark.components.Application = FlexGlobals.topLevelApplication as spark.components.Application;
							if(app4){
								id = app4.automationName +"."+ objTyped.className + "."+ getItemsNumber(objTyped, app4 as UIComponent, 1).itemNumber;	
							} else {
								throw new Error("This component can not be found in your app." + mx.utils.ObjectUtil.toString(objTyped));
							}
							
						} else {
							var app3:mx.core.Application = mx.core.Application.application as mx.core.Application;
							if(app3){
								id = app3.automationName +"."+ objTyped.className + "."+ getItemsNumber(objTyped, app3 as UIComponent, 1).itemNumber;	
							} else {
								throw new Error("This component can not be found in your app." + mx.utils.ObjectUtil.toString(objTyped));
							}
						}
					} else {
						id = responcibleParent.automationName +"."+ objTyped.className + "."+ getItemsNumber(objTyped, responcibleParent as UIComponent, 1).itemNumber;	
					}
				}  else {
					id = "NotAUiComponent";
				}
			}
			return {"idProp":idProp, "id":id};
		}
		public function findFirstParentWithAutomationName(comp:UIComponent):UIComponent{
			if(comp.parent == null){
				return null;
			}
			if((comp.parent as UIComponent).automationName != null && (comp.parent as UIComponent).automationName != ""){
				return comp.parent as UIComponent;
			} else {
				return findFirstParentWithAutomationName(comp.parent as UIComponent);
			}
		}
		public function getItemsNumber(comp:UIComponent, parent:UIComponent, numberOn:int):Object{
			var itemNumber:int = numberOn;
			var itemFound:Boolean = false;
			if(parent != null){
				for (var i:int = 0; i < parent.numChildren; i++){
					var ch:DisplayObject = parent.getChildAt(i);
					if(ch == comp){
						itemFound = true;
						return {"itemNumber": itemNumber, "itemFound": itemFound};
						
					} else if(ch is UIComponent){
						var retVal:Object = getItemsNumber(comp, ch as UIComponent, itemNumber);
						if(retVal.itemFound){
							return retVal;
						}
					}
					else if(mx.utils.ObjectUtil.getClassInfo(ch).name == comp.className){
						itemNumber++;
					}
					
				}
			}
			return {"itemNumber": itemNumber, "itemFound": itemFound};	
		}
		public function recordEventHandler(event:AutomationRecordEvent):void {
			
			var obj:IAutomationObject = event.automationObject;
			var NVPairForRecordProp:Object = this.getComponentAutomationName(obj);
			var idProp:String = NVPairForRecordProp.idProp;
			var id:String = NVPairForRecordProp.id;
			var uiEventCommand:UIEventMonkeyCommand = new UIEventMonkeyCommand();
			uiEventCommand.value = id;
			uiEventCommand.prop = idProp;
			uiEventCommand.command = event.name;
			uiEventCommand.args = event.args;
			
			if (MonkeyAutomationState.monkeyAutomationState.state != MonkeyAutomationState.SNAPSHOT) {
				FMHub.instance.dispatchEvent(new CommandRecordedEvent(uiEventCommand));
			}
			
			switch (MonkeyAutomationState.monkeyAutomationState.state) {
				case MonkeyAutomationState.NORMAL:  {
					writeConsole("Sending RecordEvent when AutomationState NORMAL");
					sendObj("_flexMonkey", "respondNewUIEvent", uiEventCommand);
					break;
				}
				case MonkeyAutomationState.SNAPSHOT:  {
					sendObj("_flexMonkey", "respondNewSnapshot", uiEventCommand);
					var snapEnd:Object = AQAdapter.aqAdapter.endRecording();
					MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
					break;
				}
				default:
					break;
			}
		}
		
		public function startRecording(txCount:uint):void {
			sendAck(txCount);
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.NORMAL;
			AQAdapter.aqAdapter.beginRecording();
			writeConsole("Start recording");
		}
		
		public function stopRecording(txCount:uint):void {
			sendAck(txCount);
			var recordEnd:Object = AQAdapter.aqAdapter.endRecording();
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
			writeConsole("Stop recording");
		}
		
		//
		// env file communication
		//
		
		public function requestLoadEnvFile(txCount:uint):void {
			sendAck(txCount);
			
			sendObj(txChannelName, "respondLoadEnvFile",
				{ usingDefaultEnv: AQAdapter.aqAdapter.usingDefaultEnv, envData: AQAdapter.aqAdapter.envData });
		}
		
		//
		// application tree communication
		//
		
		public function requestLoadApplicationAutomationTree(txCount:uint):void {
			sendAck(txCount);
			sendObj(txChannelName, "respondLoadApplicationAutomationTree", MonkeyUtils.getApplicationTreeInfo());
		}
		
		//
		// ui event command communication
		//
		
		public function respondRunCommand(commandByteArray:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var command:MonkeyRunnable = loadObj(commandByteArray, status, txCount) as MonkeyRunnable;
			
			if (command != null) {
				writeConsole("MonkeyLink: runCommand deserialized command "
					+ ((command is UIEventMonkeyCommand) ? UIEventMonkeyCommand(command).command : "non-UIEventMonkeyCommand")
					+ " "
					+ ((command is UIEventMonkeyCommand) ? UIEventMonkeyCommand(command).value : "")
				);
				
				// run the command:
				if (command is UIEventMonkeyCommand) {
					(command as UIEventMonkeyCommand).run(function(dontuse:Object, errorMessage:String):void {
						// send the completed command back to the monkey here:
						sendObj("_flexMonkey", "respondUiCommandReturn", [ command, errorMessage ]);
						writeConsole("MonkeyLink: runCommand completion sent uiCommandReturn on "
							+ ((command is UIEventMonkeyCommand) ? UIEventMonkeyCommand(command).command : "non-UIEventMonkeyCommand")
							+ " "
							+ ((command is UIEventMonkeyCommand) ? UIEventMonkeyCommand(command).value : "")
						);
					});
				} else {
					writeConsole("MonkeyLink: runCommand could not execute command");
				}
			}
		}
		
		//
		// verify communications
		//
		
		public function selectComponent(txCount:uint):void {
			sendAck(txCount);
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.SNAPSHOT;
			AQAdapter.aqAdapter.beginRecording();
		}
		
		public function cancelComponentSelection(txCount:uint):void {
			sendAck(txCount);
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
			AQAdapter.aqAdapter.endRecording();
		}
		
		public function getVerifyTarget(ba:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var verify:VerifyMonkeyCommand = loadObj(ba, status, txCount) as VerifyMonkeyCommand;
			
			if (verify != null) {
				var targetVO:TargetVO;
				var errorMessage:String;
				
				try {
					writeConsole("returnTarget method invoked");
					targetVO = verify.loadTarget();
				} catch (error:Error) {
					errorMessage = error.message;
				}
				
				sendObj("_flexMonkey", "respondNewTarget", [ targetVO, errorMessage, verify ]);
			}
		}
		
		public function loadComponentProperties(ba:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var verify:VerifyMonkeyCommand = loadObj(ba, status, txCount) as VerifyMonkeyCommand;
			
			if (verify != null) {
				var targetVO:TargetVO;
				var errorMessage:String;
				
				try {
					targetVO = verify.loadTarget(false);
					targetVO.snapshotVO.bitmapData = null;
				} catch (error:Error) {
					errorMessage = error.message;
				}
				
				sendObj("_flexMonkey", "respondNewTarget", [ targetVO, errorMessage ]);
			}
		}
		
		//
		// verify prop communications
		//
		
		public function getVerifyProp(ba:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var verify:VerifyPropertyMonkeyCommand = loadObj(ba, status, txCount) as VerifyPropertyMonkeyCommand;
			
			if (verify != null) {
				var value:Object;
				var errorMessage:String;
				
				try {
					value = verify.getVerifyPropertyValue()
				} catch (error:Error) {
					errorMessage = error.message;
				}
				
				sendObj("_flexMonkey", "respondVerifyProp", [ value, errorMessage, verify ]);
			}
		}
		
		//
		// verify grid communication
		//
		
		public function respondGridCell(ba:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var verifyGridMonkeyCommand:VerifyGridMonkeyCommand = loadObj(ba, status, txCount) as VerifyGridMonkeyCommand;
			
			if (verifyGridMonkeyCommand != null) {
				writeConsole("MonkeyLink: getGridCell - " + verifyGridMonkeyCommand.shortDescription);
				
				var errorMessage:String;
				var actualValue:String;
				
				try {
					actualValue = verifyGridMonkeyCommand.getCellValue();
				} catch (error:Error) {
					errorMessage = error.message;
				}
				
				writeConsole('MonkeyLink: respondGridCell - sending actualValue="' + actualValue + '"');
				sendObj("_flexMonkey", "respondGridCell", [ actualValue, errorMessage, verifyGridMonkeyCommand ]);
			}
		}
		
		//
		// set property communication
		//
		
		public function respondSetPropertyCommand(commandByteArray:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var command:MonkeyRunnable = loadObj(commandByteArray, status, txCount) as MonkeyRunnable;
			
			if (command != null) {
				// run the command:
				if (command is SetPropertyMonkeyCommand) {
					(command as SetPropertyMonkeyCommand).run(function(command:Object, errorMessage:String):void {
						sendObj("_flexMonkey", "respondSetPropertyCommand", [ command, errorMessage ]);
					});
				} else {
					writeConsole("MonkeyLink: respondSetPropertyCommand could not execute command");
				}
			}
		}
		
		//
		// store value communication
		//
		
		public function respondStoreValueCommand(commandByteArray:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var command:MonkeyRunnable = loadObj(commandByteArray, status, txCount) as MonkeyRunnable;
			
			if (command != null) {
				// run the command:
				if (command is StoreValueMonkeyCommand) {
					(command as StoreValueMonkeyCommand).load(function(command:Object, actualValue:Object, errorMessage:String):void {
						sendObj("_flexMonkey", "respondStoreValueCommand", [ command, actualValue, errorMessage ]);
					});
				} else {
					writeConsole("MonkeyLink: respondStoreValueCommand could not execute command");
				}
			}
		}
		
		//
		// call function communication
		//
		
		public function respondCallFunctionCommand(commandByteArray:ByteArray, status:String, txCount:uint):void {
			sendAck(txCount);
			var command:MonkeyRunnable = loadObj(commandByteArray, status, txCount) as MonkeyRunnable;
			
			if (command != null) {
				// run the command:
				if (command is CallFunctionMonkeyCommand) {
					(command as CallFunctionMonkeyCommand).run(function(command:Object, errorMessage:String):void {
						sendObj("_flexMonkey", "respondCallFunctionCommand", [ command, errorMessage ]);
					});
				} else {
					writeConsole("MonkeyLink: respondCallFunctionCommand could not execute command");
				}
			}
		}
		
		
		//
		// version number
		//
		
		public function requestMonkeyLinkVersionNumber(txCount:uint):void {
			sendObj("_flexMonkey", "respondMonkeyLinkVersionNumber", [ FMLibraryVersionUtil.libraryVersion ]);
		}
		
		
		// Called from FlexMonkiumConsole when new Verify has been created
		public function newVerifyProperty(ba:ByteArray, status:String, txCount:uint = 0):void {
			sendAck(txCount);
			var verifyMonkeyCommand:VerifyMonkeyCommand = loadObj(ba, status, txCount) as VerifyMonkeyCommand;
			
			if (verifyMonkeyCommand != null) {
				FlexMonkium.sendVerifyToSelenium(verifyMonkeyCommand);
			}
		}
		
	}
}