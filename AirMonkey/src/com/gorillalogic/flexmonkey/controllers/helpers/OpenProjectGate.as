/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillajawn.gate.SerialGate;
    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.ProjectFilesEvent;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.OpenProjectCommand;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.OpenSuitesCommand;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.ParseSuiteDataCommand;
    import com.gorillalogic.flexmonkey.controllers.helpers.cmds.SavePreferencesCommand;


    public class OpenProjectGate extends SerialGate {

        public function OpenProjectGate() {
            this.successHandler = startupSuccessHandler;
            this.faultHandler = startupFault;
        }

        override protected function register():void {
            this.commands = [];
            this.commands.push(new SavePreferencesCommand());
            this.commands.push(new OpenProjectCommand());
            this.commands.push(new OpenSuitesCommand());
            this.commands.push(new ParseSuiteDataCommand());
        }

        private function startupSuccessHandler():void {
            FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.TEST_PROJECT_FILE_OPENED));
            FMHub.instance.dispatchEvent(new ApplicationEvent(ApplicationEvent.UPDATE_SUMMARY));
        }

        private function startupFault(cmd:GateCommand, msg:String):void {
            FMHub.instance.dispatchEvent(new ProjectFilesEvent(ProjectFilesEvent.FAILED_TO_OPEN_PROJECT, msg));
        }
    }

}
