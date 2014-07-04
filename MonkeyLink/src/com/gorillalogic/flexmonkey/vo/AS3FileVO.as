/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.vo
{
	import com.gorillalogic.flexmonkey.codeGen.AS3FileCollector;
	
	public class AS3FileVO
	{
		public function AS3FileVO(fileName:String=null,fileContents:String=null)
		{
			this.fileName = fileName;
			this.fileContents = fileContents;
		}

		public var fileName:String;
		public var fileContents:String;
		
		private var _children:AS3FileCollector;
		public function get children():AS3FileCollector{
			return _children;
		}
		public function set children(c:AS3FileCollector):void{
			_children = c;
		}

	}
}