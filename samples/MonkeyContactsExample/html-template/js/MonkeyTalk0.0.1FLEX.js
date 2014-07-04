/**
 * @author Mike Wells
 */
/**
 * Definition of the applicaiton class
 */
    function MonkeyApplication(nameOfApp) {

    	this.appName = nameOfApp;
    	if (navigator.appName.indexOf ("Microsoft") !=-1) {
		this.app =  window[this.appName];
	} else {
		this.app =  document[this.appName];
	}
    	
    }   
      MonkeyApplication.prototype.find = function(componentType, monkeyId){  
      var object = this.app.findFromJS('','',monkeyId, 'automationName');
      switch(componentType){
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
           case "Grid":
      	      var grid =  new MonkeyGrid(this.app);
      	      grid.monkeyID = object.automationName;
      	      return grid;
      	      break;         	      
      	      
      }
       
    }; 

/**
 * Definition of the root monkey component
 */
    function MonkeyComponent(appParam) {
    	var app = appParam;
    }  
    MonkeyComponent.prototype.getId = function(){  
      alert ('GetId - Not Implemented');  
    }; 
    MonkeyComponent.prototype.click = function(x,y,retrys,delay){  
      alert('Click('+ x + ',' + y +') - not implemented');  
    }  
    MonkeyComponent.prototype.verify = function(expectedValue, propertyPath){  
      alert('Verify('+ expectedValue + '=' + propertyPath +') - not implemented');  
    } 
        MonkeyComponent.prototype.verifyNot = function(expectedValue, propertyPath){  
      alert('VerifyNot('+ expectedValue + ',' + propertyPath +') - not implemented');  
    } 
        MonkeyComponent.prototype.VerifyWildcard = function(wildcard,propertyPath){  
      alert('VerifyWildCard('+ wildcard + ',' + propertyPath +') - not implemented');  
    } 
        MonkeyComponent.prototype.VerifyNotWildCard = function(wildcard,propertyPath){  
      alert('VerifyNotWildCard('+ wildcard + ',' + propertyPath +') - not implemented');  
    } 
        MonkeyComponent.prototype.VerifyRegex = function(regex,propertyPath){  
      alert('VerifyRegex('+ regex + ',' + propertyPath +') - not implemented');  
    } 
        MonkeyComponent.prototype.VerifyExists = function(){  
      alert('VerifyExists() - not implemented');  
    }   
          MonkeyComponent.prototype.VerifyNotExists = function(){  
      alert('VerifyNotExist() - not implemented');  
    } 
    //Store and Value field
/**
 * Definition of components 
 */
    function MonkeyButton(appParam) {
    	var app = appParam;
      // Call the parent constructor  
      MonkeyComponent.call(this);  
    }   
    MonkeyButton.prototype = new MonkeyComponent();  
    MonkeyButton.prototype.constructor = MonkeyButton;  
    MonkeyButton.prototype.click = function(){
    	doFlexUiEvent('Click', this.monkeyID, 'automationName', [],'', '', '10', '1000', false);
    }
    function MonkeyTextField(appParam) {
    	var app = appParam;
      // Call the parent constructor  
      MonkeyComponent.call(this);  
    }   
    MonkeyTextField.prototype = new MonkeyComponent();  
    MonkeyTextField.prototype.constructor = MonkeyTextField;  
    MonkeyTextField.prototype.inputText = function(text){
    	doFlexUiEvent('Input', this.monkeyID, 'automationName', [text],'', '', '10', '1000', false, this.app);
    }

    function MonkeyList(appParam) {
    	var app = appParam;
      // Call the parent constructor  
      MonkeyComponent.call(this);  
    }   
    MonkeyList.prototype = new MonkeyComponent();  
    MonkeyList.prototype.constructor = MonkeyList; 
    MonkeyList.prototype.select = function(value){
    	doFlexUiEvent('Select', this.monkeyID, 'automationName', [value], '', '', '10', '1000', false, this.app);
    } 

    MonkeyList.prototype.selectRow = function(index){
    	alert('SelectRow('+index+') - not implemented');
    }     
    
    function MonkeyDropDownList(appParam) {
    	var app = appParam;
      // Call the parent constructor  
      MonkeyList.call(this);  
    }   
    MonkeyDropDownList.prototype = new MonkeyList();  
    MonkeyDropDownList.prototype.constructor = MonkeyDropDownList;  
    MonkeyDropDownList.prototype.open = function(){
    	            doFlexUiEvent('Open', this.monkeyID, 'automationName', [null], '', '', '10', '1000', false, this.app);

    }

    function MonkeyGrid(appParam) {
    	var app = appParam;
      // Call the parent constructor  
      MonkeyComponent.call(this);  
    }   
    MonkeyGrid.prototype = new MonkeyComponent();  
    MonkeyGrid.prototype.constructor = MonkeyGrid;  
    MonkeyGrid.prototype.verify = function(row, column, expectedValue, isRetryable){
    	verify = verifyGridFromJS('VerifyGrid', 'New Verify Grid', this.monkeyID, 'automationName', '' + row, '' + column, expectedValue, '', '', '' + isRetryable, '10', '1000');
        equal( verify, true, 'Verify of grid failed.' );
    }


