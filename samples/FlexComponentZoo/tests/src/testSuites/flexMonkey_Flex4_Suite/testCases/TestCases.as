package testSuites.flexMonkey_Flex4_Suite.testCases {

	import com.gorillalogic.flexunit.IFlexMonkeyTestCase
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.ASetupUp;
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.Button;
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.ButtonBar;
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.CheckBox;
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.ComboBox;
    import testSuites.flexMonkey_Flex4_Suite.testCases.tests.List;

    [Suite (order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class TestCases implements IFlexMonkeyTestCase {

        public var test1:ASetupUp;
        public var test2:Button;
        public var test3:ButtonBar;
        public var test4:CheckBox;
        public var test5:ComboBox;
        public var test6:List;

    }
}