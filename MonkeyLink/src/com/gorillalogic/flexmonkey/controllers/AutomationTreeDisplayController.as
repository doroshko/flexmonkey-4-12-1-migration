/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.PayloadEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;

    import flash.events.Event;

    public class AutomationTreeDisplayController implements IFMController {

        public function register(hub:FMHub):void {
            hub.listen(ApplicationEvent.GET_APPLICATION_AUTOMATION_TREE, getApplicationAutomationTree, this);
        }

        private function getApplicationAutomationTree(event:Event = null):void {
            if (ApplicationModel.instance.isConnected) {
                MonkeyLinkConsoleConnectionController.instance.requestApplicationAutomationTree();
                MonkeyLinkConsoleConnectionController.instance.addEventListener("applicationAutomationTreePayloadEvent", loadAutomationApplicationTreeHandler);
            }
        }

        private function loadAutomationApplicationTreeHandler(event:PayloadEvent):void {
            MonkeyLinkConsoleConnectionController.instance.removeEventListener("applicationAutomationTreePayloadEvent", loadAutomationApplicationTreeHandler);
            ApplicationModel.instance.applicationAutomationTreeData = event.data as Array;
        }

    }
}
