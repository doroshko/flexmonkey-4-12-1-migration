
package com.gorillalogic.utils
{

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.utils.ObjectUtil;
	
	import org.flexunit.internals.namespaces.classInternal;
	FLEXMONKEY::vfour
	{
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.Skin;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.IViewport;
	}
    

	public class MonkeyMagicAutomationDelegate implements IAutomationObject
	{
		public static var elementsToExpose:ArrayCollection = new ArrayCollection();
		private var _trueDelegate:IAutomationObject;
		private var _trueComponent:UIComponent;
	 public function MonkeyMagicAutomationDelegate() 
		{
			
		}
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationDelegate
		//----------------------------------
		
		public function get trueComponent():UIComponent
		{
			return _trueComponent;
		}

		public function set trueComponent(value:UIComponent):void
			
		{
			_trueComponent = value;
//			if(!_trueComponent || !mx.utils.ObjectUtil.getClassInfo(_trueComponent)["name"])
//				trace("The true component is either null or has no name");
			
		}

		public function get trueDelegate():IAutomationObject
		{
			return _trueDelegate;
		}

		public function set trueDelegate(value:IAutomationObject):void
		{
			
			_trueDelegate = value;
		}
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root The SystemManger of the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public  function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(Class(trueComponent.className), Class(this));
			
		} 
		/**
		 *  The delegate object that is handling the automation-related public functionality.
		 *  Automation sets this when it creates the delegate object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		
		public function get automationDelegate():Object{
			return trueDelegate.automationDelegate;
}
		
		/**
		 *  @private
		 */
		public function set automationDelegate(delegate:Object):void{
			trueDelegate.automationDelegate = delegate;
}
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  Name that can be used as an identifier for this object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get automationName():String{
			return trueDelegate.automationName;
}
		
		/**
		 *  @private
		 */
		public function set automationName(name:String):void{
			trueDelegate.automationName = name;
}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  This value generally corresponds to the rendered appearance of the 
		 *  object and should be usable for correlating the identifier with
		 *  the object as it appears visually within the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get automationValue():Array{
			return trueDelegate.automationValue;
}

		
		/** 
		 *  A flag that determines if an automation object
		 *  shows in the automation hierarchy.
		 *  Children of containers that are not visible in the hierarchy
		 *  appear as children of the next highest visible parent.
		 *  Typically containers used for layout, such as boxes and Canvas,
		 *  do not appear in the hierarchy.
		 *
		 *  <p>Some controls force their children to appear
		 *  in the hierarchy when appropriate.
		 *  For example a List will always force item renderers,
		 *  including boxes, to appear in the hierarchy.
		 *  Implementers must support setting this property
		 *  to <code>true</code>.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get showInAutomationHierarchy():Boolean{
			return trueDelegate.showInAutomationHierarchy;
}
		
		/**
		 *  @private
		 */
		public function set showInAutomationHierarchy(value:Boolean):void{
			trueDelegate.showInAutomationHierarchy = value;
}
		
		/**
		 *  An implementation of the <code>IAutomationTabularData</code> interface, which 
		 *  can be used to retrieve the data.
		 * 
		 *  @return An implementation of the <code>IAutomationTabularData</code> interface.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get automationTabularData():Object{
			return trueDelegate.automationTabularData;
}

		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
//Since automation is diffrent in v3 and v4 we have to make some compile time decisions
if(FLEXMONKEY::vfour){
	/**
	 *  Returns a set of properties that identify the child within 
	 *  this container.  These values should not change during the
	 *  lifespan of the application.
	 *  
	 *  @param child Child for which to provide the id.
	 * 
	 *  @return Sets of properties describing the child which can
	 *          later be used to resolve the component.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function createAutomationIDPart(child:IAutomationObject):Object{
		return trueDelegate.createAutomationIDPart(child);
	}
		/**
		 *  Returns a set of properties as automation IDs that identify the child within
		 *  this container.  These values should not change during the
		 *  lifespan of the application
		 * 
		 *  @param child Child for which to provide the id.
		 * 
		 *  @param properties which needs to be considered for forming the Id.
		 *
		 *  @return Sets of properties describing the child which can
		 *          later be used to resolve the component.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object{
			return trueDelegate.createAutomationIDPartWithRequiredProperties(child, properties);
}
		
		/**
		 *  Provides the automation object list .  This list
		 *  does not include any children that are composites.
		 *
		 *  @return the automation children.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getAutomationChildren():Array{
			if(elementsToExpose.contains(automationName)){
				var cont:UIComponent = (trueComponent as UIComponent);
				var retVal:Array = new Array();
				for(var i:int = 0; i < cont.numChildren; i++){
					retVal.push(cont.getChildAt(i));
				}

					if(cont is SkinnableComponent){
						var cont_sc:SkinnableComponent = cont as SkinnableComponent;
						for(var j:int = 0; j < cont_sc.skin.numChildren; j++){
							retVal.push(cont_sc.skin.getChildAt(j));
						}
					}
				return retVal;
			}
			return trueDelegate.getAutomationChildren();
		}
		
		/**
		 *  The owner of this component for automation purposes.
		 * 
		 *  @see mx.core.IVisualElement#owner
		 * 
		 *  @return The owner of this component
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationOwner():DisplayObjectContainer{
			return trueDelegate.automationOwner;
		}
		
		/**
		 *  The parent of this component for automation purposes.
		 * 
		 *  @see mx.core.IVisualElement#parent
		 * 
		 *  @return The parent of this component
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationParent():DisplayObjectContainer{
			return trueDelegate.automationParent;
		}
		
		/**
		 *  True if this component is enabled for automation, false
		 *  otherwise.
		 * 
		 *  @see mx.core.IUIComponent#enabled
		 * 
		 *  @return <code>true</code> if this component is enabled for automation,
		 *          <code>false</code> otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationEnabled():Boolean{
			return trueDelegate.automationEnabled;
		}
		
		/**
		 *  True if this component is visible for automation, false
		 *  otherwise.
		 * 
		 *  @see flash.display.DisplayObject#visible
		 * 
		 *  @return <code>true</code> if this component is visible for automation,
		 *          <code>false</code> otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get automationVisible():Boolean{
			return trueDelegate.automationVisible;
		}
} else {
	/**
	 *  Returns a set of properties as automation IDs that identify the child within
	 *  this container.  These values should not change during the
	 *  lifespan of the application
	 * 
	 *  @param child Child for which to provide the id.
	 * 
	 *  @param properties which needs to be considered for forming the Id.
	 *
	 *  @return Sets of properties describing the child which can
	 *          later be used to resolve the component.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function createAutomationIDPart(child:IAutomationObject):Object{
		return trueDelegate.createAutomationIDPart(child);
	}
	
	/**
	 *  Provides the automation object list .  This list
	 *  does not include any children that are composites.
	 *
	 *  @return the automation children.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function getAutomationChildren():Array{
		if(elementsToExpose.contains(automationName)){
			var cont:UIComponent = (trueComponent as UIComponent);
			var retVal:Array = new Array();
			for(var ii:int = 0; ii < cont.numChildren; ii++){
				retVal.push(cont.getChildAt(ii));
			}
			

			return retVal;
		}
		var children:Array = new Array();
		for(var i:int = 0; i < trueDelegate.numAutomationChildren; i++){
		children.push(trueDelegate.getAutomationChildAt(i));
		}
		
		return children;
	}
	

}
		/**
		 *  Resolves a child by using the id provided. The id is a set 
		 *  of properties as provided by the <code>createAutomationIDPart()</code> method.
		 *
		 *  @param criteria Set of properties describing the child.
		 *         The criteria can contain regular expression values
		 *         resulting in multiple children being matched.
		 *  @return Array of children that matched the criteria
		 *          or <code>null</code> if no children could not be resolved.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function resolveAutomationIDPart(criteria:Object):Array{
			return trueDelegate.resolveAutomationIDPart(criteria);
}
		
		/**
		 *  The number of automation children this container has.
		 *  This sum should not include any composite children, though
		 *  it does include those children not significant within the
		 *  automation hierarchy.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numAutomationChildren():int{
			if(elementsToExpose.contains(automationName)){
				return getAutomationChildren().length;
						}
			
			return trueDelegate.numAutomationChildren;
		}
		/** 
		 *  Provides the automation object at the specified index.  This list
		 *  should not include any children that are composites.
		 *
		 *  @param index The index of the child to return
		 * 
		 *  @return The child at the specified index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getAutomationChildAt(index:int):IAutomationObject{
			if(elementsToExpose.contains(automationName)){
				
				return getAutomationChildren()[index] as IAutomationObject;
			}
			return trueDelegate.getAutomationChildAt(index);
}

		
		/**
		 *  Replays the specified event.  A component author should probably call 
		 *  super.replayAutomatableEvent in case default replay behavior has been defined 
		 *  in a superclass.
		 *
		 *  @param event The event to replay.
		 *
		 *  @return <code>true</code> if a replay was successful.  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function replayAutomatableEvent(event:Event):Boolean{
			return trueDelegate.replayAutomatableEvent(event);
}
		FLEXMONKEY::vfour
		{
		//Lemme hit them skinz
		/**
		 *  @private
		 */
		
		 public function get SKINnumAutomationChildren():int
		{ 
			
			var objArray:Array = getAutomationChildren();
			return (objArray?objArray.length:0);
		}

		/**
		 *  @private
		 */
		
		// Monkey Patch
		 public function SKINgetAutomationChildAt(index:int):IAutomationObject
		{
			//			var numChildren:int = container.contentGroup.numChildren;
			//			if(index < numChildren )
			//				return   container.contentGroup.getChildAt(index) as IAutomationObject;
			//			else
			//			{
			//				index = index - numChildren;
			//				var scrollBars:Array = getScrollBars(container,container.contentGroup);
			//				if(scrollBars && index < scrollBars.length)
			//					return scrollBars[index];
			//			}   
			//			
			//			
			//			return null;
			var kids:Array = getAutomationChildren();
			return kids && index < kids.length ? kids[index] : null;
		}
		// End Monkey Patch
		
		
		/**
		 *  @private
		 */
		 public function SKINgetAutomationChildren(container:SkinnableContainer):Array
		{
			
			var chilArray:Array = new Array();
			if(container.contentGroup)
			{
				var n:int = container.contentGroup.numChildren;
				
				for (var i:int = 0; i<n ; i++)
				{
					var obj:Object = container.contentGroup.getChildAt(i);
					// here if are getting scrollers, we need to add the viewport's children as the actual children
					// instead of the scroller
					if(obj is spark.components.Scroller)
					{
						var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
						var viewPort:IViewport =  scroller.viewport;
						if(viewPort is IAutomationObject)
							chilArray.push(viewPort);
						if(scroller.horizontalScrollBar)
							chilArray.push(scroller.horizontalScrollBar);
						if(scroller.verticalScrollBar)
							chilArray.push(scroller.verticalScrollBar);
					}
						// Monkey Patch
					else if (obj is IAutomationObject)
						// Monkey Patch
						chilArray.push(obj);
				}
			}
			var scrollBars:Array = container.automationDelegate.getScrollBars(null,container.contentGroup);
			n = scrollBars? scrollBars.length : 0;
			
			for ( i=0; i<n ; i++)
			{
				chilArray.push(scrollBars[i]);
			}
			
			// Monkey Patch
			return chilArray.concat(getSkinParts(container));
			// End Monkey Patch
		}
		 // Monkey Patch
		 public function getSkinParts(container:SkinnableContainer):Array {
			 return container.skin.getAutomationChildren().filter(function(obj:Object, index:int, array:Array):Boolean {
				 return (obj && obj is IAutomationObject && obj.hasOwnProperty("id") && obj["id"] != "contentGroup");
			 });
		 }
		 // End Monkey Patch
		 }
	}

}