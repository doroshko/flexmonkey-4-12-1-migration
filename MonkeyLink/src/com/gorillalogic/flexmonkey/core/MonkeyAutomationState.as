/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core {
	
	public class MonkeyAutomationState {

		public static const IDLE:String = "idle";
		public static const NORMAL:String = "normal";
		public static const SNAPSHOT:String = "snapshot";
		
		private static var _monkeyAutomationState:MonkeyAutomationState;
		public var state:String = IDLE;

		public static function get monkeyAutomationState():MonkeyAutomationState {
			if(MonkeyAutomationState._monkeyAutomationState == null) {
				MonkeyAutomationState._monkeyAutomationState = new MonkeyAutomationState(new SingletonEnforcer());
			}
			return MonkeyAutomationState._monkeyAutomationState;
		}
		
		public function MonkeyAutomationState(singletonEnforcer:SingletonEnforcer) {
		}

	}
}

class SingletonEnforcer {}
