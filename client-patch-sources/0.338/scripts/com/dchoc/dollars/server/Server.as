package com.dchoc.dollars.server
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.hud.HudOwner;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
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
      
      private var mCache:Array = new Array();
      
      private var mCacheUpdatesMinTimer:int = 0;
      
      private var mCacheUpdatesMaxTimer:int = 0;
      
      private var mPacketCmdList:Object;
      
      private var mPermanentUpdatesTimer:int = 0;
      
      private var mRetriesCount:int = 0;
      
      private var mRetryUploadCommands:Boolean = false;
      
      private var mPacketNoResponseTimer:int = 0;
      
      private var mLoginRetryTimer:int = 0;
      
      private var mLoginRetriesCount:int = 0;
      
      private var mPingUpdatesTimer:int = 0;
      
      private var mPingUpdatesCount:int = 0;
      
      private var mLogged:Boolean;
      
      private var mLogoutDone:Boolean;
      
      private var messageCnt:int = 0;
      
      private var mStartTime:Number;
      
      private var mSync:int;
      
      private var mCMDcnt:int = 1;
      
      private var wcrmMakeVisibleAfterAt:int;
      
      public var mForceSendAllNow:Boolean = false;
      
      private var mNick:String;
      
      private var mPass:String;
      
      public function Server()
      {
         super();
         this.mLogged = false;
         var flashVars:Object = Dollars.smStage.root.loaderInfo.parameters;
         wcrmServerURL = flashVars.wcrm_server;
         var secondsToMakeCRMVisible:int = int(flashVars.wcrm_visible_at);
         this.wcrmMakeVisibleAfterAt = secondsToMakeCRMVisible * 1000;
         this.externalTaskInit();
      }
      
      public static function XMLToObject(xml:XML) : Object
      {
         var nameStr:String = null;
         var valueStr:String = null;
         var codeName:String = xml.name();
         var outputObj:Object = new Object();
         var xmlMain:XMLList = xml.attributes();
         for(var index:uint = 0; index < xmlMain.length(); index++)
         {
            nameStr = xmlMain[index].name();
            valueStr = xmlMain[index].valueOf();
            outputObj[nameStr] = valueStr;
         }
         var xmlChildren:XMLList = xml.elements();
         outputObj[codeName] = XMLToObjectGetChildren(xmlChildren);
         return outputObj;
      }
      
      public static function XMLToObjectGetChildren(xmlChildren:XMLList) : Array
      {
         var codeName:String = null;
         var outputObj:Object = null;
         var xmlChild:XMLList = null;
         var indexAttr:uint = 0;
         var nameStr:String = null;
         var valueStr:String = null;
         var outputArr:Array = new Array();
         for(var index:uint = 0; index < xmlChildren.length(); index++)
         {
            codeName = xmlChildren[index].name();
            outputObj = new Object();
            xmlChild = xmlChildren[index].attributes();
            for(indexAttr = 0; indexAttr < xmlChild.length(); indexAttr++)
            {
               nameStr = xmlChild[indexAttr].name();
               valueStr = xmlChild[indexAttr].valueOf();
               outputObj[nameStr] = valueStr;
            }
            if(xmlChildren.elements().length() > 0)
            {
               outputObj[codeName] = XMLToObjectGetChildren(xmlChildren[index].elements());
            }
            else
            {
               outputObj[codeName] = new Array();
            }
            outputArr.push(outputObj);
         }
         return outputArr;
      }
      
      public static function objectToXML(obj:Object) : XML
      {
         return new XML(objectToXMLString(obj));
      }
      
      public static function objectToXMLString(obj:Object) : String
      {
         var objName:String = null;
         var output:String = null;
         var outputChild:String = null;
         var isEmpty:Boolean = false;
         var param:String = null;
         var count:uint = 0;
         var index:uint = 0;
         var value:String = null;
         if(obj is Object)
         {
            objName = "Name";
            output = "";
            outputChild = "";
            isEmpty = true;
            for(param in obj)
            {
               isEmpty = false;
               if(obj[param] is Array)
               {
                  objName = param;
                  count = uint(obj[param].length);
                  for(index = 0; index < count; index++)
                  {
                     outputChild += objectToXMLString(obj[param][index]);
                  }
               }
               else
               {
                  value = obj[param];
                  output += " " + param + "=\"" + value + "\"";
               }
            }
            if(!isEmpty)
            {
               if(outputChild.length > 0)
               {
                  return "<" + objName + output + ">\n" + outputChild + "\n</" + objName + ">";
               }
               return "<" + objName + output + "/>";
            }
         }
         return "";
      }
      
      public function login(nick:String, pass:String) : void
      {
         this.mNick = nick;
         this.mPass = pass;
         this.mLogged = false;
         Debug.trace(">>>>>>>>>>> Sending LOGIN...");
         this.uploadCommands("login",{
            "nick":nick,
            "pass":pass
         });
      }
      
      public function logout() : void
      {
         this.mLogoutDone = true;
         this.mLogged = false;
      }
      
      public function isLogged() : Boolean
      {
         return this.mLogged;
      }
      
      public function sendQuery(cmd:String, data:Object) : void
      {
         this.sendCommand(cmd,data);
         this.mForceSendAllNow = true;
      }
      
      public function sendCommand(cmd:String, data:Object) : void
      {
         var cmdObj:Object = new Object();
         cmdObj._cmd = cmd;
         cmdObj._dat = data;
         cmdObj._cnt = this.mCMDcnt++;
         if(this.mCache.length == 0 && this.mCacheUpdatesMinTimer == 0)
         {
            this.mCacheUpdatesMinTimer = CACHE_UPDATES_MIN_TIME;
            this.mCacheUpdatesMaxTimer = CACHE_UPDATES_MAX_TIME;
         }
         else if(this.mCacheUpdatesMaxTimer > 0)
         {
            this.mCacheUpdatesMinTimer = Math.max(this.mCacheUpdatesMinTimer,CACHE_UPDATES_MIN_TIME);
         }
         this.mCache.push(cmdObj);
      }
      
      public function serverIsBusy() : int
      {
         var returnValue:int = 0;
         if(this.mCache.length == 0)
         {
            if(this.mPacketCmdList == null)
            {
               returnValue = 2;
            }
            else
            {
               returnValue = 1;
            }
         }
         return returnValue;
      }
      
      public function logicUpdate(deltaTime:int) : void
      {
         if(this.mLoginRetryTimer > 0 && (this.mLoginRetryTimer = this.mLoginRetryTimer - deltaTime) <= 0)
         {
            this.mLoginRetryTimer = 0;
            this.login(this.mNick,this.mPass);
            return;
         }
         if(this.mCacheUpdatesMaxTimer > 0 && (this.mCacheUpdatesMaxTimer = this.mCacheUpdatesMaxTimer - deltaTime) <= 0)
         {
            this.mCacheUpdatesMaxTimer = 0;
         }
         if(this.mCacheUpdatesMinTimer > 0 && (this.mCacheUpdatesMinTimer = this.mCacheUpdatesMinTimer - deltaTime) <= 0)
         {
            this.mCacheUpdatesMinTimer = 0;
            this.mForceSendAllNow = true;
         }
         if(this.mPingUpdatesCount > 0)
         {
            this.mPingUpdatesTimer -= deltaTime;
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
            this.mPermanentUpdatesTimer -= deltaTime;
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
         if(this.mPacketNoResponseTimer > 0 && (this.mPacketNoResponseTimer = this.mPacketNoResponseTimer - deltaTime) <= 0)
         {
            this.mPacketNoResponseTimer = 0;
            Debug.trace("*** Server not responded in a long time ***");
            MyMetrics.send_GA_metric("OutOfSync","Client: Server not responded in a long time");
            this.logout();
            DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
         }
         if(Tutorial.smTutorialEnd)
         {
            if(this.wcrmMakeVisibleAfterAt > 0 && (this.wcrmMakeVisibleAfterAt = this.wcrmMakeVisibleAfterAt - deltaTime) <= 0)
            {
               this.wcrmMakeVisibleAfterAt = 0;
               this.externalTaskRequest("showCRM",{});
            }
         }
      }
      
      private function sendPacketNow() : void
      {
         var cmdArray:Array = null;
         var cmdLimit:int = 0;
         var cmdObj:Object = null;
         if(this.mLogged)
         {
            if(this.mCache.length == 0 && this.mPacketCmdList == null)
            {
               if(!PERMANENT_UPDATES_ENABLED)
               {
                  return;
               }
               cmdObj = new Object();
               cmdObj._cmd = "empty";
               cmdObj._dat = new Object();
               cmdObj._cnt = this.mCMDcnt++;
               this.mCache.push(cmdObj);
            }
            this.mRetryUploadCommands = false;
            Debug.trace("** Server Request (" + this.messageCnt + ") >>>>");
            cmdArray = null;
            if(this.mPacketCmdList == null)
            {
               this.mPacketCmdList = new Object();
               cmdArray = new Array();
            }
            else
            {
               cmdArray = this.mPacketCmdList._cmdList;
               if(this.mCache.length > 0)
               {
                  this.mPacketCmdList.retry = this.mCache[0]._cnt;
               }
               else
               {
                  this.mPacketCmdList.retry = 0;
               }
            }
            cmdLimit = MAX_CMDS_IN_ONE_PACKET;
            while(this.mCache.length > 0)
            {
               cmdArray.push(this.mCache.shift());
               if(--cmdLimit <= 0)
               {
                  break;
               }
            }
            this.mPacketCmdList._cmdList = cmdArray;
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
      
      protected function uploadCommands(cmd:String, cmdList:Object) : void
      {
         this.mPacketNoResponseTimer = PACKET_NO_RESPONSE_TIMEOUT;
      }
      
      protected function downloadedCommands(cmdList:Object) : void
      {
         var msgCnt:int = 0;
         var responseList:Object = null;
         var response:Object = null;
         var serverEvt:ServerEvent = null;
         var elapsedTime:int = PACKET_NO_RESPONSE_TIMEOUT - this.mPacketNoResponseTimer;
         this.mPacketNoResponseTimer = 0;
         if(cmdList != null)
         {
            msgCnt = int(cmdList.dataObj._msgCount);
            if(!(msgCnt == this.messageCnt || msgCnt < 0))
            {
               Debug.trace("Server Command Response NOT MATCH (" + msgCnt + ") instead of " + this.messageCnt);
               MyMetrics.send_GA_metric("OutOfSync","Client: packed cnt not match");
               this.logout();
               DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
               return;
            }
            this.mPacketCmdList = null;
            Debug.trace("** Server Response (" + msgCnt + ") " + (System.currentTimeMillis() - this.mStartTime) + " <<<<");
            responseList = cmdList.dataObj;
            for each(response in responseList.list)
            {
               this.processCommand(response);
               serverEvt = new ServerEvent(ServerEvent.onCommandResponse,response);
               dispatchEvent(serverEvt);
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
                  this.mLoginRetryTimer = Math.max(1,LOGIN_RETRY_TIMEOUT - elapsedTime);
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
            this.mCacheUpdatesMinTimer = Math.max(1,PACKET_RETRY_TIMEOUT - elapsedTime);
            Debug.trace("** going to retry: " + this.mRetriesCount + " in " + this.mCacheUpdatesMinTimer + " milliseconds");
         }
         ++this.messageCnt;
      }
      
      private function processCommand(responseObj:Object) : void
      {
         var cmd:String = responseObj._cmd;
         var data:Object = responseObj._dat;
         if(cmd == "logOK")
         {
            Debug.trace(">>>>>>>>>>>>>>>> Login OK <<<<<<<<<<<<<<");
            this.mLogged = true;
            if(data.hasOwnProperty("token"))
            {
               UserDataFacade.getInstance().mToken = data.token;
            }
            this.mSync = responseObj._sync;
            if(data.hasOwnProperty("currentServerTime"))
            {
               UserDataFacade.getInstance().setServerTimeAtLogin(data.currentServerTime);
               Debug.trace("currentServerTime: " + data.currentServerTime);
            }
            else
            {
               Debug.trace("currentServerTime not found");
            }
         }
         else if(cmd == "logKO")
         {
            Debug.trace(">>>>>>>>>>>>>>>> Login FAILED <<<<<<<<<<<<<<");
            this.mLogged = false;
         }
         else if(cmd == "logOut")
         {
            Debug.trace(">>>>>>>>>>>>>>>> LogOut <<<<<<<<<<<<<<");
            this.mLogged = false;
         }
         else if(cmd == "update_item")
         {
            Debug.trace(">>>>>>>>>>>>>>>> update_item ACTION:: " + data.action);
            if(data.action == "give_collectible")
            {
               DollarsGame.externalRequest(DollarsGame.REQ_GIVE_COLLECTIBLE,data);
            }
            if(data.action == "limEdBuy")
            {
               DollarsGame.externalRequest(DollarsGame.REQ_LIM_ED_RESPONSE,data);
            }
         }
      }
      
      private function externalTaskInit() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("externalTaskResponse",this.externalTaskResponse);
         }
      }
      
      public function externalTaskRequest(task:String, data:Object = null) : void
      {
         var jsonStr:String = null;
         if(data == null)
         {
            data = new Object();
         }
         Debug.trace("--=> Server.externalTaskRequest(" + task + ")");
         Debug.traceObject(data);
         if(ExternalInterface.available)
         {
            jsonStr = com.adobe.serialization.json.JSON.encode(data);
            ExternalInterface.call("flashRequest_Received",task,jsonStr);
         }
      }
      
      private function externalTaskResponse(task:String, params:String = null) : void
      {
         var array:Array = null;
         Debug.trace("--> externalTaskResponse: ");
         Debug.trace("JavaScript Response: " + task);
         if(task == null)
         {
            return;
         }
         var e:Object = new Object();
         var tokens:Array = task.split(":");
         if(task == "ping")
         {
            this.sendQuery("ping",{});
         }
         else if(task == "pingCurrency")
         {
            this.mPingUpdatesCount = PING_UPDATES_COUNTS;
         }
         else if(task.search("sendGift") != -1)
         {
            array = task.split(":");
            CollectibleManager.getInstance().giveCollectible(array[1]);
            if(Boolean(PopupCollectibleManager.getInstance().smPopupCollectibleShop) && PopupCollectibleManager.getInstance().smPopupCollectibleShop.isOpen())
            {
               PopupCollectibleManager.getInstance().smPopupCollectibleShop.refreshGroups();
            }
         }
         else if(task == "investmentResponse")
         {
            DollarsGame.externalRequest(DollarsGame.REQ_POST_INVERSION,{"extIds":params});
         }
         else if(tokens[0] == "localStatsUpdate")
         {
            this.applyLocalStatsUpdate(tokens);
         }
         else if(task == "localProfileUpdate")
         {
            this.applyLocalProfileUpdate(params);
         }
         else if(task != "HideGame")
         {
            if(task != "ShowGame")
            {
               if(task == "RequestLevel")
               {
                  DollarsGame.externalRequest(DollarsGame.REQ_LEVEL);
               }
               else if(DollarsGame.smInstance.messagesAddMessage(task))
               {
               }
            }
         }
      }

      private function applyLocalStatsUpdate(tokens:Array) : void
      {
         var profile:Object = null;
         var coins:Number = NaN;
         var cash:Number = NaN;
         var exp:Number = NaN;
         var level:uint = 1;
         var minExp:Number = NaN;
         var maxExp:Number = NaN;
         var companyValue:Number = NaN;
         if(tokens.length < 8)
         {
            return;
         }
         profile = DollarsGame.getProfile();
         if(profile == null)
         {
            return;
         }
         coins = Number(tokens[1]);
         cash = Number(tokens[2]);
         exp = Number(tokens[3]);
         level = uint(Math.max(1,Number(tokens[4])));
         minExp = Number(tokens[5]);
         maxExp = Number(tokens[6]);
         companyValue = Number(tokens[7]);
         if(isNaN(coins) || isNaN(cash) || isNaN(exp) || isNaN(Number(tokens[4])) || isNaN(minExp) || isNaN(maxExp) || isNaN(companyValue))
         {
            return;
         }
         profile.setDCCoins(Math.max(0,coins));
         profile.setDCCash(uint(Math.max(0,cash)));
         profile.setExp(Math.max(0,exp));
         profile.level = level;
         profile.minExp = Math.max(0,minExp);
         profile.maxExp = Math.max(profile.minExp,maxExp);
         profile.companyValue = Math.max(0,companyValue);
         profile.update();
         if(DollarsGame.getCurrentWorld() != null && DollarsGame.getCurrentWorld().getCompanyMine() != null)
         {
            DollarsGame.getCurrentWorld().getCompanyMine().synchronizeDataWithProfile();
         }
         if(FriendsManager.mNeighborMyself != null)
         {
            FriendsManager.mNeighborMyself.exp = profile.exp;
            FriendsManager.mNeighborMyself.companyValue = profile.companyValue;
         }
         if(DollarsGame.getFriendsBar() != null && DollarsGame.getFriendsBar().getMyself() != null)
         {
            DollarsGame.getFriendsBar().getMyself().updateExp();
            DollarsGame.getFriendsBar().getMyself().updateCompanyValue();
         }
         UserDataFacade.securityInit();
      }

      private function applyLocalProfileUpdate(json:String) : void
      {
         var data:Object = null;
         var userName:String = null;
         var cityName:String = null;
         var profilePictureUrl:String = null;
         var cityNameChanged:Boolean = false;
         if(json == null || json.length == 0)
         {
            return;
         }
         try
         {
            data = com.adobe.serialization.json.JSON.decode(json);
         }
         catch(error:Error)
         {
            return;
         }
         userName = String(data.userName);
         cityName = String(data.cityName);
         profilePictureUrl = String(data.profilePictureUrl);
         if(userName != null && userName.length > 0 && userName != "undefined")
         {
            UserDataFacade.getInstance().mUserName = userName;
            if(FriendsManager.mNeighborMyself != null)
            {
               FriendsManager.mNeighborMyself.nameFriend = userName;
            }
            if(DollarsGame.getFriendsBar() != null && DollarsGame.getFriendsBar().getMyself() != null)
            {
               DollarsGame.getFriendsBar().getMyself().updateExp();
            }
         }
         if(cityName != null && cityName.length > 0 && cityName != "undefined")
         {
            if(DollarsGame.getProfile() != null)
            {
               cityNameChanged = DollarsGame.getProfile().cityname != cityName;
               DollarsGame.getProfile().cityname = cityName;
            }
            if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER && DollarsGame.getProfileUniverse() != null)
            {
               DollarsGame.getProfileUniverse().cityname = cityName;
               if(DollarsGame.getCurrentWorld() != null && DollarsGame.getCurrentWorld().role != null && DollarsGame.getCurrentWorld().role.hud is HudOwner)
               {
                  HudOwner(DollarsGame.getCurrentWorld().role.hud).setCityName(cityName);
               }
               if(cityNameChanged && DollarsGame.smInstance != null && DollarsGame.smInstance.mPlane != null)
               {
                  DollarsGame.smInstance.mPlane.removePlane();
                  DollarsGame.smInstance.mPlane.setPlane(DollarsGame.getProfileUniverse().planeSku);
                  DollarsGame.smInstance.mPlane.start(cityName);
               }
            }
         }
         if(profilePictureUrl != null && profilePictureUrl.length > 0 && profilePictureUrl != "undefined")
         {
            UserDataFacade.getInstance().mUserPhotoUrl = profilePictureUrl;
            if(FriendsManager.mNeighborMyself != null)
            {
               FriendsManager.mNeighborMyself.url = profilePictureUrl;
            }
            if(DollarsGame.getFriendsBar() != null && DollarsGame.getFriendsBar().getMyself() != null)
            {
               DollarsGame.getFriendsBar().getMyself().loadImage();
            }
         }
      }
      
      public function externalWCRMRequest(groupName:String, eventName:String, label:String, jsonParams:Object) : void
      {
         var jsonStr:String = null;
         if(jsonParams == null)
         {
            jsonParams = new Object();
         }
         Debug.trace("--=> Server.externalWCRMRequest()");
         if(ExternalInterface.available)
         {
            jsonStr = com.adobe.serialization.json.JSON.encode(jsonParams);
            ExternalInterface.call("notifyWCRM_fromFlash",eventName,label,jsonStr);
         }
      }
   }
}

