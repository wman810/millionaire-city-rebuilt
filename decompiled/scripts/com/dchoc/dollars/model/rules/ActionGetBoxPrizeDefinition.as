package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.ReadXMLAction;
   
   public class ActionGetBoxPrizeDefinition extends ReadXMLAction
   {
      
      private var mFreeGiftDefinitionManager:FreeGiftDefinitionManager = FreeGiftDefinitionManager.getInstance();
      
      public function ActionGetBoxPrizeDefinition()
      {
         super(Config.getRoot() + ModelConfig.FREE_GIFT_BOX_PRIZES_XML_FILE);
      }
      
      override public function destroy() : void
      {
         this.mFreeGiftDefinitionManager.destroySequenceData();
      }
      
      override protected function fromXML(param1:XML) : void
      {
         this.mFreeGiftDefinitionManager.buildPrizeListData(param1);
      }
   }
}

