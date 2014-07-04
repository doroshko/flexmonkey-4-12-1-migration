package com.gorillalogic.utils {
	
	public class FMXmlUtil {

		public static function parseIntFromXMLAttr(x:XML, attr:String, defaultValue:int = 0):int {
			if (x.hasOwnProperty('@' + attr) == true) {
				var val:String = x['@' + attr].toString();
				var n:Number = parseInt(val);
				if (!isNaN(n)) {
					return int(n);
				}
			}
			return defaultValue;
		}
		
	}
}