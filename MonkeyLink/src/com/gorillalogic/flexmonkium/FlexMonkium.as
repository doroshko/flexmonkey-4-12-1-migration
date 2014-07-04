package com.gorillalogic.flexmonkium {
	

	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.events.ApplicationEvent;
	import com.gorillalogic.flexmonkey.events.CommandRecordedEvent;
	import com.gorillalogic.flexmonkey.model.ApplicationModel;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
	import com.gorillalogic.flexmonkey.vo.AttributeVO;
	import com.gorillalogic.flexmonkey.xmlConversion.XmlConversionFactory;
	import com.gorillalogic.framework.FMHub;
	import com.gorillalogic.json.JSON;
	import com.gorillalogic.monkeylink.MonkeyLink;
	import com.gorillalogic.monkeylink.MonkeyLinkConsoleConnectionController;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	
	import mx.automation.IAutomationObject;
	import mx.collections.ArrayCollection;
	if(FLEXMONKEY::vfour){
	import mx.core.FlexGlobals;
	}
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	/**
	 * The FlexMonkey/Selenium Bridge
	 */
	[Mixin]
	public class FlexMonkium {
		public static var localConnection:LocalConnection = null; // both sender and receiver
		// I'm totally static. No need to instance me.
		public function FlexMonkium() {
			localConnection = new LocalConnection()
			localConnection.client = this; // receiver only
			localConnection.allowDomain("*");
			try{
				trace("connecting on channel 0");
			localConnection.connect("_monkeyTalkConnection");
			
			} catch(e:Error) {
				try{
					trace("connecting on channel 1");
					localConnection.connect("_monkeyTalkConnection1");
					trace("connected on channel 1");
				} catch(e:Error) {
					try{
						trace("connecting on channel 2");
						localConnection.connect("_monkeyTalkConnection2");
						trace("connected on channel 2");
					} catch(e:Error) {
						trace("could not connect due to the fact that another app has the local swf connection to _monkeyTalkConnection");
					}
				}
			}
		}
		
		function statusHandler (event:StatusEvent):void
		{
			switch (event.level)
			{
				case "status" :
					//trace("LocalConnection.send() succeeded");
					break;
				case "error" :
					//trace("LocalConnection.send() failed");
					break;
			}
		}
		///Stuff for MonkeyTalk
		//public function playCommand(action:String, monkeyID:String, respNumber:Number, args:Array = null):void{
		public function ping(respNumber:Number):void{
			var localConnectionSender:LocalConnection = new LocalConnection();
			localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
			if(FLEXMONKEY::vfour){
			try{
			var url:String = (FlexGlobals.topLevelApplication.stage.loaderInfo as LoaderInfo).loaderURL;
			localConnectionSender.send("_monkeyTalkConnectionRecorder","answerping", url, "");
			} catch (e:TypeError){
				return; // if the app is not initalized fully yet
			}
			} else {
				localConnectionSender.send("_monkeyTalkConnectionRecorder","answerping", "The App", "");
			}
			
			
		}
		///Stuff for MonkeyTalk
		//public function playCommand(action:String, monkeyID:String, respNumber:Number, args:Array = null):void{
			public function playCommand(action:String, monkeyID:String, respNumber:Number, args:Array):void{

			var command:UIEventMonkeyCommand = new UIEventMonkeyCommand(action,
				monkeyID,
				"automationName", args);
			trace("got to play");
			command.run(returnFromPlayCommand, respNumber);

		}
		public function returnFromPlayCommand(wtf:Object, message:Object, respNumber:Number):void{
			var localConnectionSender:LocalConnection = new LocalConnection();
			localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
			

			localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", message, ""+respNumber);
			
		}

	   public function verifyFromMonkeyTalk(respNumber:Number,
													monkeyID:String,
													expectedValue:String,
													property:String = "text"
													):void {
			var attributes:ArrayCollection = new ArrayCollection();

				//"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
				var attributeVO:AttributeVO = new AttributeVO(property, null, "property", expectedValue, "");
				attributes.addItem(attributeVO);

			
				var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(null,
					null,
					monkeyID,
					"automationName",
					null,
					attributes,
					null,
					null,
					null,
					null,
					null,
					null);
				    var val:String =  command.compareAttributesMT(command.loadTarget(false));

					var localConnectionSender:LocalConnection = new LocalConnection();
					localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
					

					if(val != null)
					    localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Expected '" + expectedValue + "' got '" + val + "'", ""+respNumber);
					else
						localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	

				
		}

	   public function verifyRegExFromMonkeyTalk(respNumber:Number,
											monkeyID:String,
											expectedValue:String,
											property:String = "text"
	   ):void {
		   var attributes:ArrayCollection = new ArrayCollection();
		   
		   //"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
		   var attributeVO:AttributeVO = new AttributeVO(property, null, "property", expectedValue, "");
		   attributes.addItem(attributeVO);
		   
		   
		   var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(null,
			   null,
			   monkeyID,
			   "automationName",
			   null,
			   attributes,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null);
		   var val:String =  command.compareAttributesMTRegEx(command.loadTarget(false));
		   
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   if(val || val == "")
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Expected '" + expectedValue + "' got '" + val + "'", ""+respNumber);
		   else
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	
		   
		   
	   }
	   public function verifyNotRegExFromMonkeyTalk(respNumber:Number,
												 monkeyID:String,
												 expectedValue:String,
												 property:String = "text"
	   ):void {
		   var attributes:ArrayCollection = new ArrayCollection();
		   
		   //"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
		   var attributeVO:AttributeVO = new AttributeVO(property, null, "property", expectedValue, "");
		   attributes.addItem(attributeVO);
		   
		   
		   var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(null,
			   null,
			   monkeyID,
			   "automationName",
			   null,
			   attributes,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null);
		   var val:String =  command.compareAttributesMTRegEx(command.loadTarget(false));
		   
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   if(!val && val != "")
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Regex '" + expectedValue + "' matches '" + val + "'", ""+respNumber);
		   else
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	
		   
		   
	   }
	   public function verifyNotWildcardFromMonkeyTalk(respNumber:Number,
													monkeyID:String,
													expectedValue:String,
													property:String = "text"
	   ):void {
		   var attributes:ArrayCollection = new ArrayCollection();
		   
		   //"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
		   expectedValue = expectedValue.replace("*", ".*");
		   var attributeVO:AttributeVO = new AttributeVO(property, null, "property", expectedValue, "");
		   attributes.addItem(attributeVO);
		   
		   
		   var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(null,
			   null,
			   monkeyID,
			   "automationName",
			   null,
			   attributes,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null);
		   var val:String =  command.compareAttributesMTRegEx(command.loadTarget(false));
		   
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   if(!val && val != "")
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Regex '" + expectedValue + "' matches '" + val + "'", ""+respNumber);
		   else
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	
		   
		   
	   }
	   public function verifyWildcardFromMonkeyTalk(respNumber:Number,
													   monkeyID:String,
													   expectedValue:String,
													   property:String = "text"
	   ):void {
		   var attributes:ArrayCollection = new ArrayCollection();
		   
		   //"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
		   expectedValue = expectedValue.replace("*", ".*");
		   var attributeVO:AttributeVO = new AttributeVO(property, null, "property", expectedValue, "");
		   attributes.addItem(attributeVO);
		   
		   
		   var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(null,
			   null,
			   monkeyID,
			   "automationName",
			   null,
			   attributes,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null);
		   var val:String =  command.compareAttributesMTRegEx(command.loadTarget(false));
		   
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   if(val || val == "")
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Expected value '" + expectedValue + "' does not match '" + val + "'", ""+respNumber);
		   else
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	
		   
		   
	   }
	    public function verifyGridFromMonkeyTalk(respNumber:Number, monkeyID:String, row:int, col:int, expectedValue:String):void {
	
			   var command2:VerifyGridMonkeyCommand = new VerifyGridMonkeyCommand(null, monkeyID, "automationName", row, col, expectedValue, null, null, null, null, null);
			  
			   var actualValue:String = command2.getCellValue();
			   var localConnectionSender:LocalConnection = new LocalConnection();
			   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
			   

			   if(expectedValue != actualValue)
				   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Expected '" + expectedValue + "' got '" + actualValue, ""+respNumber);
			   else
				   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "", ""+respNumber);	

	   }
	    public function findFromMonkeyTalk(respNumber:Number, monkeyID:String, property:String):void{
		   var uic:UIComponent = MonkeyUtils.findComponent(null, null, monkeyID, "automationName");
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   var asArray:Array = property.split(".");
		   var value:Object = uic;
		   for(var i:int = 0; i < asArray.length; i++){
			 if(value.hasOwnProperty(asArray[i])){
			     value = value[asArray[i]];
			 } else {
				 value = null;
				 break;
			 }
		   }
		   if(value != null)
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "Value:" + value.toString(), ""+respNumber);
		   else
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveResponce", "No property " + property + " on component " + monkeyID, ""+respNumber);

	   }
	   public function dumpcomponentTree():void{
		   var ret:Array = MonkeyUtils.getApplicationTreeInfo() as Array;
		   var dump:String = JSON.encode(ret[0]);
		   var localConnectionSender:LocalConnection = new LocalConnection();
		   localConnectionSender.addEventListener(StatusEvent.STATUS, statusHandler);
		   

		   var packetSize:Number = 1000;
		   trace(dump.length);
		   for(var i:int = 0; (i*packetSize) < dump.length; i++){
			   localConnectionSender.send("_monkeyTalkConnectionRecorder","recieveDump",  dump.substr(i*packetSize,packetSize), (i == 0),((i*packetSize) + packetSize > dump.length), i);
		   }
		   
		   
	   }
		/////END Stuff for monkey talk

		
		public static function init(root:DisplayObject):void {
			
			// SWF receiver on unknown domain
			if(localConnection == null)
				var fm:FlexMonkium = new FlexMonkium();
			
			
			
			
			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
				// If we're in MonkeyLink, the external interface will be available. In AirMonkey, it won't be.
				if (ExternalInterface.available) {
					ExternalInterface.addCallback("playFromSelenium", FlexMonkium.playFromSelenium);
					ExternalInterface.addCallback("verifyFromSelenium", FlexMonkium.verifyFromSelenium);
					ExternalInterface.addCallback("getForSelenium", FlexMonkium.getForSelenium);
					ExternalInterface.addCallback("getCellForSelenium", FlexMonkium.getCellForSelenium);
					
					ExternalInterface.addCallback("playFromJS", FlexMonkium.playFromJS);
					ExternalInterface.addCallback("findFromJS", FlexMonkium.findFromJS);
					ExternalInterface.addCallback("verifyFromJS", FlexMonkium.verifyFromJS);
					ExternalInterface.addCallback("verifyGridFromJS", FlexMonkium.verifyGridFromJS);
					ExternalInterface.addCallback("verifyPropertyFromJS", FlexMonkium.verifyPropertyFromJS);
					
					ExternalInterface.addCallback("sendTestResult", FlexMonkium.sendTestResult);
					
					ExternalInterface.addCallback("startJSTests", FlexMonkium.startJSTests);
					ExternalInterface.addCallback("endJSTests", FlexMonkium.endJSTests);
					
					
					AQAdapter.aqAdapter.beginRecording();
					FMHub.instance.listen(CommandRecordedEvent.COMMAND_RECORDED, function(ev:CommandRecordedEvent):void {
						sendToSelenium(ev.command);
					}, this, false, 0, false); 
					
					//                    FMHub.instance.listen(VerifyCreatedEvent.VERIFY_CREATED, function(ev:VerifyCreatedEvent):void {
					//                        sendVerifyToSelenium(ev.verify);
					//                    }, this, 0, false);
					if (ExternalInterface.available)
					{
						var js:String = 'function() {window["_Selenium_IDE_Recorder"].record("waitForFlexMonkey")}';
						ExternalInterface.call(js);
					} else {
						trace(new Error("FlexMonkium: Unexpectedly found ExternalInterface to be unavailable").getStackTrace());
					}
				}
			}, false, -1); // Set to -1 priority so that aqadapter can initialize first			
		}
		
		
		
		static public function playFromSelenium(locator:String, text:String):Boolean {
			trace("playFromSelenium: " + locator + " ," + text);
			var command:UIEventMonkeyCommand = XmlConversionFactory.decode(XML(wrapXml(locator))) as UIEventMonkeyCommand;
			//trace(command);
			var target:IAutomationObject = command.target;
			if (target == null) {
				return false;
			}
			command.run();
			return true;
		}	
		public static var server:TalkToFlexUnitResponder;
		static public function startJSTests():void{
			server = new TalkToFlexUnitResponder();
			server.connect();
		}
		static public function endJSTests():void{
			server.disconnect();
		}
		static public function playFromJS(eventType:String, command:String, value:String, prop:String, args:Array, containerValue:String, containerProp:String, attempts:String, delay:String, retryOnResponse:Boolean):Boolean {
			if(eventType == "UIEvent"){
				var uiEventMonkeyCommand:UIEventMonkeyCommand = new UIEventMonkeyCommand();
				uiEventMonkeyCommand.command = command;
				uiEventMonkeyCommand.value = value;
				uiEventMonkeyCommand.prop = prop;
				uiEventMonkeyCommand.attempts = attempts;
				uiEventMonkeyCommand.delay = delay;
				uiEventMonkeyCommand.containerValue = containerValue;
				uiEventMonkeyCommand.containerProp = containerProp;
				uiEventMonkeyCommand.retryOnlyOnResponse = retryOnResponse;
				uiEventMonkeyCommand.args = args;	
				var target:IAutomationObject = uiEventMonkeyCommand.target;
				if (target == null) {
					return false;
				}
				uiEventMonkeyCommand.run();
			}
			return true;
		}
		
		static public function sendTestResult(className:String, testName:String, time:Number, status:String, failMessages:Array):void {
			server.sendTestResult(className, testName, time, status, failMessages);
		}
		static public function verifyPropertyFromJS(eventType:String, description:String, value:String, prop:String, containerValue:String, containerProp:String, isRetryable:Boolean, delay:String, attempts:String, propertyString:String, expectedValue:String, propertyType:String):Boolean {
			if(eventType == "VerifyProperty"){
				var command:VerifyPropertyMonkeyCommand = new VerifyPropertyMonkeyCommand(description, value, prop, containerValue, containerProp, isRetryable, delay, attempts, propertyString, expectedValue, propertyType);
				return command.isTrue();
			} 
			return false;
		}
		
		static public function verifyGridFromJS(eventType:String, description:String, value:String, prop:String, row:int, col:int, expectedValue:String, containerValue:String, containerProp:String, isRetryable:Boolean, delay:String, attempts:String):Boolean {
			if(eventType == "VerifyGrid"){
				var command2:VerifyGridMonkeyCommand = new VerifyGridMonkeyCommand(description, value, prop, row, col, expectedValue, containerValue, containerProp, isRetryable, delay, attempts);
				var actualValue:String = command2.getCellValue();
				return expectedValue == actualValue;
			}
			return false;
		}
		static public function findFromJS(containerValue:String, containerProp:String, value:String, prop:String):Object{
			var uic:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);
			trace(uic.id);
			return {
				"id":uic.id,
					"automationName": uic.automationName,
					"className":uic.className
			};
		}
		static public function verifyFromJS(eventType:String, description:String = null,
											snapshotURL:String = null,
											value:String = null,
											prop:String = null,
											verifyBitmap:Boolean = false,
											attributes_obj:Array = null,
											containerValue:String = null,
											containerProp:String = null,
											isRetryable:Boolean = true,
											delay:String = null,
											attempts:String = null,
											verifyBitmapFuzziness:int = 0):Boolean {
			var attributes:ArrayCollection = new ArrayCollection();
			for each (var avo:Object in attributes_obj){
				//"name":"text","expectedValue":"Intentiionally Wrong String","type":"property","actualValue":""
				var attributeVO:AttributeVO = new AttributeVO(avo.name, null, avo.type, avo.expectedValue, avo.actualValue);
				attributes.addItem(attributeVO);
			}
			
			if(eventType == "Verify"){
				var command:VerifyMonkeyCommand = new VerifyMonkeyCommand(description,
					snapshotURL,
					value,
					prop,
					verifyBitmap,
					attributes,
					containerValue,
					containerProp,
					isRetryable,
					delay,
					attempts,
					verifyBitmapFuzziness);
				return command.compareAttributesJS(command.loadTarget(false));
			} 
			return false;
		}
		
		static public function verifyFromSelenium(locator:String = null, text:String = null):Boolean {
			//trace("verifyFromSelenium: " + locator + " ," + text);
			// If there's no locator, we're just waiting for the SWF to load, and if we're executing, the SWF has been loaded, so return true
			if (!locator || locator.search(/\S/) == -1) {
				return true;
			}
			var xml:XML = XML(wrapXml(locator));
			if (xml.name() == "UIEvent") {
				return playFromSelenium(locator, text);
			}
			
			if (xml.name() == "VerifyProperty") {
				var vp:VerifyPropertyMonkeyCommand = XmlConversionFactory.decode(XML(xml)) as VerifyPropertyMonkeyCommand;
				return vp.isTrue();
			}	
			
			if (xml.name() == "VerifyGrid") {
				var vg:VerifyGridMonkeyCommand = XmlConversionFactory.decode(XML(xml)) as VerifyGridMonkeyCommand;
				//				return vg.verifyGridCellValue();
			}			
			
			//            var command:VerifyMonkeyCommand = XmlConversionFactory.decode(XML(xml)) as VerifyMonkeyCommand;
			//            command.getVerifyTarget();
			//			return command.lastResult;
			return true;
		}
		
		
		static public function getForSelenium(locator:String = null, text:String = null):String {
			
			var xml:XML = XML(wrapXml(locator));
			if (xml.name() == "VerifyGrid") {
				var vg:VerifyGridMonkeyCommand = XmlConversionFactory.decode(XML(locator)) as VerifyGridMonkeyCommand;
				return vg.getCellValue();
			}	
			
			if (xml.name() == "VerifyProperty") {
				var vp:VerifyPropertyMonkeyCommand = XmlConversionFactory.decode(XML(locator)) as VerifyPropertyMonkeyCommand;
				return new String(vp.getVerifyPropertyValue(false));
			}
			
			var command:VerifyMonkeyCommand = XmlConversionFactory.decode(XML(locator)) as VerifyMonkeyCommand;
			return command.getActualValueForAttribute(0); // currently only support getting first attribute in list
		}
		
		static public function getCellForSelenium(locator:String = null, text:String = null):String {
			var command:VerifyGridMonkeyCommand = XmlConversionFactory.decode(XML(wrapXml(locator))) as VerifyGridMonkeyCommand;
			return command.getCellValue();
		}
		public static var localConnectionSender:LocalConnection = new LocalConnection();
		//RECORDER
		static private function onStatus(event:StatusEvent):void {
			switch (event.level) {
				case "status":
					//trace("good"); //bridge is good
					break;
				case "error":
					//trace("error"); not connected to bridge
					break;
			}
		}
		static public function sendToSelenium(event:UIEventMonkeyCommand):void {
			localConnectionSender.addEventListener(StatusEvent.STATUS, onStatus);
			try {
			
		    //Find the class name as best we can
			var clazzName:String = "*";
			if(event && event.target && event.target.automationName){
				clazzName = event.target.automationName;
			} else if(event && event.target && event.target["className"]){
				clazzName = event.target["className"] as String;
				
			} else {
			//trace(mx.utils.ObjectUtil.toString(event))
			}
			//Find the monkeyID as best we can
			var monkeyID:String = "*";
			if(event && event.value){
				monkeyID = event.value;
			}
			
			//Find the command as best we can
			var command:String = "*";
			if(event && event.command){
				command = event.command;
			}
			
			//Find the args as best we can
			var args:Array = new Array();
			if(event && event.args){
				args = event.args;
			}
				
			    localConnectionSender.send("_monkeyTalkConnectionRecorder","record", clazzName, monkeyID, command, args);

			} catch(e:Error){
				trace("Could not record event " + event.command);
			}
			
			
			if (ExternalInterface.available) {
				//trace("FlexMonkium: Send to selenium: " + event.xml.toXMLString());
				var js:String = 'function(s) {window["_Selenium_IDE_Recorder"].record("waitForFlexMonkey",s)}';
				var xml:String = XmlConversionFactory.encode(event, true).toXMLString();
				ExternalInterface.call(js,stripXml(xml));
			} else {
				trace(new Error("FlexMonkium: Unexpectedly found ExternalInterface to be unavailable").getStackTrace());
			}
			
		}
		
		public static function sendVerifyToSelenium(vmc:VerifyMonkeyCommand):void {
			
			if (!ExternalInterface.available) {
				trace(new Error("FlexMonkium: Unexpectedly found ExternalInterface to be unavailable").getStackTrace());
				return;
			}
			//trace("FlexMonkium: Send to verify to selenium: " + vmc.xml.toXMLString());
			
			// We assume that the first observer is the editor. Tell him to start recording so he'll see the new verify
			var js:String = 'function() {window["_Selenium_IDE_Recorder"].observers[0].toggleRecordingEnabled(true)}';
			ExternalInterface.call(js);
			
			var vpc:VerifyPropertyMonkeyCommand = new VerifyPropertyMonkeyCommand();
			vpc.prop = vmc.prop;
			vpc.value = vmc.value;
			if (vmc.attributes && vmc.attributes.length) {
				var attr:AttributeVO = vmc.attributes.getItemAt(0) as AttributeVO;
				vpc.propertyString = attr.name;
				vpc.expectedValue = attr.expectedValue;
			}
			
			var xml:String = XmlConversionFactory.encode(vpc, true).toXMLString();
			js = 'function(s) {window["_Selenium_IDE_Recorder"].record("waitForFlexMonkey",s)}';
			
			ExternalInterface.call(js, stripXml(xml));
			AQAdapter.aqAdapter.beginRecording();
		}
		
		private static function stripXml(xml:String):String {
			
			xml = xml.split("\n").join(" ");
			return xml;			
			//			var s:String = xml.toString().replace(/^\s*</,"");
			//			s = s.replace(/\/>\s*$/,"");
			//			return s;
		} 
		
		private static function wrapXml(xml:String):String {
			return xml;
			//			if (xml.match(/^\s*<.*\/>\s*$/)) {
			//				return xml;
			//			} else {
			//				return "<" + xml + "/>";
			//			}
			
			
		}
		
	}
	
	
}