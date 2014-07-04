8/26/2010
Gorilla Logic
For support: http://www.gorillalogic.com/forum/7

This project is a full sample configuration for running FlexMonkey tests against a Flex application.  The tests were built using the FlexMonkey console and generated into ActionScript with the 'Generate AS3' feature of the console.  You can do a "Continuous Integration" run by using the ANT build target: clean-build-test. Simply update the build.properties for your env. and run.

If you are running from a file URL (default in this build), you need to trust the application SWF and the test module SWF (MonkeyContacts.swf & TestModule.swf) at: http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html

This sample project has been tested on Max OSX (10.6.4), Windows XP, and Ubuntu Linux (10.04 Desktop).  The following product versions were used in creating / testing this sample project: 

- Flex 4.1
- ANT 1.7.x
- Java 1.6.x
- Flash 10.1
