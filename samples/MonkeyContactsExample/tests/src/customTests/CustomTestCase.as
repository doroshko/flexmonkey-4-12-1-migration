package customTests {

	import com.gorillalogic.flexunit.IFlexMonkeyTestCase
    import customTests.CustomTest;

    [Suite (order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class CustomTestCase implements IFlexMonkeyTestCase {

        public var test1:CustomTest;

    }
}