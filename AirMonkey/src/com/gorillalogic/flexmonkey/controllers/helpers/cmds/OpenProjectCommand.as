/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.utils.FMErrorUtil;

    import flash.events.Event;
    import flash.filesystem.FileStream;

    public class OpenProjectCommand extends GateCommand {

        private var model:ProjectTestModel = ProjectTestModel.instance;

        override public function execute():void {
            FMFileUtils.readFile(ProjectTestModel.instance.projectFileUrl, successHandler, faultHandler);
        }

        /**
         * project file load success handler. if all succeeds, proceed with opening the suites file
         */
        private function successHandler(event:Event):void {
            var xml:XML = FMFileUtils.parseXmlFile(event.target as FileStream, faultHandler);

            if (xml) {
                ProjectTestModel.instance.projectXML = xml;
                updateProjectPropertiesFromXML();
                this.proceed();
            } else {
                this.error("Project File is empty: " + ProjectTestModel.instance.projectFileUrl);
            }
        }

        /**
         * Error opening the project file, dispatch event to provided users with options on how to proceed
         */
        private function faultHandler(e:Object):void {
            var msg:String = FMErrorUtil.getErrorMessage(e);
            this.error(msg);
        }

        /**
         *
         */
        private function updateProjectPropertiesFromXML():void {
            model.generatedCodeUrl = model.projectXML.generatedCode.@url;
            model.generatedCodeSuitesPackageName = model.projectXML.generatedCode.@suitesPackageName;
			model.generatedCodeTestCaseBaseClass = model.projectXML.generatedCode.@testCaseBaseClass;
            model.codeGenTimeoutPadding = model.projectXML.@codeGenTimeoutPadding;

            if (model.codeGenTimeoutPadding == 0) {
                model.codeGenTimeoutPadding = 2000;
            }

            if (model.projectXML.@useMultipleSuiteFiles == null ||
                model.projectXML.@useMultipleSuiteFiles.toString().toLowerCase().indexOf("t") == 0) {
                model.useMultipleSuiteFiles = true;
            } else {
                model.useMultipleSuiteFiles = false;
            }
        }

    }

}
