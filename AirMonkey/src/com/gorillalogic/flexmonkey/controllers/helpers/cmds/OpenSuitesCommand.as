/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.controllers.helpers.SuiteChildFilesGate;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.flexmonkey.xmlConversion.TestXMLConvertor;
    import com.gorillalogic.utils.FMErrorUtil;

    import flash.events.Event;
    import flash.filesystem.FileStream;

    import mx.collections.ArrayCollection;

    public class OpenSuitesCommand extends GateCommand {

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var testXMLConvertor:TestXMLConvertor;

        public function OpenSuitesCommand() {
            testXMLConvertor = new TestXMLConvertor();
        }

        override public function execute():void {
            model.suiteChildFileDataReturn = {};
            model.suiteChildFileData = new ArrayCollection();
            FMFileUtils.readFile(model.monkeyTestFileUrl, successHandler, faultHandler);
        }

        /**
         * suite file opened successfully
         */
        private function successHandler(event:Event):void {
            var xml:XML = FMFileUtils.parseXmlFile(event.target as FileStream, faultHandler);

            if (xml.TestSuiteFile.length() == 0) {
                model.suiteXml = xml;
                this.proceed();
            } else {
                // load suite files
                var suitesGate:SuiteChildFilesGate = new SuiteChildFilesGate();
                suitesGate.successHandler = childSuitesSuccess;
                suitesGate.faultHandler = childSuitesFault;
                var count:int = 0;

                for each (var x:XML in xml.elements()) {
                    if (x.localName() == "TestSuiteFile") {
                        var f:String = xml.TestSuiteFile[count].@filename.toString();
                        suitesGate.addFile(f);
                        count++;
                    }
                }

                suitesGate.run();
            }
        }

        /**
         * Error opening the suite file, dispatch event to provided users with options on how to proceed
         */
        private function faultHandler(e:Object):void {
            var msg:String = FMErrorUtil.getErrorMessage(e);
            this.error(msg);
        }

        private function childSuitesSuccess():void {
            this.proceed();
        }

        private function childSuitesFault(cmd:GateCommand, msg:String):void {
            this.error(msg);
        }

    }
}
