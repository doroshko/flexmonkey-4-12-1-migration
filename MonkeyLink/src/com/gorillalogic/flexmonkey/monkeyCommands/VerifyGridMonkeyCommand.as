/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.monkeyCommands {

    import com.gorillalogic.flexmonkey.core.*;
    import com.gorillalogic.utils.StoredValueLookup;

//    import mx.controls.AdvancedDataGrid;
//    import mx.controls.DataGrid;
    import mx.core.UIComponent;

    import org.flexunit.asserts.assertEquals;

    [RemoteClass]
    [Bindable]
    public class VerifyGridMonkeyCommand extends MonkeyRunnable implements IVerifyCommand {

        public var row:int = 0;
        public var col:int = 0;
        public var expectedValue:String;
        public var actualValue:String;
        public var failureMessage:String;
        public var finalExpectedValue:Object;

        public function VerifyGridMonkeyCommand(description:String = null,
                                                value:String = null,
                                                prop:String = 'automationName',
                                                row:int = 0,
                                                col:int = 0,
                                                expectedValue:String = '',
                                                containerValue:String = null,
                                                containerProp:String = null,
                                                isRetryable:Boolean = true,
                                                attempts:String = "10",
                                                delay:String = "1000") {

            super(null, isRetryable, delay, attempts, description, value, prop, containerValue, containerProp);

            this.description = description;
            this.row = row;
            this.col = col;
            this.expectedValue = expectedValue;

            if (this.prop == null || this.prop.length == 0) {
                this.prop = 'automationName';
            }
        }

        override public function get thinkTime():uint {
            return MonkeyTest(parent).defaultThinkTime;
        }

        //
        // public apis
        //

        public function loadValue(callback:Function):void {
            var errorMessage:String;
            var actualValue:String;

            try {
                actualValue = getCellValue();
            } catch (error:Error) {
                errorMessage = error.message;
            }

            callback(actualValue, errorMessage);
        }

        public function verify(actualValue:Object):void {
            if (actualValue == null) {
                var msg:String = 'Error finding grid cell at (' + row + ',' + col + ').  Either DataGrid not found at ' + prop + '="' + value + '" or bad row/col value.'
                throw new Error(msg);
            } else {
                if (finalExpectedValue == null) {
                    loadFinalExpectedValue();
                }
                assertEquals(finalExpectedValue, actualValue);
            }
        }

        public function loadFinalExpectedValue():void {
            finalExpectedValue = StoredValueLookup.instance.getExpectedValue(expectedValue);
        }


        public function getCellValue():String {
            //find target
            var target:UIComponent = MonkeyUtils.findComponent(containerValue, containerProp, value, prop);

            //get actualValue out of grid
            var actualValue:String = null;

            if (target == null) {
                throw new Error("Target not found");
                actualValue = null;
            // spark DataGrid arrived in 4.5, but currently building with 4.1, so remove this guard
//            } else if (!(target is DataGrid) && !(target is AdvancedDataGrid) && !(target is spark.components.DataGrid)) {
//                throw new Error("Target is not a DataGrid");
//                actualValue = null;

            } else {
                //removed this guard because rowCount & colCount are only the number of visible rows & cols
                //if (verifyGridMonkeyCommand.row >= 0 && verifyGridMonkeyCommand.row < targetGrid.rowCount && verifyGridMonkeyCommand.col >= 0 && verifyGridMonkeyCommand.col < targetGrid.columnCount) {
                if (row >= 0 && col >= 0) {
                    var data:Array

                    try {
                        //data = targetGrid.automationTabularData.getValues(row, row);
                        // changed to use untyped so it will work with ADG and DG
                        data = target.automationTabularData.getValues(row, row);
                    } catch (error:Error) {
                        throw new Error("VerifyGrid failed: You likely need to override/implement 'get automationValues' for all custom ItemRenderers on the DataGrid.  System Error: " + error.message);
                    }

                    if (data != null && data.length == 1) {
                        var rowData:Array = data[0] as Array;

                        if (rowData != null && rowData.length > col) {
                            actualValue = rowData[col] as String;
                        }
                    }
                }
            }
            return actualValue;
        }

        //
        // clone
        //

        public function clone():VerifyGridMonkeyCommand {
            var copy:VerifyGridMonkeyCommand = new VerifyGridMonkeyCommand(
                description, value, prop, row, col, expectedValue, containerValue, containerProp);

            setParentCloneProps(copy)

            copy.failureMessage = failureMessage;

            return copy;
        }

        override public function isEqualTo(that:Object):Boolean {
            if (that != null && that is VerifyGridMonkeyCommand) {
                return (
                    (this.value == that.value) &&
                    (this.prop == that.prop) &&
                    (this.row == that.row) &&
                    (this.col == that.col) &&
                    (this.expectedValue == that.expectedValue) &&
                    (this.containerValue == that.containerValue) &&
                    (this.containerProp == that.containerProp)
                    );
            }
            return false;
        }

        //
        // label fields
        //

        override public function get typeDesc():String {
            return "Verify Grid";
        }

        override public function get labelAdditionalInfo():String {
            return '(' + row + ',' + col + ')="' + expectedValue + '"';
        }

    }
}