/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;

    public class SavePreferencesCommand extends GateCommand {

        override public function execute():void {
            XML.prettyPrinting = true;
            FMFileUtils.saveFile(ProjectTestModel.instance.preferencesUrl, ProjectTestModel.instance.preferencesXML.toXMLString());
            this.proceed();
        }

    }

}
