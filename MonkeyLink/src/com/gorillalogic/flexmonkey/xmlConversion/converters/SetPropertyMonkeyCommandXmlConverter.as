package com.gorillalogic.flexmonkey.xmlConversion.converters {

	import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
	import com.gorillalogic.utils.FMStringUtil;
	import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

	public class SetPropertyMonkeyCommandXmlConverter implements IXmlConverter {

		public function encode(obj:Object, short:Boolean = false):XML {
			var cmd:SetPropertyMonkeyCommand = obj as SetPropertyMonkeyCommand;

			var xml:XML = <SetPropertyCommand value={cmd.value}
				prop={cmd.prop}
				propertyString={cmd.propertyString}
				setToValue={cmd.setToValue}  />

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

			return xml;
		}

		public function decode(x:XML):Object {
			var cmd:SetPropertyMonkeyCommand = new SetPropertyMonkeyCommand();
			cmd.description = x.@description;
			cmd.value = x.@value;
			cmd.prop = x.@prop;
			cmd.containerValue = x.@containerValue;
			cmd.containerProp = x.@containerProp;
			cmd.isRetryable = true; //always true
			cmd.propertyString = x.@propertyString;
			cmd.setToValue = x.@setToValue;

			if (cmd.isRetryable) {
				cmd.attempts = x.@attempts;
				cmd.delay = x.@delay;
			}

			return cmd;
		}

	}
}