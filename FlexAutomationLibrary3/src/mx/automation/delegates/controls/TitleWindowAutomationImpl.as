package mx.automation.delegates.controls
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.delegates.containers.PanelAutomationImpl;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.events.ChildExistenceChangedEvent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;

	[Mixin]
	public class TitleWindowAutomationImpl extends PanelAutomationImpl
	{
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(TitleWindow, TitleWindowAutomationImpl);
		}  		
		public function TitleWindowAutomationImpl(obj:TitleWindow) 
		{
			super(obj);
			obj.addEventListener(FlexEvent.CREATION_COMPLETE, function():void {
				if(obj.getAutomationChildAt(obj.numAutomationChildren-1) != null &&
						obj.getAutomationChildAt(obj.numAutomationChildren-1) is Button) {
					obj.getAutomationChildAt(obj.numAutomationChildren-1).automationName = "closeButton";					
				}
			});
		}
	} 
}