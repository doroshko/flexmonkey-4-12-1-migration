package com.gorillalogic.flexmonkey.codeGen.generator {

	import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
	import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
	import com.gorillalogic.utils.FMStringUtil;

	public class StoreValueMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {

		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;\n";

		protected function getProperties(cmd:StoreValueMonkeyCommand):Array {
			var a:Array = [
				FMStringUtil.formatForOutput(cmd.description),
				FMStringUtil.formatForOutput(cmd.value),
				FMStringUtil.formatForOutput(cmd.prop),
			];


			if (!FMStringUtil.isEmpty(cmd.containerValue)) {
				a.push(FMStringUtil.formatForOutput(cmd.containerValue));
			} else {
				a.push(FMStringUtil.formatForOutput(null));
			}

			if (!FMStringUtil.isEmpty(cmd.containerProp)) {
				a.push(FMStringUtil.formatForOutput(cmd.containerProp));
			} else {
				a.push(FMStringUtil.formatForOutput(null))
			}

			a.push(FMStringUtil.formatForOutput(cmd.isRetryable));
			a.push(FMStringUtil.formatForOutput(cmd.delay));
			a.push(FMStringUtil.formatForOutput(cmd.attempts));
			a.push(FMStringUtil.formatForOutput(cmd.propertyString));
			a.push(FMStringUtil.formatForOutput(cmd.keyName));

			return a;
		}

		public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}

			var setCmd:StoreValueMonkeyCommand = cmd as StoreValueMonkeyCommand;
			var a:Array = getProperties(setCmd);
			return 'new StoreValueMonkeyCommand(' + getProperties(setCmd).join(', ') + ')';
		}
	}
}