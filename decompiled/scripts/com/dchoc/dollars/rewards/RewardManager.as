package com.dchoc.dollars.rewards
{
   import flash.utils.Dictionary;
   
   public class RewardManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:RewardManager;
      
      public static const REWARD_EXP_ID:String = "exp";
      
      public static const REWARD_COINS_ID:String = "coins";
      
      public static const REWARD_ITEM_ID:String = "item";
      
      public static const REWARD_COLLECTIBLE_ID:String = "collectible";
      
      public static const REWARD_GIFT_ID:String = "gift";
      
      public static const REWARD_VIEW_MISSIONS_ID:int = 0;
      
      public static const REWARD_VIEW_NEWS_FEED_ID:int = 1;
      
      public static const DESC_ID:int = 0;
      
      public static const GIVEN_ID:int = 1;
      
      private var mCatalogDictionary:Dictionary;
      
      public function RewardManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: RewardManager Error: Instantiation failed: Use RewardManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : RewardManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new RewardManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function destroy() : void
      {
         this.mCatalogDictionary = null;
         smInstance = null;
         smAllowInstantiation = true;
      }
      
      public function getReward(param1:Array) : Reward
      {
         var _loc3_:RewardComposite = null;
         var _loc4_:int = 0;
         var _loc2_:int = int(param1.length);
         if(_loc2_ > 1)
         {
            _loc3_ = new RewardComposite();
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_.addReward(param1[_loc4_]);
               _loc4_++;
            }
            return _loc3_;
         }
         return param1[0];
      }
      
      private function load() : void
      {
      }
   }
}

