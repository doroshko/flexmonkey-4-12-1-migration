/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.core {

    import com.gorillalogic.aqadaptor.AQAdapter;
    import com.gorillalogic.utils.ApplicationWrapper;
    import com.gorillalogic.utils.FMStringUtil;
    import com.gorillalogic.utils.MonkeyAutomationManager;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.getQualifiedClassName;
    
    import mx.automation.Automation;
    import mx.automation.AutomationID;
    import mx.automation.AutomationManager;
    import mx.automation.IAutomationClass;
    import mx.automation.IAutomationObject;
    import mx.collections.XMLListCollection;
    import mx.containers.TitleWindow;
    import mx.core.Container;
    import mx.core.IChildList;
    import mx.core.UIComponent;
    import mx.utils.ObjectUtil;
    
    import org.as3commons.bytecode.abc.Integer;

    public class MonkeyUtils {

        /**
         * Find the first component with the specified property/value pair.
         *
         * If a container is specified, then only its children and descendents are searched.
         * The search order is (currently) indeterminate. If no container is specified,
         * then all components will be searched. If the prop value is "automationID",
         * then the id is resolved directly without searching.
         */
        public static function findComponent(containerValue:String, containerProp:String, value:String, prop:String = "automationName"):UIComponent {
            var target:UIComponent = null;
            var container:UIComponent = null;

            if (!FMStringUtil.isEmpty(containerValue)) {
                container = findComponentWith(containerValue, containerProp);
            }
            target = findComponentWith(value, prop, container);
            return target;
        }
		protected static function getItemsNumber(className:String, parent:UIComponent, classNumber:int, numberOn:int):Object{
			for ( var i:int = 0 ; i < parent.numChildren; i++){
				var ch:DisplayObject = parent.getChildAt(i);
				
				var clazzName:String = ObjectUtil.getClassInfo(ch).name as String;
				if(clazzName.indexOf("::") > -1){
				clazzName = clazzName.split("::")[1];
				}
				if(clazzName == className){
					if(classNumber == numberOn){
						return ch;
					} else {
						numberOn++;
					}
					
				} else if(ch && ch is UIComponent && (ch as UIComponent).numChildren > 0){
					var retVal:Object = getItemsNumber(className, ch as UIComponent, classNumber, numberOn);
					if(retVal is int){
						numberOn = retVal as int;
					} else {
						return retVal;
					}
				}

				
			}	
			return numberOn;	
		}
        protected static function findComponentWith(value:String, prop:String, container:UIComponent = null):UIComponent {
			if(prop == "monkeyID" || value.indexOf(".") > -1){
				var vals:Array = value.split(".");
				var className:String = vals[vals.length - 2];
				var classNumber:String = vals[vals.length - 1];
				var cont:UIComponent;
				var val:Object;
				if(vals.length == 2)
					cont = MonkeyAutomationManager.instance.applications.getItemAt(0) as UIComponent;
				else
					cont = findComponentWith(vals[0], "automationName") as UIComponent;
				var valr:Object = getItemsNumber(className,cont , parseInt(classNumber), 1);
				
				return valr as UIComponent;
			}
            if (prop == "automationID") {
                var rid:AutomationID = AutomationID.parse(value);

                try {
                    var obj:IAutomationObject = MonkeyAutomationManager.instance.resolveIDToSingleObject(rid);
                    return UIComponent(obj);
                } catch (error:Error) {
                    // Automation manager is sometimes null-pointering out on resolveIDToSingleObject
                    // trace("Unable to resolve component id: " + rid + "\n" + error);
                }
            }

            if (container == null) {
                // Check windows whose parent is the SystemManager
                for each (var app:DisplayObject in MonkeyAutomationManager.instance.applications) {
                    var kids:IChildList = UIComponent(app).systemManager.rawChildren;

                    for (i = 0; i < kids.numChildren; i++) {
                        var child:DisplayObject = kids.getChildAt(i);

                        if (!(child is UIComponent)) {
                            continue;
                        }

                        //traceIt(child as UIComponent);
                        if (child.hasOwnProperty(prop) && child[prop] == value) {
                            return UIComponent(child);
                        }
                        child = findComponentWith(value, prop, UIComponent(child));

                        if (child != null && isVisible(child)) {
                            return UIComponent(child);
                        }
                    }
                }

                return null;
            }
            var numChildren:int = 0;

            try {
                numChildren = container.numAutomationChildren;
            } catch (e:Error) {
                // In Flex 3 (maybe Flex 4 too), he blows up on numChildren call if component tree is not fully initialized (or something)
                return null;
            }

            if (numChildren == 0) {
                return null;
            }

            var component:UIComponent;

            for (var i:int = 0; i < numChildren; i++) {
                child = container.getAutomationChildAt(i) as DisplayObject;

                if (!(child is UIComponent)) {
                    continue;
                }

                //traceIt(child as UIComponent);
                // Because sometimes (inexplicably) the automation manager is unable to resolve the automationID using AutomationHelper,
                // we check for it here too
                if (prop == "automationID") {
                    var id:String = MonkeyAutomationManager.instance.createID(child as IAutomationObject).toString();

                    if (id == value) {
                        return UIComponent(child);
                    }
                }

                if (child.hasOwnProperty(prop) && child[prop] == value && isVisible(child)) {
                    return UIComponent(child);
                } else {
                    var grandChild:UIComponent = findComponentWith(value, prop, UIComponent(child));

                    if (grandChild != null && isVisible(grandChild)) {
                        return grandChild;
                    }
                }
            }

            return null;

        }

        static private function isVisible(c:Object):Boolean {
            if (MonkeyAutomationManager.instance.isVisible(c as DisplayObject)) {
                return true;
            }
            trace("Child found, but it's not visible. Continuing search...");
            return false;
        }

        static private function traceIt(c:UIComponent):void {

            var comp:DisplayObjectContainer = c;
            var indent:String = "";

            if (comp != null) {
                while (comp.parent != null) {
                    indent += " ";
                    comp = comp.parent;
                }

                //rewrite to access automationOwner dynamicallys because its a Flex 4 property, so it won't compile in Flex 3
                var msg:String = indent + c.className + "(" + c.automationName + "," + "automationChildren: " + c.numAutomationChildren;

                if (c.hasOwnProperty("automationOwner") && c["automationOwner"] != null) {
                    var automationOwner:Object = c["automationOwner"];
                    msg += "automationOwner: ";

                    if (automationOwner.hasOwnProperty("className")) {
                        msg += automationOwner["className"] + "(" + automationOwner["automationName"] + ")"
                    } else {
                        msg += "SystemManager";
                    }
                }
                trace(msg);

            }
        }

        /**
         * @return the path of FlexMonkey.swf's file location
         */
        static public function getAppPath():String {
            return ApplicationWrapper.instance.application.url.split('/').slice(0, -1).join('/');
        }

        static public function visitComponentTree(visitor:Function, from:UIComponent = null):void {
            var i:int;

            if (from != null) {
                visitor(from);
            } else {
                var kids:IChildList = UIComponent(ApplicationWrapper.instance.application).systemManager.rawChildren;

                for (i = 0; i < kids.numChildren; i++) {
                    if (kids.getChildAt(i) == null || !(kids.getChildAt(i) is UIComponent)) {
                        continue;
                    }

                    visitComponentTree(visitor, kids.getChildAt(i) as UIComponent);
                }
                return;
            }

            for (i = 0; i < from.numAutomationChildren; i++) {
                var child:UIComponent = from.getAutomationChildAt(i) as UIComponent;

                if (child) {
                    visitComponentTree(visitor, child);
                }
            }
        }

        static public function dumpComponentTree(from:UIComponent = null):void {
            visitComponentTree(traceIt, from);
        }

        static public function dumpFullComponentTree(comp:UIComponent = null):Object {
            var a:Array = [];

            if (comp != null) {
                dumpFullComponentTreeComp(comp, a);
            }

            return a;
        }

        static public function getApplicationTreeInfo(comp:UIComponent = null):Object {
            var a:Array = [];

            for each (var comp:UIComponent in MonkeyAutomationManager.instance.applications) {
                if (comp != null) {
                    dumpFullComponentTreeComp(comp, a);
                }
            }

            return a;
        }

        static protected function dumpFullComponentTreeComp(comp:UIComponent, parentCompObject:Object):void {
            var text:String = ""
            var label:String = "";
            var autoOwner:String = "";
            var parent:String = "";

            if (comp.hasOwnProperty("text")) {
                text = comp["text"];
            }

            if (comp.hasOwnProperty("label")) {
                label = comp["label"];
            }

            if (comp.hasOwnProperty("automationOwner")) {
                autoOwner = getQualifiedClassName(comp["automationOwner"]);
            }

            if (comp.hasOwnProperty("parent")) {
                parent = getQualifiedClassName(comp["parent"]);
            }

            var auto:IAutomationClass = MonkeyAutomationManager.instance.automationEnvironment.getAutomationClassByInstance(comp);
            var name:String = auto.name;

            var compObj:Object = {
                    name: comp.className + " (" + comp.automationName + ")",
                    id: comp.id,
                    automationName: comp.automationName,
                    numAutomationChildren: comp.numAutomationChildren,
                    text: text,
                    label: label,
                    automationClass: name,
                    automationOwner: autoOwner,
                    parent: parent,
                    children: []};

            if (parentCompObject is Array) {
                (parentCompObject as Array).push(compObj);
            } else {
                (parentCompObject.children as Array).push(compObj);
            }

            for (var i:int = 0; i < comp.numAutomationChildren; i++) {
                var child:Object = comp.getAutomationChildAt(i);

                if (child is UIComponent) {
                    dumpFullComponentTreeComp(child as UIComponent, compObj);
                }
            }
        }

    }
}