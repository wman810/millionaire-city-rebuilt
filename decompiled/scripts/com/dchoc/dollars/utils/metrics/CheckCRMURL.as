package com.dchoc.dollars.utils.metrics
{
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class CheckCRMURL extends EventDispatcher
   {
      
      protected var mXmlDoc:XML;
      
      public function CheckCRMURL()
      {
         super();
      }
      
      protected function readUrl(param1:String) : void
      {
         var _loc2_:URLRequest = new URLRequest(param1);
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.load(_loc2_);
         _loc3_.addEventListener(Event.COMPLETE,this.checkStatus);
         _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
      }
      
      protected function checkStatus(param1:Event) : void
      {
      }
      
      protected function onIOError(param1:IOErrorEvent) : void
      {
         Debug.trace("File Error");
      }
   }
}

