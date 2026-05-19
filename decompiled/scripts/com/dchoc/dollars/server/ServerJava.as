package com.dchoc.dollars.server
{
   import com.adobe.crypto.MD5;
   import com.adobe.serialization.json.*;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Utils;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import flash.events.*;
   import flash.net.*;
   import flash.system.Capabilities;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class ServerJava extends Server
   {
      
      private var mRequestPending:Boolean = false;
      
      private var uid:String;
      
      private var version:String;
      
      private var serverVersion:String;
      
      private var url:String;
      
      private var mTimeoutId:int = -1;
      
      private var useSignature:Boolean = true;
      
      private var token:String;
      
      private const TIME_OUT:int = 40000;
      
      private var mCurrentLoader:URLLoader;
      
      public function ServerJava()
      {
         super();
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         this.token = _loc1_.token;
         this.uid = _loc1_.uid;
         this.url = _loc1_.server;
         this.serverVersion = _loc1_.game_version;
         var _loc2_:String = _loc1_.data;
         if(_loc2_ != null && _loc2_.length > 0)
         {
            Config.setRoot(_loc2_);
         }
         this.version = Capabilities.version;
      }
      
      private function listeners(param1:URLLoader, param2:Boolean) : void
      {
         if(param2)
         {
            param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
            param1.addEventListener(Event.COMPLETE,this.completeHandler);
            param1.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
            this.mTimeoutId = setTimeout(this.requestTimeout,this.TIME_OUT,param1);
         }
         else
         {
            clearTimeout(this.mTimeoutId);
            this.mTimeoutId = -1;
            param1.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
            param1.removeEventListener(Event.COMPLETE,this.completeHandler);
            param1.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         }
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         if(param1.status != 200 && param1.status != 0)
         {
            MyMetrics.send_GA_metric("httpRequests","httpStatusHandler","" + param1.status);
         }
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         this.listeners(_loc2_,false);
         if(_loc2_ != this.mCurrentLoader || this.mRequestPending == false)
         {
            MyMetrics.send_GA_metric("httpRequests","old req completed",this.mRequestPending ? "pending" : "not pending");
            return;
         }
         this.mRequestPending = false;
         var _loc3_:XML = new XML(_loc2_.data);
         var _loc4_:String = _loc3_.@service;
         var _loc5_:String = _loc3_.@call_id;
         var _loc6_:int = int(_loc3_.response_code);
         if(_loc6_ != 0)
         {
            Debug.trace("completeHandler: failed: service: " + _loc4_ + ", call_id: " + _loc5_ + ", responseCode:" + _loc6_);
            downloadedCommands(null);
            return;
         }
         if(_loc4_ != "Command")
         {
            Debug.trace("completeHandler: Received response for unknown command (response\'s attribute command): " + _loc4_);
            downloadedCommands(null);
            return;
         }
         var _loc7_:int = int(_loc3_.data.chk);
         var _loc8_:String = _loc3_.data.commands;
         if(!UserDataFacade.chk)
         {
            UserDataFacade.chk = _loc7_ != Utils.getChk(_loc8_);
         }
         var _loc9_:Object = com.adobe.serialization.json.JSON.decode(_loc8_);
         var _loc10_:Object = new Object();
         _loc10_.dataObj = _loc9_;
         downloadedCommands(_loc10_);
      }
      
      private function requestTimeout(param1:URLLoader) : void
      {
         this.listeners(param1,false);
         MyMetrics.send_GA_metric("httpRequests","timeout",param1 == this.mCurrentLoader ? "current " + this.mRequestPending : "old " + this.mRequestPending);
         if(param1 != this.mCurrentLoader || this.mRequestPending == false)
         {
            return;
         }
         this.mRequestPending = false;
         downloadedCommands(null);
      }
      
      private function hashCode(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = 31 * _loc2_ + param1.charCodeAt(_loc4_);
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function createSignature(param1:Object) : String
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc2_:String = "";
         var _loc3_:Array = new Array();
         for(_loc4_ in param1)
         {
            _loc3_.push({
               "key":_loc4_,
               "value":param1[_loc4_]
            });
         }
         _loc3_.sortOn("key",Array.CASEINSENSITIVE);
         _loc5_ = 0;
         for each(_loc6_ in _loc3_)
         {
            _loc2_ = _loc2_ + _loc6_.key + "=" + _loc6_.value;
            if(_loc5_ < _loc3_.length - 1)
            {
               _loc2_ += "&";
            }
            _loc5_++;
         }
         if(UserDataFacade.getInstance().mToken != null)
         {
            this.token = UserDataFacade.getInstance().mToken;
         }
         _loc2_ += this.token;
         _loc2_ += "Host4h";
         return MD5.hash(_loc2_);
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         this.listeners(_loc2_,false);
         MyMetrics.send_GA_metric("httpRequests","ioErrorHandler",_loc2_ == this.mCurrentLoader ? "current " + this.mRequestPending : "old " + this.mRequestPending);
         if(_loc2_ != this.mCurrentLoader || this.mRequestPending == false)
         {
            return;
         }
         this.mRequestPending = false;
         downloadedCommands(null);
      }
      
      override protected function uploadCommands(param1:String, param2:Object) : void
      {
         var params:Object;
         var variables:URLVariables;
         var sig:String = null;
         var key:String = null;
         var request:URLRequest = null;
         var loader:URLLoader = null;
         var cmd:String = param1;
         var cmdList:Object = param2;
         super.uploadCommands(cmd,cmdList);
         params = new Object();
         params.uid = this.uid;
         params.cmd = cmd;
         params.version = this.serverVersion;
         params.data = com.adobe.serialization.json.JSON.encode(cmdList);
         params.flash_version = this.version;
         if(this.useSignature)
         {
            sig = this.createSignature(params);
         }
         else
         {
            sig = "pass";
         }
         variables = new URLVariables();
         for(key in params)
         {
            variables[key] = params[key];
         }
         variables.sig = sig;
         request = new URLRequest(this.url + "/Game");
         request.data = variables;
         request.method = "POST";
         loader = new URLLoader();
         this.mCurrentLoader = loader;
         this.listeners(loader,true);
         try
         {
            loader.load(request);
            this.mRequestPending = true;
         }
         catch(error:Error)
         {
            Debug.trace("sendCommand: failed to send CMD to server: " + error);
            listeners(loader,false);
            MyMetrics.send_GA_metric("httpRequests","request failed","" + error.message);
            downloadedCommands(null);
         }
      }
   }
}

