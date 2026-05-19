package com.dchoc.dollars.world.items.commerces
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class CommerceTypeDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:CommerceTypeDefinitionManager;
      
      public function CommerceTypeDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: CommerceTypeDefinitionManager Error: Instantiation failed: Use CommerceTypeDefinitionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : CommerceTypeDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new CommerceTypeDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override public function requestLoadResources(param1:int) : void
      {
         var _loc2_:String = "common";
         PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_LOADING,mDirectoryPath + _loc2_ + ".swf",_loc2_,"swf");
      }
      
      override public function load(param1:String = "") : void
      {
         super.load(Config.getRoot() + ModelConfig.DIR_ITEMS_COMMERCE_TYPES);
      }
   }
}

