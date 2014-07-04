/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers {

    import com.gorillajawn.gate.ParallelGate;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.LoadChildSuiteFileCommand;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;

    public class SuiteChildFilesGate extends ParallelGate {

        private var model:ProjectTestModel = ProjectTestModel.instance;
        private var files:Array;

        override protected function register():void {
            this.commands = [];

            for each (var filename:String in files) {
                this.commands.push(new LoadChildSuiteFileCommand(filename));
            }
        }

        public function addFile(filename:String):void {
            if (files == null) {
                files = [];
            }

            files.push(filename);
        }

        override protected function notifySuccess():void {
            for each (var filename:String in files) {
                model.suiteChildFileData.addItem(model.suiteChildFileDataReturn[filename]);
            }

            super.notifySuccess();
        }
    }
}
