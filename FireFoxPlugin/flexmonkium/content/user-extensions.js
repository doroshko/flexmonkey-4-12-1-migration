/*      
 *      License
 *      
 *      This file is part of FlexMonkium.
 *
 *      
 *      FlexMonkium is free software: you can redistribute it and/or
 *  modify it  under  the  terms  of  the  GNU  General Public License as 
 *  published  by  the  Free  Software Foundation,  either  version  3 of 
 *  the License, or any later version.
 *
 *  FlexMonkium is distributed in the hope that it will be useful,
 *  but  WITHOUT  ANY  WARRANTY;  without  even the  implied  warranty  of
 *  MERCHANTABILITY   or   FITNESS   FOR  A  PARTICULAR  PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with FlexMonkium.
 *      If not, see http://www.gnu.org/licenses/
 *
 * Copyright 2010 (c) Gorilla Logic, Inc. All rights reserved.
 *
 */
 
 /** 
  * user-extensions.js adds FlexMonkey command extensions to Selenium Core
  */


// Code below adapted from: http://code.google.com/p/flash-selenium/issues/detail?id=38, comment #1

Selenium.prototype.getFlexObject =  function(){
	var obj = (selenium.browserbot.locateElementByXPath('//embed', selenium.browserbot.getDocument())) ?
		selenium.browserbot.locateElementByXPath('//embed', selenium.browserbot.getDocument()) :
		selenium.browserbot.locateElementByXPath('//object', selenium.browserbot.getDocument());
	return obj;
}

Selenium.prototype.flashObject = null;

Selenium.prototype.callFlexMethod = function (method, id, args) {
	try {
	
		if (this.flashObjectLocator == null) {
			this.flashObjectLocator = this.getFlexObject().id;
		}
		// the object that contains the exposed Flex functions
		var funcObj = null;
		var isBCC = false;

		// get the flash object
		var flashObj = selenium.browserbot.findElement(this.flashObjectLocator);

		if (flashObj['playFromSelenium'] == null) {
			flashObj = this.getFlexObject();
//			flashObj = flashObj.childNodes[11];
//			if (flashObj == null) {
//				return false;
//			}
//			isBCC = true;
		}

		if (flashObj.wrappedJSObject) {
			flashObj = flashObj.wrappedJSObject;
		}

		// find object holding functions
//		if(typeof(flashObj[method]) == 'object' || typeof(flashObj[method]) == 'unknown'  || typeof(flashObj[method]) == 'function') {
  		if (navigator.appName == 'Microsoft Internet Explorer') {

			// for IE (will be the flash object itself)

			// throw a error to Selenium if the exposed function could not be found
			if(flashObj == null)
				throw new SeleniumError('Function ' + method + ' not found on the External Interface for the flash object ' + this.flashObjectLocator);

			if (id == '' && args == '') {
				return flashObj[method]();
			}
			if (typeof(args) == 'undefined') {
				return flashObj[method](id);
			}
			return flashObj[method](id, args);
		} else {
	
			// Firefox (add temp button and work with it)
			var input = selenium.browserbot.getCurrentWindow().document.getElementById('selenium_bridge');
			if (input == null) {
				input = selenium.browserbot.getCurrentWindow().document.createElement('input');
				input.setAttribute('id', 'selenium_bridge');
				input.setAttribute('type', 'hidden');
				selenium.browserbot.getCurrentWindow().document.body.appendChild(input); 
			}
			input.value = 'novalue';
			var attVal = 'document.getElementById("selenium_bridge").value = ' +
						 'document.getElementById(\'' + this.flashObjectLocator + '\')' +
						 (isBCC ? '.childNodes[11]' : '') +
						 '[\'' + method + '\']';
			if (id == '' || typeof(id) == 'undefined') {
				attVal += '()';
			} else {
				attVal += '(\'' + id + '\'';
				// Some functions have more parameters than just 'args'
				for (i=2; i<arguments.length; i++) {
					if (typeof(arguments[i]) == 'undefined') {
						break;
					}
					attVal += ',\'' + arguments[i] + '\'';
				}
				attVal += ')';
			}
			input.setAttribute('onClick', attVal);
			var e =  selenium.browserbot.getCurrentWindow().document.createEvent('HTMLEvents');
			e.initEvent('click', true, false);
			input.dispatchEvent(e);
			return input.value;
		}

	} catch(err) {
		//return (err.description);
		//alert(err.description)
		throw err;
	}

	return 'Unexpected way of execution';
}

// FlexMonkium

Selenium.prototype.doFlexMonkey = function(locator, text) {
	this.callFlexMethod("playFromSelenium", locator, text);
};

Selenium.prototype.isFlexMonkey = function(locator, text) {
	try {
		ret = this.callFlexMethod("verifyFromSelenium", locator, text);
		return (ret == "true" || ret == true);
	} catch (error) {
		//alert(error.message);
		return false;
	}
};


Selenium.prototype.getFlexMonkeyValue = function(locator, text) {
	try {
		val = this.callFlexMethod("getForSelenium", locator, text);
		// storedVars is defined by Selenium and is a map of his variables
		storedVars[text] = val;
		return val;
	} catch (error) {
		return error.name + ": " + error.message;
	}
};


Selenium.prototype.getFlexMonkeyCell = function(locator, text) {
	try {
		val = this.callFlexMethod("getCellForSelenium", locator, text);
		// storedVars is defined by Selenium and is a map of his $-variables
		storedVars[text] = val;
		return val;
	} catch (error) {
		return error.name + ": " + error.message;
	}
};