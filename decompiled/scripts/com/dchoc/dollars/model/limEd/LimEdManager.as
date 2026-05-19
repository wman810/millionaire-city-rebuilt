package com.dchoc.dollars.model.limEd
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class LimEdManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:LimEdManager;
      
      public function LimEdManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: LimEdManager Error: Instantiation failed: Use LimEdManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : LimEdManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new LimEdManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function destroy() : void
      {
      }
      
      public function updateItem(param1:String, param2:int, param3:Number) : void
      {
         var _loc4_:ItemDefinition = null;
         var _loc5_:Date = null;
         var _loc6_:Number = NaN;
         if(param1 != null)
         {
            _loc4_ = ItemDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDefinition;
            if(param3 > 0)
            {
               _loc5_ = new Date(param3);
               _loc6_ = RulesFacade.getInstance().settingsLimEdSoldOutShowTime();
               _loc4_.setExpireTime(param3 + _loc6_);
               param2 = 0;
            }
            _loc4_.setUnitsAmount(param2);
         }
      }
      
      public function build() : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:ItemDefinition = null;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_LIM_ED_LIST);
         var _loc2_:ItemDefinitionManager = ItemDefinitionManager.getInstance();
         var _loc3_:Number = RulesFacade.getInstance().settingsLimEdSoldOutShowTime();
         for each(_loc4_ in _loc1_.limEd)
         {
            _loc5_ = _loc4_.@sku;
            _loc6_ = _loc2_.getDefinitionBySku(_loc5_) as ItemDefinition;
            if(_loc6_ != null)
            {
               _loc7_ = int(_loc4_.@unitsAmount);
               _loc8_ = Number(_loc4_.@lastLegalBuyTime);
               if(_loc8_ > 0)
               {
                  _loc6_.setExpireTime(_loc8_ + _loc3_);
                  _loc7_ = 0;
               }
               _loc6_.setUnitsAmount(_loc7_);
            }
         }
      }
      
      public function load() : void
      {
      }
   }
}

