/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers.helpers.cmds {

    import com.gorillajawn.gate.GateCommand;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;

    public class SaveProjectCommand extends GateCommand {

        override public function execute():void {
            FMFileUtils.saveFile(ProjectTestModel.instance.projectFileUrl, ProjectTestModel.instance.projectXML.toXMLString());
            this.proceed();
        }

    }

}
