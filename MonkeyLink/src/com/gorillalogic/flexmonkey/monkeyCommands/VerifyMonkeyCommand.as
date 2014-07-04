/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.core.MonkeyUtils;
    import com.gorillalogic.flexmonkey.model.ProjectTestModel;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.flexmonkey.vo.SnapshotVO;
    import com.gorillalogic.flexmonkey.vo.TargetVO;
    import com.gorillalogic.utils.AttributeFinder;
    import com.gorillalogic.utils.FMBitMapUtil;
    import com.gorillalogic.utils.SnapshotLoader;
    import com.gorillalogic.utils.StoredValueLookup;

    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    import mx.utils.ArrayUtil;
    import mx.utils.ObjectUtil;

    import org.as3commons.lang.ArrayUtils;
    import org.flexunit.asserts.assertEquals;

    [RemoteClass]
    [Bindable]
    public class VerifyMonkeyCommand extends MonkeyRunnable implements IVerifyCommand {

        public var snapshotURL:String;
        public var verifyBitmap:Boolean;
        public var verifyBitmapFuzziness:int = 0;
        public var attributes:ArrayCollection;
        public var expectedSnapshot:SnapshotVO;

        private var attributeFinder:AttributeFinder = new AttributeFinder();
        public var targetVO:TargetVO;

        // NOTE: Currently the only place we actually use non-null values for this constructor's parameters is in the generated code.
        public function VerifyMonkeyCommand(description:String = null,
                                            snapshotURL:String = null,
                                            value:String = null,
                                            prop:String = null,
                                            verifyBitmap:Boolean = false,
                                            attributes:ArrayCollection = null,
                                            containerValue:String = null,
                                            containerProp:String = null,
                                            isRetryable:Boolean = true,
                                            delay:String = null,
                                            attempts:String = null,
                                            verifyBitmapFuzziness:int = 0) {

            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);

            this.description = description;
            this.snapshotURL = snapshotURL;
            this.verifyBitmap = verifyBitmap;
            this.verifyBitmapFuzziness = verifyBitmapFuzziness;
            this.error = null;

            if (attributes != null) {
                this.attributes = attributes;
            } else {
                this.attributes = new ArrayCollection();
            }
        }

        //
        // overrides
        //

        override public function get thinkTime():uint {
            return MonkeyTest(parent).defaultThinkTime;
        }

        override public function isEqualTo(item:Object):Boolean {
            if (item == null || !item is VerifyMonkeyCommand) {
                return false;
            } else {
                if ((item.description == this.description) &&
                    (item.value == this.value) &&
                    (item.prop == this.prop) &&
                    (item.containerValue == this.containerValue) &&
                    (item.containerProp == this.containerProp) &&
                    (item.verifyBitmap == this.verifyBitmap) &&
                    (item.verifyBitmapFuzziness == this.verifyBitmapFuzziness) &&
                    (item.attempts == this.attempts) &&
                    (item.delay == this.delay) &&
                    (item.isRetryable = this.isRetryable)) {
                    for (var i:uint = 0; i < attributes.length; i++) {
                        if (!item.attributes[i].isEqualTo(this.attributes[i])) {
                            return false;
                        }
                    }
                    return true;
                }
                return false;
            }
        }

        //
        // public api
        //

		public function verify(actual:Object):void {
			var actualTarget:TargetVO = actual as TargetVO;
			
			if (actualTarget.snapshotVO == null) {
				throw new Error("Could not find target " + value);
			} else {
				compareAttributes(actualTarget);
				
				runActualSnapshot = actualTarget.snapshotVO;
				
				if (verifyBitmap && !compareSnapshots(actualTarget)) {
					assertEquals("snapshot", "no match");
				}
			}
		}


        public function loadFinalExpectedValues():void {
            for each (var attribute:AttributeVO in attributes) {
                attribute.loadFinalExpectedValue();
            }
        }

        public function get target():UIComponent {
            var container:UIComponent = null;
            return MonkeyUtils.findComponent(containerValue, containerProp, value, prop);
        }

        public function loadSnapshot():void {
            if (!expectedSnapshot && snapshotURL) {
                var snapshotLoader:SnapshotLoader = new SnapshotLoader(ProjectTestModel.instance.snapshotsDirUrl);
                snapshotLoader.getSnapshot(snapshotURL, this);
            }
        }

        public function loadTarget(includeSnapshot:Boolean = true):TargetVO {
            var attributeFinder:AttributeFinder = new AttributeFinder();
            var propertyArray:Array;
            var styleArray:Array;
            var snapshotVO:SnapshotVO;
            var targetVO:TargetVO;
            var target:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

            if (target == null) {
                throw Error("component not found");

            } else {
                // put all items into the propertyArray, so that we can see them all in single ui
                var pCol:ArrayCollection = attributeFinder.getProperties(target);

                //pCol.addAll(attributeFinder.getStyles(target)); // doesn't work with Flex 3.3 or 3.2
                for each (var o:Object in attributeFinder.getStyles(target)) {
                    pCol.addItem(o);
                }
                propertyArray = pCol.source;
                styleArray = attributeFinder.getStyles(target).source;

                if (includeSnapshot) {
                    snapshotVO = SnapshotVO.createFromUiComponent(target);
                }
            }

            targetVO = new TargetVO(propertyArray, styleArray, snapshotVO);
            return targetVO;
        }

        //
        // internal
        //

        private function compareSnapshots(currentTarget:TargetVO):Boolean {
            if (currentTarget.snapshotVO && currentTarget.snapshotVO.bitmapData && expectedSnapshot && expectedSnapshot.bitmapData) {
                return FMBitMapUtil.pixelCompareBitmaps(currentTarget.snapshotVO.bitmapData, expectedSnapshot.bitmapData, verifyBitmapFuzziness);
            }
            loadSnapshot();
            return false;
        }

        private function compareAttributes(targetVO:TargetVO):void {
            for each (var attribute:AttributeVO in attributes) {
                attribute.setActualValueForTargetVO(targetVO);

                if (attribute.finalExpectedValue == null) {
                    attribute.loadFinalExpectedValue();
                }

                assertEquals(attribute.finalExpectedValue, attribute.actualValue);
            }
        }
		public function compareAttributesJS(targetVO:TargetVO):Boolean {
			var ret:Boolean = true;
			for each (var attribute:AttributeVO in attributes) {
				attribute.setActualValueForTargetVO(targetVO);
				
				if (attribute.finalExpectedValue == null) {
					attribute.loadFinalExpectedValue();
				}
				
				ret = ret && (attribute.finalExpectedValue ==  attribute.actualValue);
			}
			return ret;
		}
		public function compareAttributesMT(targetVO:TargetVO):String {
			var ret:Boolean = true;
			var actualValues:String = "";
			for each (var attribute:AttributeVO in attributes) {
				attribute.setActualValueForTargetVO(targetVO);
				
				if (attribute.finalExpectedValue == null) {
					attribute.loadFinalExpectedValue();
				}
				actualValues += attribute.actualValue;
				ret = ret && (attribute.finalExpectedValue ==  attribute.actualValue);
			}
			if(ret == true)
			         return null;
			else
				return actualValues;
		}
		public function compareAttributesMTRegEx(targetVO:TargetVO):String {
			for each (var attribute:AttributeVO in attributes) {
				attribute.setActualValueForTargetVO(targetVO);
				
				if (attribute.finalExpectedValue == null) {
					attribute.loadFinalExpectedValue();
				}
				var pattern:RegExp = new RegExp(attribute.finalExpectedValue);
				var result:Object = pattern.exec(attribute.actualValue);
				if(result == null) {
					return attribute.actualValue;
				}
			}
			return null;
		}
        //
        // clone
        //

        public function clone():VerifyMonkeyCommand {
            var copy:VerifyMonkeyCommand = new VerifyMonkeyCommand();
            setParentCloneProps(copy);

            copy.snapshotURL = snapshotURL;
            copy.value = value;
            copy.prop = prop;
            copy.containerValue = containerValue;
            copy.containerProp = containerProp;
            copy.verifyBitmap = verifyBitmap;
            copy.verifyBitmapFuzziness = verifyBitmapFuzziness;
            copy.attributes = ObjectUtil.copy(attributes) as ArrayCollection;

            return copy;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Verify Component";
        }


        override public function get labelAdditionalInfo():String {
            return timeOut;
        }


        //
        // FlexMonkium
        //

        // Currently only used by FlexMonkium
        public function getActualValueForAttribute(index:int):String {
            if (index >= attributes.length || index < 0) {
                return "Index out of bounds: " + index;
            }

            var attribute:AttributeVO = attributes.getItemAt(index) as AttributeVO;

            if (!target.hasOwnProperty(attribute.name)) {
                return "No such property: " + attribute.name;
            }

            return this.target[attribute.name].toString();
        }

    }
}