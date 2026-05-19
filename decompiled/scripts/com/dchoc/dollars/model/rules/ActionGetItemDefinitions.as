package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class ActionGetItemDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetItemDefinitions(param1:String, param2:int, param3:int)
      {
         super(ItemDefinitionManager.getInstance(),param1,param2,param3,!Config.SMART_RESOURCE_LOADING);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc3_:XML = null;
         var _loc2_:ItemDefinition = super.itemFromXML(param1) as ItemDefinition;
         this.itemCommonFromXML(_loc2_,param1);
         for each(_loc3_ in param1.decoration)
         {
            _loc2_.decoration = _loc3_.@sku;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ItemDefinition(mType);
      }
      
      protected function itemCommonFromXML(param1:ItemDefinition, param2:XML) : void
      {
         param1.baseRows = int(param2.@baseRows);
         param1.baseCols = int(param2.@baseCols);
         param1.shadowRows = int(param2.@shadowRows);
         var _loc3_:int = int(param2.@isAnimated);
         param1.isAnimated = _loc3_ == 1;
         param1.itemName = param2.@buildingsName;
         param1.subtype = param2.@subtype;
         param1.target = param2.@target;
         param1.shopTab = param2.@shopTab;
         param1.setContractsTypeSku(param2.@contractsTypeSku);
         param1.setUnlockCondition(param2.@unlockCondition);
         if("@featured" in param2)
         {
            param1.setIsFeatured(true);
            ItemDefinitionManager.getInstance().addItemDefinitionFeatured(param1);
         }
         if("@freeGift" in param2)
         {
            param1.freeGift = int(param2.@freeGift) == 1;
         }
         if("@releaseTime" in param2)
         {
            param1.setReleaseTimeFromString(param2.@releaseTime);
         }
         if("@expireTime" in param2)
         {
            param1.setExpireTimeFromString(param2.@expireTime);
         }
         if("@unlockCash" in param2)
         {
            param1.setUnlockCash(int(param2.@unlockCash));
         }
         if("@unitsAmount" in param2)
         {
            param1.setUnitsAmount(int(param2.@unitsAmount));
         }
         if("@extraType" in param2)
         {
            param1.extraType = param2.@extraType;
         }
         if("@tid" in param2)
         {
            param1.textID = param2.@tid;
         }
         if("@useAdvisor" in param2)
         {
            param1.useAdvisor = true;
         }
         param1.constructionCoins = int(param2.@constructionCoins);
         param1.constructionCash = int(param2.@constructionCash);
         param1.constructionFBC = int(param2.@constructionFBC);
         param1.constructionFBCnoCash = int(param2.@constructionFBCnoCash);
         param1.constructionTime = Number(param2.@constructionTime);
         param1.constructionCrewSku = param2.@constructionCrew;
         param1.setMoveCoins(int(param2.@movePriceCoins));
         param1.setMoveCash(int(param2.@movePriceCash));
         param1.experience = int(param2.@exp);
         param1.eventOnTime = int(param2.@eventOnTime);
         param1.incomeLevelFactor = Number(param2.@incomeLevelFactor);
         param1.incomeValue = int(param2.@incomeValue);
         param1.incomeTime = Number(param2.@incomeTime);
         param1.incomeXP = int(param2.@incomeXP);
         param1.influenceRatio = int(param2.@influenceRatio);
         param1.influenceValue = Number(param2.@influenceValue);
         param1.setCompanyValue(param2.@companyValue);
         switch(mType)
         {
            case ItemDefinition.TYPE_HOUSES_ID:
               mSig += param2.@contractsTypeSku;
               break;
            case ItemDefinition.TYPE_COMMERCES_ID:
               mSig += param2.@incomeValue + param2.@incomeTime;
               break;
            case ItemDefinition.TYPE_DECORATIONS_ID:
               mSig += param2.@influenceValue + param2.@influenceRatio;
               break;
            case ItemDefinition.TYPE_WONDERS_ID:
               mSig += param2.@incomeValue;
         }
         if("@shopIcon" in param2)
         {
            param1.setShopIcon(param2.@shopIcon);
         }
         if("@where" in param2)
         {
            param1.setWhere(param2.@where);
         }
         if("@amountofHelp" in param2)
         {
            param1.setAmountOfHelp(param2.@amountofHelp);
         }
         param1.setInstantBuildType(param2.@instantBuildType);
         if("@instantBuildTypeABTest" in param2)
         {
            param1.setInstantBuildTypeABTest(param2.@instantBuildTypeABTest);
         }
         param1.setInstantBuildFactor(Number(param2.@instantBuildFactor));
         if(param1.getInstantBuildType().indexOf("FBC") >= 0)
         {
            param1.setInstantBuildFBC(int(param2.@instantBuildFBC));
            if("@instantBuildFBCABtest" in param2)
            {
               param1.setInstantBuildFBCABTest(int(param2.@instantBuildFBCABtest));
            }
         }
         if("@tenants" in param2)
         {
            param1.setTenants(int(param2.@tenants));
         }
         if("@showInABTest" in param2)
         {
            param1.showsInABTest = param2.@showInABTest;
         }
      }
   }
}

