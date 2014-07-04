package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.utils.FMXmlUtil;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

    public class VerifyPropertyMonkeyCommandXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var cmd:VerifyPropertyMonkeyCommand = obj as VerifyPropertyMonkeyCommand;
            var xml:XML = <VerifyProperty value={cmd.value} 
                    propertyString={cmd.propertyString}
                    expectedValue={cmd.expectedValue}
                    propertyType={cmd.propertyType}
                    />
			
			if (!short) {
				xml.@prop = cmd.prop;
			} else {
				if (cmd.prop != "automationName") {
					xml.@prop = cmd.prop;
				}
			}
			

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
            var verifyCommand:VerifyPropertyMonkeyCommand = new VerifyPropertyMonkeyCommand();

            verifyCommand.description = x.@description;
            verifyCommand.value = x.@value;
            verifyCommand.prop = x.@prop;
            verifyCommand.containerValue = x.@containerValue;
            verifyCommand.containerProp = x.@containerProp;
            verifyCommand.isRetryable = true; //always true
            verifyCommand.propertyString = x.@propertyString;
            verifyCommand.expectedValue = x.@expectedValue;

            if (x.@propertyType != null) {
                verifyCommand.propertyType = x.@propertyType;
            } else {
                verifyCommand.propertyType = VerifyPropertyMonkeyCommand.DEFAULT_EQUALS_TYPE;
            }

            if (verifyCommand.isRetryable) {
                verifyCommand.attempts = x.@attempts;
                verifyCommand.delay = x.@delay;
            }

            return verifyCommand;
        }

    }
}