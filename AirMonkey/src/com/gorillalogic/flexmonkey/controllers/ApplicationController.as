/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;

    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.utils.Timer;

    /**
     * AIR API dependencies
     */
    public class ApplicationController implements IFMController {

        private var model:ProjectTestModel = ProjectTestModel.instance;

        public function register(hub:FMHub):void {
            // summary
            hub.listen(ApplicationEvent.UPDATE_SUMMARY, updateSummaryCounts, this);

            // what is the difference between these two?
            hub.listen(ApplicationEvent.MONKEY_EXIT, monkeyExit, this);
            hub.listen(ApplicationEvent.CLOSE_APPLICATION, closeApplication, this);
        }

        //
        // exit logic
        //

        private function monkeyExit(event:Event):void {
            if (ApplicationModel.instance.isMonkeyTestFileDirty) {
                FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.PROMPT_FOR_SAVE));
            } else {
                var timer:Timer = new Timer(10, 1);
                timer.addEventListener("timer", closeApplication, false, 0, true);
                timer.start();
            }
        }

        private function closeApplication(event:Event = null):void {
            MonkeyLinkConsoleConnectionController.instance.sendDisconnect();
            NativeApplication.nativeApplication.exit();
        }

        //
        // update summary
        //

        private function updateSummaryCounts(event:Event):void {
            if (model != null && model.suites != null) {
                model.suiteCount = model.suites.length;
                model.caseCount = 0;
                model.testCount = 0;
                model.commandCount = 0;

                for each (var s:MonkeyTestSuite in model.suites) {
                    model.caseCount += s.children.length;

                    for each (var c:MonkeyTestCase in s.children) {
                        model.testCount += c.children.length;

                        for each (var t:MonkeyTest in c.children) {
                            model.commandCount += t.children.length;
                        }
                    }
                }
            }
        }

    }
}
