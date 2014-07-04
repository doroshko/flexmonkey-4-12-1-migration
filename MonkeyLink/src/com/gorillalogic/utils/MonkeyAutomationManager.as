package com.gorillalogic.utils {

    import com.gorillalogic.monkeylink.MonkeyLink;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.sampler.stopSampling;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    
    import mx.automation.Automation;
    import mx.automation.AutomationID;
    import mx.automation.AutomationIDPart;
    import mx.automation.IAutomationManager;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationTabularData;
    import mx.automation.events.AutomationReplayEvent;
    import mx.collections.ArrayCollection;
    import mx.containers.TitleWindow;
    import mx.core.Container;
    import mx.core.IChildList;
    import mx.core.UIComponent;
    import mx.managers.ISystemManager;
    import mx.managers.PopUpManager;
    import mx.managers.PopUpManagerChildList;
    import mx.managers.SystemManager;
    import mx.utils.StringUtil;
    
    import org.as3commons.lang.StringUtils;
    import org.as3commons.reflect.Type;
    

	if(FLEXMONKEY::vfour){
	import mx.core.FlexGlobals;
    import spark.components.Application;
	} else {
		import mx.core.Application;
	}

    /**
     * MonkeyAutomationManager wraps the Adobe Automation Manager and hides the two different implementation provided
     * (i.e. Automation.automationManager & Automation.automationManager2)
     *
     * Also, tracks multi-windows in AIR and TitleWindow Popups (the automation manager notifies when AIR Windows are created)
     */
    public class MonkeyAutomationManager {

        public static var instance:MonkeyAutomationManager = new MonkeyAutomationManager();

        public var isFlex4:Boolean = false;
        private var _automationManager:Object;
        private var _windows:ArrayCollection;
        private var _overlayMap:Object = new Object();

        public function MonkeyAutomationManager() {
            try {
				if(FLEXMONKEY::vfour){
					isFlex4 = true;
					_automationManager = Automation["automationManager2"];
					if(FlexGlobals.topLevelApplication){
						var app2:mx.core.Application = mx.core.Application.application as mx.core.Application;
						if(app2){
							var appAsComp:UIComponent = app2 as UIComponent;
							for each (var comp:UIComponent in getAllElementsFromAComponent(appAsComp)){
								if(comp is UIComponent){
									try{
										swapOnAdd(comp);
									} catch(e:Error){
										trace("comp.className.indexOf(\""+comp.className+"\") != -1 ||");
									}
									
								}
								
								
							} 	
						}
					}
					var app:Application = FlexGlobals.topLevelApplication as Application;
					if(app){
						for each (var compr:UIComponent in getAllElementsFromAComponent(app as UIComponent)){
							if(compr is UIComponent){
								try{
									swapOnAdd(compr);
								} catch(e:Error){
									trace("comp.className.indexOf(\""+compr.className+"\") != -1 ||");
								}
								
							}
							
							
						} 
					}
				} else {
					isFlex4 = false;
					_automationManager = Automation.automationManager;
					var app2:mx.core.Application = mx.core.Application.application as mx.core.Application;
					if(app2){
						var appAsComp:UIComponent = app2 as UIComponent;
						for each (var comp:UIComponent in getAllElementsFromAComponent(appAsComp)){
							if(comp is UIComponent){
									try{
								swapOnAdd(comp);
									} catch(e:Error){
										trace("comp.className.indexOf(\""+comp.className+"\") != -1 ||");
									}
								
							}
							
							
						} 	
				}
				}    
					
			
                _windows = new ArrayCollection();
                addWindow(ApplicationWrapper.instance.application);

                _automationManager.addEventListener("newAirWindow", newAirWindowHandler, false, 0, true);

            } catch (e:Error) {
                isFlex4 = false;
            }
        }
		public static function getAllElementsFromAComponent(container:UIComponent, indent:String = ""):ArrayCollection{
			var comps:ArrayCollection = new ArrayCollection();
			
			for(var i:int = 0; i < container.numChildren; i++)
			{
			if(container.getChildAt(i) is UIComponent){
			var comp:UIComponent = (container.getChildAt(i) as UIComponent);
			if(comp.numChildren > 0) {
				    var ell:ArrayCollection = getAllElementsFromAComponent(comp, indent + "    ");
					for each (var iee:Object in ell){
						comps.addItem(iee);
					}
			} 
					comps.addItem(comp);
			
				///
			}}
			return comps;
		}
//		public static function getAllAutomationElementsFromAComponent(container:UIComponent):ArrayCollection{
//			var comps:ArrayCollection = new ArrayCollection();
//				if(container is UIComponent){
//					var comp:UIComponent = (container as UIComponent);
//					
//					if(comp is Container && comp.numChildren > 0) {
//						comps.addAll(getAllElementsFromAComponent(comp));
//					}  else { 
//						comps.addItem(comp);
//					}
//					///
//				}
//			return comps;
//		}

		public static function swapOnAdd(event:UIComponent):void{
            
			var comp:UIComponent = event;
			
			if(!comp.automationDelegate as IAutomationObject || comp.automationDelegate as IAutomationObject is MonkeyMagicAutomationDelegate){// || comp is Group){
				trace("trying to add a null delegate or the magic delegate has already been added -- " + comp.className);
			} else {
				var magicMonkey:MonkeyMagicAutomationDelegate = new MonkeyMagicAutomationDelegate();
				magicMonkey.trueDelegate = comp.automationDelegate as IAutomationObject;
				magicMonkey.trueComponent = comp;
				comp.automationDelegate = magicMonkey;
			}
		}
        /**
         * Handler to track when new windows are created
         */
        private function newAirWindowHandler(event:Object):void {
            var window:DisplayObject = getAIRWindow(event.windowId);
            MonkeyLink.monkeyLink.addWindowToComponentSelector(window);
            addWindow(window);
        }

        /**
         * Adds window to tracking, creates overlay UIComponent
         */
        private function addWindow(app:Object):void {
            _windows.addItem(app);
            var overlay:UIComponent = new SnapshotOverlay();
            _overlayMap[app] = overlay;

            //listen for add to stage events
            if (TypeUtils.checkForType(app, [ "Application", "Window", "Menu" ])) {
                app.systemManager.addEventListener(Event.ADDED_TO_STAGE, addToStageHandler, true, 0, true);
                loadExistingPopups(app as UIComponent);
            }

            //add overlay to comp
            app.systemManager.getSandboxRoot().toolTipChildren.addChild(overlay);
        }

        /**
         * Looks for popups add
         */
        private function loadExistingPopups(w:UIComponent):void {
            for (var c:int = 0; c < w.systemManager.rawChildren.numChildren; c++) {
                var child:Object = w.systemManager.rawChildren.getChildAt(c);

                if (child != w && !_windows.contains(child)) {
                    checkForPopup(child);
                }
            }
        }

        /**
         * Watch for popup windows
         */
        private function addToStageHandler(event:Event):void {
            checkForPopup(event.target);
        }

        /**
         * look for title windows
         */
        private function checkForPopup(c:Object):void {
            if (TypeUtils.checkForType(c, [ "TitleWindow" ])) {
                MonkeyLink.monkeyLink.addWindowToComponentSelector(c as DisplayObject);
                addWindow(c);
            }
        }

        /**
         * Returns snapshot for a given application
         */
        public function getSnapshotOverlay(app:Object):SnapshotOverlay {
            var s:SnapshotOverlay = _overlayMap[app] as SnapshotOverlay;
            return s;
        }

        /**
         * Clears the snapshot graphic for a given application
         */
        public function clearSnapshotOverlay(app:Object):void {
            var overlay:SnapshotOverlay = (_overlayMap[app] as SnapshotOverlay);

            if (overlay != null) {
                overlay.clear();
            }
        }

        /**
         * Returns the automationManager
         */
        public function get automationManager():IAutomationManager {
            return (_automationManager as IAutomationManager);
        }

        /**
         * Checks if the automation manager is available
         * useful for checking if automation is compiled into the application
         */
        public function get isAutomationManagerAvailable():Boolean {
            if (_automationManager == null) {
                return false;
            }
            return true;
        }

        /**
         * Returns the list of applications
         */
        public function get applications():ArrayCollection {
            return _windows;
        }

        //
        // automationManager(1) functions
        //

        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            (_automationManager as IAutomationManager).addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            (_automationManager as IAutomationManager).removeEventListener(type, listener, useCapture);
        }

        public function beginRecording():void {
            (_automationManager as IAutomationManager).beginRecording();
        }

        public function endRecording():void {
            (_automationManager as IAutomationManager).endRecording();
        }

        public function replayAutomatableEvent(event:AutomationReplayEvent):Boolean {
            return (_automationManager as IAutomationManager).replayAutomatableEvent(event);
        }

        public function isVisible(c:Object):Boolean {
            var am:IAutomationManager = _automationManager as IAutomationManager;
            var disObj:DisplayObject = c as DisplayObject;
            var b:Boolean = am.isVisible(disObj);
            return b;
            //return am.isVisible(c as DisplayObject);
        }

        public function get automationEnvironment():Object {
            return (_automationManager as IAutomationManager).automationEnvironment;
        }

        public function set automationEnvironment(value:Object):void {
            (_automationManager as IAutomationManager).automationEnvironment = value;
        }

        public function incrementCacheCounter():int {
            return (_automationManager as IAutomationManager).incrementCacheCounter();
        }

        public function decrementCacheCounter(clearNow:Boolean = false):int {
            return (_automationManager as IAutomationManager).decrementCacheCounter(clearNow);
        }

        public function createID(obj:IAutomationObject):AutomationID {
            return (_automationManager as IAutomationManager).createID(obj);
        }

        public function resolveIDToSingleObject(rid:AutomationID, currentParent:IAutomationObject = null):IAutomationObject {
            return (_automationManager as IAutomationManager).resolveIDToSingleObject(rid, currentParent);
        }

        public function getParent(obj:IAutomationObject, parentToStopAt:IAutomationObject = null, ignoreShowInHierarchy:Boolean = false):IAutomationObject {
            return (_automationManager as IAutomationManager).getParent(obj, parentToStopAt, ignoreShowInHierarchy);
        }

        public function getTabularData(obj:IAutomationObject):IAutomationTabularData {
            return (_automationManager as IAutomationManager).getTabularData(obj);
        }

        public function getProperties(obj:IAutomationObject, names:Array = null, forVerification:Boolean = true, forDescription:Boolean = true):Array {
            return (_automationManager as IAutomationManager).getProperties(obj, names, forVerification, forDescription);
        }

        public function isSynchronized(target:IAutomationObject):Boolean {
            return (_automationManager as IAutomationManager).isSynchronized(target);
        }

        public function getElementFromPoint(x:int, y:int, currentTarget:Object):IAutomationObject {
            if (isFlex4 && currentTarget != null && currentTarget is DisplayObject) {

                var a:Object = currentTarget;

                if (TypeUtils.checkForType(currentTarget.parentApplication, [ "spark.components::Window" ], true)) {
                    a = currentTarget.parentApplication;
                }

                var myWindowId:String = getAIRWindowUniqueID(a as DisplayObject);

                if (myWindowId != null) {
                    return _automationManager.getElementFromPoint2(x, y, myWindowId);
                }
            }
            return (_automationManager as IAutomationManager).getElementFromPoint(x, y);
        }

        //
        // automationManager2 specific functions
        //

        public function dispatchToAllChildren(event:Event):void {
            _automationManager.dispatchToAllChildren(event);
        }

        public function dispatchToParent(event:Event):void {
            _automationManager.dispatchToParent(event);
        }

        public function getAIRWindow(windowId:String):DisplayObject {
            return _automationManager.getAIRWindow(windowId) as DisplayObject;
        }

        public function getAIRWindowUniqueID(newWindow:DisplayObject):String {
            return _automationManager.getAIRWindowUniqueID(newWindow) as String;
        }

        public function getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart:AutomationIDPart):String {
            return _automationManager.getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart) as String;
        }

        public function getAIRWindowUniqueIDFromObjectIDString(objectId:String):String {
            return _automationManager.getAIRWindowUniqueIDFromObjectIDString(objectId) as String;
        }

        public function getApplicationNameFromAutomationIDPart(objectID:AutomationIDPart):String {
            return _automationManager.getApplicationNameFromAutomationIDPart(objectID) as String;
        }

        public function registerNewWindow(newWindow:DisplayObject):void {
            _automationManager.registerNewWindow(newWindow);
        }

        public function registerNewApplication(application:DisplayObject):void {
            _automationManager.registerNewApplication(application);
        }

        public function isObjectPopUp(obj:IAutomationObject):Boolean {
            return _automationManager.isObjectPopUp(obj) as Boolean;
        }

    }

}
