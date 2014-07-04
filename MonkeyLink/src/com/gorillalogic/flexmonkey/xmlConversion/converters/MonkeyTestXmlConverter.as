package com.gorillalogic.flexmonkey.xmlConversion.converters {

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;
    import com.gorillalogic.flexmonkey.xmlConversion.XmlConversionFactory;

    public class MonkeyTestXmlConverter implements IXmlConverter {

        public function encode(obj:Object, short:Boolean = false):XML {
            var monkeyTest:MonkeyTest = obj as MonkeyTest;

            var xml:XML = <Test name={monkeyTest.name}
                    description={monkeyTest.description}
                    defaultThinkTime={monkeyTest.defaultThinkTime}
                    ignore={monkeyTest.ignore}/>

            for each (var c:Object in monkeyTest.children) {
                xml.appendChild(XmlConversionFactory.encode(c, short));
            }

            return xml;
        }

        public function decode(x:XML):Object {
            var newTest:MonkeyTest = new MonkeyTest();
            newTest.name = x.@name;
            newTest.description = x.@description;
            newTest.ignore = (x.@ignore == "true");

            // This XML may have been generated internally via new project creation code.
            // In this case make sure default defaultThinkTime from MonkeyTest class gets used.
            var rawDefaultThinkTime:String = x.@defaultThinkTime;

            if (rawDefaultThinkTime != "") {
                newTest.defaultThinkTime = parseInt(rawDefaultThinkTime);
            }

            return newTest;
        }
    }
}