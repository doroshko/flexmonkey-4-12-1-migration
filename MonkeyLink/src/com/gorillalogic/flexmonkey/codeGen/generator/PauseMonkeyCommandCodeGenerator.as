/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.codeGen.generator {
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
	
	public class PauseMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {
		
		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;\n";
		
		public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}
			
			var pauseCmd:PauseMonkeyCommand = cmd as PauseMonkeyCommand;
			return "new PauseMonkeyCommand(" + pauseCmd.duration + ")";
		}	
		
	}
	
}
