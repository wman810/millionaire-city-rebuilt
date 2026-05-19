package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.ReadXMLAction;
   
   public class ActionGetMapDefinition extends ReadXMLAction
   {
      
      private var mMapDefinition:MapDefinition = MapDefinition.getInstance();
      
      public function ActionGetMapDefinition()
      {
         super(Config.getRoot() + ModelConfig.MAP_DEFINITION_XML_FILE);
      }
      
      override public function destroy() : void
      {
         this.mMapDefinition.destroy();
      }
      
      override protected function fromXML(param1:XML) : void
      {
         this.mMapDefinition.setPersistence(param1);
      }
   }
}

