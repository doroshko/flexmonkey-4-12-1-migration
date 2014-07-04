package com.gorillalogic.monkeylink {

    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.events.PayloadEvent;
    import com.gorillalogic.flexmonkey.events.RecordEvent;
    import com.gorillalogic.flexmonkey.model.ApplicationModel;
    import com.gorillalogic.flexmonkey.monkeyCommands.CallFunctionMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.SetPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.StoreValueMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyGridMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyPropertyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.TXVO;
    import com.gorillalogic.flexmonkey.vo.TargetVO;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;
    import com.gorillalogic.utils.MonkeyConnection;

    import flash.events.Event;
    import flash.utils.ByteArray;

    [Event(name="envPayloadEvent", type="com.gorillalogic.flexmonkey.events.PayloadEvent")]
    [Event(name="applicationAutomationTreePayloadEvent", type="com.gorillalogic.flexmonkey.events.PayloadEvent")]
    public class MonkeyLinkConsoleConnectionController extends MonkeyConnection implements IFMController {

        static public var instance:MonkeyLinkConsoleConnectionController;

        private var recordingActive:Boolean = false;

        private var getStoreValueCommandCallback:Function;
        private var getSetPropertyCommandCallback:Function;
        private var getVerifyTargetCallback:Function;
        private var getVerifyPropCallback:Function;
        private var verifyGridCallback:Function;
        private var runCommandCallback:Function;
        private var componentSelectionCallback:Function;
        private var versionCallBack:Function;

        private var isSetPropertyCommandRunning:Boolean;
        private var isStoreValueCommandRunning:Boolean;
        private var isVerifyRunning:Boolean;
        private var isVerifyGridRunning:Boolean;
        private var isVerifyPropRunning:Boolean;
        private var isCommandRunning:Boolean;

        private var currentRunnable:MonkeyRunnable;
        private var currentVerify:MonkeyRunnable;

        public function MonkeyLinkConsoleConnectionController() {
            instance = this;
            txChannelName = "_agent";
            rxChannelName = "_flexMonkey";
            writeConsole = function(message:String):void {
                //trace(message);
            }
            super();
            super.startConnection();
            init();
        }

        public function register(hub:FMHub):void {
        }

        private function init():void {
            pingTXTimer.start();
        }

        //
        // overrides
        //

        override public function disconnect():void {
            super.disconnect();
        }

        override public function sendDisconnect():void {
            if (ApplicationModel.instance.isConnected) {
                super.sendDisconnect();
            }
        }

        override protected function isConnectedChangeHandler(event:Event):void {
            super.isConnectedChangeHandler(event);

            if (ApplicationModel.instance.isConnected && recordingActive) {
                // If a new SWF just connected and the console is in recording mode, tell the newly loaded SWF to start recroding
                trace("New SWF connected in recording mode.");
                startRecording();
            }
        }

        override protected function commFailed(details:String):void {
            if (isVerifyRunning) {
                getVerifyTargetCallback(null, currentVerify, COMM_FAILURE_PREFIX + details);
            } else if (isVerifyPropRunning) {
                getVerifyPropCallback(null, currentVerify, COMM_FAILURE_PREFIX + details);
            } else if (isVerifyGridRunning) {
                verifyGridCallback(null, currentVerify, COMM_FAILURE_PREFIX + details);
            } else if (isCommandRunning) {
                runCommandCallback(currentRunnable, COMM_FAILURE_PREFIX + details);
            } else if (isSetPropertyCommandRunning) {
                getSetPropertyCommandCallback(currentRunnable, COMM_FAILURE_PREFIX + details);
            } else if (isStoreValueCommandRunning) {
                getStoreValueCommandCallback(currentRunnable, COMM_FAILURE_PREFIX + details);
            }
        }

        //
        // recording communicaton
        //

        public function startRecording():void {
            send(new TXVO("_agent", "startRecording"));
            recordingActive = true;
        }

        public function stopRecording():void {
            send(new TXVO("_agent", "stopRecording"));
            recordingActive = false;
        }

        public function selectComponent(callBack:Function):void {
            componentSelectionCallback = callBack;
            send(new TXVO("_agent", "selectComponent"));
        }

        public function cancelComponentSelection():void {
            send(new TXVO("_agent", "cancelComponentSelection"));
        }

        //
        // ui event commands comm
        //

        public function respondNewUIEvent(ba:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);

            if (ApplicationModel.instance.isRecording) {
                var uiEventMonkeyCommand:UIEventMonkeyCommand = loadObj(ba, status, txCount) as UIEventMonkeyCommand;

                if (uiEventMonkeyCommand != null) {
                    writeConsole("BrowserConnection: New UI Event");
                    FMHub.instance.dispatchEvent(new RecordEvent(RecordEvent.NEW_UI_EVENT, uiEventMonkeyCommand));
                }
            }
        }

        public function respondUiCommandReturn(ba:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(ba, status, txCount) as Array;

            if (args != null) {
                var command:UIEventMonkeyCommand = args[0] as UIEventMonkeyCommand;
                var errorMessage:String = args[1] as String;

                writeConsole("BrowserConnection: uiCommandReturn");
                runCommandCallback(currentRunnable, errorMessage);
                isCommandRunning = false;
            }
        }

        public function requestRunCommand(c:UIEventMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                runCommandCallback = callBack;
                currentRunnable = c;
                var clone:UIEventMonkeyCommand = c.clone();
                clone.parent = null;
                isCommandRunning = true;
                sendObj("_agent", "respondRunCommand", clone);
            } else {
                callBack(currentRunnable, COMM_FAILURE_PREFIX + "not connected");
            }
        }

        //
        // verify comm
        //

        public function respondNewSnapshot(ba:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var uiEventMonkeyCommand:UIEventMonkeyCommand = loadObj(ba, status, txCount) as UIEventMonkeyCommand;

            if (uiEventMonkeyCommand != null && componentSelectionCallback != null) {
                componentSelectionCallback(uiEventMonkeyCommand);
            }
        }

        public function respondNewTarget(baArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);

            var args:Array = loadObj(baArray, status, txCount) as Array;

            if (args != null) {
                var targetVO:TargetVO;
                var errorMessage:String = args[1] as String;
                var verify:VerifyMonkeyCommand = args[2] as VerifyMonkeyCommand;

                if (args[0] != null) {
                    targetVO = args[0] as TargetVO;
                    targetVO.snapshotVO.createBitmap();
                }

                getVerifyTargetCallback(targetVO, currentVerify, errorMessage);
                isVerifyRunning = false;
            }
        }

        public function requestVerifyTarget(verifyMonkeyCommand:VerifyMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                getVerifyTargetCallback = callBack;
                currentVerify = verifyMonkeyCommand;
                var clone:VerifyMonkeyCommand = verifyMonkeyCommand.clone();
                clone.parent = null;
                isVerifyRunning = true;
                sendObj("_agent", "getVerifyTarget", clone);
            } else {
                callBack(null, currentVerify, COMM_FAILURE_PREFIX + "not connected");
            }
        }

        public function requestLoadComponentProperties(verifyMonkeyCommand:VerifyMonkeyCommand, callBack:Function):void {
            getVerifyTargetCallback = callBack;
            var clone:VerifyMonkeyCommand = verifyMonkeyCommand.clone();
            clone.parent = null;
            sendObj("_agent", "loadComponentProperties", clone);
        }

        //
        // verify prop
        //

        public function requestVerifyProp(cmd:VerifyPropertyMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                getVerifyPropCallback = callBack;
                currentVerify = cmd;
                var clone:VerifyPropertyMonkeyCommand = cmd.clone();
                clone.parent = null;
                isVerifyPropRunning = true;
                sendObj("_agent", "getVerifyProp", clone);
            } else {
                callBack(null, currentVerify, COMM_FAILURE_PREFIX + "not connected");
            }

        }

        public function respondVerifyProp(baArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(baArray, status, txCount) as Array;

            if (args != null) {
                var actualValue:Object = args[0];
                var errorMessage:String = args[1] as String;
                var verify:VerifyPropertyMonkeyCommand = args[2] as VerifyPropertyMonkeyCommand;
                getVerifyPropCallback(actualValue, currentVerify, errorMessage);
                isVerifyPropRunning = false;
            }
        }

        //
        // verify grid comm
        //

        public function requestGridCell(verifyGridMonkeyCommand:VerifyGridMonkeyCommand, callback:Function):void {
            if (model.isConnected) {
                verifyGridCallback = callback;
                currentVerify = verifyGridMonkeyCommand;
                var clone:VerifyGridMonkeyCommand = verifyGridMonkeyCommand.clone();
                clone.parent = null;
                isVerifyGridRunning = true;
                sendObj("_agent", "respondGridCell", clone);
            } else {
                callback(null, currentVerify, COMM_FAILURE_PREFIX + "not connected");
            }

        }

        public function respondGridCell(ba:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(ba, status, txCount) as Array;

            if (args != null) {
                var actualValue:String = args[0] as String;
                var errorMessage:String = args[1] as String;
                var verify:VerifyGridMonkeyCommand = args[2] as VerifyGridMonkeyCommand;

                writeConsole('BrowserConnection: receive returnGridCell - actualValue="' + actualValue + '"');
                verifyGridCallback(actualValue, currentVerify, errorMessage);
                isVerifyGridRunning = false;
            }
        }

        //
        // SetPropertyMonkeyCommand logic
        //

        public function requestSetPropertyCommand(cmd:SetPropertyMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                getSetPropertyCommandCallback = callBack;
                currentRunnable = cmd;
                var clone:SetPropertyMonkeyCommand = cmd.clone();
                clone.parent = null;
                isSetPropertyCommandRunning = true;
                sendObj("_agent", "respondSetPropertyCommand", clone);
            } else {
                callBack(currentRunnable, COMM_FAILURE_PREFIX + "not connected");
            }
        }

        public function respondSetPropertyCommand(baArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(baArray, status, txCount) as Array;

            if (args != null) {
                var clone:Object = args[0];
                var errorMessage:String = args[1] as String;
                getSetPropertyCommandCallback(currentRunnable, errorMessage);
                isSetPropertyCommandRunning = false;
            }
        }

        //
        // Store Value logic
        //

        public function requestStoreValueCommand(cmd:StoreValueMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                getStoreValueCommandCallback = callBack;
                currentRunnable = cmd;
                var clone:StoreValueMonkeyCommand = cmd.clone();
                clone.parent = null;
                isStoreValueCommandRunning = true;
                sendObj("_agent", "respondStoreValueCommand", clone);
            } else {
                callBack(currentRunnable, COMM_FAILURE_PREFIX + "not connected");
            }
        }

        public function respondStoreValueCommand(baArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(baArray, status, txCount) as Array;

            if (args != null) {
                var clone:Object = args[0];
                var actualValue:String = args[1];
                var errorMessage:String = args[2] as String;
                getStoreValueCommandCallback(currentRunnable, actualValue, errorMessage);
                isStoreValueCommandRunning = false;
            }
        }

        //
        // Call Function logic
        //

        public function requestCallFunctionCommand(cmd:CallFunctionMonkeyCommand, callBack:Function):void {
            if (model.isConnected) {
                runCommandCallback = callBack;
                currentRunnable = cmd;
                var clone:CallFunctionMonkeyCommand = cmd.clone();
                clone.parent = null;
                isCommandRunning = true;
                sendObj("_agent", "respondCallFunctionCommand", clone); //
            } else {
                callBack(currentRunnable, COMM_FAILURE_PREFIX + "not connected");
            }
        }

        public function respondCallFunctionCommand(baArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var args:Array = loadObj(baArray, status, txCount) as Array;

            if (args != null) {
                var clone:Object = args[0];
                var errorMessage:String = args[1] as String;
                runCommandCallback(currentRunnable, errorMessage);
                isCommandRunning = false;
            }
        }

        //
        // env file comm
        //

        public function requestEnvFile():void {
            send(new TXVO("_agent", "requestLoadEnvFile"));
        }

        public function respondLoadEnvFile(incomingByteArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var obj:Object = loadObj(incomingByteArray, status, txCount);

            if (obj != null) {
                dispatchEvent(new PayloadEvent("envPayloadEvent", obj));
            }
        }

        //
        // automation tree communication
        //

        public function requestApplicationAutomationTree():void {
            send(new TXVO("_agent", "requestLoadApplicationAutomationTree"));
        }

        public function respondLoadApplicationAutomationTree(incomingByteArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var obj:Object = loadObj(incomingByteArray, status, txCount);

            if (obj != null) {
                dispatchEvent(new PayloadEvent("applicationAutomationTreePayloadEvent", obj));
            }
        }

        //
        // version number
        //

        public function requestMonkeyLinkVersionNumber(_versionCallBack:Function):void {
            versionCallBack = _versionCallBack;
            send(new TXVO("_agent", "requestMonkeyLinkVersionNumber"));
        }

        public function respondMonkeyLinkVersionNumber(incomingByteArray:ByteArray, status:String, txCount:uint):void {
            sendAck(txCount);
            var obj:Object = loadObj(incomingByteArray, status, txCount);

            if (obj != null) {
                versionCallBack(obj[0]);
            } else {
                versionCallBack("Unable to find FlexMonkey library version number.");
            }
        }

    }
}
