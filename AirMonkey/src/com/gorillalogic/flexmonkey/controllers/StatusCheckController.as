/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.controllers {

    import com.gorillalogic.flexmonkey.events.ApplicationEvent;
    import com.gorillalogic.flexmonkey.events.StatusCheckEvent;
    import com.gorillalogic.utils.FMFileError;
    import com.gorillalogic.flexmonkey.utils.FMFileUtils;
    import com.gorillalogic.framework.FMHub;
    import com.gorillalogic.framework.IFMController;

    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;

    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;

	/**
	 * AIR API dependencies
	 */ 
    public class StatusCheckController implements IFMController {

        private var service:HTTPService;
        private var lastDate:Date;
        private var lastVersionAcknowledge:String;
        private var latestVersion:String;
        private var installedVersion:String;
        private var newsItems:ArrayCollection;

        private static const STATUS_URL:String = "http://www.gorillalogic.com/flexmonkeyStatus.xml";
        private static const STATUS_PREFERENCE_FILE_URL:String = "statusPreferences.xml";

        public function register(hub:FMHub):void {
            hub.listen(ApplicationEvent.WINDOW_LOADED, checkStatusHandler, this);
            hub.listen(StatusCheckEvent.ACKNOWLEDGE_STATUSES, userViewedStatusHandler, this);
        }

        private function notifyStatusCheck():void {
            if (lastVersionAcknowledge == latestVersion) {
                installedVersion = "";
                latestVersion = "";
            }

            if (installedVersion != latestVersion || newsItems.length > 0) {
                FMHub.instance.dispatchEvent(new StatusCheckEvent(StatusCheckEvent.SHOW_STATUS_WINDOW, installedVersion, latestVersion, newsItems));
            }
        }

        private function doCheckStatus():void {
            var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
            var ns:Namespace = appDescriptor.namespace();
            installedVersion = appDescriptor.ns::versionNumber;

            //filter news items
            newsItems.filterFunction = filterNewsItems;
            newsItems.addEventListener(CollectionEvent.COLLECTION_CHANGE, refreshFinished);
            newsItems.refresh();
        }

        private function refreshFinished(event:Event):void {
            notifyStatusCheck();
        }

        private function filterNewsItems(obj:Object):Boolean {
            if (newsItems == null || obj.itemDate > lastDate) {
                return true;
            }
            return false;
        }

        private function checkStatusHandler(event:Event):void {
            service = new HTTPService();
            service.url = STATUS_URL;
            service.useProxy = false;
            service.method = "GET";
            service.addEventListener(ResultEvent.RESULT, statusCheckServiceResponse);
            service.addEventListener(FaultEvent.FAULT, faultEvent);
            service.send();
        }

        private function faultEvent(faultEvent:FaultEvent):void {
            trace("Failed to load server status: " + faultEvent.fault.faultString);
        }

        private function statusCheckServiceResponse(event:ResultEvent):void {
            latestVersion = event.result.FlexMonkey.currentVersion;
            newsItems = new ArrayCollection();

            for each (var newsItem:Object in event.result.FlexMonkey.newsItem) {
                var d:Date = new Date(Date.parse(newsItem.date));

                if (d.time > Date.parse("1/1/2000")) {
                    var o:Object = { itemDate: d, headline: newsItem.headline, newsInfo: newsItem.info };
                    newsItems.addItem(o);
                }
            }

            loadStatusFile();
        }

        private function loadStatusFile():void {
            FMFileUtils.readFile(File.applicationStorageDirectory.resolvePath(STATUS_PREFERENCE_FILE_URL).nativePath,
                                 openPreferenceFileSuccessHandler,
                                 openPreferenceFileFaultHandler);
        }

        private function openPreferenceFileSuccessHandler(event:Event):void {
            var xml:XML = FMFileUtils.parseXmlFile(event.target as FileStream);
            lastDate = new Date(Date.parse(xml.@lastAcknowledgedDate));
            lastVersionAcknowledge = xml.@lastVersionAcknowledge;
            doCheckStatus();
        }

        private function openPreferenceFileFaultHandler(error:FMFileError):void {
            doCheckStatus();
        }

        private function userViewedStatusHandler(event:Event = null):void {
            var content:XML = <FlexMonkeyStatus lastAcknowledgedDate={new Date().toDateString()} lastVersionAcknowledge={latestVersion} />;
            FMFileUtils.saveFile(File.applicationStorageDirectory.resolvePath(STATUS_PREFERENCE_FILE_URL).nativePath, content.toXMLString());
        }
    }

}
