package com.dchoc.dollars.world.items.wonders
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   
   public class WonderTypeDefinition extends Definition
   {
      
      private static const TYPE_NPC_INCOME:String = "npcIncome";
      
      private static const TYPE_INFLUENCE:String = "influence";
      
      public function WonderTypeDefinition(param1:int)
      {
         super(param1);
      }
      
      public function getTidDescription(param1:String = null) : int
      {
         return tid + ItemDefinition.getTypeIDFromName(param1);
      }
      
      public function doEffect(param1:ItemObject) : void
      {
         if(!param1.isSuspended && DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            if(param1.itemDefinition.isSubtypeOf(TYPE_NPC_INCOME))
            {
               DollarsGame.getProfile().registerEventsAdd(Profile.REGISTER_EVENT_NPC_INCOME + param1.itemDefinition.target);
            }
            else
            {
               param1.company.attributesAddValue(sku,param1.getIncomeCoins(),param1.itemDefinition.target);
            }
         }
      }
      
      public function undoEffect(param1:ItemObject) : void
      {
         if(param1.isBuilt() && DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            if(param1.itemDefinition.isSubtypeOf(TYPE_NPC_INCOME))
            {
               DollarsGame.getProfile().registerEventsRemove(Profile.REGISTER_EVENT_NPC_INCOME + param1.itemDefinition.target);
            }
            else
            {
               param1.company.attributesAddValue(sku,-param1.getIncomeCoins(),param1.itemDefinition.target);
            }
         }
      }
   }
}

