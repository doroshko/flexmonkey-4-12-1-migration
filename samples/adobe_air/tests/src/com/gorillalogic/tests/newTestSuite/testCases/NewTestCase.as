package com.gorillalogic.tests.newTestSuite.testCases {

	import com.gorillalogic.flexunit.IFlexMonkeyTestCase
    import com.gorillalogic.tests.newTestSuite.testCases.tests.MyTest;

    [Suite (order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class NewTestCase implements IFlexMonkeyTestCase {

        public var test1:MyTest;

    }
}