/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.core.MonkeyAutomationState;
	import com.gorillalogic.flexmonkey.events.FMRunnerEvent;
	import com.gorillalogic.flexmonkey.events.PayloadEvent;
	import com.gorillalogic.flexmonkey.events.RecordEvent;
	import com.gorillalogic.flexmonkey.model.ApplicationModel;
	import com.gorillalogic.flexmonkey.model.ProjectTestModel;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.framework.FMHub;
	import com.gorillalogic.framework.IFMController;
	import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;
	import com.gorillalogic.utils.MonkeyAutomationManager;

	import flash.events.Event;

	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationRecordEvent;
	import mx.core.UIComponent;

	public class RecordController implements IFMController {

		public function register(hub:FMHub):void {
			hub.listen(RecordEvent.START_RECORDING, startRecordHandler, this);
			hub.listen(RecordEvent.STOP_RECORDING, stopRecordingHandler, this);
			hub.listen(RecordEvent.NEW_UI_EVENT, newUiEventHandler, this);
			hub.listen(RecordEvent.DELETE_ITEMS, deleteItemsEventHandler, this);
			hub.listen(RecordEvent.PLAY_ITEMS, playItemsEventHandler, this);
		}

		private function startRecordHandler(event:Event):void {
			if (ApplicationModel.instance.isConnected) {
				ApplicationModel.instance.isRecording = true;
				MonkeyLinkConsoleConnectionController.instance.startRecording();
			}
		}

		private function stopRecordingHandler(event:Event):void {
			ApplicationModel.instance.isRecording = false;

			if (ApplicationModel.instance.isConnected) {
				MonkeyLinkConsoleConnectionController.instance.stopRecording();
			}
		}

		private function newUiEventHandler(event:RecordEvent):void {
			ProjectTestModel.instance.recordUiEvent(event.uiEventCommand);
		}

		private function deleteItemsEventHandler(event:RecordEvent):void {
			ProjectTestModel.instance.recordItems = null;
		}

		private function playItemsEventHandler(event:RecordEvent):void {
			FMHub.instance.dispatchEvent(new FMRunnerEvent(FMRunnerEvent.SETUP_TEST_RUNNER, null, true));
		}

	}

}
