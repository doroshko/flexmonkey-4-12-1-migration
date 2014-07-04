/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

    public class CallFunctionMonkeyCommandXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var cmd:CallFunctionMonkeyCommand = obj as CallFunctionMonkeyCommand;

            var xml:XML = <CallFunctionMonkeyCommand
                    value={cmd.value}
                    prop={cmd.prop}
                    functionName={cmd.functionName}
                    retryOnlyOnResponse={cmd.retryOnlyOnResponse} />

            if (!FMStringUtil.isEmpty(cmd.containerValue)) {
                xml.@containerValue = cmd.containerValue;
            }

            if (!FMStringUtil.isEmpty(cmd.containerProp)) {
                xml.@containerProp = cmd.containerProp;
            }

            if (!short) {
                xml.@description = cmd.description;
                xml.@isRetryable = cmd.isRetryable;
                xml.@delay = cmd.delay;
                xml.@attempts = cmd.attempts;
            }

            for (var i:uint; i < cmd.args.length; i++) {
                xml.appendChild(<arg value={cmd.args[i]}/>);
            }

            return xml;
        }

        public function decode(x:XML):Object {
            var cmd:CallFunctionMonkeyCommand = new CallFunctionMonkeyCommand();
            cmd.description = x.@description;
            cmd.value = x.@value;
            cmd.prop = x.@prop;
            cmd.containerValue = x.@containerValue;
            cmd.containerProp = x.@containerProp;
            cmd.isRetryable = true; //always true
            cmd.functionName = x.@functionName;
            cmd.retryOnlyOnResponse = (x.@retryOnlyOnResponse == "true");

            if (cmd.isRetryable) {
                cmd.attempts = x.@attempts;
                cmd.delay = x.@delay;
            }

            cmd.args = [];
            var argNodes:XMLList = x.elements();
            for (var i:int = 0; i < argNodes.length(); i++) {
                 cmd.args[i] = argNodes[i].@value.toString();
            }

            return cmd;
        }

    }
}