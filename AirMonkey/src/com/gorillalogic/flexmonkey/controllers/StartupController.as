/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.FMHubEvent;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.flexmonkey.controllers.helpers.StartupGate;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;

    import flash.events.Event;


    public class StartupController implements IFMController {

        private var isWindowLoaded:Boolean = false;
        private var isHubLoaded:Boolean = false;

        public function register(hub:FMHub):void {
            // is application ready to go ?
            hub.listen(FMHubEvent.LOADED, hubLoaded, this);
            hub.listen(ApplicationEvent.WINDOW_LOADED, windowLoaded, this);
        }

        /**
         * Listener to know when the main window has been loaded
         */
        private function windowLoaded(event:Event):void {
            isWindowLoaded = true;
            doStartup();
        }

        /**
         * Listener to know when bus is up and ready to go
         */
        private function hubLoaded(event:Event):void {
            isHubLoaded = true;
            doStartup();
        }

        private function doStartup():void {
            if (isHubLoaded && isWindowLoaded) {
                FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.OPENING_TEST_PROJECT_FILE));

                var startup:StartupGate = new StartupGate();
                startup.run();
            }
        }
    }

}
