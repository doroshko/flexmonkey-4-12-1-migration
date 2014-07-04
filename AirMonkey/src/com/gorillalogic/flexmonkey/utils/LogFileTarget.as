package com.gorillalogic.flexmonkey.utils {
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	use namespace mx_internal;
	
	/**
	 * An Adobe AIR only class that provides a log target for the Flex logging
	 * framework, that logs files to a file on the user's system.
	 * 
	 * This class will only work when running within Adobe AIR>
	 */
	public class LogFileTarget extends LineFormattedTarget
	{
		public const DEFAULT_LOG_PATH:String = "app-storage:/fm-application.log";
		
		public var log:File;
		
		public function LogFileTarget(logFile:File = null)
		{
			if(logFile != null)
			{
				log = logFile;
			}
			else
			{
				log = new File(DEFAULT_LOG_PATH);
				trace("Opened Logging File: " + log.nativePath);
			}
		}
		
		public function get logURI():String
		{
			return log.url;
		}
		
		mx_internal override function internalLog(message:String):void
		{
			write(message);
		}           
		
		private function write(msg:String):void
		{               
			var fs:FileStream = new FileStream();
			fs.open(log, FileMode.APPEND);
			fs.writeUTFBytes(msg + File.lineEnding);
			fs.close();
		}       
		
		public function clear():void
		{
			var fs:FileStream = new FileStream();
			fs.open(log, FileMode.WRITE);
			fs.writeUTFBytes("");
			fs.close();                     
		}
		
	}
}