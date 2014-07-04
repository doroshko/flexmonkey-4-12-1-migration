package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.XmlConversionFactory;

    public class MonkeyTestCaseXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var testCase:MonkeyTestCase = obj as MonkeyTestCase;

            var xml:XML = <TestCase name={testCase.name}
                    description={testCase.description}
                    ignore={testCase.ignore}/>

            for each (var c:Object in testCase.children) {
                xml.appendChild(XmlConversionFactory.encode(c, short));
            }

            return xml;
        }

        public function decode(x:XML):Object {
            var newTestCase:MonkeyTestCase = new MonkeyTestCase();
            newTestCase.name = x.@name;
            newTestCase.description = x.@description;
            newTestCase.ignore = (x.@ignore == "true");
            return newTestCase;
        }

    }

}
