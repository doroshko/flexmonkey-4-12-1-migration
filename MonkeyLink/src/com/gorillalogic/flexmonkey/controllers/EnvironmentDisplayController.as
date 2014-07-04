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

    public class EnvironmentDisplayController implements IFMController {

        public function register(hub:FMHub):void {
            // app windows
            hub.listen(ApplicationEvent.GET_ENV_FILE, getEnvFile, this);
        }

        private function getEnvFile(event:Event = null):void {
            if (ApplicationModel.instance.isConnected) {
                MonkeyLinkConsoleConnectionController.instance.requestEnvFile();
                MonkeyLinkConsoleConnectionController.instance.addEventListener("envPayloadEvent", loadEvnFileHandler);
            }
        }

        private function loadEvnFileHandler(event:PayloadEvent):void {
            MonkeyLinkConsoleConnectionController.instance.removeEventListener("envPayloadEvent", loadEvnFileHandler);
            ApplicationModel.instance.applicationEnvFileData = event.data;
        }

    }
}
