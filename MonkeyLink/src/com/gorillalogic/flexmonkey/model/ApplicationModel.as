	/*
	 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.model {

	[Bindable]
	public class ApplicationModel {

		public static var instance:ApplicationModel = new ApplicationModel();

		// connection / playing properties
		public var isConnected:Boolean = false;
		public var isRecording:Boolean = false;
		public var isProjectOpen:Boolean = false;
		public var isNewProject:Boolean = false;
		public var isMonkeyTestFileDirty:Boolean = false;

		public var isSpyHeaderChecked:Boolean = false;
		public var isVerticalLayout:Boolean = true;

		public var airMonkeyWindow:Object;

		public var applicationEnvFileData:Object;
		public var applicationAutomationTreeData:Array;

		public var logFileLocation:String;
		public var logFileData:String;

	}

}
