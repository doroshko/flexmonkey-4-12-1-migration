function doTests(){

    module('Basic Functionality');
    test('Data Entry.Happy Path', function() {
    	
    	var app = new MonkeyApplication("MonkeyContacts");
		
		var inNameTextField = app.find("TextInput","inName");
		inNameTextField.inputText("Mike Wells");
		
		var inPhoneTextField = app.find("TextInput","inPhone");
		inPhoneTextField.inputText("2058213928");
		
		var dropDownList = app.find("DropDownList", "inType");
		dropDownList.open();
		dropDownList.select("Work");
		
		var addButton = app.find("Button", "Add");
		addButton.click();
       
		
    });

}