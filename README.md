#FlexMonkey

The good old Gorilla Logic UI testing platform for Flex and AIR applications. Carrying the flame further ...

## Building

### Flash Builder
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

### IntelliJ IDEA
- compile web apps with: -load-config="${flexlib}/flex-config.xml"
- compile air apps with: -load-config="${flexlib}/air-config.xml"

## Versions

- 5.2.1 was tested with Flash Builder 4.6, Flex SDK 4.6, Flash Payer 14, Adobe AIR 14 and Firefox. 
- 5.3 was tested with Flash Builder 4.6, Flex SDK 4.12.1, Flash Payer 14, Adobe AIR 14 and Firefox. 
- Tested say_hello_air & say_hello_web with Flex 4.13.0 + Air 13 + IntelliJ 13.1.4.