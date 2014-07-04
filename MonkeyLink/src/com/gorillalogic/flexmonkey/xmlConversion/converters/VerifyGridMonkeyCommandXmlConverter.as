package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

    public class VerifyGridMonkeyCommandXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var cmd:VerifyGridMonkeyCommand = obj as VerifyGridMonkeyCommand;

            var xml:XML = <VerifyGrid value={cmd.value} 
                    description={cmd.description}
                    prop={cmd.prop} 
                    row={cmd.row} 
                    col={cmd.col} 
                    expectedValue={cmd.expectedValue} />;

            if (!FMStringUtil.isEmpty(cmd.containerValue)) {
                xml.@containerValue = cmd.containerValue;
            }

            if (!FMStringUtil.isEmpty(cmd.containerProp)) {
                xml.@containerProp = cmd.containerProp;
            }


            xml.@isRetryable = cmd.isRetryable;
            xml.@delay = cmd.delay;
            xml.@attempts = cmd.attempts;

            return xml;
        }

        public function decode(x:XML):Object {
            var verifyDesc:String = x.@description;
            var verifyValue:String = x.@value;
            var verifyProp:String = x.@prop;
            var verifyRow:String = x.@row;
            var verifyCol:String = x.@col;
            var verifyExpectedValue:String = x.@expectedValue;
            var verifyContainerValue:String = x.@containerValue;
            var verifyContainerProp:String = x.@containerProp;
            //var verifyIsRetryable:Boolean = (x.@isRetryable == "true");
            var verifyIsRetryable:Boolean = true; // always true
            var verifyAttempts:String = x.@attempts;
            var verifyDelay:String = x.@delay;

            return new VerifyGridMonkeyCommand(
                verifyDesc,
                verifyValue,
                verifyProp,
                parseInt(verifyRow),
                parseInt(verifyCol),
                verifyExpectedValue,
                verifyContainerValue,
                verifyContainerProp,
                verifyIsRetryable,
                verifyAttempts,
                verifyDelay);
        }

    }
}