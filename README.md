# FlexMonkey Migration to Flex SDK 4.12.1

- **Project type**: Migration.
- **Request**: [https://github.com/BAXTER-IT/FlexMonkey/issues/1](https://github.com/BAXTER-IT/FlexMonkey/issues/1)
- **Description**: FlexMonkey throws an exception when used with Flex SDK 4.12.1. 
- **Solution**: This particular bug was not in FlexMonkey but in compiler configuration. 
I also cleaned up FlexMonkey to compile without warnings, fixed small UI problems, 
tested all the samples and made the ant tasks work. 
FlexMonkey is now ready for 4.12.1 and 4.13. 
- **Technologies**: Flex, ActionScript, Adobe Flash Builder, IntelliJ IDEA, ant

## Using Flash Builder

- Create a workspace somewehere. 
- Add the projects to the workspace:
    - /AirMonkey
    - /as3gate
    - /FlexAutomationLibrary4
    - /libs
    - /MonkeyLink
    - /samples/adobe_air
    - /samples/FlexComponentZoo
    - /samples/MonkeyContactsExample
    - /samples/TomSwftie1
    - /samples/say_hello_web
    - /samples/say_hello_air
- Projects are configured to use the default SDK.

## Using IntelliJ IDEA

- Compile web apps with: -load-config="${flexlib}/flex-config.xml".
- Compile air apps with: -load-config="${flexlib}/air-config.xml".

## Tests

- 5.2.1 was tested with Flash Builder 4.6, Flex SDK 4.6 + Flash Payer 14 + Adobe AIR 14 + Firefox. 
- 5.3 was tested with Flash Builder 4.6, Flex SDK 4.12.1 + Flash Payer 14 + Adobe AIR 14 + Firefox. 
- 5.3 (only say_hello_air & say_hello_web) was tested with Flex 4.13.0 + Air 13 + IntelliJ 13.1.4 + Firefox.







