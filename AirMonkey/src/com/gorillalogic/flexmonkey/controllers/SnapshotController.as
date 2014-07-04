/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.events.SnapshotEvent;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    
    import flash.events.Event;
    import flash.filesystem.File;
    
    import mx.collections.ArrayCollection;
    
    import org.as3commons.lang.StringUtils;

    /**
     * AIR API dependencies
     */
    public class SnapshotController implements IFMController {

        private var model:ProjectTestModel = ProjectTestModel.instance;

        public function register(hub:FMHub):void {
            // snapshot files
            hub.listen(SnapshotEvent.SAVE_SNAPSHOT, saveSnapshotHandler, this);
            hub.listen(SnapshotEvent.DELETE_SNAPSHOT, deleteSnapshotHandler, this);

            //clean-up snapshots
            hub.listen(SnapshotEvent.REMOVE_UNUSED_SNAPSHOTS, cleanUpsnapshots, this);
        }


        private function saveSnapshotHandler(event:SnapshotEvent):void {
            var url:String = FMFileUtils.getFullURL(ProjectTestModel.instance.snapshotsDirUrl, event.url);
			checkForSnapshotLocationBackwardCompatibility();
            FMFileUtils.saveFile(url, event.fileData);
        }

        private function deleteSnapshotHandler(event:SnapshotEvent):void {
            if (event.url != null && event.url.length > 0) {
                var url:String = FMFileUtils.getFullURL(ProjectTestModel.instance.snapshotsDirUrl, event.url);
                FMFileUtils.deleteFile(url);
            }
        }

        private function removeUnusedFiles(filenamesSaved:ArrayCollection):void {
            var projectDir:File = new File(model.projectUrl);

            for each (var f:File in projectDir.getDirectoryListing()) {
                if (!f.isDirectory &&
                    !filenamesSaved.contains(f.name) &&
                    f.name != ProjectTestModel.PROJECT_FILE_NAME &&
                    f.name != ProjectTestModel.PROJECT_SUITE_FILE_NAME &&
                    StringUtils.endsWith(f.name, ".xml")) {
                    FMFileUtils.deleteFile(f.nativePath);
                }
            }
        }

        /**
         * Remove unused files from file system
         */
        private function cleanUpsnapshots(event:Event):void {
            var usedSnapshotFileNames:ArrayCollection = new ArrayCollection();

            //get list of snapshots
            for each (var s:MonkeyTestSuite in model.suites) {
                for each (var c:MonkeyTestCase in s.children) {
                    for each (var t:MonkeyTest in c.children) {
                        for each (var cmd:MonkeyRunnable in t.children) {
                            if (cmd is VerifyMonkeyCommand) {
                                var v:VerifyMonkeyCommand = cmd as VerifyMonkeyCommand;

                                if (v.verifyBitmap && v.snapshotURL != null && v.snapshotURL.length > 0) {
                                    usedSnapshotFileNames.addItem(v.snapshotURL);
                                } else {
                                    v.snapshotURL = "";
                                }
                            }
                        }
                    }
                }
            }

			var snapshotsDirFile:File = new File(ProjectTestModel.instance.snapshotsDirUrl);
			if (snapshotsDirFile.exists) {
	            var files:Array = snapshotsDirFile.getDirectoryListing();
	            var successRemoving:Boolean = true;
	            var removedCount:int = 0;
	
	            // remove any unused files
	            for (var i:int; i < files.length; i++) {
	                var snapshotFile:File = files[i] as File;
	
	                if (!snapshotFile.isDirectory) {
	                    var used:Boolean = usedSnapshotFileNames.contains(snapshotFile.name);
	
	                    if (!used) {
	                        successRemoving = FMFileUtils.deleteFile(snapshotFile.nativePath);
	
	                        if (!successRemoving) {
	                            FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Failed to remove all unused Snapshot files - (" + removedCount + ") were removed"));
	                            break;
	                        } else {
	                            removedCount++;
	                        }
	                    }
	                }
	            }
			}

            if (successRemoving) {
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.Alert, "Unused Snapshot files removed (" + removedCount + ")"));
            }
        }
		
		// during "Releaded" beta, snapshots were moved from <project-dir>/snapshots
		// to <generated_code_dir>/snapshots 
		private function checkForSnapshotLocationBackwardCompatibility():void {
			// check to see if the new location is defined in the project
			var desiredSnapshotsDir:String = ProjectTestModel.instance.snapshotsDirUrl;
			var desiredSnapshotsDirFile:File = new File(desiredSnapshotsDir);
			if (! desiredSnapshotsDirFile.exists) {
				// define it 
				desiredSnapshotsDirFile.createDirectory();	
				// check to see if the old location has anything
				var oldStyleSnapshotsDir:String = ProjectTestModel.instance.projectUrl + "/snapshots";
				var oldStyleSnapshotsDirFile:File = new File(oldStyleSnapshotsDir);
				if (oldStyleSnapshotsDirFile.exists) {
					//  copy the old stuff to the new location
					var copyThese:Array = oldStyleSnapshotsDirFile.getDirectoryListing();	
					for each (var copyMe:File in copyThese) {
						if (copyMe.name.indexOf(".snp")==copyMe.name.length-4) {
							var targetFile:File = new File(desiredSnapshotsDir + "/" + copyMe.name);
							copyMe.copyTo(targetFile);
						}
					}
				}
			}
		}

    }

}
