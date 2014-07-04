/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;

    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;

    public class LoadPreferencesCommand extends GateCommand {

        private var model:ProjectTestModel = ProjectTestModel.instance;

        override public function execute():void {
            model.preferencesUrl = File.userDirectory.url + "/flexMonkeyPreferences.xml";
            FMFileUtils.readFile(model.preferencesUrl, successHandler, faultHandler);
        }

        /**
         * preference file read success
         */
        private function successHandler(event:Event):void {
            var xml:XML = FMFileUtils.parseXmlFile(event.target as FileStream, faultHandler);

            if (xml) {
                model.preferencesXML = xml;
                var url:String = xml.project.@url;

                if (url) {
                    model.projectUrl = url;
                    this.proceed();
                } else {
                    faultHandler();
                }
            } else {
                faultHandler();
            }
        }

        /**
         * Handle preference file load error.  If we can't load the preference file, open new dialog on the project properties window.
         */
        private function faultHandler(e:Object = null):void {
            this.error("Failed to load preferences");
        }

    }
}
