/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen {

    import com.gorillalogic.flexmonkey.vo.AS3FileVO;

    import mx.collections.ArrayCollection;

    public class AS3FileCollector {

        private var _as3Files:ArrayCollection = new ArrayCollection();
        private var _packageName:String;

        public function AS3FileCollector(packageName:String) {
            _packageName = packageName;
        }

        public function get as3Files():ArrayCollection {
            return _as3Files;
        }

        public function get packageName():String {
            return _packageName;
        }

        public function addItem(fr:AS3FileVO):void {
            _as3Files.addItem(fr);
        }

    }
}