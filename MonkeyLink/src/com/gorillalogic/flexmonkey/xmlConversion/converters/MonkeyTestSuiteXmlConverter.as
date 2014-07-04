package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.XmlConversionFactory;

    import mx.collections.ArrayCollection;

    public class MonkeyTestSuiteXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var suite:MonkeyTestSuite = obj as MonkeyTestSuite;

            var xml:XML = <TestSuite name={suite.name}
                    description={suite.description}
                    ignore={suite.ignore}/>

            for each (var testCase:MonkeyTestCase in suite.children) {
                xml.appendChild(XmlConversionFactory.encode(testCase, short));
            }
            return xml;
        }

        public function decode(x:XML):Object {
            var newTestSuite:MonkeyTestSuite = new MonkeyTestSuite();
            newTestSuite.name = x.@name;
            newTestSuite.description = x.@description;
            newTestSuite.ignore = (x.@ignore == "true");
            return newTestSuite;
        }

    }

}
