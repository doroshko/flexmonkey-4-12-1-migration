/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.utils.FMStringUtil;

    public class VerifyPropertyMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {

		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;\n";

        protected function getProperties(verify:VerifyPropertyMonkeyCommand):Array {
            var a:Array = [
                FMStringUtil.formatForOutput(verify.description),
                FMStringUtil.formatForOutput(verify.value),
                FMStringUtil.formatForOutput(verify.prop),
                ];


            if (!FMStringUtil.isEmpty(verify.containerValue)) {
                a.push(FMStringUtil.formatForOutput(verify.containerValue));
            } else {
                a.push(FMStringUtil.formatForOutput(null));
            }

            if (!FMStringUtil.isEmpty(verify.containerProp)) {
                a.push(FMStringUtil.formatForOutput(verify.containerProp));
            } else {
                a.push(FMStringUtil.formatForOutput(null))
            }

            a.push(FMStringUtil.formatForOutput(verify.isRetryable));
            a.push(FMStringUtil.formatForOutput(verify.delay));
            a.push(FMStringUtil.formatForOutput(verify.attempts));
            a.push(FMStringUtil.formatForOutput(verify.propertyString));
            a.push(FMStringUtil.formatForOutput(verify.expectedValue));
			a.push(FMStringUtil.formatForOutput(verify.propertyType));

            return a;
        }

        public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}

            var verify:VerifyPropertyMonkeyCommand = cmd as VerifyPropertyMonkeyCommand;
            var a:Array = getProperties(verify);
            return 'new VerifyPropertyMonkeyCommand(' + getProperties(verify).join(', ') + ')';
        }

    }
}