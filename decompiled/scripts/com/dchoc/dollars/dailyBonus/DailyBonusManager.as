package com.dchoc.dollars.dailyBonus
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class DailyBonusManager
   {
      
      private static var smAllowInstantation:Boolean;
      
      private static var smInstance:DailyBonusManager;
      
      private var mCash:int;
      
      private var mDailyBonusDefinition:DailyBonusDefinition;
      
      private var mCurrentDailyBonusSku:String;
      
      private var mDailyBonusList:Array;
      
      private var mCoins:int;
      
      private var mItem:String;
      
      private var mLastDailyBonusDateInMs:Number;
      
      private var mExp:int;
      
      private var mDailyBonusCount:int;
      
      public function DailyBonusManager()
      {
         super();
         if(!smAllowInstantation)
         {
            throw new Error("ERROR: DailyBonusManager Error: Instantiation failed: Use DailyBonusnManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : DailyBonusManager
      {
         if(!smInstance)
         {
            smAllowInstantation = true;
            smInstance = new DailyBonusManager();
            smAllowInstantation = false;
         }
         return smInstance;
      }
      
      public function isTimeExpired() : Boolean
      {
         var _loc1_:Date = new Date(UserDataFacade.getInstance().getServerTimeAtLogin());
         var _loc2_:Number = _loc1_.getDate();
         return _loc2_ - this.mLastDailyBonusDateInMs >= 2;
      }
      
      public function keepDailyBonus(param1:String) : void
      {
         var _loc3_:ItemDefinition = null;
         this.mDailyBonusDefinition = DailyBonusDefinitionManager.getInstance().getDefinitionBySku(param1) as DailyBonusDefinition;
         this.mExp = 0;
         this.mCash = 0;
         this.mCoins = 0;
         switch(this.mDailyBonusDefinition.bonusType)
         {
            case DailyBonusDefinition.TYPE_EXP:
               this.mExp = int(this.mDailyBonusDefinition.value);
               DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + this.mExp;
               break;
            case DailyBonusDefinition.TYPE_CASH:
               this.mCash = int(this.mDailyBonusDefinition.value);
               DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + this.mCash;
               break;
            case DailyBonusDefinition.TYPE_COINS:
               this.mCoins = int(this.mDailyBonusDefinition.value);
               if(this.mDailyBonusDefinition.getDate() != 0)
               {
                  this.mCoins *= DollarsGame.getProfile().level;
               }
               DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + this.mCoins;
               break;
            case DailyBonusDefinition.TYPE_ITEM:
               _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mDailyBonusDefinition.value) as ItemDefinition;
               this.mItem = _loc3_.sku;
               StorageManager.getInstance().addItem(this.mItem,1);
         }
         var _loc2_:Object = UserDataFacade.securityCreateObj(this.mExp,this.mCoins,this.mCash);
         _loc2_.item = this.mItem;
         UserDataFacade.getInstance().updateRewards(param1,{},_loc2_);
      }
      
      public function isBonusEnabled() : Boolean
      {
         var _loc1_:Date = new Date(UserDataFacade.getInstance().getServerTimeAtLogin());
         var _loc2_:Number = _loc1_.time - this.mLastDailyBonusDateInMs;
         var _loc3_:Number = _loc2_ / 1000 / 60 / 60 / 24;
         return Math.abs(_loc3_) >= 1;
      }
      
      public function build() : void
      {
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_DAILY_BONUS_INFO);
         this.mDailyBonusCount = int(_loc1_.@dailyRewardsCount);
         var _loc2_:String = _loc1_.@dailyRewardsLastGiven;
         this.mLastDailyBonusDateInMs = Number(_loc1_.@dailyRewardsLastGivenDate);
         this.mCurrentDailyBonusSku = _loc1_.@dailyRewardsNextRewardId;
         this.mDailyBonusList = _loc2_.split(",");
         if(this.mDailyBonusList.length <= 1 && this.mDailyBonusList[0] == "")
         {
            this.mDailyBonusList.splice(0);
         }
      }
      
      public function getCurrentDailyBonusSku() : String
      {
         return this.mCurrentDailyBonusSku;
      }
      
      public function getCollectedDailyBonuses() : Array
      {
         return this.mDailyBonusList;
      }
      
      public function getDailyBonusCount() : int
      {
         return this.mDailyBonusCount;
      }
   }
}

