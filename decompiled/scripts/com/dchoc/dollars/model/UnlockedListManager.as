package com.dchoc.dollars.model
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class UnlockedListManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:UnlockedListManager;
      
      public function UnlockedListManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: UnlockedListManager Error: Instantiation failed: Use UnlockedListManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : UnlockedListManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new UnlockedListManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function build() : void
      {
         var _loc3_:XML = null;
         var _loc4_:ItemDefinition = null;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_UNLOCKED_LIST);
         var _loc2_:ItemDefinitionManager = ItemDefinitionManager.getInstance();
         for each(_loc3_ in _loc1_.item)
         {
            _loc4_ = _loc2_.getDefinitionBySku(_loc3_.@sku) as ItemDefinition;
            if(_loc4_ != null)
            {
               _loc4_.setNeedsToCheckLocked(false);
            }
         }
      }
      
      public function unlockItem(param1:ItemDefinition) : void
      {
         param1.setNeedsToCheckLocked(false);
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:int = param1.getUnlockPrice(false);
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc2_.DCCash < _loc3_)
         {
            _loc3_ = param1.getUnlockPrice();
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_EARLY_UNLOCK,MetricConstants.PRODUCT_ITEM,param1.itemName,null,0,_loc3_);
         }
         else
         {
            DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash - _loc3_;
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_EARLY_UNLOCK,MetricConstants.PRODUCT_ITEM,param1.itemName,null,0,_loc3_);
         }
         UserDataFacade.getInstance().updateMoney("unlockItem",{"value":param1.sku});
         Debug.trace("############# UNLOCK ITEM: " + param1.sku + " price = " + _loc3_);
      }
   }
}

