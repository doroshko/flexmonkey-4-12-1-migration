package com.gorillalogic.flexmonkey.xmlConversion {
	
	public interface IXmlConverter {
		function encode(obj:Object, short:Boolean=false):XML;
		function decode(xml:XML):Object;
	}
	
}
