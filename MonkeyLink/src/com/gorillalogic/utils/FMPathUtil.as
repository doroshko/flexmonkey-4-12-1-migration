/*
* FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
* FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
*/
package com.gorillalogic.utils
{
	public class FMPathUtil
	{
		import mx.utils.URLUtil;
		
		// figure out project url
		public static function getFullURL(rootURL:String, url:String):String {
			if (url == null || url.length == 0) {
				return rootURL;
			}
			
			// see if the add-on has a protocol
			var myProtocol:String = URLUtil.getProtocol(url);
			
			if (myProtocol == null || myProtocol.length == 0) {
				if (url.indexOf("./") == 0) {
					url = url.substring(2);
				}
				
				var slashPos:Number;
				var rootProtocol:String = URLUtil.getProtocol(rootURL);
				
				if (url.charAt(0) == '/') {
					// non-relative path, "/dev/foo.bar".
					slashPos = rootURL.indexOf("/", rootProtocol.length);
					
					if (slashPos == -1) {
						slashPos = rootURL.length;
					}
				} else {
					// relative path, "dev/foo.bar".
					slashPos = rootURL.lastIndexOf("/") + 1;
					
					if (slashPos != rootURL.length - 1) {
						rootURL += "/";
						slashPos = rootURL.length;
					}
				}
				
				if (slashPos > 0) {
					url = rootURL.substring(0, slashPos) + url;
				}
			}
			
			return url;
		}
	}
}