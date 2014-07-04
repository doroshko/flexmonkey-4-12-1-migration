/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.monkeylink {

    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexunit.NoTestsFoundTest;
    import com.gorillalogic.utils.ApplicationWrapper;
    
    import flash.utils.getDefinitionByName;
    
    import mx.core.EventPriority;
    
    import org.flexunit.internals.TraceListener;
    import org.flexunit.listeners.AirCIListener;
    import org.flexunit.listeners.CIListener;
    import org.flexunit.runner.FlexUnitCore;
    import org.flexunit.runner.notification.ITemporalRunListener;

    public class MonkeyLinkTestLauncher {

        public static const monkeyLinkTestLauncher:MonkeyLinkTestLauncher = new MonkeyLinkTestLauncher();

        public function startTestLauncher(suiteClasses:Array,
                                          snapshotDir:String,
                                          listener:ITemporalRunListener = null):void {
            // ProjectTestModel.instance.snapshotDir = snapshotDir;

            var core:FlexUnitCore = new FlexUnitCore();
            core.addUncaughtErrorListener(ApplicationWrapper.instance.application.systemManager.loaderInfo, EventPriority.DEFAULT + 10);

            if (listener != null) {
                core.addListener(listener);
            } else {
                if (isAdobeAirApp()) {
                    core.addListener(new AirCIListener());

                } else {
                    core.addListener(new CIListener());
                }
				core.addListener(new TraceListener);
            }

            if (suiteClasses == null || suiteClasses.length <= 0) {
                core.run(NoTestsFoundTest);
            } else {
                core.run(suiteClasses);
            }
        }

        private function isAdobeAirApp():Boolean {
            try {
                var clazz:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;

                if (clazz != null && clazz.nativeApplication != null) {
                    return true;
                }
            } catch (e:Error) {
                //ignore
            }
            return false;
        }
    }
}
