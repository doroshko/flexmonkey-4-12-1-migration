/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.xmlConversion.TestXMLConvertor;
    import com.gorillalogic.utils.StoredValueLookup;

    public class ParseSuiteDataCommand extends GateCommand {

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var testXMLConvertor:TestXMLConvertor;

        public function ParseSuiteDataCommand() {
            testXMLConvertor = new TestXMLConvertor();
        }

        override public function execute():void {
            if (model.suiteChildFileData.length > 0) {
                model.suiteXml = <FlexMonkey></FlexMonkey>;

                for each (var t:XML in model.suiteChildFileData) {
                    model.suiteXml.appendChild(t.elements());
                }
            }

            loadMonkeySuiteXmlNodes();
        }

        /**
         * parses and loads child xml
         */
        private function loadMonkeySuiteXmlNodes():void {
            if (model.suiteXml) {
                model.suites = null;
                model.suites = testXMLConvertor.parseXML(model.suiteXml);

                StoredValueLookup.instance.setup();
                ApplicationModel.instance.isProjectOpen = true;

                this.proceed();
            } else {
                this.error("Suite File is empty: " + model.monkeyTestFileUrl);
            }
        }
    }
}
