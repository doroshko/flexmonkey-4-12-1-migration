package testSuites.exampleTestSuite.testCases {

	import com.gorillalogic.flexunit.IFlexMonkeyTestCase
    import testSuites.exampleTestSuite.testCases.tests.ExampleTest;

    [Suite (order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class ExampleTestCase implements IFlexMonkeyTestCase {

        public var test1:ExampleTest;

    }
}