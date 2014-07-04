/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.events.InteractionEvent;
    import com.gorillalogic.flexmonkey.events.MonkeyRunnableEvent;
    import com.gorillalogic.flexmonkey.events.SnapshotEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.TargetVO;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;
    import com.gorillalogic.utils.FMMessageConstants;
    import com.gorillalogic.utils.StoredValueLookup;
    
    import mx.collections.ArrayCollection;
    import mx.utils.ObjectUtil;

    public class MonkeyRunnableController implements IFMController {

        private var model:ProjectTestModel;

        public function MonkeyRunnableController() {
            model = ProjectTestModel.instance;
        }

        public function register(hub:FMHub):void {
            hub.listen(MonkeyRunnableEvent.DELETE_MONKEY_RUNNABLE, deleteMonkeyRunnable, this);
            hub.listen(MonkeyRunnableEvent.NEW_VERIFY, addVerify, this);
            hub.listen(MonkeyRunnableEvent.NEW_VERIFY_GRID, addVerifyGrid, this);
			hub.listen(MonkeyRunnableEvent.EXPLORE_APP, exploreAutomationChildren, this);
            hub.listen(MonkeyRunnableEvent.NEW_VERIFY_PROP, addVerifyProp, this);
            hub.listen(MonkeyRunnableEvent.NEW_SET_PROPERTY_CMD, addSetPropertyCommand, this);
            hub.listen(MonkeyRunnableEvent.NEW_STORE_VALUE_CMD, addStoreValueCommand, this);
            hub.listen(MonkeyRunnableEvent.NEW_FUNCTION_CMD, addFunctionCommand, this);
            hub.listen(MonkeyRunnableEvent.NEW_PAUSE, addPause, this);
            hub.listen(MonkeyRunnableEvent.CANCEL_COMPONENT_SELECTION, cancelComponentSelection, this);
            hub.listen(MonkeyRunnableEvent.MOVE_MONKEY_RUNNABLE, moveMonkeyRunnable, this);
            hub.listen(MonkeyRunnableEvent.COPY_MONKEY_RUNNABLE, copyMonkeyRunnable, this);
            hub.listen(MonkeyRunnableEvent.MOVE_ALL_RECORDED_ITEMS, moveAllRecordedItems, this);
            hub.listen(MonkeyRunnableEvent.LOAD_COMPONENT_SELECTION, loadComponentSelection, this);
            hub.listen(MonkeyRunnableEvent.RETAKE_VERIFY_SNAPSHOT, retakeVerifySnapshot, this);
            hub.listen(MonkeyRunnableEvent.CANCEL_RETAKE_VERIFY_SNAPSHOT, cancelRetakeSnapshotSelection, this);
        }

        protected function getParentCollection(node:MonkeyRunnable):ArrayCollection {
            var parentCollection:ArrayCollection;

            if (model.isRunnableInRecording(node)) {
                parentCollection = model.recordItems;
            } else if (node is MonkeyTestSuite) {
                parentCollection = model.suites;
            } else if (node is MonkeyTestCase) {
                parentCollection = (node.parent as MonkeyTestSuite).children;
            } else if (node is MonkeyTest) {
                parentCollection = (node.parent as MonkeyTestCase).children;
            } else {
                parentCollection = (node.parent as MonkeyTest).children;
            }

            return parentCollection;
        }

        private function deleteMonkeyRunnable(event:MonkeyRunnableEvent):void {
            var n:MonkeyRunnable = event.monkeyRunnable;
            var col:ArrayCollection = getParentCollection(n);
            col.removeItemAt(col.getItemIndex(n));

            if (n is VerifyMonkeyCommand) {
                var v:VerifyMonkeyCommand = n as VerifyMonkeyCommand;
                FMHub.instance.dispatchEvent(SnapshotEvent.deleteSnapshot(v.snapshotURL, v.expectedSnapshot));
            } else if (n is StoreValueMonkeyCommand) {
                StoredValueLookup.instance.removeCommand(n as StoreValueMonkeyCommand);
            }

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            StoredValueLookup.instance.setup();
        }		

        private function copyMonkeyRunnable(event:MonkeyRunnableEvent):void {
            var col:ArrayCollection;
            var parentNode:MonkeyNode = event.parentNode;

            var copy:MonkeyRunnable = (event.monkeyRunnable as Object).clone();
            copy.parent = parentNode;
            copyChildren(copy);

            if (parentNode == null) { //suite
                col = model.suites;
            } else {
                col = parentNode.children;
            }

            // add to new
            if (col.length > event.position) {
                col.addItemAt(copy, event.position);
            } else {
                col.addItem(copy);
            }

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
            StoredValueLookup.instance.setup();
        }

        private function copyChildren(copy:MonkeyRunnable):void {
            if (copy is MonkeyNode) {
                var newChildren:ArrayCollection = new ArrayCollection();

                for each (var oldNode:MonkeyRunnable in(copy as MonkeyNode).children) {
                    var newRunnable:MonkeyRunnable = (oldNode as Object).clone() as MonkeyRunnable;
                    newRunnable.parent = copy;

                    if (newRunnable is MonkeyNode) {
                        copyChildren(newRunnable);
                    }
                    newChildren.addItem(newRunnable);
                }
                (copy as MonkeyNode).children = newChildren;
            }
        }

        private function moveMonkeyRunnable(event:MonkeyRunnableEvent):void {
            var parentNode:MonkeyNode = event.parentNode;
            var monkeyRunnable:MonkeyRunnable = event.monkeyRunnable;
            var newParentCollection:ArrayCollection;
            var oldParentCollection:ArrayCollection;
            var newIndex:int = event.position;
            var previousIndex:int;

            if (parentNode == null) { //suite
                newParentCollection = model.suites;
                oldParentCollection = model.suites;
            } else {
                newParentCollection = parentNode.children;

                //check for current parent and collection
                if (monkeyRunnable.parent) {
                    oldParentCollection = monkeyRunnable.parent.children;
                } else if (model.recordItems.contains(monkeyRunnable)) {
                    oldParentCollection = model.recordItems;
                }

                //set parent
                monkeyRunnable.parent = parentNode;
            }

            // remove from old
            if (oldParentCollection != null) {
                previousIndex = oldParentCollection.getItemIndex(monkeyRunnable)
                oldParentCollection.removeItemAt(previousIndex);

                // adjust if we were above where we are moving
                if (newParentCollection == oldParentCollection && previousIndex < newIndex) {
                    newIndex--;
                }
            }

            // add to new
            if (newParentCollection.length > newIndex) {
                newParentCollection.addItemAt(monkeyRunnable, newIndex);
            } else {
                newParentCollection.addItem(monkeyRunnable);
            }

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
        }

        private function moveAllRecordedItems(event:MonkeyRunnableEvent):void {
            var parentNode:MonkeyTest = event.parentNode as MonkeyTest;
            var index:int = event.position;
            ProjectTestModel.instance.moveAllRecordedItems(parentNode, index);

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
			FMHub.instance.dispatchEvent(new InteractionEvent(InteractionEvent.DRAG_DONE));
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            FMHub.instance.dispatchEventAsync(new ApplicationEvent(ApplicationEvent.CLOSE_RECORD_WINDOW_VIEW),500);
        }

        private function addPause(event:MonkeyRunnableEvent):void {
            var p:PauseMonkeyCommand = new PauseMonkeyCommand();
            p.parent = event.parentNode;
            p.duration = 500;
            event.parentNode.children.addItemAt(p, event.position);

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

		//
		//Explore Automation Children logic
		//
		
		private function exploreAutomationChildren(event:MonkeyRunnableEvent):void {
			if (ApplicationModel.instance.isConnected) {
				    FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EXPLORE_CHILDREN_POPUP,  new VerifyMonkeyCommand()));
					compSelection(exploreMonkeyCommandCallBack);
			} else {
				FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_EXPLORE_MESSAGE));
			}
		}
		private function exploreMonkeyCommandCallBack(uiCommand:UIEventMonkeyCommand):void {
			var v:VerifyMonkeyCommand = new VerifyMonkeyCommand();
			v.value = uiCommand.value;
			v.prop = uiCommand.prop;
			v.containerValue = uiCommand.containerValue;
			v.containerProp = uiCommand.containerProp;
            v_selected = v;
			 MonkeyLinkConsoleConnectionController.instance.requestVerifyTarget(v, processTarget);
			//change display
			FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EXPLORE_CHILDREN_POPUP_PROPVIEW, v));
		}
		
        //
        // verify selection logic
        //

        private function addVerify(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {

                var verify:VerifyMonkeyCommand = new VerifyMonkeyCommand();
                verify.parent = event.parentNode;
                verify.description = "New Verify";
                event.parentNode.children.addItemAt(verify, event.position);

                // component selection
                model.selectedItem = verify;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, verify));
                compSelection(addVerifyMonkeyCommandCallBack);
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_VERIFY_CREATION_MESSAGE));
            }

            ApplicationModel.instance.isMonkeyTestFileDirty = true;
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

        private function addVerifyMonkeyCommandCallBack(uiCommand:UIEventMonkeyCommand):void {
            var v:VerifyMonkeyCommand = model.selectedItem as VerifyMonkeyCommand;
            v.value = uiCommand.value;
            v.prop = uiCommand.prop;
            v.containerValue = uiCommand.containerValue;
            v.containerProp = uiCommand.containerProp;
			v_selected = v;
            //load target data
            MonkeyLinkConsoleConnectionController.instance.requestVerifyTarget(v, processTarget);

            //change display
            FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_VERIFY_SPY_WINDOW, v));
        }
