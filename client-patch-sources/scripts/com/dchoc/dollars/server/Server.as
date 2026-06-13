package com.dchoc.dollars.server
{
   import com.adobe.serialization.json.JSON;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.hud.HudOwner;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.utils.System;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   public class Server extends EventDispatcher
   {
      
      private static const CACHE_UPDATES_MIN_TIME:int = 2000;
      
      private static const CACHE_UPDATES_MAX_TIME:int = 7000;
      
      private static const MAX_CMDS_IN_ONE_PACKET:int = 15;
      
      private static const PACKET_RETRY_TIMEOUT:int = 20000;
      
      private static const PACKET_NO_RESPONSE_TIMEOUT:int = 2 * 60000;
      
      private static const RETRY_COUNTS_TO_PAUSE_GAMEPLAY:int = 2;
      
      private static const RETRY_COUNTS_TO_LOGOUT_GAMEPLAY:int = 3;
      
      private static const LOGIN_RETRY_TIMEOUT:int = 5000;
      
      private static const PING_UPDATES_COUNTS:int = 15;
      
      private static const PING_UPDATES_TIME:int = 15000;
      
      private static const PERMANENT_UPDATES_ENABLED:Boolean = false;
      
      private static const PERMANENT_UPDATES_TIME:int = 10000;
      
      public static var wcrmServerURL:String = "";
      
      private var mPingUpdatesCount:int = 0;
      
      private var mLoginRetriesCount:int = 0;
      
      private var mCache:Array = new Array();
      
      private var mLoginRetryTimer:int = 0;
      
      private var mPass:String;
      
      private var mCacheUpdatesMinTimer:int = 0;
      
      private var mPacketNoResponseTimer:int = 0;
      
      private var mPaymentCommandToBeSent:Object;
      
      private var mSync:int;
      
      private var mPingUpdatesTimer:int = 0;
      
      public var mForceSendAllNow:Boolean = false;
      
      private var mCMDcnt:int = 1;
      
      private var mRetryUploadCommands:Boolean = false;
      
      private var mLogged:Boolean;
      
      private var wcrmMakeVisibleAfterAt:int;
      
      private var mCacheUpdatesMaxTimer:int = 0;
      
      private var messageCnt:int = 0;
      
      private var mPacketCmdList:Object;
      
      private var mNick:String;
      
      private var mStartTime:Number;
      
      private var mRetriesCount:int = 0;
      
      private var mLogoutDone:Boolean;
      
      private var mPermanentUpdatesTimer:int = 0;
      
      public function Server()
      {
         super();
         this.mLogged = false;
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         wcrmServerURL = _loc1_.wcrm_server;
         var _loc2_:int = int(_loc1_.wcrm_visible_at);
         this.wcrmMakeVisibleAfterAt = _loc2_ * 1000;
         this.externalTaskInit();
      }
      
      public static function XMLToObjectGetChildren(param1:XMLList) : Array
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:XMLList = null;
         var _loc7_:uint = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc2_:Array = new Array();
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length())
         {
            _loc4_ = param1[_loc3_].name();
            _loc5_ = new Object();
            _loc6_ = param1[_loc3_].attributes();
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length())
            {
               _loc8_ = _loc6_[_loc7_].name();
               _loc9_ = _loc6_[_loc7_].valueOf();
               _loc5_[_loc8_] = _loc9_;
               _loc7_++;
            }
            if(param1.elements().length() > 0)
            {
               _loc5_[_loc4_] = XMLToObjectGetChildren(param1[_loc3_].elements());
            }
            else
            {
               _loc5_[_loc4_] = new Array();
            }
            _loc2_.push(_loc5_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function objectToXMLString(param1:Object) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:String = null;
         if(param1 is Object)
         {
            _loc2_ = "Name";
            _loc3_ = "";
            _loc4_ = "";
            _loc5_ = true;
            for(_loc6_ in param1)
            {
               _loc5_ = false;
               if(param1[_loc6_] is Array)
               {
                  _loc2_ = _loc6_;
                  _loc7_ = uint(param1[_loc6_].length);
                  _loc8_ = 0;
                  while(_loc8_ < _loc7_)
                  {
                     _loc4_ += objectToXMLString(param1[_loc6_][_loc8_]);
                     _loc8_++;
                  }
               }
               else
               {
                  _loc9_ = param1[_loc6_];
                  _loc3_ += " " + _loc6_ + "=\"" + _loc9_ + "\"";
               }
            }
            if(!_loc5_)
            {
               if(_loc4_.length > 0)
               {
                  return "<" + _loc2_ + _loc3_ + ">\n" + _loc4_ + "\n</" + _loc2_ + ">";
               }
               return "<" + _loc2_ + _loc3_ + "/>";
            }
         }
         return "";
      }
      
      public static function objectToXML(param1:Object) : XML
      {
         return new XML(objectToXMLString(param1));
      }
      
      public static function XMLToObject(param1:XML) : Object
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:String = param1.name();
         var _loc3_:Object = new Object();
         var _loc4_:XMLList = param1.attributes();
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_.length())
         {
            _loc7_ = _loc4_[_loc5_].name();
            _loc8_ = _loc4_[_loc5_].valueOf();
            _loc3_[_loc7_] = _loc8_;
            _loc5_++;
         }
         var _loc6_:XMLList = param1.elements();
         _loc3_[_loc2_] = XMLToObjectGetChildren(_loc6_);
         return _loc3_;
      }
      
      private function sendPacketNow() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.mLogged)
         {
            if(this.mCache.length == 0 && this.mPacketCmdList == null)
            {
               if(!PERMANENT_UPDATES_ENABLED)
               {
                  return;
               }
               _loc3_ = new Object();
               _loc3_._cmd = "empty";
               _loc3_._dat = new Object();
               _loc3_._cnt = this.mCMDcnt++;
               this.mCache.push(_loc3_);
            }
            this.mRetryUploadCommands = false;
            Debug.trace("** Server Request (" + this.messageCnt + ") >>>>");
            _loc1_ = null;
            if(this.mPacketCmdList == null)
            {
               this.mPacketCmdList = new Object();
               _loc1_ = new Array();
            }
            else
            {
               _loc1_ = this.mPacketCmdList._cmdList;
               if(this.mCache.length > 0)
               {
                  this.mPacketCmdList.retry = this.mCache[0]._cnt;
               }
               else
               {
                  this.mPacketCmdList.retry = 0;
               }
            }
            _loc2_ = MAX_CMDS_IN_ONE_PACKET;
            while(this.mCache.length > 0)
            {
               _loc1_.push(this.mCache.shift());
               if(--_loc2_ <= 0)
               {
                  break;
               }
            }
            this.mPacketCmdList._cmdList = _loc1_;
            this.mPacketCmdList._msgCount = this.messageCnt;
            this.mPacketCmdList._sync = this.mSync;
            if(this.mPingUpdatesCount > 0)
            {
               this.mPacketCmdList.ping = 1;
            }
            this.uploadCommands("cmdList",this.mPacketCmdList);
            this.mStartTime = System.currentTimeMillis();
         }
      }
      
      public function externalTaskRequest(param1:String, param2:Object = null) : void
      {
         var _loc3_:String = null;
         if(param2 == null)
         {
            param2 = new Object();
         }
         Debug.trace("--=> Server.externalTaskRequest(" + param1 + ")");
         Debug.traceObject(param2);
         if(ExternalInterface.available)
         {
            _loc3_ = com.adobe.serialization.json.JSON.encode(param2);
            ExternalInterface.call("flashRequest_Received",param1,_loc3_);
         }
      }
      
      public function logout() : void
      {
         this.mLogoutDone = true;
         this.mLogged = false;
      }
      
      public function sendQuery(param1:String, param2:Object) : void
      {
         this.sendCommand(param1,param2);
         this.mForceSendAllNow = true;
      }
      
      public function sendCommand(param1:String, param2:Object) : void
      {
         var _loc3_:Object = new Object();
         _loc3_._cmd = param1;
         _loc3_._dat = param2;
         _loc3_._cnt = this.mCMDcnt++;
         if(this.mCache.length == 0 && this.mCacheUpdatesMinTimer == 0)
         {
            this.mCacheUpdatesMinTimer = CACHE_UPDATES_MIN_TIME;
            this.mCacheUpdatesMaxTimer = CACHE_UPDATES_MAX_TIME;
         }
         else if(this.mCacheUpdatesMaxTimer > 0)
         {
            this.mCacheUpdatesMinTimer = Math.max(this.mCacheUpdatesMinTimer,CACHE_UPDATES_MIN_TIME);
         }
         this.mCache.push(_loc3_);
      }
      
      private function externalTaskInit() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("externalTaskResponse",this.externalTaskResponse);
            ExternalInterface.addCallback("videoAdAvailableResponse",this.videoAdAvailableResponse);
            ExternalInterface.addCallback("videoAdCompleteResponse",this.videoAdCompleteResponse);
            ExternalInterface.addCallback("videoAdIncompleteResponse",this.videoAdIncompleteResponse);
         }
         else
         {
            Debug.trace("--=> Server.externalTaskInit: ExternalInterface available? " + ExternalInterface.available);
         }
      }
      
      protected function uploadCommands(param1:String, param2:Object) : void
      {
         this.mPacketNoResponseTimer = PACKET_NO_RESPONSE_TIMEOUT;
      }
      
      public function videoAdCompleteResponse() : void
      {
         Debug.trace("---InGame Video Ad----: Movie Complete");
         CustomizerManager.getInstance().setVideoAdEnabled(false);
         DollarsGame.externalRequest(DollarsGame.REQ_RESUME_SOUND);
         this.sendCommand("get_storage_list",{});
         ExternalInterface.call("checkInGameAd");
      }
      
      public function externalFunctionCall(param1:String, param2:Object = null) : void
      {
         var _loc3_:String = null;
         if(param2 == null)
         {
            param2 = new Object();
         }
         Debug.trace("--=> Server.externalTaskRequest(" + param1 + ")");
         Debug.traceObject(param2);
         if(ExternalInterface.available)
         {
            _loc3_ = com.adobe.serialization.json.JSON.encode(param2);
            ExternalInterface.call(param1,_loc3_);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.mLoginRetryTimer > 0 && (this.mLoginRetryTimer = this.mLoginRetryTimer - param1) <= 0)
         {
            this.mLoginRetryTimer = 0;
            this.login(this.mNick,this.mPass);
            return;
         }
         if(this.mCacheUpdatesMaxTimer > 0 && (this.mCacheUpdatesMaxTimer = this.mCacheUpdatesMaxTimer - param1) <= 0)
         {
            this.mCacheUpdatesMaxTimer = 0;
         }
         if(this.mCacheUpdatesMinTimer > 0 && (this.mCacheUpdatesMinTimer = this.mCacheUpdatesMinTimer - param1) <= 0)
         {
            this.mCacheUpdatesMinTimer = 0;
            this.mForceSendAllNow = true;
         }
         if(this.mPingUpdatesCount > 0)
         {
            this.mPingUpdatesTimer -= param1;
            if(this.mPingUpdatesTimer <= 0)
            {
               this.sendCommand("ping",{});
               this.mForceSendAllNow = true;
               --this.mPingUpdatesCount;
               this.mPingUpdatesTimer = PING_UPDATES_TIME;
            }
         }
         if(PERMANENT_UPDATES_ENABLED)
         {
            this.mPermanentUpdatesTimer -= param1;
            if(this.mPermanentUpdatesTimer <= 0)
            {
               this.mPermanentUpdatesTimer = PERMANENT_UPDATES_TIME;
               this.mForceSendAllNow = true;
            }
         }
         if(this.mForceSendAllNow)
         {
            this.mForceSendAllNow = false;
            if(this.mPacketCmdList != null && !this.mRetryUploadCommands)
            {
               this.mCacheUpdatesMinTimer = Math.max(this.mCacheUpdatesMinTimer,CACHE_UPDATES_MIN_TIME);
               return;
            }
            this.sendPacketNow();
            if(this.mCache.length == 0)
            {
               this.mCacheUpdatesMinTimer = 0;
            }
            else
            {
               this.mCacheUpdatesMinTimer = Math.max(this.mCacheUpdatesMinTimer,CACHE_UPDATES_MIN_TIME);
            }
            if(PERMANENT_UPDATES_ENABLED)
            {
               this.mPermanentUpdatesTimer = PERMANENT_UPDATES_TIME;
            }
         }
         if(this.mPacketNoResponseTimer > 0 && (this.mPacketNoResponseTimer = this.mPacketNoResponseTimer - param1) <= 0)
         {
            this.mPacketNoResponseTimer = 0;
            Debug.trace("*** Server not responded in a long time ***");
            MyMetrics.send_GA_metric("OutOfSync","Client: Server not responded in a long time");
            this.logout();
            DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
         }
         if(this.serverIsBusy() == 2 && this.mPaymentCommandToBeSent != null)
         {
            this.mPaymentCommandToBeSent._msgCount = this.messageCnt;
            this.uploadCommands("payments",this.mPaymentCommandToBeSent);
            this.mPaymentCommandToBeSent = null;
         }
         if(Tutorial.smTutorialEnd)
         {
            if(this.wcrmMakeVisibleAfterAt > 0 && (this.wcrmMakeVisibleAfterAt = this.wcrmMakeVisibleAfterAt - param1) <= 0)
            {
               this.wcrmMakeVisibleAfterAt = 0;
               this.externalTaskRequest("showCRM",{});
            }
         }
      }
      
      public function isLogged() : Boolean
      {
         return this.mLogged;
      }
      
      private function externalTaskResponse(param1:String, param2:String = null) : void
      {
         var _loc5_:Array = null;
         Debug.trace("--> externalTaskResponse: ");
         Debug.trace("JavaScript Response: " + param1);
         if(param1 == null)
         {
            return;
         }
         var _loc3_:Object = new Object();
         var _loc4_:Array = param1.split(":");
         if(param1 == "ping")
         {
            this.sendQuery("ping",{});
         }
         else if(param1 == "pingCurrency")
         {
            this.mPingUpdatesCount = PING_UPDATES_COUNTS;
            this.externalTaskRequest(UserDataFacade.TASK_FACEBOOK_CREDITS_GET_BALANCE,{});
         }
         else if(param1.search("sendGift") != -1)
         {
            _loc5_ = param1.split(":");
            CollectibleManager.getInstance().giveCollectible(_loc5_[1]);
            if(Boolean(PopupCollectibleManager.getInstance().smPopupCollectibleShop) && PopupCollectibleManager.getInstance().smPopupCollectibleShop.isOpen())
            {
               PopupCollectibleManager.getInstance().smPopupCollectibleShop.refreshGroups();
            }
         }
         else if(param1 == "investmentResponse")
         {
            DollarsGame.externalRequest(DollarsGame.REQ_POST_INVERSION,{"extIds":param2});
         }
         else if(param1 == "HideGame")
         {
            Dollars.focusGame(false);
         }
         else if(param1 == "ShowGame")
         {
            Dollars.focusGame(true);
         }
         else if(param1 == "RequestLevel")
         {
            DollarsGame.externalRequest(DollarsGame.REQ_LEVEL);
         }
         else if(_loc4_[0] == "messageResponseFacebookCredits")
         {
            FBCreditsPurchase.getInstance().endPurchaseProcess(_loc4_[1],false);
         }
         else if(_loc4_[0] == "fbcreditsCurrentBalance")
         {
            DollarsGame.getProfile().setFacebookCredits(int(_loc4_[1]),int(_loc4_[2]));
            if(DollarsGame.smFakeCredtisInfoShowed == 1 && DollarsGame.getProfile().facebookCreditsNotSpent > 0)
            {
               DollarsGame.externalRequest(DollarsGame.REQ_FAKE_CREDITS_INFO);
            }
         }
         else if(_loc4_[0] == "localStatsUpdate")
         {
            this.applyLocalStatsUpdate(_loc4_);
         }
         else if(param1 == "localProfileUpdate")
         {
            this.applyLocalProfileUpdate(param2);
         }
         else if(_loc4_[0] == "addVideoReward")
         {
            this.videoAdCompleteResponse();
         }
         else if(DollarsGame.smInstance.messagesAddMessage(param1))
         {
         }
      }
      
      private function applyLocalStatsUpdate(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:uint = 1;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(param1.length < 8)
         {
            return;
         }
         _loc2_ = DollarsGame.getProfile();
         if(_loc2_ == null)
         {
            return;
         }
         _loc3_ = Number(param1[1]);
         _loc4_ = Number(param1[2]);
         _loc5_ = Number(param1[3]);
         _loc6_ = uint(Math.max(1,Number(param1[4])));
         _loc7_ = Number(param1[5]);
         _loc8_ = Number(param1[6]);
         _loc9_ = Number(param1[7]);
         if(isNaN(_loc3_) || isNaN(_loc4_) || isNaN(_loc5_) || isNaN(Number(param1[4])) || isNaN(_loc7_) || isNaN(_loc8_) || isNaN(_loc9_))
         {
            return;
         }
         _loc2_.setDCCoins(Math.max(0,_loc3_));
         _loc2_.setDCCash(uint(Math.max(0,_loc4_)));
         _loc2_.setExp(Math.max(0,_loc5_));
         _loc2_.level = _loc6_;
         _loc2_.minExp = Math.max(0,_loc7_);
         _loc2_.maxExp = Math.max(_loc2_.minExp,_loc8_);
         _loc2_.companyValue = Math.max(0,_loc9_);
         _loc2_.update();
         UserDataFacade.securityInit();
      }
      
      private function applyLocalProfileUpdate(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         try
         {
            _loc2_ = com.adobe.serialization.json.JSON.decode(param1);
         }
         catch(error:Error)
         {
            return;
         }
         _loc3_ = String(_loc2_.userName);
         _loc4_ = String(_loc2_.cityName);
         _loc5_ = String(_loc2_.profilePictureUrl);
         if(_loc3_ != null && _loc3_.length > 0 && _loc3_ != "undefined")
         {
            UserDataFacade.getInstance().mUserName = _loc3_;
            if(FriendsManager.mNeighborMyself != null)
            {
               FriendsManager.mNeighborMyself.nameFriend = _loc3_;
            }
            if(DollarsGame.getFriendsBar() != null)
            {
               DollarsGame.getFriendsBar().refreshMySelf();
            }
         }
         if(_loc4_ != null && _loc4_.length > 0 && _loc4_ != "undefined")
         {
            if(DollarsGame.getProfile() != null)
            {
               _loc6_ = DollarsGame.getProfile().cityname != _loc4_;
               DollarsGame.getProfile().cityname = _loc4_;
            }
            if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER && DollarsGame.getProfileUniverse() != null)
            {
               DollarsGame.getProfileUniverse().cityname = _loc4_;
               if(DollarsGame.getCurrentWorld() != null && DollarsGame.getCurrentWorld().role != null && DollarsGame.getCurrentWorld().role.hud is HudOwner)
               {
                  HudOwner(DollarsGame.getCurrentWorld().role.hud).setCityName(_loc4_);
               }
               if(_loc6_ && DollarsGame.smInstance != null && DollarsGame.smInstance.mPlane != null)
               {
                  DollarsGame.smInstance.mPlane.removePlane();
                  DollarsGame.smInstance.mPlane.setPlane(DollarsGame.getProfileUniverse().planeSku);
                  DollarsGame.smInstance.mPlane.start(_loc4_);
               }
            }
         }
         if(_loc5_ != null && _loc5_.length > 0 && _loc5_ != "undefined")
         {
            UserDataFacade.getInstance().mUserPhotoUrl = _loc5_;
            if(FriendsManager.mNeighborMyself != null)
            {
               FriendsManager.mNeighborMyself.setPictureURL(_loc5_);
            }
         }
      }
      
      public function videoAdAvailableResponse(param1:Boolean, param2:String) : void
      {
         Debug.trace("---InGame Video Ad----: Movie Available");
         CustomizerManager.getInstance().setVideoAdEnabled(true);
         CustomizerManager.getInstance().setVideoFunctionName(param2);
      }
      
      public function videoAdIncompleteResponse() : void
      {
         Debug.trace("---InGame Video Ad----: Movie Incomplete");
         DollarsGame.externalRequest(DollarsGame.REQ_RESUME_SOUND);
      }
      
      public function sendPayment(param1:Object) : void
      {
         if(this.mPaymentCommandToBeSent != null)
         {
            Debug.trace("Error!! 2 payment commands cannot be set at the same time!");
            return;
         }
         this.mForceSendAllNow = true;
         this.mPaymentCommandToBeSent = param1;
      }
      
      public function externalWCRMRequest(param1:String, param2:String, param3:String, param4:Object) : void
      {
         var _loc5_:String = null;
         if(param4 == null)
         {
            param4 = new Object();
         }
         Debug.trace("--=> Server.externalWCRMRequest()");
         if(ExternalInterface.available)
         {
            _loc5_ = com.adobe.serialization.json.JSON.encode(param4);
            ExternalInterface.call("notifyWCRM_fromFlash",param2,param3,_loc5_);
         }
      }
      
      public function serverIsBusy() : int
      {
         var _loc1_:int = 0;
         if(this.mCache.length == 0)
         {
            if(this.mPacketCmdList == null)
            {
               _loc1_ = 2;
            }
            else
            {
               _loc1_ = 1;
            }
         }
         return _loc1_;
      }
      
      protected function downloadedCommands(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:ServerEvent = null;
         var _loc2_:int = PACKET_NO_RESPONSE_TIMEOUT - this.mPacketNoResponseTimer;
         this.mPacketNoResponseTimer = 0;
         if(param1 != null)
         {
            _loc3_ = int(param1.dataObj._msgCount);
            if(!(_loc3_ == this.messageCnt || _loc3_ < 0))
            {
               Debug.trace("Server Command Response NOT MATCH (" + _loc3_ + ") instead of " + this.messageCnt);
               MyMetrics.send_GA_metric("OutOfSync","Client: packed cnt not match");
               this.logout();
               DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
               return;
            }
            this.mPacketCmdList = null;
            Debug.trace("** Server Response (" + _loc3_ + ") " + (System.currentTimeMillis() - this.mStartTime) + " <<<<");
            _loc4_ = param1.dataObj;
            for each(_loc5_ in _loc4_.list)
            {
               this.processCommand(_loc5_);
               _loc6_ = new ServerEvent(ServerEvent.onCommandResponse,_loc5_);
               dispatchEvent(_loc6_);
            }
            if(this.mLogged && this.mRetriesCount >= RETRY_COUNTS_TO_PAUSE_GAMEPLAY)
            {
               DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_RESUME);
               MyMetrics.send_GA_metric("NetworkBusy","Game Resumed");
            }
            this.mRetriesCount = 0;
         }
         else
         {
            Debug.trace("** Server Response (" + this.messageCnt + ") " + (System.currentTimeMillis() - this.mStartTime) + " <<xx FAILED");
            if(!this.mLogged && !this.mLogoutDone)
            {
               if(this.mLoginRetriesCount++ < RETRY_COUNTS_TO_LOGOUT_GAMEPLAY)
               {
                  this.mLoginRetryTimer = Math.max(1,LOGIN_RETRY_TIMEOUT - _loc2_);
                  Debug.trace("** going to retry LOGIN in " + this.mLoginRetryTimer + " milliseconds");
               }
               else
               {
                  Debug.trace("** impossible to login with server **");
                  MyMetrics.send_GA_metric("OutOfSync","Client: all LOGIN attents failed");
                  this.logout();
                  this.mLoginRetryTimer = 0;
               }
               return;
            }
            ++this.mRetriesCount;
            if(this.mRetriesCount == RETRY_COUNTS_TO_PAUSE_GAMEPLAY)
            {
               DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_PAUSE);
               MyMetrics.send_GA_metric("NetworkBusy","Game Paused");
            }
            else if(this.mRetriesCount > RETRY_COUNTS_TO_LOGOUT_GAMEPLAY)
            {
               this.logout();
               DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
               MyMetrics.send_GA_metric("OutOfSync","Client: all server requests failed");
               MyMetrics.send_GA_metric("NetworkBusy","Game Exit");
               return;
            }
            this.mRetryUploadCommands = true;
            this.mCacheUpdatesMinTimer = Math.max(1,PACKET_RETRY_TIMEOUT - _loc2_);
            Debug.trace("** going to retry: " + this.mRetriesCount + " in " + this.mCacheUpdatesMinTimer + " milliseconds");
         }
         ++this.messageCnt;
      }
      
      public function login(param1:String, param2:String) : void
      {
         this.mNick = param1;
         this.mPass = param2;
         this.mLogged = false;
         Debug.trace(">>>>>>>>>>> Sending LOGIN...");
         this.uploadCommands("login",{
            "nick":param1,
            "pass":param2
         });
      }
      
      private function processCommand(param1:Object) : void
      {
         var _loc2_:String = param1._cmd;
         var _loc3_:Object = param1._dat;
         if(_loc2_ == "logOK")
         {
            Debug.trace(">>>>>>>>>>>>>>>> Login OK <<<<<<<<<<<<<<");
            this.mLogged = true;
            if(_loc3_.hasOwnProperty("token"))
            {
               UserDataFacade.getInstance().mToken = _loc3_.token;
            }
            this.mSync = param1._sync;
            if(_loc3_.hasOwnProperty("currentServerTime"))
            {
               UserDataFacade.getInstance().setServerTimeAtLogin(_loc3_.currentServerTime);
               Debug.trace("currentServerTime: " + _loc3_.currentServerTime);
            }
            else
            {
               Debug.trace("currentServerTime not found");
            }
         }
         else if(_loc2_ == "logKO")
         {
            Debug.trace(">>>>>>>>>>>>>>>> Login FAILED <<<<<<<<<<<<<<");
            this.mLogged = false;
         }
         else if(_loc2_ == "logOut")
         {
            Debug.trace(">>>>>>>>>>>>>>>> LogOut <<<<<<<<<<<<<<");
            this.mLogged = false;
         }
         else if(_loc2_ == "update_item")
         {
            Debug.trace(">>>>>>>>>>>>>>>> update_item ACTION:: " + _loc3_.action);
            if(_loc3_.action == "give_collectible")
            {
               DollarsGame.externalRequest(DollarsGame.REQ_GIVE_COLLECTIBLE,_loc3_);
            }
            if(_loc3_.action == "limEdBuy")
            {
               DollarsGame.externalRequest(DollarsGame.REQ_LIM_ED_RESPONSE,_loc3_);
            }
         }
      }
   }
}

