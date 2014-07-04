/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.InteractionEvent;
    import com.gorillalogic.flexmonkey.events.MonkeyNodeEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    
    import mx.collections.ArrayCollection;

    public class MonkeyNodeController extends MonkeyRunnableController implements IFMController {

        override public function register(hub:FMHub):void {
            hub.listen(MonkeyNodeEvent.NEW_TEST_SUITE, newTestSuite, this);
            hub.listen(MonkeyNodeEvent.NEW_TEST_CASE, newTestCase, this);
            hub.listen(MonkeyNodeEvent.NEW_TEST, newTest, this);
            hub.listen(MonkeyNodeEvent.NEW_TEST_FROM_RECORD_ITEMS, newTestFromRecordItems, this);
            hub.listen(MonkeyNodeEvent.NEW_CASE_FROM_RECORD_ITEMS, newTestCaseFromRecordItems, this);
            hub.listen(MonkeyNodeEvent.NEW_SUITE_FROM_RECORD_ITEMS, newTesSuitetFromRecordItems, this);
        }

        private function newTestFromRecordItems(event:MonkeyNodeEvent):void {
            if (ProjectTestModel.instance.recordItems != null && ProjectTestModel.instance.recordItems.length > 0) {
                var t:MonkeyTest = createNewTest(event.monkeyNode as MonkeyTestCase);
                event.monkeyNode.children.addItemAt(t, event.newNodePosition);
                ProjectTestModel.instance.moveAllRecordedItems(t, 0);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
                FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
                FMHub.instance.dispatchEventAsync(new ApplicationEvent(ApplicationEvent.CLOSE_RECORD_WINDOW_VIEW));
            }
        }

        private function newTestCaseFromRecordItems(event:MonkeyNodeEvent):void {
            if (ProjectTestModel.instance.recordItems != null && ProjectTestModel.instance.recordItems.length > 0) {
                var c:MonkeyTestCase = createNewTestCase(event.monkeyNode as MonkeyTestSuite);
                event.monkeyNode.children.addItemAt(c, event.newNodePosition);

                var t:MonkeyTest = c.children.getItemAt(0) as MonkeyTest;
                ProjectTestModel.instance.moveAllRecordedItems(t, 0);

                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
                FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
                FMHub.instance.dispatchEventAsync(new ApplicationEvent(ApplicationEvent.CLOSE_RECORD_WINDOW_VIEW));
            }
        }

        private function newTesSuitetFromRecordItems(event:MonkeyNodeEvent):void {
            if (ProjectTestModel.instance.recordItems != null && ProjectTestModel.instance.recordItems.length > 0) {
                var s:MonkeyTestSuite = createNewTestSuite();
                ProjectTestModel.instance.suites.addItemAt(s, event.newNodePosition);

                var t:MonkeyTest = (s.children.getItemAt(0) as MonkeyTestCase).children.getItemAt(0) as MonkeyTest;
                ProjectTestModel.instance.moveAllRecordedItems(t, 0);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
                FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
                FMHub.instance.dispatchEventAsync(new ApplicationEvent(ApplicationEvent.CLOSE_RECORD_WINDOW_VIEW));
            }
        }

        private function newTestSuite(event:MonkeyNodeEvent):void {
            var s:MonkeyTestSuite = createNewTestSuite();
            ProjectTestModel.instance.suites.addItemAt(s, event.newNodePosition);

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

        private function newTestCase(event:MonkeyNodeEvent):void {
            var c:MonkeyTestCase = createNewTestCase(event.monkeyNode as MonkeyTestSuite);
            event.monkeyNode.children.addItemAt(c, event.newNodePosition);

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

        private function newTest(event:MonkeyNodeEvent):void {
            var t:MonkeyTest = createNewTest(event.monkeyNode as MonkeyTestCase);
            event.monkeyNode.children.addItemAt(t, event.newNodePosition);

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

        private function createNewTest(monkeyCase:MonkeyTestCase):MonkeyTest {
            var t:MonkeyTest = new MonkeyTest();
            t.name = "New Test";
            t.defaultThinkTime = MonkeyRunnable.DEFAULT_THINK_TIME;
            t.children = new ArrayCollection();
            t.parent = monkeyCase;
            return t;
        }

        private function createNewTestCase(suite:MonkeyTestSuite):MonkeyTestCase {
            var c:MonkeyTestCase = new MonkeyTestCase();
            c.name = "New Test Case";
            c.children = new ArrayCollection();
            c.children.addItem(createNewTest(c));
            c.parent = suite;
            return c;
        }

        private function createNewTestSuite():MonkeyTestSuite {
            var s:MonkeyTestSuite = new MonkeyTestSuite();
            s.name = "New Test Suite";
            s.children = new ArrayCollection();
            s.children.addItem(createNewTestCase(s));
            return s;
        }

    }

}
