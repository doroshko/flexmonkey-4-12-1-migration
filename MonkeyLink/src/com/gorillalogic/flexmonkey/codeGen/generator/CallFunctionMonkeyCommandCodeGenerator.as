/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;

    public class CallFunctionMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {

        private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;\n";

        public function getAS3(cmdObj:Object, cmdImports:Array):String {
            if (cmdImports.indexOf(importStr) == -1) {
                cmdImports.push(importStr);
            }

            var cmd:CallFunctionMonkeyCommand = cmdObj as CallFunctionMonkeyCommand;

            var a:Array = [
                FMStringUtil.formatForOutput(cmd.description),
                FMStringUtil.formatForOutput(cmd.value),
                FMStringUtil.formatForOutput(cmd.prop),
                FMStringUtil.formatForOutput(cmd.containerValue),
                FMStringUtil.formatForOutput(cmd.containerProp)];

            //add retry options
            a.push(FMStringUtil.formatForOutput(cmd.isRetryable).toString());
            a.push(FMStringUtil.formatForOutput(cmd.delay));
            a.push(FMStringUtil.formatForOutput(cmd.attempts));

            // custom props
            a.push(FMStringUtil.formatForOutput(cmd.functionName));
            a.push(FMStringUtil.formatArrayForOutput(cmd.args));
            a.push(FMStringUtil.formatForOutput(cmd.retryOnlyOnResponse));

            return 'new CallFunctionMonkeyCommand(' + a.join(', ') + ')';
        }
    }

}