package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.math.DChocMath;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.utils.clearInterval;
   
   public class FriendsManager
   {
      
      private static var mAllFriends:Vector.<FriendObject>;
      
      private static var mCurrentFriend:FriendObject;
      
      private static var smExtIdsToThankForHelpingBuilding:Vector.<String>;
      
      public static var smFriendsLoaded:Boolean;
      
      private static var mNeighbors:Vector.<NeighborObject>;
      
      public static var mNeighborMyself:NeighborObject;
      
      private static var mHelpFriends:Vector.<Object>;
      
      private static var mFriendsNoNeighbors:Vector.<FriendObject>;
      
      private static var mTimerID:int;
      
      private static const NPCS_EXT_ID:Array = new Array("100001135295884","100001188295998","100001211196508");
      
      private static var smFriendsRetryCount:int = 1;
      
      public function FriendsManager()
      {
         super();
      }
      
      public static function getBuildingHelp(param1:String) : Vector.<String>
      {
         var _loc5_:Object = null;
         var _loc2_:Vector.<String> = new Vector.<String>();
         var _loc3_:int = int(mHelpFriends.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = mHelpFriends[_loc4_];
            if(_loc5_.sid == param1)
            {
               _loc2_.push(_loc5_.friendExtId);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function getExtIdsToThankForHelpingBuilding() : String
      {
         var _loc1_:String = "";
         var _loc2_:int = int(smExtIdsToThankForHelpingBuilding.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += smExtIdsToThankForHelpingBuilding[_loc3_];
            if(_loc3_ < _loc2_ - 1)
            {
               _loc1_ += ",";
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public static function init() : void
      {
         var _loc1_:UserDataFacade = null;
         if(!smFriendsLoaded)
         {
            _loc1_ = UserDataFacade.getInstance();
            if(_loc1_.isFileLoaded(UserDataFacade.TAG_FRIEND_LIST) && _loc1_.isFileLoaded(UserDataFacade.TAG_NEIGHBOR_LIST))
            {
               checkFriendsLoaded();
            }
         }
      }
      
      public static function removeNeighbor(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:NeighborObject = getNeighborByExtID(param1);
         if(_loc2_ != null)
         {
            _loc3_ = mNeighbors.indexOf(_loc2_);
            mNeighbors.splice(_loc3_,1);
         }
      }
      
      public static function silhouette() : Bitmap
      {
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wonders_friend_x"))();
         var _loc2_:BitmapData = new BitmapData(_loc1_.width,_loc1_.height,true);
         _loc2_.draw(_loc1_);
         return new Bitmap(_loc2_);
      }
      
      public static function reload() : void
      {
         Debug.trace("Friends bar: Reload.");
         smFriendsLoaded = false;
         if(DollarsGame.getFriendsBar() != null)
         {
            DollarsGame.getFriendsBar().refreshBar();
         }
      }
      
      public static function getFriendsNoNeighbors() : Vector.<FriendObject>
      {
         return mFriendsNoNeighbors;
      }
      
      public static function getNeightbors() : Vector.<NeighborObject>
      {
         return mNeighbors;
      }
      
      public static function preLoad() : void
      {
         var _loc2_:XML = null;
         mHelpFriends = new Vector.<Object>();
         smExtIdsToThankForHelpingBuilding = new Vector.<String>();
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_HELP_BUILDING_LIST);
         for each(_loc2_ in _loc1_.item)
         {
            mHelpFriends.push({
               "friendExtId":_loc2_.@friendExtId,
               "sid":_loc2_.@sid
            });
         }
      }
      
      public static function getAdvisor() : FriendObject
      {
         var _loc1_:NeighborObject = null;
         for each(_loc1_ in mNeighbors)
         {
            if(_loc1_.isRonald())
            {
               return _loc1_ as FriendObject;
            }
         }
         return null;
      }
      
      public static function getFriendsByCollectibleSku(param1:String) : Vector.<NeighborObject>
      {
         var _loc3_:NeighborObject = null;
         var _loc2_:Vector.<NeighborObject> = new Vector.<NeighborObject>();
         for each(_loc3_ in mNeighbors)
         {
            if(!_loc3_.isMyself() && !_loc3_.isAdvisor())
            {
               if(_loc3_.collectibleWished(param1))
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      private static function npcsLoad() : void
      {
         var _loc7_:NeighborObject = null;
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:UserDataFacade = UserDataFacade.getInstance();
         var _loc3_:int = _loc1_.npcsGetCount();
         var _loc4_:int = DollarsGame.getProfile().bossGenre;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            if(!_loc1_.npcsIsAdvisor(_loc5_) || _loc1_.npcsIsMyAdvisor(_loc5_,_loc4_))
            {
               _loc7_ = new NeighborObject();
               _loc7_.userId = _loc2_.mNPCSArray[_loc5_];
               _loc7_.exp = _loc1_.npcsGetXp(_loc5_);
               _loc7_.companyValue = _loc1_.npcsGetCompanyValue(_loc5_);
               _loc7_.nameFriend = _loc1_.npcsGetShortName(_loc5_);
               _loc7_.setPictureURL(_loc1_.npcsGetUrl(_loc5_));
               mNeighbors.push(_loc7_);
               _loc7_.loadImage();
            }
            _loc5_++;
         }
         mFriendsNoNeighbors = new Vector.<FriendObject>();
         var _loc6_:Boolean = false;
         _loc5_ = 0;
         while(_loc5_ < mAllFriends.length)
         {
            if(mAllFriends[_loc5_].userId == -1)
            {
               mFriendsNoNeighbors.push(mAllFriends[_loc5_]);
            }
            _loc5_++;
         }
      }
      
      private static function sortCompareFunctionID(param1:FriendObject, param2:FriendObject) : Number
      {
         var _loc3_:Number = param1.userId;
         var _loc4_:Number = param2.userId;
         var _loc5_:Number = 0;
         if(_loc3_ < _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ > _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      public static function getNeighborsRandomly() : Vector.<NeighborObject>
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:NeighborObject = null;
         var _loc6_:FriendObject = null;
         var _loc1_:Vector.<NeighborObject> = new Vector.<NeighborObject>();
         if(getNeighborsNoAdvisors().length > 0)
         {
            _loc2_ = DChocMath.randomNumber(1,getNeighborsNoAdvisors().length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = DChocMath.randomNumber(0,getNeighborsNoAdvisors().length - 1);
               _loc5_ = getNeighborsNoAdvisors()[_loc4_] as NeighborObject;
               if(_loc1_.indexOf(_loc5_) <= -1)
               {
                  _loc1_.push(_loc5_);
                  _loc3_++;
               }
            }
         }
         else
         {
            _loc2_ = DChocMath.randomNumber(1,getFriendsNoAdvisors().length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = DChocMath.randomNumber(0,getFriendsNoAdvisors().length - 1);
               _loc6_ = getFriendsNoAdvisors()[_loc4_] as FriendObject;
               if(_loc1_.indexOf(_loc6_) <= -1)
               {
                  _loc1_.push(_loc6_);
                  _loc3_++;
               }
            }
         }
         _loc1_.sort(sortCompareFunctionID);
         return _loc1_;
      }
      
      public static function changeBoss() : void
      {
         var _loc2_:int = 0;
         var _loc1_:NeighborObject = getNeighborByID(UserDataFacade.getInstance().mNPCSArray[0]);
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_FEMALE)
         {
            _loc2_ = 1;
            _loc1_.nameFriend = RulesFacade.getInstance().npcsGetShortName(_loc2_);
            _loc1_.setPictureURL(RulesFacade.getInstance().npcsGetUrl(_loc2_));
         }
      }
      
      private static function sortCompareFunctionExp(param1:NeighborObject, param2:NeighborObject) : Number
      {
         var _loc3_:Number = param1.exp;
         var _loc4_:Number = param2.exp;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      public static function loadSimple() : void
      {
         var _loc3_:NeighborObject = null;
         if(mAllFriends != null)
         {
            return;
         }
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:UserDataFacade = UserDataFacade.getInstance();
         mAllFriends = new Vector.<FriendObject>();
         mNeighbors = new Vector.<NeighborObject>();
         _loc3_ = new NeighborObject();
         _loc3_.nameFriend = _loc2_.mUserName;
         _loc3_.userId = _loc2_.mUserId;
         _loc3_.extId = "" + _loc3_.userId;
         _loc3_.exp = DollarsGame.getProfile().exp;
         _loc3_.companyValue = DollarsGame.getProfile().companyValue;
         _loc3_.wishList = null;
         mNeighbors.push(_loc3_);
         mNeighborMyself = _loc3_;
         mNeighborMyself.loadImage();
         npcsLoad();
      }
      
      public static function getNeighborByID(param1:int) : NeighborObject
      {
         var _loc2_:int = 0;
         while(_loc2_ < mNeighbors.length)
         {
            if(mNeighbors[_loc2_].userId == param1)
            {
               return mNeighbors[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public static function getSortedNeightbors() : Vector.<NeighborObject>
      {
         var _loc1_:Vector.<NeighborObject> = null;
         var _loc2_:int = 0;
         if(mNeighbors != null)
         {
            _loc1_ = new Vector.<NeighborObject>(mNeighbors.length,true);
            _loc2_ = 0;
            while(_loc2_ < mNeighbors.length)
            {
               _loc1_[_loc2_] = mNeighbors[_loc2_];
               _loc2_++;
            }
            _loc1_.sort(sortCompareFunctionCompanyValue);
            return _loc1_;
         }
         return new Vector.<NeighborObject>();
      }
      
      public static function removeCollectibleFromFriendWishedList(param1:String, param2:String) : void
      {
         var _loc3_:NeighborObject = null;
         for each(_loc3_ in mNeighbors)
         {
            if(_loc3_.extId == param1)
            {
               _loc3_.removeCollectibleFromList(param2);
            }
         }
      }
      
      private static function checkFriendsLoaded() : void
      {
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:UserDataFacade = UserDataFacade.getInstance();
         var _loc3_:XML = _loc2_.getFileXML(UserDataFacade.TAG_FRIEND_LIST);
         var _loc4_:XML = _loc2_.getFileXML(UserDataFacade.TAG_NEIGHBOR_LIST);
         if(_loc3_ != null && _loc4_ != null)
         {
            clearInterval(mTimerID);
            load();
            Debug.trace("Friends bar: Create.");
            Debug.traceXML(_loc4_);
            smFriendsLoaded = true;
            UpgradesManager.getInstance().build();
            InvestManager.getInstance().load();
         }
      }
      
      public static function getFriendsNoAdvisors() : Vector.<FriendObject>
      {
         var _loc2_:FriendObject = null;
         var _loc1_:Vector.<FriendObject> = new Vector.<FriendObject>();
         for each(_loc2_ in mAllFriends)
         {
            if(!_loc2_.isMyself() && !_loc2_.isAdvisor())
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public static function getNeighborByExtID(param1:String) : NeighborObject
      {
         var _loc2_:int = 0;
         while(_loc2_ < mNeighbors.length)
         {
            if(mNeighbors[_loc2_].extId == param1)
            {
               return mNeighbors[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public static function getFriends() : Vector.<FriendObject>
      {
         return mAllFriends;
      }
      
      public static function getSortedFriends() : Vector.<FriendObject>
      {
         var _loc1_:Vector.<FriendObject> = new Vector.<FriendObject>(mAllFriends.length,true);
         var _loc2_:int = 0;
         while(_loc2_ < mAllFriends.length)
         {
            _loc1_[_loc2_] = mAllFriends[_loc2_];
            _loc2_++;
         }
         _loc1_.sort(sortCompareFunctionID);
         return _loc1_;
      }
      
      public static function addExtIdsToThankForHelpingBuilding(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Vector.<String> = getBuildingHelp(param1);
         for each(_loc3_ in _loc2_)
         {
            if(smExtIdsToThankForHelpingBuilding.indexOf(_loc3_) == -1)
            {
               smExtIdsToThankForHelpingBuilding.push(_loc3_);
            }
         }
      }
      
      private static function npcIsFriend(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < NPCS_EXT_ID.length)
         {
            if(NPCS_EXT_ID[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public static function load() : void
      {
         var _loc4_:FriendObject = null;
         var _loc5_:XML = null;
         var _loc6_:NeighborObject = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:UserDataFacade = UserDataFacade.getInstance();
         var _loc3_:XML = _loc2_.getFileXML(UserDataFacade.TAG_FRIEND_LIST);
         mAllFriends = new Vector.<FriendObject>();
         for each(_loc5_ in _loc3_.friend)
         {
            _loc7_ = _loc5_.@extId;
            if(!npcIsFriend(_loc7_))
            {
               _loc4_ = new FriendObject();
               _loc4_.extId = _loc7_;
               _loc4_.nameFriend = _loc5_.@name;
               _loc4_.userId = int(_loc5_.@userId);
               mAllFriends.push(_loc4_);
            }
         }
         _loc3_ = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_NEIGHBOR_LIST);
         mNeighbors = new Vector.<NeighborObject>();
         for each(_loc5_ in _loc3_.neighbor)
         {
            _loc8_ = int(_loc5_.@id);
            _loc4_ = getFriendPlayerByID(_loc8_);
            if(_loc4_ != null)
            {
               _loc6_ = new NeighborObject();
               _loc6_.extId = _loc4_.extId;
               _loc6_.nameFriend = _loc4_.nameFriend;
               _loc6_.userId = _loc8_;
               _loc6_.exp = Number(_loc5_.@xp);
               _loc6_.companyValue = Number(_loc5_.@companyValue);
               _loc9_ = String(_loc5_.@collectiblesRequested).split(",");
               _loc6_.wishList = _loc9_;
               mNeighbors.push(_loc6_);
            }
         }
         _loc6_ = new NeighborObject();
         _loc6_.nameFriend = _loc2_.mUserName;
         _loc6_.userId = _loc2_.mUserId;
         _loc6_.extId = _loc2_.mUserExtId;
         _loc6_.exp = DollarsGame.getProfile().exp;
         _loc6_.companyValue = DollarsGame.getProfile().companyValue;
         _loc6_.wishList = null;
         mNeighbors.push(_loc6_);
         mNeighborMyself = _loc6_;
         mNeighborMyself.loadImage();
         npcsLoad();
         UpgradesManager.getInstance().partnersReload();
      }
      
      public static function getFriendPlayerByID(param1:int) : FriendObject
      {
         var _loc2_:int = 0;
         while(_loc2_ < mAllFriends.length)
         {
            if(mAllFriends[_loc2_].userId == param1)
            {
               return mAllFriends[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private static function sortCompareFunctionCompanyValue(param1:NeighborObject, param2:NeighborObject) : Number
      {
         var _loc3_:Number = param1.companyValue;
         var _loc4_:Number = param2.companyValue;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      public static function getFriendByID(param1:String) : FriendObject
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 != null)
         {
            _loc2_ = int(mAllFriends.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(mAllFriends[_loc3_].extId == param1)
               {
                  return mAllFriends[_loc3_];
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      public static function get currentFriend() : FriendObject
      {
         return mCurrentFriend;
      }
      
      public static function set currentFriend(param1:FriendObject) : void
      {
         mCurrentFriend = param1;
      }
      
      public static function getNeighborsNoAdvisors() : Vector.<NeighborObject>
      {
         var _loc2_:NeighborObject = null;
         var _loc1_:Vector.<NeighborObject> = new Vector.<NeighborObject>();
         for each(_loc2_ in mNeighbors)
         {
            if(!_loc2_.isMyself() && !_loc2_.isAdvisor())
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
   }
}

