/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.views.containers {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.events.FMRunnerEvent;
    import com.gorillalogic.flexmonkey.events.MonkeyRunnableEvent;
    import com.gorillalogic.framework.FMHub;

    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import mx.controls.Image;

    import org.as3commons.lang.StringUtils;

    import spark.components.Button;
    import spark.components.Label;
    import spark.components.SkinnableContainer;

    public class FMPopup extends SkinnableContainer {

        [SkinPart(required="false")]
        public var closeButton:Button;

        [SkinPart(required="false")]
        public var titleLabel:Label;

        [SkinPart(required="false")]
        public var titleImage:Image;

        [Bindable] public var title:String;
        [Bindable] public var titleColor:uint = 0x333333;
        [Bindable] public var showClose:Boolean = true;
        [Bindable] public var showBottomNav:Boolean = true;
        [Bindable] public var monkeyRunnable:MonkeyRunnable;
        [Bindable] public var titleImageSource:Class;

        public function FMPopup() {
            super();
        }

        override protected function commitProperties():void {
            super.commitProperties();

            //set position
            this.top = 0;
            this.bottom = 0;
            this.right = 0;
            this.left = 0;
        }

        override protected function createChildren():void {
            super.createChildren();
            this.addEventListener(KeyboardEvent.KEY_UP, enterKeyHandler);
        }

        private function enterKeyHandler(event:KeyboardEvent):void {
            if (event.keyCode == Keyboard.ENTER) {
                closePopup();
            }
        }

        public function closeClickHander(evetn:MouseEvent):void {
            closePopup();
        }

        public function openPopup(state:String = null):void {
            if (state != null) {
                this.currentState = state;
            }

            this.visible = true;
        }

        public function closePopup():void {
            this.visible = false;
        }

        override public function set currentState(value:String):void {
            super.currentState = value;

            if (StringUtils.contains(super.currentState, "base")) {
                showBottomNav = true;
            } else {
                showBottomNav = false;
            }
        }

        public function playPauseButtonClickHandler(event:MouseEvent):void {
            FMHub.instance.dispatchEvent(new FMRunnerEvent(FMRunnerEvent.SETUP_TEST_RUNNER, monkeyRunnable));
            closePopup();
        }

        public function deleteButtonClickHandler(event:MouseEvent):void {
            FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.CONFIRM_DELETE_MONKEY_RUNNABLE, monkeyRunnable));
            closePopup();
        }


    }

}
