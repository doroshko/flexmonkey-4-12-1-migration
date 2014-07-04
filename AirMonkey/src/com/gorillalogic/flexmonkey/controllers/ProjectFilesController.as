/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.controllers.helpers.NewProjectGate;
    import com.gorillalogic.flexmonkey.controllers.helpers.OpenProjectGate;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.SaveProjectCommand;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.SaveSuitesCommand;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.vo.ProjectPropertiesVO;
    import com.gorillalogic.flexmonkey.xmlConversion.TestXMLConvertor;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.utils.ProjectXmlUtils;

    import flash.events.Event;
    import flash.events.FileListEvent;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    /**
     * AIR API dependencies
     */
    public class ProjectFilesController implements IFMController {

        private var browseAfterSave:Boolean = false;

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var newProjectURL:String;
        private var testXMLConvertor:TestXMLConvertor;

        public function ProjectFilesController() {
            testXMLConvertor = new TestXMLConvertor();
        }

        public function register(hub:FMHub):void {
            hub.listen(ProjectFilesEvent.NEW_PROJECT, requestForNewProject, this);
            hub.listen(ProjectFilesEvent.OPEN_PROJECT, requestForOpenProject, this);
            hub.listen(ProjectFilesEvent.PROJECT_PROPERTIES_UPDATE, updateProjectProperties, this);
            hub.listen(ProjectFilesEvent.SAVE_CANCELLED, testFileSaveCancelled, this);
            hub.listen(ProjectFilesEvent.SAVE, saveSuiteFileHandler, this);
        }

        //
        // request file dialogs
        //

        /**
         * open file browse for creating a new project
         */
        private function requestForNewProject(event:Event = null):void {
            ApplicationModel.instance.isNewProject = true;

            if (ApplicationModel.instance.isMonkeyTestFileDirty) {
                browseAfterSave = true;
                FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.PROMPT_FOR_SAVE));
            } else {
                projectBrowse();
            }
        }

        /**
         * open file browse for opening an existing project
         */
        private function requestForOpenProject(event:Event = null):void {
            if (ApplicationModel.instance.isMonkeyTestFileDirty) {
                browseAfterSave = true;
                FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.PROMPT_FOR_SAVE));
            } else {
                projectBrowse();
            }
        }

        /**
         * update project file
         */
        private function updateProjectProperties(event:Object = null):void {
            var properties:ProjectPropertiesVO = event.item as ProjectPropertiesVO;
            model.generatedCodeSuitesPackageName = properties.generatedCodeSuitesPackageName;
			model.generatedCodeTestCaseBaseClass = properties.generatedCodeTestCaseBaseClass;
            model.generatedCodeUrl = properties.generatedCodeSourceDirectory;
            model.codeGenTimeoutPadding = properties.codeGenTimeoutPadding;
            model.projectXML = ProjectXmlUtils.getProjectXML();

            new SaveProjectCommand().execute();
        }

        //
        // browse for project files
        //

        private function projectBrowse():void {
            var file:File;

            if (ProjectTestModel.instance.projectUrl == "" || ProjectTestModel.instance.projectUrl == null) {
                file = new File();
            } else {
                try {
                    file = new File(ProjectTestModel.instance.projectUrl);
                } catch (error:ArgumentError) {
                    try {
                        file = new File(File.userDirectory.url);
                    } catch (error:ArgumentError) {
                        throw new Error("Malformed Project URL while browsing for Project Directory.");
                        ApplicationModel.instance.isNewProject = false;
                        return;
                    }
                }
            }
            file.addEventListener(Event.CANCEL, projectBrowseCancelHandler, false, 0, true);
            file.addEventListener(Event.SELECT, projectBrowseSelectHandler, false, 0, true);

            if (ApplicationModel.instance.isNewProject) {
                file.browseForDirectory("New Project: Select a location to store the FlexMonkey project files");
            } else {
                file.browseForDirectory("Open Project: Select a location to with FlexMonkey project files");
            }
        }

        private function projectBrowseCancelHandler(event:Event):void {
            ApplicationModel.instance.isNewProject = false;
        }

        private function projectBrowseSelectHandler(event:Event):void {
            newProjectURL = event.target.url;
            var file:File = new File(newProjectURL);
            file.addEventListener(IOErrorEvent.IO_ERROR, directoryListingIOErrorHandler, false, 0, true);
            file.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingHandler, false, 0, true);
            file.getDirectoryListingAsync();
        }

        private function directoryListingIOErrorHandler(event:IOErrorEvent):void {
            FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Could not check selected directory for Monkey Project Files"));
            ApplicationModel.instance.isNewProject = false;
        }

        private function directoryListingHandler(event:FileListEvent):void {
            var directoryContents:Array = event.files;
            var hasMonkeyTestProjectFile:Boolean = false;

            //check for file
            for each (var file:File in directoryContents) {
                if (file.nativePath.indexOf(ProjectTestModel.PROJECT_FILE_NAME) > -1) {
                    hasMonkeyTestProjectFile = true;
                    break;
                }
            }

            if (!ApplicationModel.instance.isNewProject) {
                if (hasMonkeyTestProjectFile) {
                    openProject();
                } else {
                    FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "No Project Files Found!"));
                }
            } else {
                if (hasMonkeyTestProjectFile) {
                    FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Project Already Exists!"));
                    ApplicationModel.instance.isNewProject = false;
                } else {
                    newProject();
                }
            }
        }

        private function openProject():void {
            model.projectUrl = newProjectURL;
            model.preferencesXML.project.@url = newProjectURL;

            var openProject:OpenProjectGate = new OpenProjectGate();
            openProject.run();
        }

        private function newProject():void {
            model.projectUrl = newProjectURL;
            model.preferencesXML.project.@url = newProjectURL;
            model.generatedCodeSuitesPackageName = "testSuites";
			model.generatedCodeTestCaseBaseClass = "";
            model.generatedCodeUrl = "tests/src";
            model.projectXML = ProjectXmlUtils.getProjectXML();

            var newProject:NewProjectGate = new NewProjectGate();
            newProject.run();
        }

        /**
         * user canceled file creationg
         */
        private function testFileSaveCancelled(event:Event = null):void {
            browseAfterSave = false;
            ApplicationModel.instance.isNewProject = false;
        }

        private function saveSuiteFileHandler(event:ProjectFilesEvent = null):void {
            new SaveSuitesCommand((event != null && event.closeApplicationAfterSave)).execute();
        }

    }
}
