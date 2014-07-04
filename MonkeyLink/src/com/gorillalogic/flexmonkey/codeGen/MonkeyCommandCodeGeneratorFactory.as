/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen {

    import com.gorillalogic.flexmonkey.codeGen.generator.CallFunctionMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.PauseMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.SetPropertyMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.StoreValueMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.UIEventMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.VerifyGridMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.VerifyMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.codeGen.generator.VerifyPropertyMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;

    import flash.utils.getQualifiedClassName;

    public class MonkeyCommandCodeGeneratorFactory {

        public static function generateCode(cmd:Object, cmdImports:Array):String {
            var generator:IMonkeyCommandCodeGenerator;

            if (cmd is VerifyPropertyMonkeyCommand) {
                generator = new VerifyPropertyMonkeyCommandCodeGenerator();
            } else if (cmd is VerifyMonkeyCommand) {
                generator = new VerifyMonkeyCommandCodeGenerator();
            } else if (cmd is VerifyGridMonkeyCommand) {
                generator = new VerifyGridMonkeyCommandCodeGenerator();
            } else if (cmd is UIEventMonkeyCommand) {
                generator = new UIEventMonkeyCommandCodeGenerator();
			} else if (cmd is StoreValueMonkeyCommand) {
				generator = new StoreValueMonkeyCommandCodeGenerator();
			} else if (cmd is SetPropertyMonkeyCommand) {
				generator = new SetPropertyMonkeyCommandCodeGenerator();
			} else if (cmd is PauseMonkeyCommand) {
				generator = new PauseMonkeyCommandCodeGenerator();
            } else if (cmd is CallFunctionMonkeyCommand) {
                generator = new CallFunctionMonkeyCommandCodeGenerator();
            }

            if (generator == null) {
                throw new Error("There is no code generator for class: " + getQualifiedClassName(cmd));
            }

            return generator.getAS3(cmd, cmdImports);
        }

    }

}
