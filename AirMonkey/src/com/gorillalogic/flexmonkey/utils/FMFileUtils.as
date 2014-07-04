/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.utils {

	import com.gorillalogic.flexmonkey.events.FMAlertEvent;
	import com.gorillalogic.framework.FMHub;
	import com.gorillalogic.utils.FMFileError;
	import com.gorillalogic.utils.FMPathUtil;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;

	public class FMFileUtils {
		
		private static const successHandlers:Dictionary = new Dictionary();
		private static const errorHandlers:Dictionary = new Dictionary();

		public static function readFile(url:String,
			successHandler:Function,
			errorHandler:Function=null):Boolean {
			
			var file:File;
			var fileStream:FileStream;

			if (errorHandler == null) {
				errorHandler = defaultLoadFileErrorHandler;
			}
			
			try {
				file = new File(url);
			} catch (error:ArgumentError) {
				errorHandler(new FMFileError("Error opening file: " + url + "\n" + error.message));
				return false;
			}

			if (file.exists) {
				fileStream = new FileStream();
				successHandlers[fileStream] = successHandler;
				errorHandlers[fileStream] = errorHandler;

				fileStream.addEventListener(IOErrorEvent.IO_ERROR, proxyErrorHandler);
				fileStream.addEventListener(Event.COMPLETE, proxySuccessHandler);
				fileStream.openAsync(file, FileMode.READ);
			} else {
				errorHandler(new FMFileError("Error reading file: " + url + "\nDoes not exist"));
				return false;
			}
			return true;
		}
		
		private static function proxyErrorHandler(event:IOErrorEvent):void {
			var errorHandler:Function = errorHandlers[event.target] as Function;
			errorHandler(new FMFileError("Error opening file: " + event.text));
			clearEventHandlers(event.target as FileStream);
		}
		
		private static function proxySuccessHandler(event:Event):void {
			var successHandler:Function = successHandlers[event.target] as Function;
			successHandler(event);
			clearEventHandlers(event.target as FileStream);
		}
		
		private static function clearEventHandlers(fileStream:FileStream):void {
			fileStream.removeEventListener(Event.COMPLETE, proxySuccessHandler);
			fileStream.removeEventListener(IOErrorEvent.IO_ERROR, proxyErrorHandler);
			delete successHandlers[fileStream];
			delete errorHandlers[fileStream];
		}
		
		private static function defaultLoadFileErrorHandler(event:FMFileError):void {
			FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Error opening file: " + event.message));
		}

		public static function saveFile(url:String,
			content:Object,
			errorHandler:Function=null):Boolean {
			
			var file:File;
			var fileStream:FileStream;

			if (errorHandler == null) {
				errorHandler = defaultSaveFileErrorHandler;
			}
			
			try {
				file = new File(url);
			} catch (error:ArgumentError) {
				errorHandler(new FMFileError("Error saving file: " + url + "\n" + error.message));
				return false;
			}
			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			fileStream.openAsync(file, FileMode.WRITE);

			try {
				if (content is String) {
					fileStream.writeUTFBytes(content as String);
				} else {
					fileStream.writeObject(content);
				}
			} catch (error:IOError) {
				errorHandler(new FMFileError( "Error saving file: " + url + "\n" + error.message));
				return false;
			} finally {
				fileStream.close();
			}
			return true;
		}

		private static function defaultSaveFileErrorHandler(event:IOErrorEvent):void {
			FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Failed to save file: " + event.text));
		}

		public static function parseXmlFile(fileStream:FileStream,
			errorHandler:Function=null):XML {

			var text:String;
			var xml:XML
			var bytesAvailable:uint = fileStream.bytesAvailable;

			try {
				text = fileStream.readUTFBytes(bytesAvailable);
			} catch (error:IOError) {
				var em1:String = "Could not read file: " + error.message;

				if (errorHandler != null) {
					errorHandler(new FMFileError(em1));
				} else {
					FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, em1));
				}
			} catch (error:EOFError) {
				var em2:String = "Attempt to read past end of file: " + error.message;

				if (errorHandler != null) {
					errorHandler(new FMFileError(em2));
				} else {
					FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, em2));
				}
			} finally {
				fileStream.close();
			}

			if (text != null) {
				try {
					xml = new XML(text);
				} catch (error:Error) {
					var em3:String = "Malformed XML in file: " + error.message;

					if (errorHandler != null) {
						errorHandler(new FMFileError(em3));
					} else {
						FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, em3));
					}
				}
			}

			return xml;
		}

		public static function deleteFile(url:String, showError:Boolean=false):Boolean {
			var file:File;

			try {
				file = new File(url);

				if (file.exists && !file.isDirectory) {
					file.deleteFile();
				}
			} catch (error:ArgumentError) {
				if (showError) {
					FMHub.instance.dispatchEvent(new FMAlertEvent(FMAlertEvent.ERROR, "Error deleting file: " + url + "\n" + error.message));
				}
				return false;
			}

			return true;
		}

		// figure out project url
		public static function getFullURL(rootURL:String, url:String):String {
			return FMPathUtil.getFullURL(rootURL,url);
		}
	}

}
