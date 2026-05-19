package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.ReadXMLAction;
   
   public class ActionGetFreeGiftSequenceDefinition extends ReadXMLAction
   {
      
      private var mFreeGiftDefinitionManager:FreeGiftDefinitionManager = FreeGiftDefinitionManager.getInstance();
      
      public function ActionGetFreeGiftSequenceDefinition()
      {
         super(Config.getRoot() + ModelConfig.FREE_GIFT_SEQUENCE_XML_FILE);
      }
      
      override public function destroy() : void
      {
         this.mFreeGiftDefinitionManager.destroySequenceData();
      }
      
      override protected function fromXML(param1:XML) : void
      {
         this.mFreeGiftDefinitionManager.saveSequenceData(param1);
      }
   }
}

