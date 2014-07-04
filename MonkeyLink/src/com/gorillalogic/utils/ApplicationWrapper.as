package com.gorillalogic.utils {
	
	import flash.utils.getDefinitionByName;
	
	import mx.core.Application;

	/**
	 * Class for accessing the application in MonkeyLink
	 * We need to make sure code can be compiled with both Flex 3 & 4
	 */
	public class ApplicationWrapper {
		
		public static var instance:ApplicationWrapper = new ApplicationWrapper();
		private var _application:Object; 
		
		public function ApplicationWrapper() {
			var appInstance:Object
			
            if(FLEXMONKEY::vfour){
				//try and load class at runtime - so we don't have any compile depends on FlexGlobals (flex 4 only)
				var clazz:Class = getDefinitionByName("mx.core.FlexGlobals") as Class;
				_application = clazz.topLevelApplication;
			} else {

				_application = mx.core.Application.application;
			}
		}
		
		public function get application():Object {
			return _application;
		}
	}
	
}