package com.gorillalogic.utils {

    import org.as3commons.lang.StringUtils;
    import org.as3commons.reflect.Type;

    public class TypeUtils {

        /**
         * Check for type using String names.  Useful for doing type checking without introduce compile depends
         */
        public static function checkForType(obj:Object, classnames:Array, absoluteMatch:Boolean = false):Boolean {
            if (obj != null) {
                var type:Type;

                try {
                    type = Type.forInstance(obj);
                } catch (e:Error) {
                    trace('Error checking type: ' + e.message);
                }

                if (type != null) {
					if (classnames.indexOf(type.name) > -1) {
						return true;
					}
										
                    var extendTypes:Array = type.extendsClasses;
					
                    for each (var extendClassName:String in extendTypes) {
                        for each (var n:String in classnames) {
                            if ((!absoluteMatch && StringUtils.endsWith(extendClassName, n)) || extendClassName == n) {
                                return true;
                            }
                        }
                    }
                }
            }
            return false;
        }

    }
}
