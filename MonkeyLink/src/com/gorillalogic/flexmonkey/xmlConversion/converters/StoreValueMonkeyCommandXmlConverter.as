package com.gorillalogic.flexmonkey.xmlConversion.converters {

	import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
	import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;
	import com.gorillalogic.utils.FMStringUtil;

	public class StoreValueMonkeyCommandXmlConverter implements IXmlConverter {

		public function encode(obj:Object, short:Boolean = false):XML {
			var cmd:StoreValueMonkeyCommand = obj as StoreValueMonkeyCommand;

			var xml:XML = <StoreValueMonkeyCommand value={cmd.value}
			prop={cmd.prop}
			propertyString={cmd.propertyString}
			keyName={cmd.keyName}  />

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
			var cmd:StoreValueMonkeyCommand = new StoreValueMonkeyCommand();
			cmd.description = x.@description;
			cmd.value = x.@value;
			cmd.prop = x.@prop;
			cmd.containerValue = x.@containerValue;
			cmd.containerProp = x.@containerProp;
			cmd.isRetryable = true; //always true
			cmd.propertyString = x.@propertyString;
			cmd.keyName = x.@keyName;

			if (cmd.isRetryable) {
				cmd.attempts = x.@attempts;
				cmd.delay = x.@delay;
			}

			return cmd;
		}

	}
}