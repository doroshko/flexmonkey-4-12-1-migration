package com.gorillalogic.flexunit
{
	import com.gorillalogic.flexmonkey.vo.TargetVO;

	public class FlexMonkeyNestedRunner extends FlexMonkeyInternalRunner
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
		
		import com.gorillalogic.flexunit.FlexMonkeyNestedRunnerTest;
			
		public function FlexMonkeyNestedRunner(clazz:Class)
		{
			super(clazz);
		}
		
		/**
		 * runs the selected command and assigns async handlers for processing results
		 */
		override protected function runCommand():void {
			if (currentCommand.runIgnore) {
				if (this.doTrace) {
					trace("FlexMonkeyNestedRunner.runCommand, currentCommand= \"" + currentCommand + "\" (ignored)");
				}
				finishCommand(false, true);
			} else {
				var errorMessage:String = null;
				if (this.doTrace) {
					trace("FlexMonkeyNestedRunner.runCommand, currentCommand= \"" + currentCommand + "\"");
				}
				if (currentCommand is UIEventMonkeyCommand) {
					(currentCommand as UIEventMonkeyCommand).run(function ():void {
						commandReturn(currentCommand, errorMessage);;
					});
					
				} else if (currentCommand is CallFunctionMonkeyCommand) {
					(currentCommand as CallFunctionMonkeyCommand).run(function ():void {
						commandReturn(currentCommand, errorMessage);;
					});
					
				} else if (currentCommand is SetPropertyMonkeyCommand) {
					(currentCommand as SetPropertyMonkeyCommand).loadFinalSetToValue();
					(currentCommand as SetPropertyMonkeyCommand).run(function ():void {
						commandReturn(currentCommand, errorMessage);;
					});
					
				} else if (currentCommand is StoreValueMonkeyCommand) {
					(currentCommand as StoreValueMonkeyCommand).load(storeValueReturn);
					
				} else if (currentCommand is VerifyGridMonkeyCommand) {
					(currentCommand as VerifyGridMonkeyCommand).loadFinalExpectedValue();
					var actualValue:String;
					
					try {
						actualValue = (currentCommand as VerifyGridMonkeyCommand).getCellValue();
					} catch (error:Error) {
						errorMessage = error.message;
					}
					
					this.verifyReturn(actualValue, currentCommand, errorMessage);
					
				} else if (currentCommand is VerifyPropertyMonkeyCommand) {
					(currentCommand as VerifyPropertyMonkeyCommand).loadFinalExpectedValue();
					var value:Object;
					
					try {
						value = (currentCommand as VerifyPropertyMonkeyCommand).getVerifyPropertyValue();
					} catch (error:Error) {
						errorMessage = error.message;
					}

					this.verifyReturn(value, currentCommand, errorMessage);
					
				} else if (currentCommand is VerifyMonkeyCommand) {
					(currentCommand as VerifyMonkeyCommand).loadFinalExpectedValues();
					var targetVO:TargetVO;
					
					try {
						// writeConsole("returnTarget method invoked");
						targetVO = (currentCommand as VerifyMonkeyCommand).loadTarget();
					} catch (error:Error) {
						errorMessage = error.message;
					}
					this.verifyReturn(targetVO, currentCommand, errorMessage);
				}
			}			
		}
		
	}
}