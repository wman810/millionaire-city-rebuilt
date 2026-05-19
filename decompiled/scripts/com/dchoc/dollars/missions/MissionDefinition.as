package com.dchoc.dollars.missions
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardExp;
   import com.dchoc.dollars.rewards.RewardItem;
   import com.dchoc.dollars.rewards.RewardManager;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class MissionDefinition extends Definition
   {
      
      private static const EVENT_NONE:String = "none";
      
      public static const TEXT_TITLE:int = 0;
      
      public static const TEXT_DESC:int = 1;
      
      public static const TEXT_COUNT:int = 2;
      
      public static const NO_CONDITION:int = -1;
      
      private var mEventType:String;
      
      private var mMissionName:String;
      
      private var mEventCondition:Number;
      
      private var mSkuToLoad:String;
      
      private var mInitialized:Boolean;
      
      private var mRewardTypeABTest:Array;
      
      private var mRewardAmountABTest:Array;
      
      private var mUnlockSku:String;
      
      private var mTextID:String;
      
      private var mRewardType:String;
      
      private var mShowProgress:Boolean;
      
      private var mCheckInRoleVisitor:Boolean;
      
      private var mShowInABTest:String;
      
      private var mEventAmount:uint;
      
      private var mUnlockLevel:int;
      
      private var mRewardAmount:String;
      
      private var mRewards:Array;
      
      private var mImageDO:Sprite;
      
      private var mEventParameter:String;
      
      private var mImageIsRequired:Boolean;
      
      public function MissionDefinition(param1:uint)
      {
         super(param1);
         this.mEventType = EVENT_NONE;
         this.mRewards = new Array();
         this.mUnlockLevel = -1;
         this.mUnlockSku = "";
         this.mEventCondition = NO_CONDITION;
         this.mShowProgress = true;
         this.mRewardTypeABTest = new Array();
         this.mRewardAmountABTest = new Array();
      }
      
      public function needsToBeInitialized() : Boolean
      {
         return this.eventType == MissionsEventIDs.MISSION_EVENT_REPAIR && StateOnRent.smItemsBrokenCount == 0;
      }
      
      public function set unlockSku(param1:String) : void
      {
         this.mUnlockSku = param1;
      }
      
      public function setRewardAmountABTest(param1:int, param2:String) : void
      {
         this.mRewardAmountABTest[param1] = param2;
      }
      
      public function setShowInABTest(param1:String) : void
      {
         this.mShowInABTest = param1;
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      public function setRewardType(param1:String) : void
      {
         this.mRewardType = param1;
      }
      
      public function showArrow() : Boolean
      {
         return this.mEventType == "nameCity" && DollarsGame.getProfile().firstMission;
      }
      
      public function getTextTitle() : String
      {
         return TextManager.getText(TextIDs[this.mTextID + "_TITLE"]);
      }
      
      public function get eventAmount() : uint
      {
         return this.mEventAmount;
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function getEventSku() : String
      {
         return this.eventType + this.eventParameter;
      }
      
      public function getRewards() : Array
      {
         return this.mRewards;
      }
      
      public function setCheckInRoleVisitor(param1:Boolean) : void
      {
         this.mCheckInRoleVisitor = param1;
      }
      
      public function getImageDO() : Sprite
      {
         return this.mImageDO;
      }
      
      public function setRewardTypeABTest(param1:int, param2:String) : void
      {
         this.mRewardTypeABTest[param1] = param2;
      }
      
      public function initialize() : void
      {
         var _loc1_:Company = null;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:ItemObject = null;
         var _loc5_:int = 0;
         if(this.eventType == MissionsEventIDs.MISSION_EVENT_REPAIR && StateOnRent.smItemsBrokenCount == 0)
         {
            _loc1_ = DollarsGame.getCurrentWorld().getCompanyMine();
            _loc2_ = _loc1_.getItems();
            _loc3_ = int(_loc2_.length);
            _loc4_ = null;
            _loc5_ = 0;
            while(_loc5_ < _loc3_ && _loc4_ == null)
            {
               _loc4_ = _loc2_[_loc5_] as ItemObject;
               _loc5_++;
            }
         }
      }
      
      public function get unlockLevel() : int
      {
         return this.mUnlockLevel;
      }
      
      public function get eventCondition() : Number
      {
         return this.mEventCondition;
      }
      
      public function getText(param1:int) : String
      {
         var _loc2_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:ItemDefinition = null;
         var _loc3_:int = tid + param1;
         _loc2_ = TextManager.getText(_loc3_);
         if(this.mEventType == MissionsEventIDs.MISSION_EVENT_VISIT_CITY)
         {
            _loc4_ = TextIDs.TID_RONALD_NAME;
            _loc5_ = TextManager.getText(_loc4_ + DollarsGame.getProfile().bossGenre);
            _loc2_ = TextManager.replaceParameters(_loc3_,new Array(_loc5_));
         }
         else if(this.mEventParameter != null && this.mEventParameter != "")
         {
            _loc6_ = false;
            _loc7_ = int(ItemDefinition.NAME_TYPES.length);
            _loc8_ = 0;
            while(_loc8_ < _loc7_ && !_loc6_)
            {
               _loc9_ = ItemDefinition.NAME_TYPES[_loc8_] as String;
               _loc6_ = _loc9_ == this.mEventParameter;
               _loc8_++;
            }
            if(!_loc6_)
            {
               _loc10_ = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mEventParameter) as ItemDefinition;
               if(_loc10_ != null)
               {
                  _loc2_ = TextManager.replaceParameters(_loc3_,new Array(TextManager.getText(TextIDs[_loc10_.textID])));
               }
            }
         }
         return _loc2_;
      }
      
      public function set eventAmount(param1:uint) : void
      {
         this.mEventAmount = param1;
      }
      
      public function getReward(param1:int = 0) : Reward
      {
         return this.mRewards[param1];
      }
      
      public function get imageIsRequired() : Boolean
      {
         return this.mImageIsRequired;
      }
      
      public function get eventParameter() : String
      {
         return this.mEventParameter;
      }
      
      public function getRewardTypeABTest(param1:int) : String
      {
         return this.mRewardTypeABTest[param1];
      }
      
      public function get missionName() : String
      {
         return this.mMissionName;
      }
      
      public function get unlockSku() : String
      {
         return this.mUnlockSku;
      }
      
      public function getCheckInRoleVisitor() : Boolean
      {
         return this.mCheckInRoleVisitor;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return this.imageIsRequired;
      }
      
      public function hasTrigger() : Boolean
      {
         return this.mEventAmount > 0;
      }
      
      public function addReward(param1:Reward) : void
      {
         this.mRewards.push(param1);
      }
      
      public function set unlockLevel(param1:int) : void
      {
         this.mUnlockLevel = param1;
      }
      
      public function set eventCondition(param1:Number) : void
      {
         this.mEventCondition = param1;
      }
      
      public function hasUnlockSku() : Boolean
      {
         return this.mUnlockSku != "";
      }
      
      override public function getSkuToLoad() : String
      {
         if(this.mSkuToLoad == null)
         {
            this.mSkuToLoad = this.eventType + "_";
            if(this.mEventType == MissionsEventIDs.MISSION_EVENT_BEAT)
            {
               this.mSkuToLoad += this.mEventCondition;
            }
            else
            {
               this.mSkuToLoad += this.eventParameter;
            }
         }
         return this.mSkuToLoad;
      }
      
      public function getShowInABTest() : String
      {
         return this.mShowInABTest;
      }
      
      public function showProgress() : Boolean
      {
         return this.mShowProgress && (this.mEventAmount > 1 || this.mEventCondition > 1);
      }
      
      public function setShowProgress(param1:Boolean) : void
      {
         this.mShowProgress = param1;
      }
      
      public function getTextDescription(param1:Boolean = false) : String
      {
         var _loc2_:String = TextManager.getText(TextIDs[this.mTextID + "_DESC"]);
         if(param1 && TextIDs[this.mTextID + "_DESC_TIP"] != null)
         {
            _loc2_ += TextManager.getText(TextIDs[this.mTextID + "_DESC_TIP"]);
         }
         return TextManager.replaceParameters(_loc2_,new Array("" + this.eventAmount));
      }
      
      public function set eventParameter(param1:String) : void
      {
         var _loc5_:String = null;
         this.mEventParameter = param1;
         var _loc2_:Boolean = false;
         var _loc3_:int = int(ItemDefinition.NAME_TYPES.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_ && !_loc2_)
         {
            _loc5_ = ItemDefinition.NAME_TYPES[_loc4_] as String;
            _loc2_ = _loc5_ == param1;
            _loc4_++;
         }
      }
      
      public function isReadyToBeUp() : Boolean
      {
         var _loc2_:Company = null;
         var _loc3_:int = 0;
         var _loc1_:Boolean = true;
         if(this.eventType == MissionsEventIDs.MISSION_EVENT_REPAIR)
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            _loc3_ = _loc2_.getItemsCountByType(ItemDefinition.TYPE_HOUSES_ID);
            _loc1_ = _loc3_ > 0;
         }
         return _loc1_;
      }
      
      public function getCheckCondition() : Boolean
      {
         return this.mEventCondition > NO_CONDITION;
      }
      
      public function toString() : String
      {
         return this.mEventType + "_" + this.mEventParameter + "_" + this.mEventCondition;
      }
      
      override public function build() : void
      {
         var _loc1_:String = null;
         var _loc2_:Class = null;
         var _loc3_:TextField = null;
         var _loc4_:String = null;
         if(!this.mInitialized)
         {
            this.mInitialized = true;
            if(this.mEventType == MissionsEventIDs.MISSION_EVENT_BEAT)
            {
               this.eventCondition = RulesFacade.getInstance().npcsGetCompanyValue(this.mEventCondition);
            }
         }
         this.parseRewards();
         if(this.imageIsRequired)
         {
            _loc1_ = this.getSkuToLoad();
            _loc2_ = DCResourceManager.getInstance().getSWFClass(_loc1_,"image");
            if(_loc2_ != null)
            {
               this.mImageDO = new _loc2_();
               _loc3_ = this.mImageDO.getChildByName("TextInfo") as TextField;
               if(_loc3_ != null)
               {
                  _loc4_ = "";
                  if(this.eventType == MissionsEventIDs.MISSION_EVENT_CHECK_BONUS)
                  {
                     _loc4_ += TextManager.getPercentageText(this.eventCondition);
                  }
                  else
                  {
                     _loc4_ += this.eventCondition;
                  }
                  _loc3_.text = _loc4_;
               }
            }
            else if(Config.DEBUG_MODE)
            {
               Debug.trace("Resource not loaded and required: resName: " + _loc1_ + " className: " + "image");
            }
         }
      }
      
      public function set eventType(param1:String) : void
      {
         this.mEventType = param1;
      }
      
      public function setRewardAmount(param1:String) : void
      {
         this.mRewardAmount = param1;
      }
      
      public function parseRewards() : void
      {
         var _loc1_:Reward = null;
         var _loc2_:Array = this.mRewardType.split(";");
         var _loc3_:Array = this.mRewardAmount.split(";");
         this.mRewards.length = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            switch(_loc2_[_loc4_])
            {
               case RewardManager.REWARD_COINS_ID:
                  _loc1_ = new RewardCoins(_loc3_[_loc4_]);
                  this.addReward(_loc1_);
                  break;
               case RewardManager.REWARD_EXP_ID:
                  _loc1_ = new RewardExp(_loc3_[_loc4_]);
                  this.addReward(_loc1_);
                  break;
               default:
                  _loc1_ = new RewardItem(_loc3_[_loc4_],_loc2_[_loc4_]);
                  this.addReward(_loc1_);
                  ItemDefinitionManager.getInstance().requestLoadResourcesBySku(_loc2_[_loc4_],PriorityLoader.QUEUE_LOADING);
            }
            _loc4_++;
         }
      }
      
      override public function getTidsCount() : int
      {
         return TEXT_COUNT;
      }
      
      public function setImageIsRequired(param1:Boolean) : void
      {
         this.mImageIsRequired = param1;
      }
      
      public function get eventType() : String
      {
         return this.mEventType;
      }
      
      public function set missionName(param1:String) : void
      {
         this.mMissionName = param1;
      }
      
      public function getRewardAmountABTest(param1:int) : String
      {
         return this.mRewardAmountABTest[param1];
      }
   }
}

