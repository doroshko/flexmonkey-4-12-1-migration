package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.utils.FMXmlUtil;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;

    import mx.collections.ArrayCollection;

    public class VerifyMonkeyCommandXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var cmd:VerifyMonkeyCommand = obj as VerifyMonkeyCommand;
            var xml:XML = <Verify value={cmd.value} prop={cmd.prop} />

            if (!FMStringUtil.isEmpty(cmd.containerValue)) {
                xml.@containerValue = cmd.containerValue
            }
            ;

            if (!FMStringUtil.isEmpty(cmd.containerProp)) {
                xml.@containerProp = cmd.containerProp
            }
            ;

            if (!short) {
                xml.@description = cmd.description;
                xml.@isRetryable = cmd.isRetryable;
                xml.@delay = cmd.delay;
                xml.@attempts = cmd.attempts;
                xml.@verifyBitmap = cmd.verifyBitmap;
                xml.@snapshotURL = cmd.snapshotURL;
                xml.@verifyBitmapFuzziness = cmd.verifyBitmapFuzziness;
            }

            for each (var attribute:AttributeVO in cmd.attributes) {
                var attributeXML:XML = attribute.asXML(short);
                xml.appendChild(attributeXML);
            }
            return xml;
        }

        public function decode(x:XML):Object {
            var verifyCommand:VerifyMonkeyCommand = new VerifyMonkeyCommand();

            verifyCommand.description = x.@description;
            verifyCommand.value = x.@value;
            verifyCommand.prop = x.@prop;
            verifyCommand.containerValue = x.@containerValue;
            verifyCommand.containerProp = x.@containerProp;
            verifyCommand.verifyBitmap = (x.@verifyBitmap == "true");
            verifyCommand.verifyBitmapFuzziness = FMXmlUtil.parseIntFromXMLAttr(x, 'verifyBitmapFuzziness');
            verifyCommand.snapshotURL = x.@snapshotURL;
            verifyCommand.isRetryable = true; // always true;

            if (verifyCommand.isRetryable) {
                verifyCommand.attempts = x.@attempts;
                verifyCommand.delay = x.@delay;
            }

            var attributeNodes:XMLList = x.elements("Attribute");
            var attributes:ArrayCollection = new ArrayCollection();

            for (var i:int = 0; i < attributeNodes.length(); i++) {
                var attributeNode:XML = attributeNodes[i];
                var attribute:AttributeVO = new AttributeVO();
                attribute.name = attributeNode.@name;
                attribute.expectedValue = attributeNode.@expectedValue;
                attribute.type = attributeNode.@type;
                attribute.selected = true;
                attributes.addItem(attribute);
            }
            verifyCommand.attributes = attributes;

            return verifyCommand;
        }

    }
}