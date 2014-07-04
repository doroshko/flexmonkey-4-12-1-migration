package com.gorillalogic.monkeylink {

    import com.gorillalogic.flexmonkey.core.MonkeyAutomationState;
    import com.gorillalogic.utils.ApplicationWrapper;
    import com.gorillalogic.utils.MonkeyAutomationManager;
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    
    import mx.automation.IAutomationObject;
    import mx.core.EventPriority;
    import mx.core.UIComponent;
    import mx.core.UITextField;

    public class ComponentSelector {

        private var _selector:Function;
        private var _monkeyTextFieldType:String;
        private var _rollOverActive:Boolean = false;
		private var _clicked:Boolean = false;

        public function ComponentSelector(selector:Function, application:DisplayObject) {
            _selector = selector;
            addWindow(application);
        }

        public function addWindow(application:DisplayObject):void {
            application.addEventListener(MouseEvent.MOUSE_OVER, monkeyMouseOverHandler, true, EventPriority.DEFAULT + 100000, true);
            application.addEventListener(MouseEvent.MOUSE_OUT, monkeyMouseOutHandler, true, EventPriority.DEFAULT + 100000, true);
            application.addEventListener(MouseEvent.MOUSE_DOWN, monkeyMouseDownHandler, true, EventPriority.DEFAULT + 100001, true);

            application.addEventListener(MouseEvent.MOUSE_UP, monkeyMousePropagationHandler, true, EventPriority.DEFAULT + 100000, true);
            application.addEventListener(MouseEvent.ROLL_OVER, monkeyMousePropagationHandler, true, EventPriority.DEFAULT + 100000, true);
            application.addEventListener(MouseEvent.ROLL_OUT, monkeyMousePropagationHandler, true, EventPriority.DEFAULT + 100000, true);

            application.addEventListener(MouseEvent.CLICK, monkeyMouseClickHandler, true, EventPriority.DEFAULT + 100000, true);
        }

        private function monkeyMousePropagationHandler(event:MouseEvent):void {
            if (MonkeyAutomationState.monkeyAutomationState.state == MonkeyAutomationState.SNAPSHOT) {
                event.stopImmediatePropagation();
            }
        }

        private function monkeyMouseOverHandler(event:MouseEvent):void {
            if (MonkeyAutomationState.monkeyAutomationState.state == MonkeyAutomationState.SNAPSHOT) {
                var pointSource:DisplayObject = getComponentAtPositionOf(event) as DisplayObject;

                if (pointSource == null) {
                    return;
                }

                var parent:DisplayObject;

                if (event.currentTarget is DisplayObject) {
                    parent = event.currentTarget as DisplayObject;
                } else {
                    //use display object on event unless it doesn't exist - then user application
                    parent = ApplicationWrapper.instance.application as DisplayObject;
                }

                MonkeyAutomationManager.instance.getSnapshotOverlay(parent).show(pointSource, parent, event);

                event.stopImmediatePropagation();
            }
        }

        private function getComponentAtPositionOf(event:MouseEvent):IAutomationObject {
            return MonkeyAutomationManager.instance.getElementFromPoint(event.stageX, event.stageY, event.currentTarget) as UIComponent;
        }

        private function monkeyMouseOutHandler(event:MouseEvent):void {
            if (MonkeyAutomationState.monkeyAutomationState.state == MonkeyAutomationState.SNAPSHOT && !_clicked) {
                MonkeyAutomationManager.instance.clearSnapshotOverlay(event.currentTarget);
                event.stopImmediatePropagation();
            }
        }

        private function monkeyMouseDownHandler(event:MouseEvent):void {
//            if (MonkeyAutomationState.monkeyAutomationState.state == MonkeyAutomationState.SNAPSHOT) {
//                MonkeyAutomationManager.instance.clearSnapshotOverlay(event.currentTarget);
//                event.stopImmediatePropagation();
//            }
        }

        private function monkeyMouseClickHandler(event:MouseEvent):void {
			_clicked = true;
            if (MonkeyAutomationState.monkeyAutomationState.state != MonkeyAutomationState.SNAPSHOT) {
                return;
            }

            var pointSource:UIComponent = getComponentAtPositionOf(event) as UIComponent;

            if (pointSource == null) {
                return;
            }

            if (pointSource is UITextField) {
                pointSource.systemManager.stage.focus = null;
            }
            event.stopImmediatePropagation();
            _selector(pointSource);
        }

    }
}