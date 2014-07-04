/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.flexmonkey.xmlConversion.TestXMLConvertor;
    import com.gorillalogic.framework.FMHub;

    import mx.collections.ArrayCollection;

    public class SaveSuitesCommand extends GateCommand {

        private var closeApplication:Boolean;


        public function SaveSuitesCommand(closeApplication:Boolean = false) {
            this.closeApplication = closeApplication;
        }

        override public function execute():void {
            var testXMLConvertor:TestXMLConvertor = new TestXMLConvertor();
            var model:ProjectTestModel = ProjectTestModel.instance;

            var fileSaved:Boolean = false;

            var filenamesSaved:ArrayCollection = new ArrayCollection();
            var filesToSave:Array = [];
            var suiteData:Object = testXMLConvertor.generateXML(model.suites, model.useMultipleSuiteFiles);
            var rootFileXml:String = suiteData.rootFile as String;
            var suiteFiles:Array = suiteData.suiteFiles as Array;

            filesToSave[0] = { f: model.monkeyTestFileUrl, c: rootFileXml };

            var count:int = 1;

            for each (var d:Object in suiteFiles) {
                var f:String = d.filename;
                var c:String = d.xml;
                filesToSave[count] = { f: model.projectUrl + "/" + f, c: c };
                filenamesSaved.addItem(f);
                count++;
            }

            // save
            for each (var sf:Object in filesToSave) {
                fileSaved = FMFileUtils.saveFile(sf.f, sf.c);
            }

            if (fileSaved) {
                //update dirty state
                ApplicationModel.instance.isMonkeyTestFileDirty = false;

                //tell application to close
                if (closeApplication) {
                    FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.CLOSE_APPLICATION));
                } else {
                    FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.Alert, "Project File Saved Successfully"));
                }
            }

            this.proceed();
        }

    }

}
