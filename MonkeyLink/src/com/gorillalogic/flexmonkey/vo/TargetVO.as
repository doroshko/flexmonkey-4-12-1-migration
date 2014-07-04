/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.vo {

    [RemoteClass]
    public class TargetVO {

        public var propertyArray:Array;
        public var styleArray:Array;
        public var snapshotVO:SnapshotVO;

        public function TargetVO(propertyArray:Array = null,
                                 styleArray:Array = null,
                                 snapshotVO:SnapshotVO = null) {
            this.propertyArray = propertyArray;
            this.styleArray = styleArray;
            this.snapshotVO = snapshotVO;
        }

    }
}