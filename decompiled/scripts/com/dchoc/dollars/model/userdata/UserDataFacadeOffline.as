package com.dchoc.dollars.model.userdata
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.events.Event;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   
   public class UserDataFacadeOffline extends UserDataFacade
   {
      
      private var mLoadingFiles:Boolean;
      
      private var mIsFinished:Boolean;
      
      public function UserDataFacadeOffline()
      {
         super(true);
         mSocial = new SocialFacebook();
      }
      
      override public function flushUniverse() : void
      {
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            this.saveUniverse(DollarsGame.getCurrentUniverse().getPersistence());
         }
      }
      
      override public function saveUniverse(param1:XML) : void
      {
         var _loc2_:String = param1.toXMLString();
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(_loc2_);
         var _loc4_:FileReference = new FileReference();
         _loc4_.save(_loc3_,"universe.xml");
         _loc4_.addEventListener(Event.COMPLETE,this.onSaveUniverseComplete);
      }
      
      override public function load() : void
      {
         if(!this.mIsFinished)
         {
            requestFile(TAG_UNIVERSE,Config.getRoot() + ModelConfig.UNIVERSE_XML_FILE);
            requestFile(TAG_FRIEND_LIST,Config.getRoot() + ModelConfig.FRIENDSLIST_XML_FILE);
            requestFile(TAG_NEIGHBOR_LIST,Config.getRoot() + ModelConfig.NEIGHBORLIST_XML_FILE);
            requestFile(TAG_UPGRADES_LIST,Config.getRoot() + ModelConfig.UPGRADESLIST_XML_FILE);
            if(Config.USE_SUPERUPGRADES)
            {
               requestFile(TAG_UPGRADES_PARTNER_LIST,Config.getRoot() + ModelConfig.PARTNERSLIST_XML_FILE);
            }
            requestFile(TAG_HELP_BUILDING_LIST,Config.getRoot() + ModelConfig.HELPLIST_XML_FILE);
            requestFile(TAG_WELCOME_PROGRESS,Config.getRoot() + ModelConfig.WELCOME_XML_FILE);
            requestFile(TAG_GIFTS_LIST,Config.getRoot() + ModelConfig.GIFTSLIST_XML_FILE);
            requestFile(TAG_FAN_LIST,Config.getRoot() + ModelConfig.FANLIST_XML_FILE);
            requestFile(TAG_INVESTMENTS_LIST,Config.getRoot() + ModelConfig.INVESTMENTSLIST_XML_FILE);
            requestFile(TAG_GAME_CONFIG,Config.getRoot() + ModelConfig.GAME_CONFIG_XML_FILE);
            requestFile(TAG_UNLOCKED_LIST,Config.getRoot() + ModelConfig.UNLOCKEDLIST_XML_FILE);
            if(Config.AUCTIONS_ENABLED)
            {
               requestFile(TAG_AUCTIONS_LIST,Config.getRoot() + ModelConfig.AUCTIONSLIST_XML_FILE);
            }
            requestFile(TAG_LIM_ED_LIST,Config.getRoot() + ModelConfig.LIMEDLIST_XML_FILE);
            requestFile(TAG_STORAGE_LIST,Config.getRoot() + ModelConfig.STORAGELIST_XML_FILE);
            if(Config.COLLECTIBLE_FEATURE_ENABLED)
            {
               requestFile(TAG_COLLECTIBLE_LIST,Config.getRoot() + ModelConfig.COLLECTIBLELIST_XML_FILE);
               requestFile(TAG_COLLECTIBLE_PENDING_LIST,Config.getRoot() + ModelConfig.COLLECTIBLEPENDINGLIST_XML_FILE);
            }
            if(Config.DAILY_BONUS_FEATURE_ENABLED)
            {
               requestFile(TAG_DAILY_BONUS_INFO,Config.getRoot() + ModelConfig.DAILYBONUSINFO_XML_FILE);
            }
            requestFile(TAG_CRM_CUSTOMIZER,Config.getRoot() + ModelConfig.CRM_CUSTOMIZER_XML_FILE);
            mNPCSArray = new Array(100,100,101);
            this.mLoadingFiles = true;
         }
      }
      
      override public function logicUpdate(param1:int) : void
      {
         super.logicUpdate(param1);
         if(!this.mIsFinished && this.mLoadingFiles)
         {
            this.mIsFinished = allFilesLoaded();
            if(this.mIsFinished)
            {
               build();
            }
         }
      }
      
      override public function login() : void
      {
         mUserId = 0;
         timerSetTimeAtLogin();
         var _loc1_:Date = new Date();
         setServerTimeAtLogin(_loc1_.getTime());
      }
      
      override public function updateMap(param1:String, param2:String, param3:Object, param4:Object = null) : void
      {
      }
      
      override public function isLogged() : Boolean
      {
         return true;
      }
      
      override public function isLoaded() : Boolean
      {
         return this.mIsFinished;
      }
      
      override public function requestTask(param1:String, param2:Object = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(param2 == null)
         {
            param2 = new Object();
         }
         var _loc3_:Object = new Object();
         switch(param1)
         {
            case TAG_UNIVERSE:
               if(param2.userId == 0)
               {
                  requestFile(param1,Config.getRoot() + ModelConfig.UNIVERSE_XML_FILE);
                  break;
               }
               if(UserDataFacade.getInstance().isBossNPC(param2.userId))
               {
                  requestFile(param1,Config.getRoot() + ModelConfig.UNIVERSE_BOSS_XML_FILE);
                  break;
               }
               if(UserDataFacade.getInstance().isNPC(param2.userId))
               {
                  requestFile(param1,Config.getRoot() + ModelConfig.UNIVERSE_ADVISOR_XML_FILE);
                  break;
               }
               requestFile(param1,Config.getRoot() + ModelConfig.UNIVERSE_FRIEND_XML_FILE);
               break;
            case TAG_UPGRADES_ADD_ITEM:
               _loc4_ = int(param2.visitorId);
               _loc5_ = int(param2.ownerId);
               _loc6_ = param2.sid;
               trace("visitor " + _loc4_ + " has upgraded item " + _loc6_ + " in " + _loc5_ + " city ");
               break;
            case TAG_UPGRADES_REMOVE_ITEM:
               _loc5_ = int(param2.ownerId);
               _loc6_ = param2.sid;
               trace("player " + _loc5_ + " has used the upgraded of item " + _loc6_);
               break;
            case TASK_INVEST:
               switch(param2.type)
               {
                  case INVEST_TYPE_GET_INVERSION:
                     DollarsGame.externalRequest(DollarsGame.REQ_INVEST_GET_INVERSION);
                     break;
                  case INVEST_TYPE_RESULTS:
                     if(param2.success)
                     {
                        InvestDefinitionManager.getInstance().giveReward();
                     }
                     break;
                  case INVEST_TYPE_COMPLETE:
                     Dollars.checkIsFullScreen();
               }
               break;
            case TAG_CROSS_APPLICATIONS_PLAYED:
               UserDataFacade.getInstance().requestFile(TAG_CROSS_APPLICATIONS_PLAYED,Config.getRoot() + ModelConfig.CROSS_APPLICATIONS_PLAYED);
               break;
            case TASK_NEIGHBOR_LIST_RELOAD:
               UserDataFacade.getInstance().requestFile(UserDataFacade.TAG_NEIGHBOR_LIST,Config.getRoot() + ModelConfig.NEIGHBORLIST_XML_FILE);
               break;
            case TASK_SEND_COLLECTIBLE:
            case TASK_FACEBOOK_CREDITS:
            case TASK_POST_TO_FEED:
            case TASK_CREW_REQUEST:
            case TASK_BOOKMARK:
            case TASK_NEIGHBOR_REQUEST:
               Dollars.checkIsFullScreen();
               break;
            case TASK_VIDEO_AD:
               Dollars.checkIsFullScreen();
               freeFile(TAG_STORAGE_LIST);
               requestFile(TAG_STORAGE_LIST,Config.getRoot() + ModelConfig.STORAGELIST_XML_FILE);
         }
      }
      
      override public function updateNextRent(param1:String, param2:Object) : void
      {
         if(Config.DEBUG_CONSOLE)
         {
            Debug.trace("*************** updateNextRent " + param2.next_rent);
         }
      }
      
      override public function updateMoney(param1:String, param2:Object) : void
      {
         securityUpdate();
      }
      
      private function onSaveUniverseComplete(param1:Event) : void
      {
         var _loc2_:FileReference = param1.target as FileReference;
         if(_loc2_ != null)
         {
            _loc2_.removeEventListener(Event.COMPLETE,this.onSaveUniverseComplete);
         }
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_EDITOR)
         {
            RulesFacade.getInstance().universeSavePersistence();
         }
      }
      
      override public function isDoubleRent(param1:String) : Boolean
      {
         return false;
      }
   }
}

