/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.vo {

    import com.gorillalogic.utils.FlexSpyUtils;
    import com.gorillalogic.utils.StoredValueLookup;

    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    import mx.core.EdgeMetrics;
    import mx.core.UIComponent;
    import mx.styles.IStyleClient;
    import mx.utils.StringUtil;

    [RemoteClass]
    [Bindable]
    public class AttributeVO {

        public static const PROPERTY:String = "property";
        public static const STYLE:String = "style";

        private static var COLOR:String = "color";
        private static var COLORS:String = "colors";

        public var finalExpectedValue:Object;
        public var name:String;
        public var expectedValue:String;
        public var actualValue:String;
        public var result:String;
        public var selected:Boolean;
        private var _type:String;
        private var _namespaceURI:String;

        public function AttributeVO(name:String = null,
                                    ns:String = null,
                                    type:String = null,
                                    expectedValue:String = null,
                                    actualValue:String = null,
                                    result:String = "NOT_RUN") {
            this.name = name;
            this.namespaceURI = ns;
            this.type = type;
            this.expectedValue = expectedValue;
            this.actualValue = actualValue;
            this.result = result;
        }

        public function loadFinalExpectedValue():void {
            finalExpectedValue = StoredValueLookup.instance.getExpectedValue(expectedValue);
        }

        public function get namespaceURI():String {
            return _namespaceURI;
        }

        public function set namespaceURI(namespaceURI:String):void {
            if (namespaceURI == "") {
                _namespaceURI = null;
            } else {
                _namespaceURI = namespaceURI;
            }
        }

        public function get type():String {
            return _type;
        }

        public function set type(type:String):void {
            if (type == PROPERTY || type == STYLE) {
                _type = type;
            } else {
                throw new Error("Illegal value " + type + " for AttributeVO type");
            }
        }

        public function get xml():XML {
            var xml:XML =
                <Attribute name={name} expectedValue={expectedValue} actualValue={actualValue} type={type} />
            return xml;
        }

        public function asXML(short:Boolean = false):XML {
            var xml:XML =
                <Attribute name={name} expectedValue={expectedValue} type={type} />

            if (!short) {
                xml.@actualValue = actualValue;
            }
            return xml;
        }

        public function get fullyQualifiedName():String {
            if (namespaceURI != null) {
                return namespaceURI + "::" + name;
            } else {
                return name;
            }
        }

        public function isEqualTo(item:Object):Boolean {
            if (!item is AttributeVO) {
                return false;
            } else {
                if ((item.type == this.type) &&
                    (item.selected == this.selected) &&
                    (item.expectedValue == this.expectedValue) &&
                    (item.actualValue == this.actualValue) &&
                    (item.namespaceURI == this.namespaceURI) &&
                    (item.name == this.name) &&
                    (item.result == this.result)) {
                    return true;
                } else {
                    return false;
                }
            }
        }


        public function setActualValueForTargetVO(targetVO:TargetVO):void {
            var i:uint = 0;

            if (type == PROPERTY) {
                while (i < targetVO.propertyArray.length && (targetVO.propertyArray[i].name != this.name)) {
                    i++;
                }

                if (i < targetVO.propertyArray.length) {
                    actualValue = targetVO.propertyArray[i].actualValue;
                } else {
                    actualValue = "<Exception thrown in getter>";
                }
            } else {
                while (i < targetVO.styleArray.length && (targetVO.styleArray[i].name != this.name)) {
                    i++;
                }

                if (i < targetVO.styleArray.length) {
                    actualValue = targetVO.styleArray[i].actualValue;
                } else {
                    actualValue = "<Exception thrown in getter>";
                }
            }
        }

        public function setActualValueForTarget(target:Object):void {
            var valueString:String = null;
            var value:*;

            if (type == PROPERTY) {
                try {
                    if (namespaceURI == null || namespaceURI == "") {
                        value = target[name];
                    } else {
                        var ns:Namespace = new Namespace(namespaceURI);
                        value = target.ns::[ name ];
                    }
                    valueString = getPropertyItemDisplayValue(value);
                } catch (error:ReferenceError) {
                    trace("Exception thrown in getter for property " + name + ": " + error.message);
                    valueString = "<Exception thrown in getter>";
                }
            } else { // type == STYLE
                value = IStyleClient(target).getStyle(name);
                valueString = getStyleItemDisplayValue(value);
            }
            actualValue = valueString;
        }

        protected function getFormat(value:*):String {
            var valueType:String = getValueType(value);

            if (FlexSpyUtils.endsWith(name, "color", false) && (valueType == "Number" || valueType == "uint" || valueType == "int")) {
                return "Color";
            } else if (FlexSpyUtils.endsWith(name, "colors", false) && (valueType == "Number" || valueType == "uint" || valueType == "int")) {
                return "Color";
            }
            return "Undefined";
        }

        protected function getValueType(value:*):String {
            if (value != null) {
                return getQualifiedClassName(value);
            }
            return "Undefined";
        }

        protected function getPropertyArrayDisplayValue(array:Array):String {
            var result:Array = new Array();

            for each (var item:Object in array) {
                result.push(getPropertyItemDisplayValue(item));
            }
            return result.join(", ");
        }

        protected function getStyleArrayDisplayValue(array:Array):String {
            var result:Array = new Array();

            for each (var item:Object in array) {
                result.push(getStyleItemDisplayValue(item));
            }
            return result.join(", ");
        }

        protected function getPropertyItemDisplayValue(item:*):String {
            if (item == null) { // works for both undefined and null values
                return "";
            }
            var valueType:String = getValueType(item);

            if (valueType == "Array") {
                return getPropertyArrayDisplayValue(item as Array);
            } else if (valueType == "Class") {
                return FlexSpyUtils.formatClass(item);
            } else if (item is EdgeMetrics) {
                var em:EdgeMetrics = EdgeMetrics(item);
                return "EdgeMetrics(left=" + em.left + ", top=" + em.top + ", right=" + em.right + ", bottom=" + em.bottom + ")";
            } else if (item is Rectangle) {
                var r:Rectangle = Rectangle(item);
                return "Rectange(x=" + r.x + ", y=" + r.y + ", width=" + r.width + ", height=" + r.height + ")";
            } else if (item is DisplayObject) {
                var className:String = flash.utils.getQualifiedClassName(item);
                return FlexSpyUtils.formatDisplayObject(DisplayObject(item), className);
            }

            // Default behavior
            return item.toString();
        }

        protected function getStyleItemDisplayValue(item:*):String {
            if (item == null) { // works for both undefined and null values
                return "";
            }
            var valueType:String = getValueType(item);
            var format:String = getFormat(item);

            if (valueType == "Array") {
                return getStyleArrayDisplayValue(item as Array);
            } else if (format == "Color") {
                return FlexSpyUtils.toHexColor(Number(item));
            } else if (format == "File") {
                if (valueType == "String") {
                    return String(item);
                } else {
                    return FlexSpyUtils.formatClass(item);
                }
            } else if (valueType == "Class") {
                return FlexSpyUtils.formatClass(item);
            }

            // Default behavior
            return (item == null) ? "" : item.toString();
        }

        protected function toHexColor(n:Number):String {
            var result:String = n.toString(16);

            while (result.length < 6) {
                result = "0" + result;
            }
            return ("#" + result);
        }

        protected function fromHexColor(str:String):Number {
            if (str == null || str == "") {
                return 0;
            }

            if (str.charAt(0) == "#") {
                // Map "#77EE11" to 0x77EE11
                return Number("0x" + str.slice(1));
            }
            // Default
            return Number(str);
        }

        protected function isSafeType(valueType:String):Boolean {
            // Base types
            if (valueType == "Number"
                || valueType == "String"
                || valueType == "Boolean"
                || valueType == "int"
                || valueType == "uint"
                || valueType == "Date")
                return true;

            // Known types
            if (valueType == "flash.geom::Rectangle" || valueType == "mx.core::EdgeMetrics")
                return true;

            // Unknown types
            return false;
        }

        protected function endsWith(str:String, suffix:String, caseSensitive:Boolean = true):Boolean {
            if (suffix == null) {
                return true;
            }

            if (str == null) {
                return false;
            }
            var startIndex:int = str.length - suffix.length;

            if (startIndex < 0) {
                return false;
            }

            if (caseSensitive) {
                return (str.substr(startIndex) == suffix);
            } else {
                return (str.substr(startIndex).toLowerCase() == suffix.toLowerCase());
            }
        }

        protected function formatDisplayObject(displayObject:DisplayObject, className:String):String {
            if (displayObject == null)
                return "";

            var item:String = className;

            if (item.indexOf("::") >= 0) {
                item = item.substr(2 + item.indexOf("::"));
            }

            if (displayObject is UIComponent && (UIComponent(displayObject).id != null) && (UIComponent(displayObject).id != "")) {
                item += " id=\"" + UIComponent(displayObject).id + "\"";
            } else if (displayObject.name != null && displayObject.name != "") {
                item += " name=\"" + displayObject.name + "\"";
            }
            item = StringUtil.substitute("<{0}>", item);
            return item;
        }

        protected function formatClass(item:Object):String {
            var className:String = flash.utils.getQualifiedClassName(item);

            if (className != null) {
                var idx:int = className.indexOf("::");

                if (idx > 0) {
                    return "ClassReference(\"" + className + "\")";
                }
            } else {
                className = String(item);
            }

            // Embeded resource, the pattern is [Class]__embed_css_[source]_[item]_[number]
            var EMBED_CSS:String = "__embed_css_";
            idx = className.indexOf(EMBED_CSS);

            if (idx > 0) {
                var embededInfo:String = className.substr(idx + EMBED_CSS.length);
                // Remove the trailing number
                embededInfo = embededInfo.substr(0, embededInfo.lastIndexOf("_"));

                var embededFile:String = embededInfo;
                var embededParam:String = "";
                idx = embededInfo.indexOf("_swf_");

                if (idx > 0) {
                    embededFile = embededInfo.substr(0, idx) + ".swf";
                    embededParam = embededInfo.substr(idx + 4);

                    if (embededParam.length > 0) {
                        embededParam = embededParam.substr(1); // Remove the leading "_"

                        while (embededParam.indexOf("_") > 0) {
                            embededParam = embededParam.replace("_", ".");
                        }
                    }
                } else {
                    idx = embededInfo.lastIndexOf("_");

                    if (idx > 0) {
                        embededFile = embededInfo.substr(0, idx) + "." + embededInfo.substr(idx + 1);
                    }
                }

                if (embededParam.length > 0) {
                    return "Embed(source=\"" + embededFile + "\", symbol=\"" + embededParam + "\")";
                } else {
                    return "Embed(\"" + embededFile + "\")";
                }
            }
            return className;
        }
    }
}