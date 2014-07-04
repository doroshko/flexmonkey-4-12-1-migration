/**
 * @author GorillaLogic
 */

/**
 * Definition of the Monkey Application
 * @class
 */
function MonkeyApplication(nameOfApp) {

	this.appName = nameOfApp;
	if (navigator.appName.indexOf ("Microsoft") !=-1) {
		this.app =  window[this.appName];
	} else {
		this.app =  document[this.appName];
	}

}

/**
 * Use the application to find a component
 * @param componentType
 * @param monkeyId
 * @returns
 */
MonkeyApplication.prototype.find = function(componentType, monkeyId) {
	var object = this.app.findFromJS('','',monkeyId, 'automationName');
	switch(componentType) {
		case "Button":
			var monkeyButt = new MonkeyButton(this.app);
			monkeyButt.monkeyID = object.automationName;
			return monkeyButt;
			break;
		case "TextInput":
			var textField =  new MonkeyTextField(this.app);
			textField.monkeyID = object.automationName;
			return textField;
			break;
		case "List":
			return new MonkeyList(this.app);
			break;
		case "DropDownList":
			var dropDown =  new MonkeyDropDownList(this.app);
			dropDown.monkeyID = object.automationName;
			return dropDown;
			break;

	}

};
/**
 * Definition of the root monkey component
 * @class
 */
function MonkeyComponent(appParam) {
	var app = appParam;
}

/**
 * Get the ID of a monkey component
 */
MonkeyComponent.prototype.getId = function() {
	alert ('GetId - Not Implemented');
};
/**
 * Send a click command to a monkey component
 * @param x
 * @param y
 * @param retrys
 * @param delay
 */
MonkeyComponent.prototype.click = function(x,y,retrys,delay) {
	alert('Click('+ x + ',' + y +') - not implemented');
};
/**
 * Execute a verify on a monkey component
 * @param expectedValue
 * @param propertyPath
 * @returns error|success|fail
 */
MonkeyComponent.prototype.verify = function(expectedValue, propertyPath) {
	alert('Verify('+ expectedValue + '=' + propertyPath +') - not implemented');
	return "error";
};
/**
 *
 * @param expectedValue
 * @param propertyPath
 * @returns {String}
 */
MonkeyComponent.prototype.verifyNot = function(expectedValue, propertyPath) {
	alert('VerifyNot('+ expectedValue + ',' + propertyPath +') - not implemented');
	return "error";
};
MonkeyComponent.prototype.VerifyWildcard = function(wildcard,propertyPath) {
	alert('VerifyWildCard('+ wildcard + ',' + propertyPath +') - not implemented');
	return "error";
};
MonkeyComponent.prototype.VerifyNotWildCard = function(wildcard,propertyPath) {
	alert('VerifyNotWildCard('+ wildcard + ',' + propertyPath +') - not implemented');
	return "error";
};
MonkeyComponent.prototype.VerifyRegex = function(regex,propertyPath) {
	alert('VerifyRegex('+ regex + ',' + propertyPath +') - not implemented');
	return "error";
};
MonkeyComponent.prototype.VerifyExists = function() {
	alert('VerifyExists() - not implemented');
	return "error";
};
MonkeyComponent.prototype.VerifyNotExists = function() {
	alert('VerifyNotExist() - not implemented');
	return "error";
};
//Store and Value field

/**
 * Definition of MonkeyButton
 * @class
 * @extends MonkeyComponent
 */
function MonkeyButton(appParam) {
	var app = appParam;
	// Call the parent constructor
	MonkeyComponent.call(this);
}

MonkeyButton.prototype = new MonkeyComponent();
MonkeyButton.prototype.constructor = MonkeyButton;

/**
 * Executes a click on a MonkeyButton
 */
MonkeyButton.prototype.click = function() {
	doFlexUiEvent('Click', this.monkeyID, 'automationName', [],'', '', '10', '1000', false);
};
/**
 * Definition of MonkeyTextField
 * @class
 * @extends MonkeyComponent
 */
function MonkeyTextField(appParam) {
	var app = appParam;
	// Call the parent constructor
	MonkeyComponent.call(this);
}

MonkeyTextField.prototype = new MonkeyComponent();
MonkeyTextField.prototype.constructor = MonkeyButton;

/**
 * Input text into a text field
 * @param text
 */
MonkeyTextField.prototype.inputText = function(text) {
	doFlexUiEvent('Input', this.monkeyID, 'automationName', [text],'', '', '10', '1000', false, this.app);
};
/**
 * Definition of a MonkeyList
 * @class
 * @extends MonkeyComponent
 */
function MonkeyList(appParam) {
	var app = appParam;
	MonkeyComponent.call(this);
}

MonkeyList.prototype = new MonkeyComponent();
MonkeyList.prototype.constructor = MonkeyList;

/**
 * Select and Item in the list by value
 * @param value
 */
MonkeyList.prototype.select = function(value) {
	doFlexUiEvent('Select', this.monkeyID, 'automationName', [value], '', '', '10', '1000', false, this.app);
};
/**
 * Select a row in a list by index
 * @param index
 */
MonkeyList.prototype.selectRow = function(index) {
	alert('SelectRow('+index+') - not implemented');
};
/**
 * Definition of a Monkey Dropdown List
 * @class
 * @extends MonkeyComponent
 */
function MonkeyDropDownList(appParam) {
	var app = appParam;
	// Call the parent constructor
	MonkeyList.call(this);
}

MonkeyDropDownList.prototype = new MonkeyList();
MonkeyDropDownList.prototype.constructor = MonkeyDropDownList;

/**
 * Opens the dropdown List
 */
MonkeyDropDownList.prototype.open = function() {
	doFlexUiEvent('Open', this.monkeyID, 'automationName', [null], '', '', '10', '1000', false, this.app);

}