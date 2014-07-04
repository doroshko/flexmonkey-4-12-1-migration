/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.utils {

    import com.gorillalogic.views.SnapshotTooltip;

    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import mx.binding.utils.BindingUtils;
    import mx.core.UIComponent;

    public class SnapshotOverlay extends UIComponent {

        private var tooltip:SnapshotTooltip;
        [Bindable] public var automationObject:UIComponent;

        public function SnapshotOverlay() {
            super();
            mouseEnabled = false;
        }

        override protected function createChildren():void {
            super.createChildren();

            tooltip = new SnapshotTooltip();
			tooltip.closeFunction = clear;
            tooltip.visible = false;
            addChild(tooltip);
        }

        override protected function commitProperties():void {
            super.commitProperties();
            BindingUtils.bindProperty(tooltip, "automationObject", this, "automationObject");
        }

        public function show(pointSource:DisplayObject, parent:DisplayObject, event:MouseEvent):void {

            var g:Graphics = this.graphics;
            var rect:Rectangle = pointSource.getBounds(parent);

            g.clear();
            g.lineStyle(2, 0xff0000, 1.0);
            g.drawRect(rect.x + parent.x, rect.y + parent.y, rect.width, rect.height);
            g.lineStyle();

            if (pointSource is UIComponent) {
                automationObject = pointSource as UIComponent;
                tooltip.visible = true;

                var baseX:int = event.stageX + 15;
                var baseY:int = event.stageY;

                if ((baseX + tooltip.width) > parent.width) {
                    baseX = event.stageX - tooltip.width;
                }

                if ((baseY + tooltip.height) > parent.height) {
                    baseY = event.stageY - tooltip.height;
                }

                tooltip.x = baseX;
                tooltip.y = baseY;
				
            }
        }

        public function clear():void {
            this.graphics.clear();
            tooltip.visible = false;
        }
    }
}
