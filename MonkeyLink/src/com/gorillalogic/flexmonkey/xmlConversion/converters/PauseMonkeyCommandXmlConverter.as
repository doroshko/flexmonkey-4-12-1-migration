package com.gorillalogic.flexmonkey.xmlConversion.converters {
	
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.xmlConversion.IXmlConverter;
	
	public class PauseMonkeyCommandXmlConverter implements IXmlConverter {
			
		public function encode(obj:Object, short:Boolean=false):XML {
			var xml:XML = <Pause duration={obj.duration}/>			
			return xml;		
		}
		
		public function decode(x:XML):Object {			
			var pauseCommand:PauseMonkeyCommand = new PauseMonkeyCommand();
			pauseCommand.duration = x.@duration;
			return pauseCommand;
		}
		
	}
	
}
