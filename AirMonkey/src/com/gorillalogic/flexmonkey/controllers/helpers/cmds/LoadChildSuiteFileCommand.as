/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.utils.FMErrorUtil;

    import flash.events.Event;
    import flash.filesystem.FileStream;

    public class LoadChildSuiteFileCommand extends GateCommand {

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var filename:String;

        public function LoadChildSuiteFileCommand(filename:String) {
            this.filename = filename;
        }

        override public function execute():void {
            FMFileUtils.readFile(model.projectUrl + "/" + filename, fileLoadedHandler, faultReadingFile);
        }

        /**
         * Child suite file handlers
         */
        private function fileLoadedHandler(event:Event):void {
            var xml:XML = FMFileUtils.parseXmlFile(event.target as FileStream, faultReadingFile);
            model.suiteChildFileDataReturn[filename] = xml;
            this.proceed();
        }

        private function faultReadingFile(e:Object):void {
            var msg:String = FMErrorUtil.getErrorMessage(e);
            this.error(msg);
        }

    }

}
