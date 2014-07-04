var FlexMonkium = {
	onLoad : function() {
		// initialization code
		this.initialized = true;
	},

	onToolbarCommand : function() {

		var prefManager = Components.classes["@mozilla.org/preferences-service;1"]
				.getService(Components.interfaces.nsIPrefBranch);
		
		try {
			var console = prefManager
				.getCharPref("extensions.selenium-ide.flexmonkium.consolePath");
		} catch (error) {
			window.open('chrome://flexmonkium/content/options.xul','Path to FlexMonkiumConsole required','chrome,dialog=no,resizable,modal,all,dependent,centerscreen');
			return;		
		}
		
		if (console.indexOf(".app") == console.length - 4) {
			console+="/Contents/MacOS/FlexMonkiumConsole";
		}

		// create an nsILocalFile for the executable
		var file = Components.classes["@mozilla.org/file/local;1"]
				.createInstance(Components.interfaces.nsILocalFile);
		// file.initWithPath("/Applications/FlexMonkiumConsole.app/Contents/MacOS/FlexMonkiumConsole");
		
		
		try {
			file.initWithPath(console);
		} catch (e) {
			window.open('chrome://flexmonkium/content/options.xul','Path to FlexMonkiumConsole required','chrome,dialog=no,resizable,modal,all,dependent,centerscreen');
			return;
		} 
		
		// create an nsIProcess
		var process = Components.classes["@mozilla.org/process/util;1"]
				.createInstance(Components.interfaces.nsIProcess);
		process.init(file);

		// Run the process.
		// If first param is true, calling thread will be blocked until
		// called process terminates.
		// Second and third params are used to pass command-line arguments
		// to the process.
		var args = [];
		process.run(false, args, args.length);

	},
	
	chooseFile: function() {
		var nsIFilePicker = Components.interfaces.nsIFilePicker;
		var fp = Components.classes["@mozilla.org/filepicker;1"].createInstance(nsIFilePicker);
		fp.init(window, "Select the FlexMonkium Console", nsIFilePicker.modeOpen);
		var res = fp.show();
		if (res == nsIFilePicker.returnOK){
		  return fp.file.path;
		  
		}
		
		return null;


	}
};

window.addEventListener("load", function(e) {
	FlexMonkium.onLoad(e);
}, false);
