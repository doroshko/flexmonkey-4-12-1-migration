package com.gorillalogic.flexmonkium
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	
	import mx.messaging.config.ServerConfig;

	public class TalkToFlexUnitResponder
	{
		public function TalkToFlexUnitResponder()
		{
		}
		private var socket:Socket;
		
		public function connect():void{
			try{
				socket =  new Socket();
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, doNoTestCatcher);
				socket.connect("127.0.0.1", 1024);
				socket.addEventListener( Event.CONNECT, onConnect);
				socket.addEventListener( ProgressEvent.SOCKET_DATA, onSocketData);
			}
			catch(e:IOError)
			{
				trace( "IO Error" );
			}
			catch(e:SecurityError)
			{
				trace( "Security Error" );
			}
			catch( e:Error )
			{
				trace( "Error connecting to test server" );
			}
			
			
		}
		public function sendTestResult(className:String, testName:String, time:Number, status:String, failMessages:Array = null):void {
			if(status == "success"){
				sendData("<testcase classname=\""+className+"\" name=\""+testName+"\" time=\""+time+"\" status=\"success\" />");
			} else {
				for each (var messageObj:Object in failMessages){
				var messageFromTest:String = messageObj.messageFromTest;
				var type:String = messageObj.type;
				var stackTrace:String = messageObj.stackTrace;
				var message:String = "";
				message = "<testcase classname=\""+className+"\" name=\""+testName+"\" time=\""+time+"\" status=\"failure\">";
				message += "<failure message=\""+messageFromTest+"\" type=\""+type+"\" >";
				message += "<![CDATA["+stackTrace+"]]>";
				message += "</failure>";
				message += "</testcase>";
				sendData(message);
				}
			}
		}
		public function disconnect():void{
			sendData("<endOfTestRun/>");
		}
		private function sendData(data:String):void{
			
			socket.writeUTFBytes(data);
			socket.writeByte(0);
			socket.flush();
		}
		private function doNoTestCatcher(event: Event):void {
			trace("the test data catcher is not running");
		}
		private function onSocketData(event : ProgressEvent) : void {
			var thisresponse:String = "";
			while (socket.bytesAvailable) {
				thisresponse += socket.readUTFBytes(socket.bytesAvailable);
				
			}
			
			trace(thisresponse);	
		}
		private function onConnect(event:Event):void
		{
			trace("Connected to flex unit socket server.");
		}
	
	}
}