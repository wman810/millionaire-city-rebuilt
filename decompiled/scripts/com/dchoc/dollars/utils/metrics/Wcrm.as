package com.dchoc.dollars.utils.metrics
{
   import flash.events.*;
   import flash.net.*;
   import flash.xml.XMLDocument;
   
   public class Wcrm
   {
      
      private var m_crossPromotionCallback:Function;
      
      public function Wcrm()
      {
         super();
      }
      
      private function openHandler(param1:Event) : void
      {
         trace("openHandler: " + param1);
      }
      
      private function onCrossPromotionSplashComplete(param1:Event) : void
      {
         var _loc3_:XMLDocument = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         trace("completeHandler: " + _loc2_.data);
         if(this.m_crossPromotionCallback != null)
         {
            _loc3_ = new XMLDocument(_loc2_.data);
            this.m_crossPromotionCallback(_loc3_);
            this.m_crossPromotionCallback = null;
         }
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         trace("ioErrorHandler: " + param1);
      }
      
      private function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         trace("securityErrorHandler: " + param1);
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         trace("httpStatusHandler: " + param1);
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         trace("completeHandler: " + _loc2_.data);
      }
      
      private function wcrmGetServer() : String
      {
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         if(_loc1_.wcrm_server == undefined || _loc1_.wcrm_server == null)
         {
            return "https://crm.digitalchocolate.com";
         }
         return _loc1_.wcrm_server;
      }
      
      private function wcrmInternalTrackEvent(param1:String, param2:int, param3:int, param4:String, param5:String, param6:String, param7:String, param8:String, param9:int, param10:String, param11:String, param12:String, param13:String, param14:String, param15:String, param16:String, param17:int, param18:String, param19:String, param20:String, param21:String, param22:int, param23:int, param24:int, param25:int, param26:int, param27:int, param28:int, param29:int, param30:int, param31:int, param32:int, param33:int, param34:int, param35:int, param36:int, param37:int, param38:String, param39:int, param40:int, param41:int, param42:int, param43:int, param44:String, param45:String) : void
      {
         var loader:URLLoader;
         var request:URLRequest;
         var now:Date;
         var userParameters:String = param1;
         var env:int = param2;
         var project_id:int = param3;
         var event:String = param4;
         var group:String = param5;
         var label:String = param6;
         var other_user_id:String = param7;
         var other_user_id_fb:String = param8;
         var parent_event_id:int = param9;
         var p1:String = param10;
         var p2:String = param11;
         var p3:String = param12;
         var p4:String = param13;
         var p5:String = param14;
         var src:String = param15;
         var ref:String = param16;
         var level:int = param17;
         var product:String = param18;
         var product_detail:String = param19;
         var campaign_source:String = param20;
         var campaign_channel:String = param21;
         var resource_1_delta:int = param22;
         var resource_1_balance:int = param23;
         var resource_1_total:int = param24;
         var game_currency_delta:int = param25;
         var game_currency_balance:int = param26;
         var game_currency_total:int = param27;
         var paid_currency_delta:int = param28;
         var paid_currency_balance:int = param29;
         var paid_currency_total:int = param30;
         var real_currency_delta:int = param31;
         var real_currency_balance:int = param32;
         var real_currency_total:int = param33;
         var friends_total:int = param34;
         var application_friends_total:int = param35;
         var is_fan:int = param36;
         var is_bookmarked:int = param37;
         var session_id:String = param38;
         var session_duration:int = param39;
         var session_accumulated_time:int = param40;
         var nanos_delta:int = param41;
         var nanos_balance:int = param42;
         var nanos_total:int = param43;
         var ref_uid:String = param44;
         var swf_version:String = param45;
         var params:String = userParameters + "&project_id=" + project_id + "&event=" + event + "&group=" + group + "&env=" + env;
         if(label != null)
         {
            params += "&label=" + label;
         }
         if(other_user_id != null)
         {
            params += "&other_user_id=" + other_user_id;
         }
         if(other_user_id_fb != null)
         {
            params += "&other_user_id_fb=" + other_user_id_fb;
         }
         if(p1 != null)
         {
            params += "&p1=" + p1;
         }
         if(p2 != null)
         {
            params += "&p2=" + p2;
         }
         if(p3 != null)
         {
            params += "&p3=" + p3;
         }
         if(p4 != null)
         {
            params += "&p4=" + p4;
         }
         if(p5 != null)
         {
            params += "&p5=" + p5;
         }
         if(src != null)
         {
            params += "&src=" + src;
         }
         if(ref != null)
         {
            params += "&ref=" + ref;
         }
         if(ref_uid != null)
         {
            params += "&ref_uid=" + ref_uid;
         }
         if(product != null)
         {
            params += "&product=" + product;
         }
         if(product_detail != null)
         {
            params += "&product_detail=" + product_detail;
         }
         if(campaign_source != null)
         {
            params += "&campaign_source=" + campaign_source;
         }
         if(campaign_channel != null)
         {
            params += "&campaign_channel=" + campaign_channel;
         }
         if(session_id != null)
         {
            params += "&session_id=" + session_id;
         }
         if(swf_version != null)
         {
            params += "&version=" + swf_version;
         }
         params += "&parent_event_id=" + parent_event_id;
         params += "&level=" + level;
         params += "&resource_1_delta=" + resource_1_delta;
         params += "&resource_1_balance=" + resource_1_balance;
         params += "&resource_1_total=" + resource_1_total;
         params += "&game_currency_delta=" + game_currency_delta;
         params += "&game_currency_balance=" + game_currency_balance;
         params += "&game_currency_total=" + game_currency_total;
         params += "&paid_currency_delta=" + paid_currency_delta;
         params += "&paid_currency_balance=" + paid_currency_balance;
         params += "&paid_currency_total=" + paid_currency_total;
         params += "&real_currency_delta=" + real_currency_delta;
         params += "&real_currency_balance=" + real_currency_balance;
         params += "&real_currency_total=" + real_currency_total;
         params += "&friends_total=" + friends_total;
         params += "&application_friends_total=" + application_friends_total;
         params += "&is_fan=" + is_fan;
         params += "&is_bookmarked=" + is_bookmarked;
         params += "&session_duration=" + session_duration;
         params += "&session_accumulated_time=" + session_accumulated_time;
         params += "&nanos_delta=" + nanos_delta;
         params += "&nanos_balance=" + nanos_balance;
         params += "&nanos_total=" + nanos_total;
         now = new Date();
         params += "&ts=" + Math.round(now.valueOf() / 1000);
         loader = new URLLoader();
         this.configureListeners(loader);
         request = new URLRequest(this.wcrmGetServer() + "/event/track?" + params);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load requested document.");
         }
      }
      
      public function wcrmSendCrossPromotionSplashRequest(param1:String, param2:String, param3:String, param4:Function) : void
      {
         var loader:URLLoader;
         var request:URLRequest;
         var facebookId:String = param1;
         var projectId:String = param2;
         var signature:String = param3;
         var callBack:Function = param4;
         this.m_crossPromotionCallback = callBack;
         loader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.onCrossPromotionSplashComplete);
         loader.addEventListener(Event.OPEN,this.openHandler);
         loader.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         request = new URLRequest("http://crm.digitalchocolate.com/user_projects/ingame_xp?project_id=" + projectId + "&fb_user_id=" + facebookId + "&sig=" + signature);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load requested document.");
         }
      }
      
      public function wcrmTrackEventFbUserId(param1:String, param2:int, param3:int, param4:String, param5:String, param6:String, param7:String, param8:String, param9:int, param10:String, param11:String, param12:String, param13:String, param14:String, param15:String, param16:String, param17:int, param18:String, param19:String, param20:String, param21:String, param22:int, param23:int, param24:int, param25:int, param26:int, param27:int, param28:int, param29:int, param30:int, param31:int, param32:int, param33:int, param34:int, param35:int, param36:int, param37:int, param38:String, param39:int, param40:int, param41:int, param42:int, param43:int, param44:String, param45:String) : void
      {
         var _loc46_:String = "fb_user_id=" + param1;
         this.wcrmInternalTrackEvent(_loc46_,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15,param16,param17,param18,param19,param20,param21,param22,param23,param24,param25,param26,param27,param28,param29,param30,param31,param32,param33,param34,param35,param36,param37,param38,param39,param40,param41,param42,param43,param44,param45);
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
         trace("progressHandler loaded:" + param1.bytesLoaded + " total: " + param1.bytesTotal);
      }
   }
}

