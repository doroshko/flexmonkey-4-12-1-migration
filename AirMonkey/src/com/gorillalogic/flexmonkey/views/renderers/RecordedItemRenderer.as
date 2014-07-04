package com.gorillalogic.flexmonkey.views.renderers
{
	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.events.MonkeyRunnableEvent;
	import com.gorillalogic.flexmonkey.model.ProjectTestModel;
	import com.gorillalogic.framework.FMHub;
	import com.gorillalogic.utils.DragRequest;
	
	import flash.events.MouseEvent;
	
	import mx.events.DragEvent;

	public class RecordedItemRenderer extends TestRunnableItemRenderer
	{
		public function RecordedItemRenderer()
		{
			super();
		}
		
		private static var _dummyMonkeyTest:MonkeyTest = null;
		private static function get dummyMonkeyTest():MonkeyTest {
			if (_dummyMonkeyTest==null) {
				_dummyMonkeyTest=new MonkeyTest();
			}
			_dummyMonkeyTest.children = ProjectTestModel.instance.recordItems;
			return _dummyMonkeyTest;
		}
		
		override protected function isAcceptableDrag(event:DragEvent):Boolean {
			var dragType:String = event.dragSource.dataForFormat(DragRequest.TYPE) as String;
			var dragData:Object = event.dragSource.dataForFormat(DragRequest.DATA);
			
			// acceptable dropable, but only accept commands from recorded items or palette 
			if (super.isAcceptableDrag(event) &&  
					(ProjectTestModel.instance.isRunnableInRecording(dragData as MonkeyRunnable) ||
					 DragRequest.isNewCommandDrag(dragType))  ) {
				return true;
			}
			return false;
		}
		
		override protected function isConfirmDeletes():Boolean {
			return false;
		}
		
		override protected function getDropIndex(event:DragEvent):int {
			var dropIndex:int = ProjectTestModel.instance.recordItems.getItemIndex(monkeyRunnable);
			if(isBottomHalf(event)) {
				dropIndex++;
			}
			return dropIndex;
		}
		override protected function editButtonClickHandler(event:MouseEvent):void {
			
			FMHub.instance.dispatchEvent(MonkeyRunnableEvent.createMonkeyRunnableEvent(MonkeyRunnableEvent.EDIT_MONKEY_RUNNABLE_RECORDVIEW, monkeyRunnable));
		}
		// this is arguably a bit kludgy, but arguably not
		// one "dirty" issue is that the dropped command will have this
		// as its parent until it is moved to a real test or garbage collected
		override protected function getDropParentNode():MonkeyNode {
			return RecordedItemRenderer.dummyMonkeyTest;
		}
		
		

	}
}