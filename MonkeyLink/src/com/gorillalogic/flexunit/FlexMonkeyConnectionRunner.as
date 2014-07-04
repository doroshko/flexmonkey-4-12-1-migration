package com.gorillalogic.flexunit
{
	public class FlexMonkeyConnectionRunner extends FlexMonkeyInternalRunner
	{
		
		import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.IVerifyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
		import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
		
		import com.gorillalogic.flexunit.FlexMonkeyConnectionRunnerTest;
		import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;
		private var connection:MonkeyLinkConsoleConnectionController;
		
		public function FlexMonkeyConnectionRunner(clazz:Class)
		{
			super(clazz);
			this.connection = MonkeyLinkConsoleConnectionController.instance;
		}
		/**
		 * runs the selected command and assigns async handlers for processing results
		 */
		override protected function runCommand():void {
			trace("FlexMonkeyConnectionRunner.runCommand, currentCommand= \"" + currentCommand + "\"");			
			if (currentCommand.runIgnore) {
				finishCommand(false, true);
			} else {
				if (currentCommand is UIEventMonkeyCommand) {
					connection.requestRunCommand(currentCommand as UIEventMonkeyCommand, commandReturn);
					
				} else if (currentCommand is CallFunctionMonkeyCommand) {
					connection.requestCallFunctionCommand(currentCommand as CallFunctionMonkeyCommand, commandReturn);
					
				} else if (currentCommand is SetPropertyMonkeyCommand) {
					(currentCommand as SetPropertyMonkeyCommand).loadFinalSetToValue();
					connection.requestSetPropertyCommand(currentCommand as SetPropertyMonkeyCommand, commandReturn);
					
				} else if (currentCommand is StoreValueMonkeyCommand) {
					connection.requestStoreValueCommand(currentCommand as StoreValueMonkeyCommand, storeValueReturn);
					
				} else if (currentCommand is VerifyGridMonkeyCommand) {
					(currentCommand as VerifyGridMonkeyCommand).loadFinalExpectedValue();
					connection.requestGridCell(currentCommand as VerifyGridMonkeyCommand, verifyReturn);
					
				} else if (currentCommand is VerifyPropertyMonkeyCommand) {
					(currentCommand as VerifyPropertyMonkeyCommand).loadFinalExpectedValue();
					connection.requestVerifyProp(currentCommand as VerifyPropertyMonkeyCommand, verifyReturn);
					
				} else if (currentCommand is VerifyMonkeyCommand) {
					(currentCommand as VerifyMonkeyCommand).loadFinalExpectedValues();
					connection.requestVerifyTarget(currentCommand as VerifyMonkeyCommand, verifyReturn);
				}
			}
			
		}
		
	}
}