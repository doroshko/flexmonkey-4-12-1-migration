/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    public class FMMessageConstants {

        public static const FLEXMONKEY_HELP_STG:String = "FlexMonkey Help";

        public static const WINDOW_MSG:String = "FlexMonkey is powered by Gorila Logic, Inc.";

        public static const PROJECT_DIRECTORY_HELP:String = "The Project Directory is the location where you would like your FlexMonkey test scripts stored. The recommended location is a \"tests\" directory under your Flex project root.";
        public static const SOURCE_DIRECTORY_HELP:String = "The source directory is used when you generate source code from your FlexMonkey tests.  The code is typically used to run your tests within a continuous integration environment.  ";
        public static const PACKAGE_NAME_HELP:String = "The package name is used when generating source code.";
		public static const TESTCASE_BASE_CLASS_HELP:String = "Used when you create your own base class for TestCases in generated code.";
        public static const USE_MULTIPLE_SUITE_FILES_HELP:String = "FlexMonkey test suites are stored in XML files.  This option allows you to choose between a single file and multiple files.";
        public static const CODE_GEN_TIMEOUT_PADDING:String = "Generated code sets a timeout for each test method, calculated based on the number of retrys avaliable.  This setting adjusts the amount of time padding added to each timeout.";

        public static const ENV_FILE_HELP:String = "The FlexMonkeyEnv.xml environment file is used to describe the components used in a given Flex/AIR application, including defining relevant properties and events.  The default environment file describes all Flex 3 (Halo) and Flex 4 (Spark) components.  The default configuration should work fine as long as you are using the out of the box Flex components.  If you have custom components, you will likely need to instrument them to work with FlexMonkey.  You can learn how to automate your custom components here: ";
        public static const ENV_FILE_HELP_LINK:String = "http://www.gorillalogic.com/books/flexmonkey-docs/automating-custom-components";
        public static const ENV_FILE_HELP_LINK_LABEL:String = "Automating Custom Component Documentation";

        public static const VERIFY_GRID_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Verify Grid' assertion.";
        public static const VERIFY_PROP_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Verify Expression' assertion.";
        public static const VERIFY_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Verify' assertion.";
        public static const EDIT_VERIFY_SNAPSHOT:String = "Select new target component for snapshot in application under test.";
		
		public static const EXPLORE_COMPONENT_SELECTION:String = "Select target component in application under test to explore.";

        public static const SET_PROPERTY_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Set Property Command.'";
        public static const STORE_VALUE_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Store Value Command.'";
        public static const FUNCTION_CMD_COMPONENT_SELECTION:String = "Select target component in application under test for the new 'Call Function Command.'";

		public static const NOT_CONNECTED_EXPLORE_MESSAGE:String = "You must be connect to the application under test in order to explore it.";
        public static const NOT_CONNECTED_VERIFY_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Verify' assertion.";
        public static const NOT_CONNECTED_VERIFY_GRID_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Verify Grid' assertion.";
        public static const NOT_CONNECTED_VERIFY_PROP_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Verify Expression' assertion.";
        public static const NOT_CONNECTED_SET_PROPERTY_CMD_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Set Property Command.'";
        public static const NOT_CONNECTED_STORE_VALUE_CMD_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Store Value Command.'";
        public static const NOT_CONNECTED_FUNCTION_CMD_CREATION_MESSAGE:String = "You must be connect to the application under test in order to create a new 'Call Function Command.'";

        public static const RECORDING_NOT_CONNECTED:String = "Not Connected: FlexMonkey must be connected to your application in order to record new commands.";
        public static const RECORDING_OPENED_FOR_RECORDING_MSG:String = "Recorded commands will be stored here in this buffer. To save the commands, drag the buffer into an existing or new test.";
    }

}
