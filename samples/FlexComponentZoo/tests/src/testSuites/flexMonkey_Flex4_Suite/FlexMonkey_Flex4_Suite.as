package testSuites.flexMonkey_Flex4_Suite {

	import com.gorillalogic.flexunit.IFlexMonkeyTestSuite
    import testSuites.flexMonkey_Flex4_Suite.testCases.TestCases;

    [Suite(order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class FlexMonkey_Flex4_Suite implements IFlexMonkeyTestSuite {

        public var test1:TestCases;

    }
}