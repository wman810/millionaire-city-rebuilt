package com.dchoc.dollars.model
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class ReadXMLAction extends ModelAction
   {
      
      protected var mSig:String = "";
      
      protected var mFileName:String;
      
      public function ReadXMLAction(param1:String)
      {
         super();
         this.mFileName = param1;
         this.loadXML(param1);
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.completeHandler);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoad);
         var _loc3_:XML = new XML(_loc2_.data);
         this.fromXML(_loc3_);
         if(Config.SIG_WHOLE_FILE)
         {
            RulesFacade.getInstance().sigRegister(this.mFileName,_loc2_.data as String);
         }
         else
         {
            RulesFacade.getInstance().sigRegister(this.mFileName,this.mSig);
         }
         this.doCompleteHandler(param1);
         mIsFinished = true;
      }
      
      private function loadXML(param1:String) : void
      {
         var request:URLRequest;
         var fileName:String = param1;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.completeHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoad,false,0,true);
         request = new URLRequest(fileName);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + fileName + " document.");
         }
      }
      
      protected function doCompleteHandler(param1:Event) : void
      {
      }
      
      protected function fromXML(param1:XML) : void
      {
      }
      
      private function errorLoad(param1:IOErrorEvent) : void
      {
         throw new Error("ERROR: ReadXMLAction: loading error: " + param1);
      }
   }
}