//Lower Level api stuff



$(document).ready(function(){
	if (getUrlVars()["headless"]) {
		doTestLoader();
		window.setTimeout('$( "#draggable" ).show()',5000);
		window.setTimeout("doTests()", 6000);
		
	} else {
	doTestLoader();
	window.setTimeout('$( "#draggable" ).show()',5000);
	}
	
});

function pausecomp(ms) {
ms += new Date().getTime();
while (new Date() < ms){}
} 
function getFlexApp(appName) {
	if (navigator.appName.indexOf ("Microsoft") !=-1) {
		return window[appName];
	} else {
		return document[appName];
	}
}
function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}


function doFlexUiEvent(command, value, prop, args, containerProp, containerVal, retryTimes, delay, retryOnResponse){
	var response = false;
	var timesTried = 0;
	while(!response && (timesTried < retryTimes)){
		try{
	 response = getFlexApp('MonkeyContacts').playFromJS('UIEvent',command, value, prop, args, containerProp, containerVal, retryTimes, delay, retryOnResponse);
	 } catch(error){
	 	alert(error);
	 }
	 timesTried++;
	}

	
}
function doTestsWrapper(){
		//////
	var currentTest = "";
	QUnit.testStart = function (details){ 
		currentTest = details.name;
		failMessages = [];
		};
	
	/////
	var failMessages = [];
	QUnit.log = function (details) {
		//is called whenever an assertion is completed. result is a boolean (true for passing, false for failing) and message is a string description provided by the assertion. 
		if(!details.result){
			    var failMessage = {"messageFromTest": details.actual + "does not equal" + details.expected, "type":details.currentTest, "stackTrace":details.message};
                failMessages[failMessages.length] = failMessage;
		}
		
	};
	//////
	QUnit.testDone = function (details) {
	if (getUrlVars()["headless"]) {	 
      getFlexApp('MonkeyContacts').sendTestResult(details.name, details.name, 0, (details.failed > 0 ? "failed":"success"), failMessages);
    }
  };
	if (getUrlVars()["headless"]) {
      getFlexApp('MonkeyContacts').startJSTests();
     }
  doTests();
      if (getUrlVars()["headless"]) {
    getFlexApp('MonkeyContacts').endJSTests();
    }
  
}
function doTestLoader(){
	$(document.body).append($("<style>#draggable { width: 600px; height: 450px; padding: 0.5em; position:absolute; top:0;right:0;display:none }</style>"));
	$(document.body).append($("<div id='draggable' class='ui-widget-content'/>"));
	$("#draggable").append($("<h1 id='qunit-header'>Monkey Contacts Tester</h1>"));
	$("#draggable").append($("<h2 id='qunit-banner'></h2>"));
	$("#draggable").append($("<div id='qunit-testrunner-toolbar'></div>"));
	$("#draggable").append($("<h2 id='qunit-userAgent'></h2>"));
	$("#draggable").append($("<ol id='qunit-tests'></ol>"));
	$("#draggable").append($("<div id='qunit-fixture'>test markup, will be hidden</div>"));
	$("#draggable").append($("<input type='submit' name='runTest' id='runTest' value='Run Tests'/>"));
  
    $( "#draggable" ).draggable();
   
	//////
	$('#runTest').click( function() {
       doTests();
	});
}

//QUNIT

