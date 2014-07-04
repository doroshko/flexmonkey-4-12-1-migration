/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.events.FMAlertEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.flexmonkey.xmlConversion.TestXMLConvertor;
    import com.gorillalogic.framework.FMHub;

    public class SaveNewMonkeySuiteCommand extends GateCommand {

        private var newTestFileXML:XML =
            <FlexMonkey>
                <TestSuite name="New Test Suite">
                    <TestCase name="New Test Case">
                        <Test name="New Test"/>
                    </TestCase>
                </TestSuite>
            </FlexMonkey>;

        override public function execute():void {
            var testXMLConvertor:TestXMLConvertor = new TestXMLConvertor();
            var model:ProjectTestModel = ProjectTestModel.instance;

            model.suites = testXMLConvertor.parseXML(newTestFileXML);
            var suiteData:Object = testXMLConvertor.generateXML(model.suites, false);
            var rootFileXml:String = suiteData.rootFile as String;

            var fileSaved:Boolean = FMFileUtils.saveFile(model.monkeyTestFileUrl, rootFileXml);

            if (fileSaved) {
                //update dirty state
                ApplicationModel.instance.isMonkeyTestFileDirty = false;
                FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.Alert, "Project File Saved Successfully"));
            }

            this.proceed();
        }

    }
}