private var v_selected:VerifyMonkeyCommand;
        private function processTarget(targetVO:TargetVO,
                                       commandProvided:MonkeyRunnable,
                                       clone:MonkeyRunnable,
                                       errorMessage:String = null):void {

			 var v:VerifyMonkeyCommand = v_selected;

            if (errorMessage != null) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, v.description + ": " + errorMessage));
            } else if (targetVO.snapshotVO == null) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, v.description + ": Could not find target " + v.value));
            } else {
                v.targetVO = targetVO;

                if (!v.snapshotURL || v.snapshotURL == "") {
                    var t:String = new String(new Date().time);
                    v.snapshotURL = "verify-" + model.commandCount + "-" + t.substr(t.length - 4) + ".snp";
                }
                v.expectedSnapshot = targetVO.snapshotVO;
                FMHub.instance.dispatchEvent(SnapshotEvent.saveSnapshot(v.snapshotURL, v.expectedSnapshot));
            }
        }

        //
        // verify component selection / edit
        //

        private function loadComponentSelection(event:MonkeyRunnableEvent):void {
            var v:VerifyMonkeyCommand = event.monkeyRunnable as VerifyMonkeyCommand;

            if (v.targetVO == null || v.targetVO.propertyArray == null && v.targetVO.propertyArray.length <= 0) {
                model.selectedItem = v;
                MonkeyLinkConsoleConnectionController.instance.requestLoadComponentProperties(v, loadComponentSelectionCallback);
            }
        }

        private function loadComponentSelectionCallback(targetVO:TargetVO, errorMessage:String):void {
            if (errorMessage != null) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, errorMessage));
            } else {
                var v:VerifyMonkeyCommand = model.selectedItem as VerifyMonkeyCommand;

                if (v.targetVO == null) {
                    v.targetVO = targetVO;
                } else {
                    v.targetVO.propertyArray = targetVO.propertyArray;
                }
            }
        }

        //
        // verify retake snapshot
        //

        private function retakeVerifySnapshot(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {
                var verify:VerifyMonkeyCommand = event.monkeyRunnable as VerifyMonkeyCommand;

                // component selection
                model.selectedItem = verify;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_VERIFY_SNAPSHOT_WINDOW, verify));
                compSelection(retakeVerifySnapshotCallBack);
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_VERIFY_CREATION_MESSAGE));
            }
        }

        private function retakeVerifySnapshotCallBack(uiCommand:UIEventMonkeyCommand):void {
            var v:VerifyMonkeyCommand = model.selectedItem as VerifyMonkeyCommand;
            var tempVerify:VerifyMonkeyCommand = new VerifyMonkeyCommand();
            tempVerify.value = uiCommand.value;
            tempVerify.prop = uiCommand.prop;
            tempVerify.containerValue = uiCommand.containerValue;
            tempVerify.containerProp = uiCommand.containerProp;

            MonkeyLinkConsoleConnectionController.instance.requestVerifyTarget(tempVerify, processNewSnapshot);
            FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.SHOW_VERIFY_SNAPSHOT_WINDOW, v));
        }

        private function processNewSnapshot(targetVO:TargetVO,
                                            commandProvided:MonkeyRunnable,
                                            clone:MonkeyRunnable,
                                            errorMessage:String = null):void {

            var v:VerifyMonkeyCommand = model.selectedItem as VerifyMonkeyCommand;

            if (errorMessage != null) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, v.description + ": " + errorMessage));
            } else if (targetVO.snapshotVO == null) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, v.description + ": Could not find target " + v.value));
            } else {
                v.expectedSnapshot = targetVO.snapshotVO;
                FMHub.instance.dispatchEvent(SnapshotEvent.saveSnapshot(v.snapshotURL, v.expectedSnapshot));
            }
        }

        //
        // verify grid selection logic
        //

        private function addVerifyGrid(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {
                var verifyGrid:VerifyGridMonkeyCommand = new VerifyGridMonkeyCommand();
                verifyGrid.parent = event.parentNode;
                verifyGrid.description = "New Verify Grid";
                event.parentNode.children.addItemAt(verifyGrid, event.position);

                // component selection
                model.selectedItem = verifyGrid;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, verifyGrid));
                compSelection(genericCompSelectionCallBack);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_VERIFY_GRID_CREATION_MESSAGE));
            }
        }

        //
        // verify prop selection logic
        //

        private function addVerifyProp(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {
                var verify:VerifyPropertyMonkeyCommand = new VerifyPropertyMonkeyCommand();
                verify.parent = event.parentNode;
                verify.description = "New Verify Expression";
                event.parentNode.children.addItemAt(verify, event.position);

                // component selection
                model.selectedItem = verify;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, verify));
                compSelection(genericCompSelectionCallBack);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_VERIFY_PROP_CREATION_MESSAGE));
            }
        }

        //
        // generic verify functions
        //

        private function compSelection(callBack:Function):void {
            MonkeyLinkConsoleConnectionController.instance.selectComponent(callBack);
        }

        private function genericCompSelectionCallBack(uiCommand:UIEventMonkeyCommand):void {
            var r:MonkeyRunnable = model.selectedItem as MonkeyRunnable;
            r.value = uiCommand.value;
            r.prop = uiCommand.prop;
            r.containerValue = uiCommand.containerValue;
            r.containerProp = uiCommand.containerProp;

            FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_MONKEY_RUNNABLE, r));
        }

        //
        // cancel selection
        //

        private function cancelComponentSelection(event:MonkeyRunnableEvent):void {
            FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.DELETE_MONKEY_RUNNABLE, model.selectedItem));
            MonkeyLinkConsoleConnectionController.instance.cancelComponentSelection();
        }

        private function cancelRetakeSnapshotSelection(event:MonkeyRunnableEvent):void {
            MonkeyLinkConsoleConnectionController.instance.cancelComponentSelection();
        }

        //
        // set property command logic
        //

        private function addSetPropertyCommand(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {
                var cmd:SetPropertyMonkeyCommand = new SetPropertyMonkeyCommand();
                cmd.parent = event.parentNode;
                cmd.description = "New Set Property Command";
                event.parentNode.children.addItemAt(cmd, event.position);

                // component selection
                model.selectedItem = cmd;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, cmd));
                compSelection(genericCompSelectionCallBack);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_SET_PROPERTY_CMD_CREATION_MESSAGE));
            }
        }


        //
        // store value command logic
        //

        private function addStoreValueCommand(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {
                var cmd:StoreValueMonkeyCommand = new StoreValueMonkeyCommand();
                StoredValueLookup.instance.addCommand(cmd);
                cmd.parent = event.parentNode;
                cmd.description = "New Store Value Command";
                event.parentNode.children.addItemAt(cmd, event.position);

                // component selection
                model.selectedItem = cmd;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, cmd));
                compSelection(storeValueCompSelectionCallBack);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_STORE_VALUE_CMD_CREATION_MESSAGE));
            }
        }

        private function storeValueCompSelectionCallBack(uiCommand:UIEventMonkeyCommand):void {
            (model.selectedItem as StoreValueMonkeyCommand).keyName = uiCommand.value + "Key";
            genericCompSelectionCallBack(uiCommand);
        }

        //
        // call function command logic
        //

        private function addFunctionCommand(event:MonkeyRunnableEvent):void {
            if (ApplicationModel.instance.isConnected) {

                var cmd:CallFunctionMonkeyCommand = new CallFunctionMonkeyCommand();
                cmd.parent = event.parentNode;
                cmd.description = "New Call Function Command";
                event.parentNode.children.addItemAt(cmd, event.position);

                // component selection
                model.selectedItem = cmd;
                FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_NEW_MONKEY_RUNNABLE, cmd));
                compSelection(genericCompSelectionCallBack);

                ApplicationModel.instance.isMonkeyTestFileDirty = true;
                FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
            } else {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, FMMessageConstants.NOT_CONNECTED_FUNCTION_CMD_CREATION_MESSAGE));
            }
        }



    }
}
