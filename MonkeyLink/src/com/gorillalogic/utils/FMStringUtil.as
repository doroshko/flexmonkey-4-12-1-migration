package com.gorillalogic.utils {

    import org.as3commons.bytecode.emit.impl.AbcBuilder;
    import org.as3commons.lang.StringUtils;

    /**
     * String utilities methods extracted during refactor of other classes
     */
    public class FMStringUtil {

        private static const classNamePattern:RegExp = /^[a-zA-Z_][a-zA-Z0-9_]*$/;
        private static const notClassNamePattern:RegExp = new RegExp("[^a-zA-Z0-9_]", "g");
        private static const underscoreStr:String = new String("_");

        public static function formatArrayForOutput(array:Array):String {
            var result:String = "[]";
            if (array) {
                var sb:Array = [];
                for (var i:int = 0; i < array.length; i++) {
                    sb.push(FMStringUtil.formatForOutput(array[i]));
                }
                result = [ '[', sb.join(", "), ']' ].join('');
            }
            return result;
        }

        public static function formatForOutput(arg:Object):String {
			if (!(arg is String)) {
				return String(arg);
			}
			var s:String=arg as String;
			if (isEmpty(s)) {
				return "''";
            } 
			s=formatLineBreaksForOutput(s);	
			s=singleQuote(s);
			return s;
        }
	
		public static function singleQuote(s:String):String {
			var resultStr:String = s;
			
			// escape single and double quotes
			if (StringUtils.contains(resultStr, "'")) {
				resultStr = StringUtils.replace(resultStr, "'", "\\'");
			}
			
			if (StringUtils.contains(resultStr, "\"")) {
				resultStr = StringUtils.replace(resultStr, "\"", "\\\"");
			}
			
			return "'" + resultStr + "'";
		}

		public static function formatLineBreaksForOutput(s:String):String {
			if (s==null) {
				return s;
			}
			var rez:String=s;
			rez=rez.split("\n").join("\\n");
			// rez=rez.split("\u000d\u000a").join("\\n");  // unicode crlf
			rez=rez.split("\x0d\x0a").join("\\n");  // hex crlf
			// rez=rez.split("\u000a").join("\\n");  // unicode lf
			rez=rez.split("\x0a").join("\\n");  // hex lf
			// rez=rez.split("\u000d").join("\\n");  // unicode cr
			// rez=rez.split("\x0d").join("\\n");  // hex cr
			rez=rez.split("\x0d").join("\\r");  // hex cr
			// rez=rez.split("\u0085").join("\\n");  // unicode NEL
			return rez;
		}
		
        public static function isEmpty(arg:String):Boolean {
            return (arg == null || arg == "" || arg == "null"); // Check for "null" only needed for backwards XML compatibility
        }

        public static function classNameToVarName(className:String):String {
            var firstChar:String = className.charAt(0).toLowerCase();
            return firstChar.concat(className.slice(1));
        }

        public static function fileNameToPackageName(fileName:String):String {
            var firstChar:String = fileName.charAt(0).toLowerCase();
            return firstChar.concat(fileName.slice(1));
        }

        /**
         * Make sure a test suite, test case, or test name is translated into a valid Actionscript class name.
         * Per the Flex docs that means the name must start with a letter or underscore character (_), and
         * they can only contain letters, numbers, and underscore characters after that.
         */
        public static function testNameToClassName(testName:String):String {
            var transaltedName:String = testName;

            if (transaltedName != null && !classNamePattern.test(transaltedName)) {
                transaltedName = transaltedName.replace(notClassNamePattern, "");

                if (StringUtils.isNumeric(transaltedName.charAt(0))) {
                    transaltedName = underscoreStr.concat(transaltedName);
                }
            }

            return transaltedName;
        }
    }
	
		
}