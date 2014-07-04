package com.gorillalogic.utils {

	import com.gorillalogic.flexmonkey.model.ApplicationModel;
	import com.gorillalogic.flexmonkey.model.ProjectTestModel;
	import com.gorillalogic.flexmonkey.vo.TXVO;

	import flash.display.DisplayObject;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Alert;

	public class MonkeyConnection extends EventDispatcher {

		protected static const COMM_FAILURE_PREFIX:String = "Communication Failure: ";
		protected var model:ApplicationModel = ApplicationModel.instance;

		public function MonkeyConnection(target:IEventDispatcher=null) {
			super(target);

			ChangeWatcher.watch(model, "isConnected", isConnectedChangeHandler);
		}

		protected function startConnection():void {

			// set up TX channel and announce
			initializeTXChannel();

			// set up RX Channel listen
			initializeRXChannel();

			// how long to wait before declaring a communications failure and resetting the channel
			// this should be adjusted if we expect even longer operations
			pingRXTimer = new Timer(5000, 0);
			pingRXTimer.addEventListener(TimerEvent.TIMER, pingRXHandler, false, 0, true);

			// how often to send pings to partner
			pingTXTimer = new Timer(500, 0);
			pingTXTimer.addEventListener(TimerEvent.TIMER, pingTXHandler, false, 0, true);

			isConnectedChangeHandler(null);
		}

		protected var txChannelName:String;
		protected var rxChannelName:String;
		protected var writeConsole:Function;

		protected var pingTXTimer:Timer;
		protected var txConnection:LocalConnection;
		private var txCount:uint = 1;

		protected var pingRXTimer:Timer;
		protected var rxConnection:LocalConnection;
		private var rxCount:uint = 1;

		protected function isConnectedChangeHandler(event:Event):void {
			if (pingRXTimer != null) {
				if (ApplicationModel.instance.isConnected) {
					//writeConsole("Connected and timing");
					pingRXTimer.start();
					rxAlive = true;
				} else {
					//writeConsole("Disconnected");
					pingRXTimer.stop();
					rxAlive = false;

					try {
						rxConnection.close();
					} catch (error:ArgumentError) {
						writeConsole("Error closing rxConnection");
					}
					initializeRXChannel();
				}
			}
		}

		public function ack(count:uint):void {
			if (!ApplicationModel.instance.isConnected) {
				ApplicationModel.instance.isConnected = true;
			}
			rxAlive = true;

			if (txQueue.length > 0 && txQueue[ 0 ].txCount == count) {
				txQueue.shift();
				pingCount = 0;

				if (txQueue.length > 0) {
					coreSend(txQueue[ 0 ]);
				}
			}
			//writeConsole(txChannelName + " ack'd w txQueue.length=" + txQueue.length + " and txCount=" + count);
		}

		// Called over the "_agent" channel by another SWF wanting to take over the console connection
		public function drop():void {
			try {
				rxConnection.close();
			} catch (e:Error) {
				// If we were closed already, don't worry about it
				//trace("MonkeyConnection.drop: " + e);
			}
			pingTXTimer.stop();
			pingRXTimer.stop();
			Alert.show("This SWF is no longer connected to the FlexMonkey console.\nThe connection was grabbed by another SWF.");
		}

		public function disconnect():void {
			writeConsole(txChannelName + ":Disconnected");
			txQueue = [];
			ApplicationModel.instance.isConnected = false;
		}

		private var _rxAlive:Boolean = false;

		protected function get rxAlive():Boolean {
			return _rxAlive;
		}

		protected function set rxAlive(a:Boolean):void {
			_rxAlive = a;

			if (_rxAlive) {
				if (!ApplicationModel.instance.isConnected) {
					ApplicationModel.instance.isConnected = true;
				}
			}
		}

		public function ping():void {
			if (!ApplicationModel.instance.isConnected) {
				ApplicationModel.instance.isConnected = true;
			} else {
				rxAlive = true;
			}
		}

		public function initializeRXChannel():void {
			initializeRXChannel0();
			initializeRXChannel1();
		}

		protected function initializeRXChannel0():void {
			// Channels are named for their listener
			rxConnection = new LocalConnection();
			rxConnection.allowDomain('*');
			rxConnection.addEventListener(StatusEvent.STATUS, rxConnectionStatusHandler);
			rxConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			rxConnection.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			rxConnection.client = this;
		}

		protected function rxConnectionStatusHandler(event:StatusEvent):void {
			if (event.level == "error") {
				commFailed(event.code);
			}
		}

		protected function initializeRXChannel1():void {
			try {
				rxConnection.connect(rxChannelName);
			} catch (e:Error) {
				// Another SWF is already using the connection. Tell them to drop it.
				rxConnection.send(rxChannelName, "drop");

				// Give the other SWF a bit of time to drop, and then try to reconnect.
				// On Mac, this code seems to work up to about 8 tabs in Firefox, but only 2 in Chrome and Safari.
				// There seems to be an issue in Chrome/Safari with suspending the execution of SWF's or localconnections when a Tab is not active
				// so we send the "drop" to the swf holding the connection, but he doesn't receive it because he's running in an inactive tab.
				writeConsole("Could not connect to RX channel. Retrying.");
				var t:Timer = new Timer(2000, 3);
				t.addEventListener(TimerEvent.TIMER, function():void {
					try {
						rxConnection.connect(rxChannelName);
						t.stop();
					} catch (error:ArgumentError) {
						//
						writeConsole("Could not connect to " + rxChannelName + ": " + error.message);
					}
				});
				t.start();
			}
		}

		public function initializeTXChannel():void {
			txConnection = new LocalConnection();
			txConnection.allowDomain('*');
			txConnection.addEventListener(StatusEvent.STATUS, txStatusEventHandler);
			txConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			txConnection.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
		}

		protected function pingRXHandler(event:TimerEvent):void {
			if (rxAlive) {
				rxAlive = false;
			} else {
				//writeConsole("RX Disconnected (ping timeout)");
				ApplicationModel.instance.isConnected = false;
			}
		}

		protected function pingTXHandler(event:TimerEvent):void {
			send(new TXVO(txChannelName, "ping"));
		}

		private function txStatusEventHandler(event:StatusEvent):void {
			switch (event.level) {
				case "status":
					break;
				case "error": {
					if (ApplicationModel.instance.isConnected) {
						ApplicationModel.instance.isConnected = false;
					}
					break;
				}
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			writeConsole("AsyncErrorEvent" + event.text);
			commFailed(event.text);
		}

		private function IOErrorHandler(event:IOErrorEvent):void {
			writeConsole("IOErrorEvent" + event.text);
			commFailed(event.text);
		}

		private var txQueue:Array = [];

		private var pingCount:uint = 0;
		private var resendPingCount:uint = 2;

		protected function send(txVO:TXVO):void {
			if (txVO.method == "ping" ||
				txVO.method == "ack" ||
				txVO.method == "disconnect") {
				if (txVO.method == "ping" || txVO.method == "disconnect") {
					txConnection.send(txVO.channel, txVO.method);
				} else {
					txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ]);
				}

				if (txVO.method == "ping") {
					if (txQueue.length != 0) {
						pingCount++;

						if (!(pingCount < resendPingCount)) {
							coreSend(txQueue[ 0 ]);
							pingCount = 0;
						}
					} else {
						pingCount = 0;
					}
				}
				return;
			}
			txQueue.push(txVO);

			if (txQueue.length < 2) {
				coreSend(txVO);
			}
		}

		private function coreSend(txVO:TXVO):void {
			if (ApplicationModel.instance.isConnected) {
				if (txVO.txCount == 0) {
					txCount++;
					txVO.txCount = txCount;
				}

				try {
					if (txVO.arguments != null) {
						switch (txVO.arguments.length) {
							case 0: {
								writeConsole("send method received empty arguments");
							}
							case 1: {
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ], txVO.txCount);
								break;
							}
							case 2: {
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ], txVO.arguments[ 1 ], txVO.txCount);
								break;
							}
							case 3: {
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ], txVO.arguments[ 1 ], txVO.arguments[ 2 ], txVO.txCount);
								break;
							}
							case 4: {
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ], txVO.arguments[ 1 ], txVO.arguments[ 2 ], txVO.arguments[ 3 ], txVO.txCount);
								break;
							}
							case 5: {
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[ 0 ], txVO.arguments[ 1 ], txVO.arguments[ 2 ], txVO.arguments[ 3 ], txVO.arguments[ 4 ], txVO.txCount);
								break;
							}

							default: {
								writeConsole("send method received too many arguments");
							}
						}
					} else {
						txConnection.send(txVO.channel, txVO.method, txVO.txCount);
					}
				} catch (e:Error) {
					writeConsole("Could not send " + txVO.method);
					return;
				}

				// Adding this shift since txQueue.length < 2 test in send method above was never true.
				// although not doing it wasn't causing any obvious issues
				txQueue.shift();

					//writeConsole("Sending " + txVO.method + " to " + txVO.channel + " w/TXCount=" + txVO.txCount);
			}
		}

		public function sendDisconnect():void {
			send(new TXVO(txChannelName, "disconnect"));
			txQueue = [];
		}

		protected function sendAck(count:uint):void {
			send(new TXVO(txChannelName, "ack", [ count ]));
		}

		//
		// send and receive large object ... used to deal with 40k data limit on localconnection
		//

		protected var writeByteArray:ByteArray;
		protected var trackingTxCount:uint = 0;

		protected function loadObj(incomingByteArray:ByteArray,
			status:String,
			incomingTxCount:uint):Object {

			sendAck(incomingTxCount);
			rxAlive = true;

			if (trackingTxCount == incomingTxCount) {
				return null;
			}
			trackingTxCount = incomingTxCount;

			if (status == "single") {
				return incomingByteArray.readObject();
			} else if (status == "start") {
				writeByteArray = new ByteArray();
				incomingByteArray.readBytes(writeByteArray);
				return null;
			} else if (status == "body") {
				incomingByteArray.readBytes(writeByteArray, writeByteArray.length);
				return null;
			} else if (status == "end") {
				incomingByteArray.readBytes(writeByteArray, writeByteArray.length);
				return writeByteArray.readObject();
			}

			return null;
		}

		public function sendObj(txChannelName:String, methodName:String, obj:Object):void {
			var ba:ByteArray = new ByteArray();
			ba.writeObject(obj);

			ba.position = 0;
			var bufferSize:uint = 40000;

			if (ba.bytesAvailable < bufferSize) {
				send(new TXVO(txChannelName, methodName, [ ba, "single" ]));
			} else {
				var buffer:ByteArray = new ByteArray();
				ba.readBytes(buffer, 0, bufferSize);
				send(new TXVO(txChannelName, methodName, [ buffer, "start" ]));

				while (ba.bytesAvailable >= bufferSize) {
					buffer = new ByteArray();
					ba.readBytes(buffer, 0, bufferSize);
					send(new TXVO(txChannelName, methodName, [ buffer, "body" ]));
				}

				if (ba.bytesAvailable > 0) {
					buffer = new ByteArray();
					ba.readBytes(buffer);
					send(new TXVO(txChannelName, methodName, [ buffer, "end" ]));
				}
			}
		}

		protected function commFailed(details:String):void {
		}
	}
}