package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

    public class UIEventMonkeyCommandXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var cmd:UIEventMonkeyCommand = obj as UIEventMonkeyCommand;

            var xml:XML;

            if (short) {
				xml = <UIEvent command={cmd.command} value={cmd.value} />
				if (cmd.prop != "automationName") {
					xml.@prop = cmd.prop;
				}
            } else {
                xml = <UIEvent command={cmd.command}
                        value={cmd.value}
                        prop={cmd.prop}
                        delay={cmd.delay}
                        attempts={cmd.attempts}
                        retryOnlyOnResponse={cmd.retryOnlyOnResponse} />
            }

            if (!FMStringUtil.isEmpty(cmd.containerValue)) {
                xml.@containerValue = cmd.containerValue
            }
            ;

            if (!FMStringUtil.isEmpty(cmd.containerProp)) {
                xml.@containerProp = cmd.containerProp
            }
            ;

            for (var i:uint; i < cmd.args.length; i++) {
                xml.appendChild(<arg value={cmd.args[i]}/>);
            }

            return xml;
        }

        public function decode(x:XML):Object {
            var uiEventCommand:UIEventMonkeyCommand = new UIEventMonkeyCommand();

            uiEventCommand.command = x.@command;
            uiEventCommand.value = x.@value;
            uiEventCommand.prop = x.@prop;
            uiEventCommand.attempts = x.@attempts;
            uiEventCommand.delay = x.@delay;
            uiEventCommand.containerValue = x.@containerValue;
            uiEventCommand.containerProp = x.@containerProp;
            uiEventCommand.retryOnlyOnResponse = (x.@retryOnlyOnResponse == "true");

            var uiEventArgs:Array = new Array();
            var argNodes:XMLList = x.elements();

            for (var i:int = 0; i < argNodes.length(); i++) {
                uiEventArgs[i] = argNodes[i].@value.toString();
            }
            uiEventCommand.args = uiEventArgs;

            return uiEventCommand;
        }

    }
}