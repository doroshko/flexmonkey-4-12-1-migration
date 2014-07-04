/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import com.gorillalogic.flexmonkey.model.ProjectTestModel;

    public class ProjectXmlUtils {

        /**
         * xml for the project file
         */
        public static function getProjectXML():XML {
            var xml:XML = <project useMultipleSuiteFiles={ProjectTestModel.instance.useMultipleSuiteFiles}
                    codeGenTimeoutPadding={ProjectTestModel.instance.codeGenTimeoutPadding} />;
            var genCodeURLAttr:String = ProjectTestModel.instance.generatedCodeUrl;

            if (genCodeURLAttr.indexOf(ProjectTestModel.instance.projectUrl) == 0) {
                genCodeURLAttr = genCodeURLAttr.substr(ProjectTestModel.instance.projectUrl.length + 1);
            }

            xml.appendChild(<generatedCode url={genCodeURLAttr}
                                suitesPackageName={ProjectTestModel.instance.generatedCodeSuitesPackageName}
								testCaseBaseClass={ProjectTestModel.instance.generatedCodeTestCaseBaseClass} />);
            return xml;
        }

    }

}
