package com.dchoc.dollars.utils.traffic
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class TrafficAgentDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:TrafficAgentDefinitionManager;
      
      public function TrafficAgentDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: TrafficAgentDefinitionManager Error: Instantiation failed: Use TrafficAgentDefinitionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : TrafficAgentDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new TrafficAgentDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override public function load(param1:String = "") : void
      {
         super.load(Config.getRoot() + ModelConfig.DIR_CARS);
      }
   }
}

