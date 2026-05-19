package com.dchoc.dollars.model.userdata
{
   import com.adobe.serialization.json.JSON;
   import com.dchoc.dollars.server.*;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import flash.events.*;
   import flash.net.*;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class SocialFacebook extends Social
   {
      
      public static const GRAPH_API_URL:String = "https://graph.facebook.com";
      
      public static const API_URL:String = "https://api.facebook.com";
      
      private var mUserInfoSlot_timeOutId:Object = new Object();
      
      private var mIsFanTimeOutId:int = -1;
      
      private var mFacebookAppId:String;
      
      private var mGetFriendListRetryCount:int = 0;
      
      private var mGetAppFriendListUrlLoader:URLLoader;
      
      private var mUserInfoSlot_Loader:Object = new Object();
      
      private var mUserInfoSlot_userIDs:Object = new Object();
      
      private var mGetAppFriendListRetryCount:int = 0;
      
      private var mUserInfoSlot_retryCount:Object = new Object();
      
      private const RETRIES:int = 5;
      
      private var mUserInfoSlot_totalRetryCount:int = 0;
      
      private const MAX_USERS_IN_ONE_REQUEST:int = 100;
      
      private const TIME_OUT:int = 30000;
      
      private var mUserInfo_allInfoSuccess:Boolean = true;
      
      private var mOAuthToken:String;
      
      private var mGetFriendListTimeOutId:int = -1;
      
      private var mIsFanLoader:URLLoader;
      
      private var mPageId:String;
      
      private var mGetAppFriendListTimeOutId:int = -1;
      
      private var mGetFriendListUrlLoader:URLLoader;
      
      private var mUserInfoSlot_result:Object = new Object();
      
      public function SocialFacebook()
      {
         super();
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         this.mFacebookAppId = _loc1_.facebook_app_id;
         this.mOAuthToken = _loc1_.oauth_token;
         if(this.mFacebookAppId == null || this.mOAuthToken == null)
         {
            this.trace("All needed info not present in FlashVars -> cannot continue");
            return;
         }
      }
      
      protected function getAppFriendListComplete(param1:Event) : void
      {
         var _loc8_:Array = null;
         var _loc9_:uint = 0;
         this.trace("getAppFriendListComplete");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.getAppFriendListComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getAppFriendListError);
         clearTimeout(this.mGetAppFriendListTimeOutId);
         var _loc3_:String = URLLoader(param1.target).data;
         this.trace("getAppFriendListComplete: data: " + _loc3_);
         var _loc4_:Object = com.adobe.serialization.json.JSON.decode(_loc3_);
         this.trace("getAppFriendListComplete: " + _loc4_);
         var _loc5_:Array = new Array();
         if(_loc4_ is Array)
         {
            this.trace("getAppFriendListComplete: json is array");
            _loc8_ = _loc4_ as Array;
            _loc9_ = 0;
            while(_loc9_ < _loc4_.length)
            {
               _loc5_.push(_loc4_[_loc9_]);
               this.trace("getAppFriendListComplete: pushed");
               _loc9_++;
            }
         }
         var _loc6_:Object = new Object();
         _loc6_._cmd = "get_app_friends_list";
         _loc6_._dat = _loc5_;
         var _loc7_:SocialEvent = new SocialEvent(ServerEvent.onCommandResponse,_loc6_);
         dispatchEvent(_loc7_);
         UserDataFacade.smNeighborListLoadedSuccessful = true;
      }
      
      protected function isFanError(param1:Event) : void
      {
         this.trace("isFanError");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.isFanComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.isFanError);
         clearTimeout(this.mIsFanTimeOutId);
         var _loc3_:Boolean = false;
         var _loc4_:Object = new Object();
         _loc4_._cmd = "is_fan";
         _loc4_._dat = _loc3_;
         var _loc5_:SocialEvent = new SocialEvent(ServerEvent.onCommandResponse,_loc4_);
         dispatchEvent(_loc5_);
         MyMetrics.send_GA_metric("FB_Requests","isFan() fail","error");
      }
      
      override public function getUserInfo(param1:Array) : void
      {
         var _loc4_:* = 0;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc2_:int = this.MAX_USERS_IN_ONE_REQUEST;
         var _loc3_:* = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = _loc2_;
            _loc5_ = new Array();
            while(_loc3_ < param1.length && _loc4_ > 0)
            {
               _loc5_.push(param1[_loc3_++]);
               _loc4_--;
            }
            _loc6_ = "pack" + _loc3_;
            this.mUserInfoSlot_userIDs[_loc6_] = _loc5_;
            this.mUserInfoSlot_result[_loc6_] = null;
            this.mUserInfoSlot_timeOutId[_loc6_] = -1;
            this.mUserInfoSlot_retryCount[_loc6_] = 0;
            this.getUserInfoSlot(_loc6_);
         }
      }
      
      override public function isFan(param1:String, param2:String) : void
      {
         this.trace("isFan");
         var _loc3_:String = API_URL + "/method/pages.isFan?format=json&page_id=" + param2 + "&access_token=" + this.mOAuthToken;
         this.mPageId = param2;
         this.mIsFanLoader = new URLLoader();
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         this.mIsFanLoader.addEventListener(Event.COMPLETE,this.isFanComplete);
         this.mIsFanLoader.addEventListener(IOErrorEvent.IO_ERROR,this.isFanError);
         this.mIsFanLoader.load(_loc4_);
         this.trace("isFan " + _loc3_);
         this.mIsFanTimeOutId = setTimeout(this.isFanTimeout,this.TIME_OUT,this.mIsFanLoader);
      }
      
      private function isFanTimeout(param1:URLLoader) : void
      {
         this.trace("isFanTimeout");
         param1.removeEventListener(Event.COMPLETE,this.isFanComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.isFanError);
         clearTimeout(this.mIsFanTimeOutId);
         this.mIsFanTimeOutId = -1;
         var _loc2_:Boolean = false;
         var _loc3_:Object = new Object();
         _loc3_._cmd = "is_fan";
         _loc3_._dat = _loc2_;
         var _loc4_:SocialEvent = new SocialEvent(ServerEvent.onCommandResponse,_loc3_);
         dispatchEvent(_loc4_);
         MyMetrics.send_GA_metric("FB_Requests","isFan() fail","timeout");
      }
      
      protected function getAppFriendListError(param1:Event) : void
      {
         this.trace("getAppFriendListError");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.getAppFriendListComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getAppFriendListError);
      }
      
      override public function getAppFriendList() : void
      {
         this.trace("getAppFriendList");
         var _loc1_:String = API_URL + "/method/friends.getAppUsers?format=json&access_token=" + this.mOAuthToken;
         this.mGetAppFriendListUrlLoader = new URLLoader();
         var _loc2_:URLRequest = new URLRequest(_loc1_);
         this.mGetAppFriendListUrlLoader.addEventListener(Event.COMPLETE,this.getAppFriendListComplete);
         this.mGetAppFriendListUrlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.getAppFriendListError);
         this.mGetAppFriendListUrlLoader.load(_loc2_);
         this.trace("getAppFriendList " + _loc1_);
         this.mGetAppFriendListTimeOutId = setTimeout(this.getAppFriendListTimeout,this.TIME_OUT,this.mGetAppFriendListUrlLoader);
         if(this.mGetAppFriendListRetryCount == 0)
         {
         }
      }
      
      protected function getFriendListComplete(param1:Event) : void
      {
         this.trace("getFriendListComplete");
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.getFriendListComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getFriendListError);
         clearTimeout(this.mGetFriendListTimeOutId);
         var _loc3_:String = URLLoader(param1.target).data;
         var _loc4_:Object = com.adobe.serialization.json.JSON.decode(_loc3_);
         this.trace("getFriendListComplete: " + _loc4_);
         var _loc5_:Array = _loc4_.data;
         this.trace("getFriendListComplete: data " + _loc5_);
         var _loc6_:Array = new Array();
         var _loc7_:uint = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc6_.push(_loc5_[_loc7_].id);
            _loc7_++;
         }
         var _loc8_:Object = new Object();
         _loc8_._cmd = "get_friends_list";
         _loc8_._dat = _loc6_;
         var _loc9_:SocialEvent = new SocialEvent(ServerEvent.onCommandResponse,_loc8_);
         dispatchEvent(_loc9_);
         UserDataFacade.smFriendListLoadedSuccessful = true;
      }
      
      private function getUserInfoSlot(param1:String) : void
      {
         this.trace("getUserInfo");
         var _loc2_:Array = this.mUserInfoSlot_userIDs[param1];
         var _loc3_:String = API_URL + "/method/users.getInfo?format=json&uids=" + _loc2_.join(",") + "&fields=first_name,last_name,pic_square,locale&access_token=" + this.mOAuthToken;
         var _loc4_:URLLoader = new URLLoader();
         _loc4_.addEventListener(Event.COMPLETE,this.getUserInfoComplete);
         _loc4_.addEventListener(IOErrorEvent.IO_ERROR,this.getUserInfoError);
         this.mUserInfoSlot_Loader[param1] = _loc4_;
         _loc4_.load(new URLRequest(_loc3_));
         this.mUserInfoSlot_timeOutId[param1] = setTimeout(this.getUserInfoTimeout,this.TIME_OUT,_loc4_);
         this.trace("getUserInfo " + _loc3_);
      }
      
      private function getUserInfoSlotReceived(param1:String, param2:Array, param3:Boolean) : void
      {
         var _loc5_:Object = null;
         var _loc6_:SocialEvent = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         this.mUserInfo_allInfoSuccess = this.mUserInfo_allInfoSuccess && param3;
         this.mUserInfoSlot_result[param1] = param2;
         var _loc4_:Array = new Array();
         for(param1 in this.mUserInfoSlot_result)
         {
            if(this.mUserInfoSlot_result[param1] == null)
            {
               return;
            }
            _loc7_ = this.mUserInfoSlot_result[param1];
            _loc8_ = 0;
            while(_loc8_ < _loc7_.length)
            {
               _loc4_.push(_loc7_[_loc8_]);
               _loc8_++;
            }
         }
         _loc5_ = new Object();
         _loc5_._cmd = "get_user_info";
         _loc5_._dat = _loc4_;
         _loc6_ = new SocialEvent(ServerEvent.onCommandResponse,_loc5_);
         dispatchEvent(_loc6_);
         if(!this.mUserInfo_allInfoSuccess)
         {
            MyMetrics.send_GA_metric("FB_Requests","getUsersInfo() failed");
         }
      }
      
      private function getFriendListTimeout(param1:URLLoader) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:SocialEvent = null;
         this.trace("getFriendListTimeout");
         param1.removeEventListener(Event.COMPLETE,this.getFriendListComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.getFriendListError);
         clearTimeout(this.mGetFriendListTimeOutId);
         this.mGetFriendListTimeOutId = -1;
         if(++this.mGetFriendListRetryCount <= this.RETRIES)
         {
            this.getFriendList();
         }
         else
         {
            _loc2_ = new Array();
            _loc3_ = new Object();
            _loc3_._cmd = "get_friends_list";
            _loc3_._dat = _loc2_;
            _loc4_ = new SocialEvent(ServerEvent.onCommandResponse,_loc3_);
            dispatchEvent(_loc4_);
            MyMetrics.send_GA_metric("FB_Requests","getFriendList() failed");
         }
      }
      
      override public function getAPIPictureURL(param1:String) : String
      {
         return SocialFacebook.GRAPH_API_URL + "/" + param1 + "/picture";
      }
      
      protected function getUserInfoError(param1:Event) : void
      {
         this.trace("getUserInfoError");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.getUserInfoComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getUserInfoError);
      }
      
      private function getAppFriendListTimeout(param1:URLLoader) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:SocialEvent = null;
         this.trace("getFriendListTimeout");
         param1.removeEventListener(Event.COMPLETE,this.getAppFriendListComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.getAppFriendListError);
         clearTimeout(this.mGetAppFriendListTimeOutId);
         this.mGetAppFriendListTimeOutId = -1;
         if(++this.mGetAppFriendListRetryCount <= this.RETRIES)
         {
            this.getAppFriendList();
         }
         else
         {
            _loc2_ = new Array();
            _loc3_ = new Object();
            _loc3_._cmd = "get_app_friends_list";
            _loc3_._dat = _loc2_;
            _loc4_ = new SocialEvent(ServerEvent.onCommandResponse,_loc3_);
            dispatchEvent(_loc4_);
            MyMetrics.send_GA_metric("FB_Requests","getNeighborList() failed");
         }
      }
      
      private function trace(param1:String) : void
      {
         if(Config.DEBUG_FACEBOOK)
         {
            Debug.trace("[FB] " + param1);
         }
      }
      
      private function getUserInfoTimeout(param1:URLLoader) : void
      {
         var _loc3_:String = null;
         this.trace("getUserInfoTimeout");
         param1.removeEventListener(Event.COMPLETE,this.getUserInfoComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.getUserInfoError);
         var _loc2_:String = null;
         for(_loc3_ in this.mUserInfoSlot_Loader)
         {
            if(this.mUserInfoSlot_Loader[_loc3_] == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ != null)
         {
            clearTimeout(this.mUserInfoSlot_timeOutId[_loc2_]);
            this.mUserInfoSlot_timeOutId[_loc2_] = -1;
            ++this.mUserInfoSlot_retryCount[_loc2_];
            if(int(this.mUserInfoSlot_retryCount[_loc2_]) <= this.RETRIES)
            {
               ++this.mUserInfoSlot_totalRetryCount;
               this.getUserInfoSlot(_loc2_);
            }
            else
            {
               this.getUserInfoSlotReceived(_loc2_,new Array(),false);
            }
         }
      }
      
      protected function getFriendListError(param1:Event) : void
      {
         this.trace("getFriendListError");
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.getFriendListComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getFriendListError);
      }
      
      override public function getFriendList() : void
      {
         this.trace("getFriendList");
         var _loc1_:String = GRAPH_API_URL + "/me/friends?access_token=" + this.mOAuthToken;
         this.mGetFriendListUrlLoader = new URLLoader();
         var _loc2_:URLRequest = new URLRequest(_loc1_);
         this.mGetFriendListUrlLoader.addEventListener(Event.COMPLETE,this.getFriendListComplete);
         this.mGetFriendListUrlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.getFriendListError);
         this.mGetFriendListUrlLoader.load(_loc2_);
         this.trace("getFriendList " + _loc1_);
         this.mGetFriendListTimeOutId = setTimeout(this.getFriendListTimeout,this.TIME_OUT,this.mGetFriendListUrlLoader);
         if(this.mGetFriendListRetryCount == 0)
         {
         }
      }
      
      protected function isFanComplete(param1:Event) : void
      {
         this.trace("isFanComplete");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.isFanComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.isFanError);
         clearTimeout(this.mIsFanTimeOutId);
         var _loc3_:String = URLLoader(param1.target).data;
         this.trace("isFanComplete: data: " + _loc3_);
         var _loc4_:Object = com.adobe.serialization.json.JSON.decode(_loc3_);
         this.trace("isFanComplete: " + _loc4_);
         var _loc5_:Boolean = false;
         if(_loc4_ != null)
         {
            if(!_loc4_.hasOwnProperty("error_code") && Boolean(_loc4_))
            {
               _loc5_ = true;
            }
         }
         var _loc6_:Object = new Object();
         _loc6_._cmd = "is_fan";
         _loc6_._dat = _loc5_;
         var _loc7_:SocialEvent = new SocialEvent(ServerEvent.onCommandResponse,_loc6_);
         dispatchEvent(_loc7_);
      }
      
      protected function getUserInfoComplete(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:uint = 0;
         this.trace("getUserInfoComplete");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.getUserInfoComplete);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.getUserInfoError);
         var _loc3_:String = null;
         for(_loc4_ in this.mUserInfoSlot_Loader)
         {
            if(this.mUserInfoSlot_Loader[_loc4_] == _loc2_)
            {
               _loc3_ = _loc4_;
               break;
            }
         }
         if(_loc3_ != null)
         {
            clearTimeout(this.mUserInfoSlot_timeOutId[_loc3_]);
            _loc5_ = new Array();
            _loc6_ = URLLoader(param1.target).data;
            this.trace("getUserInfoComplete: " + _loc6_);
            _loc7_ = com.adobe.serialization.json.JSON.decode(_loc6_);
            this.trace("getUserInfoComplete: " + _loc7_);
            _loc8_ = 0;
            while(_loc8_ < _loc7_.length)
            {
               _loc5_.push(_loc7_[_loc8_]);
               _loc8_++;
            }
            this.getUserInfoSlotReceived(_loc3_,_loc5_,true);
         }
      }
   }
}

