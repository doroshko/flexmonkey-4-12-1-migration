/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.codeGen.generator {
	
	import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.utils.FMStringUtil;
	
	public class UIEventMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {
		
		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;\n";
		
		public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}
			
			var uiEvent:UIEventMonkeyCommand = cmd as UIEventMonkeyCommand;
			
			var argsString:String = FMStringUtil.formatForOutput(uiEvent.args[0]);			
			for each (var arg:String in uiEvent.args.slice(1)) {
				argsString += ", " + FMStringUtil.formatForOutput(arg); 
			}						
			var commandString:String = "new UIEventMonkeyCommand("
				+ FMStringUtil.formatForOutput(uiEvent.command) + ", "
				+ FMStringUtil.formatForOutput(uiEvent.value) + ", "
				+ FMStringUtil.formatForOutput(uiEvent.prop) +  ", "
				+ "[" 
				+ argsString 
				+ "]";
			
			if ( !FMStringUtil.isEmpty(uiEvent.containerValue) || !FMStringUtil.isEmpty(uiEvent.containerProp) ) {
				commandString += 
					", " + FMStringUtil.formatForOutput(uiEvent.containerValue)
					+ ", " + FMStringUtil.formatForOutput(uiEvent.containerProp);
			} else {
				commandString += ", '', ''";				
			}
			
			commandString +=  ", " + FMStringUtil.formatForOutput(uiEvent.attempts);
			commandString +=  ", " + FMStringUtil.formatForOutput(uiEvent.delay);			
			commandString +=  ", " + FMStringUtil.formatForOutput(uiEvent.retryOnlyOnResponse);

			commandString += ")";
			return commandString;
		}		
	}
}