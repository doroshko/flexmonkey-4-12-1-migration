/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.utils {

    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.views.AirMonkeyWindowView;
    import com.gorillalogic.utils.SnapshotOverlay;

    public class MainViewWindowManager {

        public static var instance:MainViewWindowManager = new MainViewWindowManager();

        private var snapshotOverlay:SnapshotOverlay = new SnapshotOverlay();
        private var airMonkeyWindow:AirMonkeyWindowView = new AirMonkeyWindowView();

        public function load():void {
            ApplicationModel.instance.airMonkeyWindow = airMonkeyWindow;
            airMonkeyWindow.open();
        }

    }

}
