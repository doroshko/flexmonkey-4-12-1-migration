/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import mx.core.UIComponent;

    import org.as3commons.lang.StringUtils;

    /**
     * Poor mans property parser
     */
    public class FMPropertyUtil {

        public static function findPropertyValue(obj:Object,
                                                 propertyString:String):Object {
            var props:Array = propertyString.split(".");
            var ref:Object = obj;

            for each (var p:String in props) {
                ref = getComp(ref, getProperty(p), getArgs(p));
            }

            return ref;
        }


        public static function updatePropertyValue(obj:Object,
                                                   propertyString:String,
                                                   value:String):String {
            var errorMessage:String;

            try {
                var props:Array = propertyString.split(".");
                var ref:Object = obj;

                //find object
                for (var i:int = 0; i < props.length - 1; i++) {
                    var p:String = props[i];
                    ref = getComp(ref, getProperty(p), getArgs(p));
                }

                //update value
                var finalProp:String = props[props.length - 1];

                if (ref[finalProp] is Boolean) {
                    if (value.toLowerCase().indexOf("t") == 0) {
                        ref[finalProp] = true;
                    } else {
                        ref[finalProp] = false;
                    }
                } else if (ref[finalProp] is Number) {
                    ref[finalProp] = new Number(value);
                } else {
                    ref[finalProp] = value;
                }
            } catch (e:Error) {
                errorMessage = e.message;
            }
            return errorMessage;
        }

        private static function getComp(ref:Object, p:String, args:String):Object {
            if (ref.hasOwnProperty(p)) {
                return getValue(ref[p], args)
            } else if (ref is UIComponent) {
                var comp:UIComponent = ref as UIComponent;

                for (var c:int = 0; c < comp.numChildren; c++) {
                    var child:Object = comp.getChildAt(c);

                    if ((child.hasOwnProperty("id") && child["id"] == p)) {
                        return getValue(child, args);
                    }
                }

                for (var ac:int = 0; ac < comp.numAutomationChildren; ac++) {
                    var autoChild:Object = comp.getAutomationChildAt(ac);

                    if ((autoChild.hasOwnProperty("automationName") && autoChild["automationName"] == p)) {
                        return getValue(autoChild, args);
                    }
                }
            }

            throw new Error("Could not find property: " + p);
        }

        private static function getProperty(p:String):String {
            if (p.indexOf("[") != -1 && p.indexOf("]") != -1) {
                return StringUtils.substringBefore(p, "[");
            }
            return p;
        }

        private static function getArgs(p:String):String {
            if (p.indexOf("[") != -1 && p.indexOf("]") != -1) {
                return extractString(extractString(p, "[", "]"), "\"", "\"");
            }
            return null;
        }

        private static function extractString(p:String, begin:String, end:String):String {
            if (p.indexOf(begin) != -1 && p.indexOf(end) != -1) {
                return StringUtils.substringBefore(StringUtils.substringAfter(p, begin), end);
            }
            return p;
        }

        private static function getValue(ref:Object, args:String):Object {
            if (args != null) {
                if (ref is Array) {
                    return ref[Number(args)];
                }
                return ref[args];
            }
            return ref;
        }

    }

}
