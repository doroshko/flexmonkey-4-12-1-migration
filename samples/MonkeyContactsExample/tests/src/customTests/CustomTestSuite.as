package customTests {

	import com.gorillalogic.flexunit.IFlexMonkeyTestSuite
    import customTests.CustomTestCase;

    [Suite(order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class CustomTestSuite implements IFlexMonkeyTestSuite {

        public var test1:CustomTestCase;

    }
}