////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.gorillalogic.aqadaptor.custom {

    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.utils.describeType;
    import mx.automation.IAutomationManager;
    import mx.automation.IAutomationMethodDescriptor;
    import mx.automation.IAutomationObject;
    import mx.core.mx_internal;

    use namespace mx_internal;

    /**
     * Method descriptor class.
     */
    public class CustomAutomationMethodDescriptor implements IAutomationMethodDescriptor {

        private var _name:String;
        private var _returnType:String;
        private var _asMethodName:String;
        private var _args:Array;

        public function CustomAutomationMethodDescriptor(name:String,
                                                         asMethodName:String,
                                                         returnType:String,
                                                         args:Array) {
            super();

            _name = name;
            _asMethodName = asMethodName;
            _returnType = returnType;
            _args = args;
        }

        public function get name():String {
            return _name;
        }

        public function get returnType():String {
            return _returnType;
        }


        public function record(target:IAutomationObject, event:Event):Array {
            // No support to record a method.
            throw new Error();
        }

        public function replay(target:IAutomationObject, args:Array):Object {
            var f:Function = Object(target)[_asMethodName];
            var retVal:Object = f.apply(target, args);
            return retVal;
        }

        public function getArgDescriptors(obj:IAutomationObject):Array {
            return _args;
        }
    }

}
