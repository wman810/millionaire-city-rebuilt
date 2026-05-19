package com.dchoc.dollars.utils.metrics
{
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class BAMetrics
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:BAMetrics;
      
      public function BAMetrics()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: BAMetrics Error: Instantiation failed: Use BAMetrics.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : BAMetrics
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new BAMetrics();
            smAllowInstantiation = false;
         }
         return BAMetrics.smInstance;
      }
      
      private function getServer() : String
      {
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         return _loc1_.bartUrl;
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         trace("BAmetrics:completeHandler: " + _loc2_.data);
      }
      
      private function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         trace("BAmetrics:securityErrorHandler: " + param1);
      }
      
      private function openHandler(param1:Event) : void
      {
         trace("BAmetrics:openHandler: " + param1);
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         trace("BAmetrics:ioErrorHandler: " + param1);
      }
      
      private function configureListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.COMPLETE,this.completeHandler);
         param1.addEventListener(Event.OPEN,this.openHandler);
         param1.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
         trace("BAmetrics:progressHandler loaded:" + param1.bytesLoaded + " total: " + param1.bytesTotal);
      }
      
      public function registerEvent(param1:String, param2:String) : void
      {
         var serverURL:String;
         var uri:String = null;
         var request:URLRequest = null;
         var group:String = param1;
         var event:String = param2;
         var loader:URLLoader = new URLLoader();
         this.configureListeners(loader);
         serverURL = this.getServer();
         if(serverURL != null && serverURL != "null")
         {
            uri = serverURL + "/event?game=" + MyMetrics.getProjectId() + "&group=" + group + "&name=" + event;
            request = new URLRequest(uri);
            try
            {
               loader.load(request);
            }
            catch(error:Error)
            {
               trace("BAmetrics:Unable to load requested document.");
            }
         }
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         trace("BAmetrics:httpStatusHandler: " + param1);
      }
   }
}

