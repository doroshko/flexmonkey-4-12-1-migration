package com.gorillalogic.flexmonkey.xmlConversion {

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.CallFunctionMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.MonkeyTestCaseXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.MonkeyTestSuiteXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.MonkeyTestXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.PauseMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.SetPropertyMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.StoreValueMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.UIEventMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.VerifyGridMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.VerifyMonkeyCommandXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.converters.VerifyPropertyMonkeyCommandXmlConverter;

    import flash.utils.getQualifiedClassName;

    public class XmlConversionFactory {

        public static function encode(obj:Object, short:Boolean = false):XML {
            var converter:IXmlConverter;

            if (obj is MonkeyTestSuite) {
                converter = new MonkeyTestSuiteXmlConverter();
            } else if (obj is MonkeyTestCase) {
                converter = new MonkeyTestCaseXmlConverter();
            } else if (obj is MonkeyTest) {
                converter = new MonkeyTestXmlConverter();
            } else if (obj is PauseMonkeyCommand) {
                converter = new PauseMonkeyCommandXmlConverter();
            } else if (obj is UIEventMonkeyCommand) {
                converter = new UIEventMonkeyCommandXmlConverter();
            } else if (obj is VerifyPropertyMonkeyCommand) {
                converter = new VerifyPropertyMonkeyCommandXmlConverter();
            } else if (obj is VerifyMonkeyCommand) {
                converter = new VerifyMonkeyCommandXmlConverter();
            } else if (obj is VerifyGridMonkeyCommand) {
                converter = new VerifyGridMonkeyCommandXmlConverter();
            } else if (obj is SetPropertyMonkeyCommand) {
                converter = new SetPropertyMonkeyCommandXmlConverter();
            } else if (obj is StoreValueMonkeyCommand) {
                converter = new StoreValueMonkeyCommandXmlConverter();
            } else if (obj is CallFunctionMonkeyCommand) {
                converter = new CallFunctionMonkeyCommandXmlConverter();
            }

            if (converter == null) {
                throw new Error("No XML Converter for class: " + getQualifiedClassName(obj));
            }

            return converter.encode(obj, short);
        }

        public static function decode(xml:XML):Object {
            var converter:IXmlConverter;

            if (xml.localName() == "TestSuite") {
                converter = new MonkeyTestSuiteXmlConverter();
            } else if (xml.localName() == "TestCase") {
                converter = new MonkeyTestCaseXmlConverter();
            } else if (xml.localName() == "Test") {
                converter = new MonkeyTestXmlConverter();
            } else if (xml.localName() == "UIEvent") {
                converter = new UIEventMonkeyCommandXmlConverter();
            } else if (xml.localName() == "Pause") {
                converter = new PauseMonkeyCommandXmlConverter();
            } else if (xml.localName() == "Verify") {
                converter = new VerifyMonkeyCommandXmlConverter();
            } else if (xml.localName() == "VerifyGrid") {
                converter = new VerifyGridMonkeyCommandXmlConverter();
            } else if (xml.localName() == "VerifyProperty") {
                converter = new VerifyPropertyMonkeyCommandXmlConverter();
            } else if (xml.localName() == "SetPropertyCommand") {
                converter = new SetPropertyMonkeyCommandXmlConverter();
            } else if (xml.localName() == "StoreValueMonkeyCommand") {
                converter = new StoreValueMonkeyCommandXmlConverter();
            } else if (xml.localName() == "CallFunctionMonkeyCommand") {
                converter = new CallFunctionMonkeyCommandXmlConverter();
            }

            if (converter == null) {
                throw new Error("No XML Converter for node: " + xml.localName());
            }

            return converter.decode(xml);
        }

    }

}
