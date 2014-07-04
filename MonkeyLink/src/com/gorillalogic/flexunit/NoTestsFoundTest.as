package com.gorillalogic.flexunit {
	
	public class NoTestsFoundTest {

		[Test]
		public function doFailure():void {
			throw new Error("Not Test Suites Found!");	
		}
		
	}
}