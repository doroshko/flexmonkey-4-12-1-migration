8/26/2010
Gorilla Logic
For support: http://www.gorillalogic.com/forum/7

This project is a full sample configuration for running FlexMonkey tests against and AIR application.  The tests were built using the FlexMonkey console and generated into ActionScript with the 'Generate AS3' feature of the console.  You can do a "Continuous Integration" run by using the ANT build target: run_tests.  

A special thank you to Digital Dump Truck (http://digitaldumptruck.jotabout.com/?p=195).  His work was an important contribution to our ability to add AIR support directly into the FlexMonkey project.  

This sample project has been tested on Max OSX (10.6.4), Windows XP, and Ubuntu Linux (10.04 Desktop).  The following product versions were used in creating / testing this sample project: 

- AIR 2.6 
- AIR 2.0 (need to change adobe-air-app.xml namespace to 2.0, and flex.home in build.properties to a 4.1 SDK)
- Flex 4.5
- ANT 1.7.x
- Java 1.6.x

AIR SDK's Download from: http://www.adobe.com/cfusion/entitlement/index.cfm?e=airsdk

