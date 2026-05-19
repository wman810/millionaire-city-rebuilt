package com.dchoc.dollars.model.userdata
{
   import com.adobe.utils.ArrayUtil;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.server.*;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import flash.events.Event;
   
   public class UserDataFacadeOnline extends UserDataFacade
   {
      
      private var userInfos:Object;
      
      private var mIsFinished:Boolean;
      
      private var clientSideFacebookCalls:Boolean = Config.CLIENT_USE_FACEBOOK_API;
      
      private var mServer:Server;
      
      private var fbLoadingState:int = 0;
      
      private var friends:Array;
      
      private var mAskForHelpFeedImg:String = "";
      
      private var mLoadingFiles:Boolean;
      
      private var mForcedToLogout:Boolean = false;
      
      private var mInvestFriendName:String = "";
      
      private var mFirstIngameActionDone:Boolean = false;
      
      private var appFriends:Array;
      
      private var mEmptyObject:Object = new Object();
      
      private var neighborInfo:Object;
      
      private var mAskForHelpWonderName:String = "";
      
      private var mPostToFeedRewardData:Object;
      
      private var DEBUG_XML:Boolean = false;
      
      private var mAskForHelpWonderType:String = "";
      
      private var mInvestFriendExtId:String = "";
      
      public function UserDataFacadeOnline()
      {
         super(true);
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         mUserLocale = _loc1_.lang;
         Debug.trace("*** LOCALE: " + mUserLocale);
         this.mServer = new ServerJava();
         this.mServer.addEventListener(ServerEvent.onCommandResponse,this.onServerResponse);
         if(this.clientSideFacebookCalls)
         {
            mSocial = new SocialFacebook();
            mSocial.addEventListener(SocialEvent.onCommandResponse,this.onSocialResponse);
         }
         else
         {
            mSocial = new Social();
         }
      }
      
      override public function updateCollectible(param1:String, param2:String, param3:String, param4:String, param5:Object, param6:Object = null) : void
      {
         Debug.trace("------------------------- updateCollectibles :: " + param3 + " ()");
         param5.sku = param2;
         param5.sid = param1;
         param5.action = param3;
         param5.receiver = param4;
         if(param6 != null)
         {
            securityUpdate();
            param5.security = param6;
         }
         else
         {
            param5.security = securityUpdate();
         }
         if(param3 == "ASK")
         {
            this.mServer.sendCommand("ask_collectible",param5);
         }
         else
         {
            this.mServer.sendCommand("update_collectible",param5);
         }
      }
      
      override public function updateItem(param1:String, param2:String, param3:Object, param4:XML = null, param5:Object = null) : void
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         if(queueGetEnabled())
         {
            _loc6_ = new Object();
            _loc6_.cmd = QUEUE_REQUEST_UPDATE_ITEM;
            _loc6_.sid = param1;
            _loc6_.action = param2;
            _loc6_.params = param3;
            _loc6_.xml = param4;
            UserDataFacade.getInstance().queueRequestAdd(_loc6_);
         }
         else
         {
            if(param4 == null)
            {
               param4 = new XML();
            }
            if(DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER && DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD && !smSecurityIgnore)
            {
               Debug.trace("------------------------- updateItem :: " + param2 + " (" + param1 + ":" + param4.@sku + ")");
               _loc7_ = param4.@sku;
               param3.action = param2;
               param3.sid = param1;
               param3.sku = _loc7_;
               if(param5 != null)
               {
                  securityUpdate();
                  param3.security = param5;
               }
               else
               {
                  param3.security = securityUpdate();
               }
               if(param3.hasOwnProperty("doubleRent"))
               {
                  mDoubleRent["Houses"] = false;
                  mDoubleRent["Commerces"] = false;
               }
               param3.millis = timerGetTimeSinceLogin();
               if(this.DEBUG_XML)
               {
                  param3.xml = Server.XMLToObject(param4);
               }
               this.mServer.sendCommand("update_item",param3);
               if(!this.mFirstIngameActionDone)
               {
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_FIRST_INGAME_ACTION,param3.action,null,param1);
                  this.mFirstIngameActionDone = true;
               }
            }
         }
      }
      
      override public function logout() : void
      {
         if(!this.mForcedToLogout)
         {
            this.mForcedToLogout = true;
            this.mServer.logout();
            DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT);
         }
      }
      
      override public function updatePlots(param1:String, param2:Object, param3:XML = null) : void
      {
         if(DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER && DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updatePlots() :: " + param1);
            param2.action = param1;
            param2.security = securityUpdate();
            if(this.DEBUG_XML)
            {
               if(param3 == null)
               {
                  param3 = new XML();
               }
               param2.xml = Server.XMLToObject(param3);
            }
            this.mServer.sendCommand("update_plots",param2);
         }
      }
      
      override public function applicationExit(param1:Event) : void
      {
         this.mServer.mForceSendAllNow = true;
      }
      
      private function onSocialResponse(param1:SocialEvent) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:XML = null;
         var _loc2_:Object = param1.params;
         var _loc3_:String = _loc2_._cmd;
         var _loc4_:Object = _loc2_._dat;
         Debug.trace("onSocialResponse: cmd: " + _loc3_);
         if(_loc3_ == "get_friends_list")
         {
            this.friends = _loc4_ as Array;
            Debug.trace("onSocialResponse friends: " + this.friends);
         }
         else if(_loc3_ == "get_app_friends_list")
         {
            this.appFriends = _loc4_ as Array;
            Debug.trace("onSocialResponse appFriends: " + this.appFriends);
         }
         else if(_loc3_ == "get_user_info")
         {
            this.userInfos = _loc4_;
            Debug.trace("onSocialResponse UserInfo received");
         }
         else if(_loc3_ == "is_fan")
         {
            Debug.trace("onSocialResponse is_fan: " + _loc4_);
            _loc5_ = Boolean(_loc4_);
            _loc6_ = _loc5_ ? "2" : "0";
            _loc7_ = <fan value={_loc6_} bookmark="0"/>;
            setFile(TAG_FAN_LIST,_loc7_);
            if(DollarsGame.getProfile() != null)
            {
               DollarsGame.getProfile().isFan = _loc5_;
            }
            Debug.trace("-*-*-*-*-*-*-*-*-*-*");
            Debug.trace(_loc7_.toXMLString());
            Debug.trace("-*-*-*-*-*-*-*-*-*-*");
         }
         this.updateLoadingState();
      }
      
      override public function updateRewards(param1:String, param2:Object, param3:Object = null) : void
      {
         param2.sku = param1;
         if(param3 != null)
         {
            securityUpdate();
            param2.security = param3;
         }
         else
         {
            param2.security = securityUpdate();
         }
         this.mServer.sendCommand("update_daily_reward",param2);
      }
      
      private function updateLoadingState() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:UserDataFacade = null;
         var _loc7_:Object = null;
         var _loc8_:* = 0;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc13_:String = null;
         var _loc14_:Object = null;
         var _loc15_:Object = null;
         Debug.trace("UpdateLoadingState: fbLoadingState -> " + this.fbLoadingState);
         if(this.fbLoadingState == 2)
         {
            return;
         }
         if(this.fbLoadingState == 0)
         {
            if(this.friends != null && this.appFriends != null)
            {
               this.fbLoadingState = 1;
               _loc1_ = new Array().concat(this.friends);
               _loc1_.push(mUserExtId);
               mSocial.getUserInfo(ArrayUtil.createUniqueCopy(_loc1_));
               _loc2_ = new Object();
               _loc2_.facebookIds = this.appFriends;
               _loc2_.useNeighborList = Config.USE_NEIGHBOR_REQUESTS ? "1" : "0";
               this.mServer.sendCommand("get_neighbor_info",_loc2_);
            }
         }
         else if(this.fbLoadingState == 1)
         {
            if(this.userInfos != null && this.neighborInfo != null)
            {
               this.fbLoadingState = 2;
               _loc3_ = Dollars.smStage.root.loaderInfo.parameters;
               if(_loc3_["allFriendsAreNeighbors"] == "1")
               {
                  _loc8_ = 1000000000;
                  for each(_loc9_ in this.userInfos as Array)
                  {
                     _loc10_ = false;
                     for each(_loc11_ in this.neighborInfo["neighborList"] as Array)
                     {
                        if(_loc9_["uid"] == _loc11_["extId"])
                        {
                           _loc10_ = true;
                           break;
                        }
                     }
                     if(!_loc10_)
                     {
                        _loc12_ = new Object();
                        _loc12_["extId"] = _loc9_["uid"];
                        _loc12_["id"] = _loc8_++;
                        _loc12_["xp"] = 2345;
                        _loc12_["companyValue"] = 987645;
                        _loc12_["tutorialEnd"] = 1;
                        _loc12_["neighbor"] = new Array();
                        this.neighborInfo["neighborList"].push(_loc12_);
                     }
                  }
               }
               _loc4_ = new Object();
               _loc5_ = new Array();
               _loc4_.friendsList = _loc5_;
               _loc6_ = UserDataFacade.getInstance();
               for each(_loc7_ in this.userInfos as Array)
               {
                  _loc13_ = _loc7_["pic_square"];
                  if(Config.SECURE_PROTOCOL)
                  {
                     _loc13_ = _loc13_.replace("http:","https:");
                  }
                  if(_loc7_["uid"] == mUserExtId)
                  {
                     _loc6_.mUserName = _loc7_["first_name"];
                     _loc6_.mUserPhotoUrl = _loc13_;
                  }
                  else
                  {
                     _loc14_ = new Object();
                     _loc14_["extId"] = _loc7_["uid"];
                     _loc14_["name"] = _loc7_["first_name"];
                     _loc14_["url"] = _loc13_;
                     _loc14_["userId"] = -1;
                     for each(_loc15_ in this.neighborInfo["neighborList"] as Array)
                     {
                        if(_loc14_["extId"] == _loc15_["extId"])
                        {
                           _loc14_["userId"] = _loc15_["id"];
                           break;
                        }
                     }
                     _loc14_["friend"] = new Array();
                     _loc5_.push(_loc14_);
                  }
               }
               setFile(TAG_FRIEND_LIST,Server.objectToXML(_loc4_));
               setFile(TAG_NEIGHBOR_LIST,Server.objectToXML(this.neighborInfo));
               FriendsManager.reload();
            }
         }
      }
      
      override public function updateProfile(param1:String, param2:Object, param3:XML = null) : void
      {
         if(DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER)
         {
            Debug.trace("------------------------- updateProfile() :: " + param1);
            if(param1 == "city_name")
            {
               param1 = "city_name_codes";
               param2.value = DollarsGame.getProfile().getCityNameCodes();
            }
            param2.action = param1;
            if(this.DEBUG_XML)
            {
               if(param3 == null)
               {
                  param3 = new XML();
               }
               param2.xml = Server.XMLToObject(param3);
            }
            this.mServer.sendCommand("update_profile",param2);
         }
      }
      
      override public function requestTask(param1:String, param2:Object = null) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:NewsFeedDefinition = null;
         var _loc6_:FriendObject = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         if(param2 == null)
         {
            param2 = new Object();
         }
         Debug.trace("--=> userDataFacade.requestTask(" + param1 + ")");
         Debug.traceObject(param2);
         if(param1 == TAG_UNIVERSE)
         {
            reserveFile(TAG_UNIVERSE);
            _loc3_ = new Object();
            _loc3_.targetUserId = param2.userId;
            this.mServer.sendQuery("get_world",_loc3_);
         }
         else if(param1 == TAG_CRM_CUSTOMIZER)
         {
            reserveFile(TAG_CRM_CUSTOMIZER);
            this.mServer.sendCommand("get_customizer_info",this.mEmptyObject);
         }
         else if(param1 == TAG_FRIEND_LIST)
         {
            reserveFile(TAG_FRIEND_LIST);
            if(this.clientSideFacebookCalls)
            {
               mSocial.getFriendList();
            }
            else
            {
               this.mServer.sendCommand("get_friends_list",this.mEmptyObject);
            }
         }
         else if(param1 == TAG_NEIGHBOR_LIST)
         {
            reserveFile(TAG_NEIGHBOR_LIST);
            if(this.clientSideFacebookCalls)
            {
               mSocial.getAppFriendList();
            }
            else
            {
               this.mServer.sendCommand("get_neighbor_list",this.mEmptyObject);
            }
         }
         else if(param1 == TASK_NEIGHBOR_LIST_RELOAD)
         {
            this.appFriends = null;
            this.neighborInfo = null;
            this.fbLoadingState = 0;
            reserveFile(TAG_NEIGHBOR_LIST);
            if(this.clientSideFacebookCalls)
            {
               mSocial.getAppFriendList();
            }
            else
            {
               this.mServer.sendCommand("get_neighbor_list",this.mEmptyObject);
            }
         }
         else if(param1 == ActionsLibrary.SHOW_FACE_BOX)
         {
            this.mServer.externalTaskRequest(param1,param2);
         }
         else if(param1 == TAG_UPGRADES_LIST)
         {
            reserveFile(TAG_UPGRADES_LIST);
            this.mServer.sendQuery("get_upgrades_list",param2);
         }
         else if(param1 == TASK_ASK_FOR_HELP)
         {
            this.mAskForHelpWonderName = param2.name;
            this.mAskForHelpFeedImg = param2.feedImg;
            this.mAskForHelpWonderType = param2.type;
            this.mServer.sendQuery("ask_for_help",{"sid":param2.sid});
         }
         else if(param1 == TASK_ASK_FOR_CASH)
         {
            this.mServer.sendQuery("ask_for_cash",{"sid":0});
         }
         else if(param1 == TASK_HELP_INVITE_FRIEND)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("fbRequest",{"action":"inviteRequest"});
         }
         else if(param1 == TASK_HELP_SEND_FREE_GIFT)
         {
            this.mServer.externalTaskRequest(param1);
         }
         else if(param1 == TASK_BECAME_FAN)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest(param1);
         }
         else if(param1 == TASK_BROWSER_REFRESH)
         {
            this.mServer.externalTaskRequest(param1);
         }
         else if(param1 == TAG_UPGRADES_ADD_ITEM)
         {
            Debug.trace("visitor " + param2.visitorId + " has upgraded item " + param2.sid + " in " + param2.ownerId + " city ");
            param2.security = securityUpdate();
            this.mServer.sendCommand("add_upgrade_item",param2);
         }
         else if(param1 == TASK_NEIGHBOR_REQUEST)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("fbRequest",{"action":"neighborRequest"});
         }
         else if(param1 == TASK_PARTNER_REQUEST)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("fbRequest",{
               "action":"partnerRequest",
               "useNeighborList":(Config.USE_NEIGHBOR_REQUESTS ? "1" : "0")
            });
         }
         else if(param1 == TASK_INVESTMENT_REQUEST)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("fbRequest",{"action":"investmentRequest"});
         }
         else if(param1 == TASK_SEND_COLLECTIBLE)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("helpSendFreeGift",param2);
         }
         else if(param1 == TASK_POST_TO_FEED)
         {
            _loc4_ = null;
            if(param2.postId == POST_LEVEL_UP)
            {
               _loc4_ = "levelUp";
            }
            else if(param2.postId == POST_GET_REWARD)
            {
               _loc4_ = "missionReward";
            }
            else if(param2.postId == POST_NOTIFY_HELP_WONDER)
            {
               _loc4_ = "askForHelpHelped";
            }
            else if(param2.postId == POST_THANK_HELPERS_WONDER)
            {
               _loc4_ = "askForHelpThanks";
            }
            else if(param2.postId == POST_PARTNER_ACCEPTED)
            {
               _loc4_ = "becomePartner";
            }
            else if(param2.postId == POST_ALL_UPGRADES_DONE)
            {
               _loc4_ = "allUpgradesDone";
            }
            else if(param2.postId == POST_NEW_EXPANSION)
            {
               _loc4_ = "newExpansion";
            }
            else if(param2.postId == POST_END_TUTORIAL)
            {
               _loc4_ = "endTutorial";
            }
            else if(param2.postId == POST_CONTRATOR_MOVE)
            {
               _loc4_ = "contractor1";
            }
            else if(param2.postId == POST_CONTRATOR_COLLECT)
            {
               _loc4_ = "contractor2";
            }
            else if(param2.postId == POST_CONTRATOR_CONTRACT)
            {
               _loc4_ = "contractor3";
            }
            else if(param2.postId == POST_COLLECTIBLE_COLLECTION_COMPLETE)
            {
               _loc4_ = "collectionCompleted";
            }
            else if(param2.postId == POST_THANKS_COLLECTIBLE)
            {
               _loc4_ = "collectibleGiftThanks";
            }
            else if(param2.postId == POST_THANKS_COLLECTIBLE_ALL)
            {
               _loc4_ = "collectibleGiftThanks";
            }
            else if(param2.postId == POST_GOLD_BOUGHT)
            {
               _loc4_ = "goldBought";
            }
            else if(param2.postId == POST_ASK_FOR_CASH_DONE)
            {
               _loc4_ = "askForCashDone";
            }
            else if(param2.postId == POST_ASK_FOR_CASH_THANKS)
            {
               _loc4_ = "askForCashThanks";
            }
            if(_loc4_ != null)
            {
               _loc5_ = NewsFeedDefinitionManager.getInstance().getDefinitionBySku(_loc4_) as NewsFeedDefinition;
               if(_loc5_ == null || !_loc5_.hasReward())
               {
                  _loc4_ = null;
               }
            }
            if(_loc4_ != null)
            {
               param2.rewardSku = _loc4_;
               this.mPostToFeedRewardData = param2;
               this.mServer.sendCommand("postReward",{"sku":_loc4_});
            }
            else
            {
               this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams(param2));
            }
         }
         else if(param1 == TASK_CASH_SHOP)
         {
            this.mServer.externalTaskRequest("cashShop",param2);
         }
         else if(param1 == TASK_CASH_SHOP_STANDALONE)
         {
            this.mServer.externalTaskRequest("cashShopStandalone",param2);
         }
         else if(param1 == TASK_OPEN_DCHOC_MMA)
         {
            this.mServer.externalTaskRequest("openDchocMMA",param2);
         }
         else if(param1 == TASK_OPEN_URL)
         {
            this.mServer.externalTaskRequest("openURL",param2);
         }
         else if(param1 == TASK_INVEST)
         {
            switch(param2.type)
            {
               case INVEST_TYPE_ON_FRIEND:
                  _loc6_ = FriendsManager.getFriendByID(param2.fExtId);
                  this.mInvestFriendName = _loc6_.nameFriend;
                  this.mInvestFriendExtId = _loc6_.extId;
                  this.mServer.sendQuery("invest_on_friend",param2);
                  break;
               case INVEST_TYPE_ON_FRIEND_REMINDER:
                  _loc6_ = FriendsManager.getFriendByID(param2.fExtId);
                  this.mInvestFriendName = _loc6_.nameFriend;
                  this.mInvestFriendExtId = _loc6_.extId;
                  this.mServer.sendQuery("invest_on_friend_reminder",param2);
                  break;
               case INVEST_TYPE_GET_INVERSION:
                  this.mServer.sendQuery("invest_get_inversion",param2);
                  break;
               case INVEST_TYPE_SPEED:
                  _loc6_ = FriendsManager.getFriendByID(param2.fExtId);
                  this.mInvestFriendName = _loc6_.nameFriend;
                  this.mInvestFriendExtId = _loc6_.extId;
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_INVEST_SPEED,
                     "feedImg":"investment_reminder.jpg",
                     "friendName":this.mInvestFriendName,
                     "fExtId":this.mInvestFriendExtId
                  }));
                  break;
               case INVEST_TYPE_CANCEL:
                  this.mServer.sendQuery("invest_cancel",param2);
                  break;
               case INVEST_TYPE_RESULTS:
                  this.mServer.sendQuery("invest_results",param2);
                  break;
               case INVEST_TYPE_THANKS:
                  _loc6_ = FriendsManager.getFriendByID(param2.fExtId);
                  this.mInvestFriendName = _loc6_.nameFriend;
                  this.mInvestFriendExtId = _loc6_.extId;
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_INVEST_THANKS,
                     "feedImg":"investment_thanks.jpg",
                     "friendName":this.mInvestFriendName
                  }));
                  break;
               case INVEST_TYPE_COMPLETE:
                  Dollars.checkIsFullScreen();
                  _loc6_ = FriendsManager.getFriendByID(param2.fExtId);
                  this.mInvestFriendName = _loc6_.nameFriend;
                  this.mInvestFriendExtId = _loc6_.extId;
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_INVEST_COMPLETE,
                     "feedImg":"investment_thanks.jpg",
                     "friendName":this.mInvestFriendName,
                     "fExtId":this.mInvestFriendExtId
                  }));
            }
         }
         else if(param1 == TASK_FACEBOOK_CREDITS)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest(TASK_FACEBOOK_CREDITS,param2);
         }
         else if(param1 == TASK_FACEBOOK_CREDITS_FRICTIONLESS)
         {
            this.mServer.sendPayment(param2);
         }
         else if(param1 == TASK_FACEBOOK_CREDITS_GET_BALANCE)
         {
            this.mServer.externalTaskRequest(TASK_FACEBOOK_CREDITS_GET_BALANCE,{});
         }
         else if(param1 == TASK_LOAD_SUCCESS)
         {
            if(UserDataFacade.chk)
            {
               param2.chk = 1;
            }
            this.mServer.sendQuery("load_success",param2);
            _loc7_ = timerGetTimeSinceLogin() / 1000;
            _loc8_ = _loc7_ / 5;
            _loc9_ = "(" + _loc8_ * 5 + "->" + (_loc8_ + 1) * 5 + ")";
            if(_loc8_ > 24)
            {
               _loc9_ = "(more than 2 minutes)";
            }
            Debug.trace("Loading bar elapsed; " + _loc7_ + " seconds, " + _loc9_);
            MyMetrics.send_GA_metric("Loading","Loading bar time elapsed",_loc9_);
         }
         else if(param1 == TAG_CROSS_APPLICATIONS_PLAYED)
         {
            _loc10_ = Server.wcrmServerURL + "/user_projects/?project_id=7&fb_user_id=" + UserDataFacade.getInstance().mUserExtId + "&sig=" + DollarsGame.smCRMhash;
            UserDataFacade.getInstance().requestFile(param1,_loc10_);
         }
         else if(param1 == TASK_FED_PAYMENT)
         {
            this.mServer.externalTaskRequest(TASK_FED_PAYMENT,param2);
         }
         else if(param1 == TASK_MESSAGE_CENTER_ASK_FOR_OPEN)
         {
            this.mServer.externalTaskRequest(param1,param2);
         }
         else if(param1 == TASK_SEND_LEVEL)
         {
            this.mServer.externalTaskRequest(param1,param2);
         }
         else if(param1 == TASK_IS_FAN)
         {
            if(this.clientSideFacebookCalls)
            {
               _loc11_ = Dollars.smStage.root.loaderInfo.parameters;
               _loc12_ = _loc11_.uid;
               _loc13_ = _loc11_.fan_page_id;
               Debug.trace("fan_page_id: " + _loc13_);
               mSocial.isFan(_loc12_,_loc13_);
            }
            else
            {
               requestFile(TAG_FAN_LIST,Config.getRoot() + ModelConfig.FANLIST_XML_FILE);
            }
         }
         else if(param1 == TASK_VIDEO_AD)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalFunctionCall(param2.func);
         }
         else if(param1 == TASK_CREW_REQUEST)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest("fbRequest",{
               "action":"addCrewToItem",
               "sid":param2.sid
            });
         }
         else if(param1 == TASK_BOOKMARK)
         {
            Dollars.checkIsFullScreen();
            this.mServer.externalTaskRequest(param1);
         }
      }
      
      override public function updateNextRent(param1:String, param2:Object) : void
      {
         if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updateNextRent() :: " + param1);
            param2.action = param1;
            this.mServer.sendCommand("update_next_rent",param2);
         }
      }
      
      override public function logicUpdate(param1:int) : void
      {
         var _loc2_:Array = null;
         super.logicUpdate(param1);
         this.mServer.logicUpdate(param1);
         if(!this.mIsFinished)
         {
            if(this.mLoadingFiles)
            {
               _loc2_ = new Array();
               _loc2_.push(UserDataFacade.TAG_FRIEND_LIST);
               _loc2_.push(UserDataFacade.TAG_NEIGHBOR_LIST);
               this.mIsFinished = allFilesLoadedExclude(_loc2_);
               if(this.mIsFinished)
               {
                  build();
               }
            }
         }
      }
      
      override public function isLogged() : Boolean
      {
         return this.mServer.isLogged();
      }
      
      override public function isLoaded() : Boolean
      {
         return this.mIsFinished;
      }
      
      override public function updateMap(param1:String, param2:String, param3:Object, param4:Object = null) : void
      {
         if(DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER && DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updateMap :: " + param2 + " ()");
            param3.sid = param1;
            param3.action = param2;
            if(param4 != null)
            {
               securityUpdate();
               param3.security = param4;
            }
            else
            {
               param3.security = securityUpdate();
            }
            this.mServer.sendCommand("update_map",param3);
         }
      }
      
      private function getPostToFeedParams(param1:Object, param2:String = null) : Object
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         Dollars.checkIsFullScreen();
         if(param1 == null)
         {
            param1 = {"postId":0};
         }
         var _loc3_:String = "default";
         if(param2 != null)
         {
            _loc3_ = "getReward" + "&" + "sku=" + param2 + "&" + "pcnt=" + param1.postCount;
         }
         var _loc4_:String = param1.postId;
         var _loc5_:Object = new Object();
         _loc5_.id = _loc4_;
         if(_loc4_ == POST_LEVEL_UP)
         {
            _loc6_ = int(DollarsGame.getProfile().level);
            _loc7_ = "TBD.jpg";
            if(_loc6_ >= 2 && _loc6_ <= 3)
            {
               _loc7_ = "level_" + _loc6_ + ".jpg";
            }
            else if(_loc6_ >= 4 && _loc6_ <= 5)
            {
               _loc7_ = "level_4_5.jpg";
            }
            else if(_loc6_ >= 6 && _loc6_ <= 7)
            {
               _loc7_ = "level_6_7.jpg";
            }
            else if(_loc6_ >= 8 && _loc6_ <= 9)
            {
               _loc7_ = "level_8_9.jpg";
            }
            else if(_loc6_ >= 10 && _loc6_ <= 14)
            {
               _loc7_ = "level_10_14.jpg";
            }
            else if(_loc6_ >= 15)
            {
               _loc7_ = "level_15_up.jpg";
            }
            _loc5_.name = TextManager.getText(TextIDs.TID_POST_LEVEL_UP_TITLE);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_LEVEL_UP_DESCRIPTION,[mUserName,_loc6_]);
            _loc5_.image_file = _loc7_;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_LEVEL_UP_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_LEVEL_UP_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_JOURNAL)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_JOURNAL_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_JOURNAL_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "newspaper.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_JOURNAL_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_JOURNAL_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_ONE_MILLION)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_ONE_MILLION_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_ONE_MILLION_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "million.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_ONE_MILLION_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_ONE_MILLION_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_GET_REWARD)
         {
            _loc5_.name = TextManager.getText(TextIDs.TID_POST_GET_REWARD_TITLE);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_GET_REWARD_DESCRIPTION,[mUserName,param1.missionName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_GET_REWARD_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_GET_REWARD_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_INVEST_ON_FRIEND)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_INVEST_POST1_TITLE,[param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_INVEST_POST1_DESCRIPTION,[param1.friendName,mUserName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_INVEST_POST1_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_INVEST_POST1_TARGET);
            _loc5_.target_task = "investOnFriend" + "&iid=" + param1.investId + "&src=vir_fb_invest";
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_INVEST_ON_FRIEND_REMINDER)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_INVEST_POST1_TITLE,[param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_INVEST_POST1_DESCRIPTION,[param1.friendName,mUserName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_INVEST_POST1_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_INVEST_POST1_TARGET);
            _loc5_.target_task = "investOnFriendReminder" + "&iid=" + param1.investId + "&src=vir_fb_invest";
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_INVEST_SPEED)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_INVEST_POST2_TITLE,[param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_INVEST_POST2_DESCRIPTION,[mUserName,param1.friendName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_INVEST_POST2_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_INVEST_POST2_TARGET);
            _loc5_.target_task = _loc3_;
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_INVEST_THANKS)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_INVEST_POST3_TITLE,[mUserName,param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_INVEST_POST3_DESCRIPTION,[mUserName,param1.friendName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_INVEST_POST3_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_INVEST_POST3_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_INVEST_COMPLETE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_INVEST_POST4_TITLE,[mUserName,param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_INVEST_POST4_DESCRIPTION,[mUserName,param1.friendName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_INVEST_POST4_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_INVEST_POST4_TARGET);
            _loc5_.target_task = _loc3_;
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_OPEN_BOX_STORAGE)
         {
            _loc5_.name = TextManager.getText(TextIDs.TID_BRIEFCASE_POST_TITLE);
            _loc5_.caption = "";
            _loc5_.description = TextManager.getText(TextIDs.TID_BRIEFCASE_POST_DESCRIPTION);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_ONE_MILLION_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_PARTNER_ACCEPTED)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_PARTNERS_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_PARTNERS_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feeds_partners.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_PARTNERS_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.replaceParameters(TextIDs.TID_PARTNERS_POST_TARGET,[mUserName]);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_ALL_UPGRADES_DONE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_UPGRADEME_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_UPGRADEME_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_UPGRADEME_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_UPGRADEME_POST_TARGET);
            _loc5_.target_task = _loc3_;
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_HELP_WONDER)
         {
            if(param1.type == ItemDefinition.TYPE_WONDERS_ID)
            {
               _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_HELP_WONDER_TITLE,[mUserName,param1.wonderName]);
            }
            else
            {
               _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_HELP_BUILDING_TITLE,[mUserName,param1.wonderName]);
            }
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_HELP_WONDER_DESCRIPTION,[mUserName,param1.wonderName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_HELP_WONDER_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.replaceParameters(TextIDs.TID_POST_HELP_WONDER_TARGET,[mUserName]);
            _loc5_.target_task = "accelerateItem" + "&hid=" + param1.hid + "&from=post";
         }
         else if(_loc4_ == POST_NOTIFY_HELP_WONDER)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_NOTIFY_HELP_BUILDING_POST_TITLE,[mUserName,param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_NOTIFY_HELP_BUILDING_POST_DESCRIPTION,[mUserName,param1.friendName,param1.itemName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_NOTIFY_HELP_BUILDING_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_NOTIFY_HELP_BUILDING_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_THANK_HELPERS_WONDER)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_NOTIFY_BUILDING_FINISHED_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_NOTIFY_BUILDING_FINISHED_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_NOTIFY_BUILDING_FINISHED_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_NOTIFY_BUILDING_FINISHED_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_ASK_FOR_CASH)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_TITLE,[mUserName,param1.wonderName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_DESCRIPTION,[mUserName,param1.wonderName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_TARGET,[mUserName]);
            _loc5_.target_task = "askForCash" + "&hid=" + param1.hid + "&from=post";
         }
         else if(_loc4_ == POST_ASK_FOR_CASH_DONE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_DONE_TITLE,[mUserName,param1.friendName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_DONE_DESCRIPTION,[mUserName,param1.friendName,param1.itemName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_DONE_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_JOURNAL_TARGET);
            _loc5_.target_task = _loc3_;
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_ASK_FOR_CASH_THANKS)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_THANKS_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_POST_ASK_FOR_CASH_THANKS_DESCRIPTION,[mUserName]);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_THANKS_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_POST_JOURNAL_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_END_TUTORIAL)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_END_TUTORIAL_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_END_TUTORIAL_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feed_tutorial.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_END_TUTORIAL_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_END_TUTORIAL_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_NEW_EXPANSION)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_NEW_EXPANSION_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_NEW_EXPANSION_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feed_expansion.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_NEW_EXPANSION_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_NEW_EXPANSION_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_CONTRATOR_MOVE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR1_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR1_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feed_move.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_CONTRACTOR1_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_CONTRACTOR1_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_CONTRATOR_COLLECT)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR2_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR2_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feed_moneyCollector.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_CONTRACTOR2_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_CONTRACTOR2_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_CONTRATOR_CONTRACT)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR3_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_CONTRACTOR3_POST_DESCRIPTION,[mUserName]);
            _loc5_.image_file = "new_feed_contractSignator.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_CONTRACTOR3_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_CONTRACTOR3_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_UPGRADE_ME)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_SHAREDDEAL_POST_TITLE,[mUserName]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.getText(TextIDs.TID_SHAREDDEAL_POST_DESCRIPTION);
            _loc5_.image_file = "Dollars_askxhelp.jpg";
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_SHAREDDEAL_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_SHAREDDEAL_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_ASK_COLLECTIBLE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_REQUEST_POST_TITLE,[mUserName,param1.name as String]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_REQUEST_POST_DESCRIPTION,[mUserName,param1.name as String]);
            _loc5_.image_file = param1.image as String;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_COLLECTIBLES_REQUEST_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_COLLECTIBLES_REQUEST_POST_TARGET);
            _loc5_.target_task = "sendGiftToFriend";
            _loc5_.sku = param1.sku;
         }
         else if(_loc4_ == POST_COLLECTIBLE_COLLECTION_COMPLETE)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_SUCCESS_POST_TITLE,[mUserName,param1.name as String]);
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_SUCCESS_POST_DESCRIPTION,[mUserName,param1.name as String]);
            _loc5_.image_file = param1.image as String;
            _loc5_.user_message_prompt = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_SUCCESS_POST_MESSAGE,[param1.name as String]);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_COLLECTIBLES_SUCCESS_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_THANKS_COLLECTIBLE)
         {
            _loc5_.name = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_TITLE);
            _loc5_.caption = "";
            _loc5_.description = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_DESCRIPTION);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_TARGET);
            _loc5_.target_task = _loc3_;
            _loc5_.target_id = param1.fExtId;
         }
         else if(_loc4_ == POST_THANKS_COLLECTIBLE_ALL)
         {
            _loc5_.name = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_TITLE);
            _loc5_.caption = "";
            _loc5_.description = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_DESCRIPTION);
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else if(_loc4_ == POST_GOLD_BOUGHT)
         {
            _loc5_.name = TextManager.replaceParameters(TextIDs.TID_GOLDBOUGHT_POST_TITLE,new Array(mUserName));
            _loc5_.caption = "";
            _loc5_.description = TextManager.replaceParameters(TextIDs.TID_GOLDBOUGHT_POST_DESCRIPTION,new Array(mUserName));
            _loc5_.image_file = param1.feedImg;
            _loc5_.user_message_prompt = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POST_MESSAGE);
            _loc5_.user_message_default = "";
            _loc5_.target_text = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POST_TARGET);
            _loc5_.target_task = _loc3_;
         }
         else
         {
            _loc5_.name = "name";
            _loc5_.caption = "caption";
            _loc5_.description = "description";
            _loc5_.image_file = "image.jpg";
            _loc5_.user_message_prompt = "user_message_prompt";
            _loc5_.user_message_default = "";
            _loc5_.target_text = "Play Millionaire City";
            _loc5_.target_task = _loc3_;
         }
         return _loc5_;
      }
      
      override public function updateMissions(param1:String, param2:Object, param3:XML = null, param4:Object = null) : void
      {
         if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updateMissions() :: " + param1);
            param2.action = param1;
            if(param4 != null)
            {
               securityUpdate();
               param2.security = param4;
            }
            else
            {
               param2.security = securityUpdate();
            }
            if(this.DEBUG_XML)
            {
               if(param3 == null)
               {
                  param3 = new XML();
               }
               param2.xml = Server.XMLToObject(param3);
            }
            this.mServer.sendCommand("update_missions",param2);
         }
      }
      
      private function onServerResponse(param1:ServerEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:String = null;
         var _loc2_:Object = param1.params;
         var _loc3_:String = _loc2_._cmd;
         var _loc4_:Object = _loc2_._dat;
         Debug.trace("<<< processResponse: " + _loc3_);
         if(_loc3_ == "get_world")
         {
            setFile(TAG_UNIVERSE,Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_customizer_info")
         {
            setFile(TAG_CRM_CUSTOMIZER,Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_friends_list")
         {
            setFile(TAG_FRIEND_LIST,Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_neighbor_list")
         {
            setFile(TAG_NEIGHBOR_LIST,Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_neighbor_info")
         {
            this.neighborInfo = _loc4_;
         }
         else if(_loc3_ == "ask_for_help")
         {
            _loc5_ = _loc4_.help_id;
            Debug.trace("--> ask_for_help : help_id: " + _loc5_);
            if(_loc5_ == "null")
            {
               DollarsGame.externalRequest(DollarsGame.REQ_SHOW_POPUP_INFO,{"text":TextManager.getText(TextIDs.TID_A4H_REQUEST)});
            }
            else
            {
               Dollars.checkIsFullScreen();
               if(Config.USE_UPGRADES_VIA_FB_REQUEST)
               {
                  this.mServer.externalTaskRequest("fbRequest",{
                     "action":"askForHelpRequest",
                     "hid":_loc5_
                  });
               }
               else
               {
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_HELP_WONDER,
                     "hid":_loc5_,
                     "wonderName":this.mAskForHelpWonderName,
                     "feedImg":this.mAskForHelpFeedImg,
                     "type":this.mAskForHelpWonderType
                  }));
               }
            }
         }
         else if(_loc3_ == "ask_for_cash")
         {
            _loc5_ = _loc4_.help_id;
            Debug.trace("--> ask_for_cash : help_id: " + _loc5_);
            if(_loc5_ == "null")
            {
               _loc6_ = int(_loc4_["time_passed"]);
               _loc7_ = int(_loc4_["time_total"]);
               _loc8_ = TextManager.replaceParameters(TextIDs.TID_INVEST_REMIND,new Array(TextManager.convertTimeToString(_loc7_ - _loc6_,true,true)));
               DollarsGame.externalRequest(DollarsGame.REQ_SHOW_POPUP_INFO,{"text":_loc8_});
            }
            else
            {
               Dollars.checkIsFullScreen();
               this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                  "postId":POST_ASK_FOR_CASH,
                  "hid":_loc5_,
                  "feedImg":"fbc_ask.jpg"
               }));
            }
         }
         else if(_loc3_ == "get_help_building_list")
         {
            setFile(TAG_HELP_BUILDING_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_upgrades_list")
         {
            setFile(TAG_UPGRADES_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(Config.USE_SUPERUPGRADES && _loc3_ == "get_partners_list")
         {
            setFile(TAG_UPGRADES_PARTNER_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_welcome_progress")
         {
            setFile(TAG_WELCOME_PROGRESS,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_investments_list")
         {
            setFile(TAG_INVESTMENTS_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_unlocked_items_list")
         {
            setFile(TAG_UNLOCKED_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_limited_edition_items_list")
         {
            setFile(TAG_LIM_ED_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_storage_list")
         {
            setFile(TAG_STORAGE_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
            DollarsGame.externalRequest(DollarsGame.REQ_LOAD_STORAGE);
         }
         else if(_loc3_ == "get_collectibles_list")
         {
            setFile(TAG_COLLECTIBLE_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_friends_collectible_sents_list")
         {
            setFile(TAG_COLLECTIBLE_PENDING_LIST,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_daily_rewards_info")
         {
            setFile(TAG_DAILY_BONUS_INFO,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "get_game_config")
         {
            setFile(TAG_GAME_CONFIG,Server.objectToXML(_loc4_));
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "payments")
         {
            FBCreditsPurchase.getInstance().endPurchaseProcess(_loc2_.success);
         }
         else if(_loc3_ == "fakebookCreditsRemaining")
         {
            DollarsGame.getProfile().facebookCreditsNotSpent = _loc2_._dat;
            Debug.trace("fakebookCreditsRemaining");
            Debug.traceXML(Server.objectToXML(_loc4_));
         }
         else if(_loc3_ == "invest_on_friend" || _loc3_ == "invest_on_friend_reminder")
         {
            _loc9_ = _loc4_.id;
            Debug.trace("--> RESPONSE: invest_on_friend, invest_id: " + _loc9_);
            if(_loc9_ != "null")
            {
               if(_loc3_ == "invest_on_friend")
               {
                  securityCoinsToAdd(-InvestDefinitionManager.getInstance().getInvestDefinition().getCostDCCoins());
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_INVEST_ON_FRIEND,
                     "friendName":this.mInvestFriendName,
                     "feedImg":"investment.jpg",
                     "investId":_loc9_,
                     "fExtId":this.mInvestFriendExtId
                  }));
               }
               else
               {
                  this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams({
                     "postId":POST_INVEST_ON_FRIEND_REMINDER,
                     "friendName":this.mInvestFriendName,
                     "feedImg":"investment.jpg",
                     "investId":_loc9_,
                     "fExtId":this.mInvestFriendExtId
                  }));
               }
            }
         }
         else if(_loc3_ == "invest_get_inversion")
         {
            _loc10_ = _loc4_.success;
            Debug.trace("--> RESPONSE: invest_get_inversion : success: " + _loc10_);
            if(_loc10_ == "true")
            {
               securityCoinsToAdd(InvestDefinitionManager.getInstance().getInvestDefinition().getCostDCCoins());
               DollarsGame.externalRequest(DollarsGame.REQ_INVEST_GET_INVERSION);
            }
         }
         else if(_loc3_ == "invest_cancel")
         {
            _loc10_ = _loc4_.success;
            Debug.trace("--> RESPONSE: invest_cancel : success: " + _loc10_);
            if(_loc10_ == "true")
            {
               securityCoinsToAdd(InvestDefinitionManager.getInstance().getInvestDefinition().getCostDCCoins());
            }
         }
         else if(_loc3_ == "invest_results")
         {
            _loc10_ = _loc4_.success;
            Debug.trace("--> RESPONSE: invest_results : success: " + _loc10_);
            if(_loc10_ == "true")
            {
               InvestDefinitionManager.getInstance().giveReward();
            }
         }
         else if(_loc3_ == "postReward")
         {
            Debug.traceObject(_loc4_);
            this.mPostToFeedRewardData.postCount = _loc4_.postCount;
            this.mServer.externalTaskRequest("postToFeed",this.getPostToFeedParams(this.mPostToFeedRewardData,this.mPostToFeedRewardData.rewardSku));
         }
         else if(_loc3_ == "load_success")
         {
            taskLoadSuccessDone = true;
         }
         else if(_loc3_ == "moneyUp")
         {
            Debug.trace("---------------------- moneyUp");
            Debug.traceObject(_loc4_);
            securityCoinsToAdd(_loc4_.coins);
            securityCashToAdd(_loc4_.cash);
            Debug.trace("----------------------");
         }
         else if(_loc3_ == "doubleRent")
         {
            Debug.trace("---------------------- doubleRent " + _loc2_._dat);
            if(mDoubleRent.hasOwnProperty(_loc2_._dat))
            {
               mDoubleRent[_loc2_._dat] = true;
            }
            else
            {
               Debug.trace("Error: " + _loc2_._dat + " does not exist as doubleRent parameter");
            }
            Debug.trace("----------------------");
         }
         else if(_loc3_ == "logOK")
         {
            mUserId = _loc4_.userId;
            mUserExtId = _loc4_.userExtId;
            _loc11_ = String(_loc4_.advisorId).split(",");
            mNPCSArray = new Array();
            mNPCSArray.push(int(_loc11_[0]));
            _loc12_ = 0;
            while(_loc12_ < _loc11_.length)
            {
               mNPCSArray.push(int(_loc11_[_loc12_]));
               _loc12_++;
            }
            timerSetTimeAtLogin();
         }
         else if(_loc3_ == "logKO")
         {
            this.mServer.logout();
         }
         else if(_loc3_ == "logOut")
         {
            this.mServer.logout();
            this.logout();
            _loc13_ = _loc4_["type"];
            if(_loc13_ == "world")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: word is corrupt","" + mUserExtId);
            }
            else if(_loc13_ == "server")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: server fail");
            }
            else if(_loc13_ == "security")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: security fail");
            }
            else if(_loc13_ == "database")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: database exception","shard " + _loc4_["shard"]);
            }
            else if(_loc13_ == "exception")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: java exception");
            }
            else if(_loc13_ == "userDataInvalid")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: session invalid");
            }
            else if(_loc13_ == "msgCntNotMatch")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: packet cnt not match");
            }
            else if(_loc13_ == "forceLogout")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: force logout hacking","" + mUserExtId);
            }
            else if(_loc13_ == "moneyNegative")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: money is negative");
            }
            else if(_loc13_ == "cache")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: userData not found in cache");
            }
            else if(_loc13_ == "update_version")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: flash version is old");
            }
            else if(_loc13_ == "syncNotMatch")
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: session expired: multiple browser tabs");
            }
            else
            {
               MyMetrics.send_GA_metric("OutOfSync","Server: undefined");
            }
            DollarsGame.externalRequest(DollarsGame.REQ_GAME_PLAY_LOGOUT,{"type":_loc4_["type"]});
            if(_loc4_.hasOwnProperty("text"))
            {
               Debug.trace("*** OUT-OF-SYNC ***");
               Debug.trace("*** " + _loc4_["text"]);
               Debug.trace("*******************");
            }
         }
         this.updateLoadingState();
      }
      
      override public function login() : void
      {
         var _loc2_:UserListQuery = null;
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         var _loc3_:String = _loc1_.uid;
         if(_loc3_ == null)
         {
            _loc2_ = new UserListQuery(this.mServer);
            return;
         }
         var _loc4_:String = _loc1_.token;
         if(_loc4_ == null)
         {
            _loc4_ = "pass";
         }
         this.mServer.login(_loc3_,_loc4_);
      }
      
      override public function updatePollManager(param1:String, param2:Object, param3:XML = null) : void
      {
         if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updatePollManager() :: " + param1);
            param2.action = param1;
            if(this.DEBUG_XML)
            {
               if(param3 == null)
               {
                  param3 = new XML();
               }
               param2.xml = Server.XMLToObject(param3);
            }
            this.mServer.sendCommand("update_pollmanager",param2);
         }
      }
      
      override public function serverIsBusy() : int
      {
         return this.mServer.serverIsBusy();
      }
      
      override public function flushUniverse() : void
      {
         Debug.trace("------------------------- flushUniverse()");
         this.mServer.mForceSendAllNow = true;
      }
      
      override public function notifyWCRM(param1:String, param2:String, param3:String, param4:Object = null) : void
      {
         this.mServer.externalWCRMRequest(param1,param2,param3,param4);
      }
      
      override public function load() : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         reserveFile(TAG_UNIVERSE);
         var _loc1_:Object = new Object();
         _loc1_.targetUserId = mUserId;
         this.mServer.sendCommand("get_world",_loc1_);
         if(Config.CUSTOMIZER_FROM_SERVER)
         {
            reserveFile(TAG_CRM_CUSTOMIZER);
            this.mServer.sendCommand("get_customizer_info",this.mEmptyObject);
         }
         reserveFile(TAG_FRIEND_LIST);
         if(this.clientSideFacebookCalls)
         {
            mSocial.getFriendList();
         }
         else
         {
            this.mServer.sendCommand("get_friends_list",this.mEmptyObject);
         }
         reserveFile(TAG_NEIGHBOR_LIST);
         if(this.clientSideFacebookCalls)
         {
            mSocial.getAppFriendList();
         }
         else
         {
            this.mServer.sendCommand("get_neighbor_list",this.mEmptyObject);
         }
         reserveFile(TAG_HELP_BUILDING_LIST);
         this.mServer.sendCommand("get_help_building_list",this.mEmptyObject);
         reserveFile(TAG_UPGRADES_LIST);
         this.mServer.sendCommand("get_upgrades_list",this.mEmptyObject);
         reserveFile(TAG_UNLOCKED_LIST);
         this.mServer.sendCommand("get_unlocked_items_list",this.mEmptyObject);
         reserveFile(TAG_LIM_ED_LIST);
         this.mServer.sendCommand("get_limited_edition_items_list",this.mEmptyObject);
         reserveFile(TAG_STORAGE_LIST);
         this.mServer.sendCommand("get_storage_list",this.mEmptyObject);
         reserveFile(TAG_COLLECTIBLE_LIST);
         this.mServer.sendCommand("get_collectibles_list",this.mEmptyObject);
         reserveFile(TAG_COLLECTIBLE_PENDING_LIST);
         this.mServer.sendCommand("get_friends_collectible_sents_list",this.mEmptyObject);
         reserveFile(TAG_DAILY_BONUS_INFO);
         this.mServer.sendCommand("get_daily_rewards_info",this.mEmptyObject);
         if(Config.USE_SUPERUPGRADES)
         {
            reserveFile(TAG_UPGRADES_PARTNER_LIST);
            this.mServer.sendCommand("get_partners_list",this.mEmptyObject);
         }
         reserveFile(TAG_WELCOME_PROGRESS);
         this.mServer.sendCommand("get_welcome_progress",this.mEmptyObject);
         requestFile(TAG_GIFTS_LIST,Config.getRoot() + ModelConfig.GIFTSLIST_XML_FILE);
         reserveFile(TAG_FAN_LIST);
         if(this.clientSideFacebookCalls)
         {
            _loc2_ = Dollars.smStage.root.loaderInfo.parameters;
            _loc3_ = _loc2_.uid;
            _loc4_ = _loc2_.fan_page_id;
            Debug.trace("fan_page_id: " + _loc4_);
            mSocial.isFan(_loc3_,_loc4_);
         }
         else
         {
            requestFile(TAG_FAN_LIST,Config.getRoot() + ModelConfig.FANLIST_XML_FILE);
         }
         reserveFile(TAG_INVESTMENTS_LIST);
         this.mServer.sendCommand("get_investments_list",this.mEmptyObject);
         reserveFile(TAG_GAME_CONFIG);
         this.mServer.sendCommand("get_game_config",this.mEmptyObject);
         this.mServer.mForceSendAllNow = true;
         this.mLoadingFiles = true;
      }
      
      override public function updateMoney(param1:String, param2:Object) : void
      {
         if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            Debug.trace("------------------------- updateMoney() :: " + param1);
            param2.action = param1;
            param2.security = securityUpdate();
            this.mServer.sendCommand("update_money",param2);
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function isDoubleRent(param1:String) : Boolean
      {
         if(!mDoubleRent.hasOwnProperty(param1))
         {
            return false;
         }
         return mDoubleRent[param1];
      }
   }
}

