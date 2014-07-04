package com.gorillalogic.utils {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;

    import mx.collections.ArrayCollection;

    import org.as3commons.lang.StringUtils;

    [Bindable]
    public class StoredValueLookup {

        public static const KEY_PREFIX:String = "KEY: ";
        public static var instance:StoredValueLookup = new StoredValueLookup();

        public var storeValueCmds:ArrayCollection;

        public function setup():void {
            storeValueCmds = new ArrayCollection();
            findStoreValueCommands(ProjectTestModel.instance.suites);
        }

        public function addCommand(cmd:StoreValueMonkeyCommand):void {
			if(storeValueCmds == null) {
				storeValueCmds = new ArrayCollection();
			}
            storeValueCmds.addItem(cmd);
        }

        public function removeCommand(cmd:StoreValueMonkeyCommand):void {
            storeValueCmds.removeItemAt(storeValueCmds.getItemIndex(cmd))
        }

        public function getCommandPos(key:String):int {
            var actualKey:String = StringUtils.substringAfter(key, KEY_PREFIX);

            for (var i:int = 0; i < storeValueCmds.length; i++) {
                var c:StoreValueMonkeyCommand = storeValueCmds.getItemAt(i) as StoreValueMonkeyCommand;

                if (c.keyName == actualKey) {
                    return i;
                }
            }
            return -1;
        }

        public function getExpectedValue(expectedValue:String):Object {
            if (StringUtils.startsWith(expectedValue, StoredValueLookup.KEY_PREFIX)) {
                var key:String = StringUtils.substringAfter(expectedValue, KEY_PREFIX);

                for each (var c:StoreValueMonkeyCommand in storeValueCmds) {
                    if (c.keyName == key) {
                        return c.runtimeValue;
                    }
                }

                throw new Error("Store Value Key Not Found: " + key);
            }
            return expectedValue;
        }

        private function findStoreValueCommands(col:ArrayCollection):void {
            for each (var c:MonkeyRunnable in col) {
                if (c is MonkeyNode) {
                    findStoreValueCommands((c as MonkeyNode).children);
                } else if (c is StoreValueMonkeyCommand) {
                    storeValueCmds.addItem(c);
                }
            }
        }
    }
}
