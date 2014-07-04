/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

	import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
	import com.gorillalogic.utils.FMStringUtil;

	public class VerifyGridMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {

		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;\n";

		public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}

			var gridCmd:VerifyGridMonkeyCommand = cmd as VerifyGridMonkeyCommand;

			var a:Array = [
				FMStringUtil.formatForOutput(gridCmd.description),
				FMStringUtil.formatForOutput(gridCmd.value),
				FMStringUtil.formatForOutput(gridCmd.prop),
				gridCmd.row,
				gridCmd.col,
				FMStringUtil.formatForOutput(gridCmd.expectedValue)];

			if (!FMStringUtil.isEmpty(gridCmd.containerValue)) {
				a.push(FMStringUtil.formatForOutput(gridCmd.containerValue));
			} else {
				a.push(FMStringUtil.formatForOutput(null));
			}

			if (!FMStringUtil.isEmpty(gridCmd.containerProp)) {
				a.push(FMStringUtil.formatForOutput(gridCmd.containerProp));
			} else {
				a.push(FMStringUtil.formatForOutput(null))
			}

			//add retry options
			a.push(FMStringUtil.formatForOutput(gridCmd.isRetryable).toString());
			a.push(FMStringUtil.formatForOutput(gridCmd.attempts));
			a.push(FMStringUtil.formatForOutput(gridCmd.delay));

			return 'new VerifyGridMonkeyCommand(' + a.join(', ') + ')';
		}
	}

}
