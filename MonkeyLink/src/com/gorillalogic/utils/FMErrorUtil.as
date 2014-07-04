/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import flash.events.ErrorEvent;

    public class FMErrorUtil {

        /**
         * error message for file failures
         */
        public static function getErrorMessage(e:Object):String {
            var msg:String;

            if (e is FMFileError) {
                msg = (e as FMFileError).message;
            } else {
                msg = (e as ErrorEvent).text;
            }
            return msg;
        }

    }

}
