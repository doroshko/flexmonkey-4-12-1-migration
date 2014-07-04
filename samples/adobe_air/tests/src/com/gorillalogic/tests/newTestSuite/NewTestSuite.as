package com.gorillalogic.tests.newTestSuite {

	import com.gorillalogic.flexunit.IFlexMonkeyTestSuite
    import com.gorillalogic.tests.newTestSuite.testCases.NewTestCase;

    [Suite(order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public class NewTestSuite implements IFlexMonkeyTestSuite {

        public var test1:NewTestCase;

    }
}