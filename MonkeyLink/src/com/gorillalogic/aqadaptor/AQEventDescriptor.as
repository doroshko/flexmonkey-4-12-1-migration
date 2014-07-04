////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.gorillalogic.aqadaptor {

    import com.gorillalogic.aqadaptor.custom.CustomAutomationEventDescriptor;
    import com.gorillalogic.utils.MonkeyAutomationManager;
    
    import flash.events.Event;
    import flash.events.TextEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.events.AutomationReplayEvent;
    import mx.core.mx_internal;

    use namespace mx_internal;

    /**
     * Method descriptor class.
     */
    public class AQEventDescriptor extends CustomAutomationEventDescriptor {

        private var _eventArgASTypesInitialized:Boolean = false;

        public function AQEventDescriptor(name:String,
                                          eventClassName:String,
                                          eventType:String,
                                          args:Array) {
            super(name, eventClassName, eventType, args);
        }

        override public function record(target:IAutomationObject, event:Event):Array {
            var args:Array = getArgDescriptors(target);

            var helper:IAQCodecHelper = AQAdapter.getCodecHelper();
            return helper.encodeProperties(event, args, target);
        }

        override public function replay(target:IAutomationObject, args:Array):Object {
            var event:Event = createEvent(target);
			if (event is TextEvent)
			{
				
				var textEvent:TextEvent = TextEvent(event);
				textEvent.text =args[0];
				event = textEvent;
			}
            var argDescriptors:Array = getArgDescriptors(target);
            var helper:IAQCodecHelper = AQAdapter.getCodecHelper();
            helper.decodeProperties(event, args, argDescriptors,
                                    IAutomationObject(target));

            var riEvent:AutomationReplayEvent = new AutomationReplayEvent();
            riEvent.automationObject = target;
            riEvent.replayableEvent = event;

            MonkeyAutomationManager.instance.replayAutomatableEvent(riEvent);

            return null;
        }

    }
}
