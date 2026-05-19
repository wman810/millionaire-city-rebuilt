package com.dchoc.dollars.model.services
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   import flash.utils.Dictionary;
   
   public class ServiceDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ServiceDefinitionManager;
      
      private var mDefinitionsCurrentContractIdPerType:Dictionary;
      
      private var mDefinitionsTypesCount:int;
      
      private var mDefinitionsTypesSkus:Dictionary;
      
      public function ServiceDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ServiceDefinitionManager Error: Instantiation failed: Use ServiceDefinitionManager.getInstance() instead of new.");
         }
         this.mDefinitionsTypesSkus = new Dictionary(true);
         this.mDefinitionsCurrentContractIdPerType = new Dictionary(true);
         this.mDefinitionsTypesCount = 0;
         load();
      }
      
      public static function getInstance() : ServiceDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ServiceDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function cheatTime(param1:Number) : void
      {
         var _loc3_:ServiceDefinition = null;
         var _loc2_:* = int(mDefinitions.length);
         while(_loc2_ > -1)
         {
            for each(_loc3_ in mDefinitions[_loc2_])
            {
               _loc3_.cheatTime(param1);
            }
            _loc2_--;
         }
      }
      
      public function hasTimeAvailable(param1:String) : Boolean
      {
         var _loc2_:String = this.getSkuFromTypeAndContract(param1,0);
         var _loc3_:ServiceDefinition = getDefinitionBySku(_loc2_) as ServiceDefinition;
         return _loc3_.getTimeAvailable() > 0;
      }
      
      public function getServiceLockable(param1:int) : ServiceDefinition
      {
         var _loc5_:ServiceDefinition = null;
         var _loc2_:ServiceDefinition = null;
         var _loc3_:Array = getDefinitions(param1);
         var _loc4_:* = int(_loc3_.length - 1);
         while(_loc4_ > -1 && _loc2_ == null)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc5_.isLockable())
            {
               _loc2_ = _loc5_;
            }
            _loc4_--;
         }
         return _loc2_;
      }
      
      public function getServiceDefinition(param1:String, param2:int = 0) : Definition
      {
         var _loc3_:String = this.getSkuFromTypeAndContract(param1,param2);
         return getDefinitionBySku(_loc3_);
      }
      
      override public function addDefinition(param1:Definition) : void
      {
         var _loc2_:ServiceDefinition = param1 as ServiceDefinition;
         if(this.mDefinitionsTypesSkus[param1.sku] == null)
         {
            this.mDefinitionsTypesSkus[param1.sku] = this.mDefinitionsTypesCount;
            ++this.mDefinitionsTypesCount;
            mTypeSkus.push(param1.sku);
            this.mDefinitionsCurrentContractIdPerType[param1.sku] = 0;
         }
         _loc2_.type = this.mDefinitionsTypesSkus[param1.sku];
         _loc2_.setContractId(this.mDefinitionsCurrentContractIdPerType[param1.sku]);
         ++this.mDefinitionsCurrentContractIdPerType[param1.sku];
         _loc2_.sku = this.getSkuFromTypeAndContract(_loc2_.sku,_loc2_.getContractId());
         super.addDefinitionType(_loc2_,_loc2_.type);
      }
      
      public function getSkuFromTypeAndContract(param1:String, param2:int = 0) : String
      {
         return param1 + "_" + param2;
      }
   }
}

