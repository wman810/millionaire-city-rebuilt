package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   
   public class ContractBoxMultiple extends ContractBox
   {
      
      private var mItemObjects:Array;
      
      public function ContractBoxMultiple()
      {
         super();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:ContractsTypeDefinitionManager = null;
         var _loc2_:Array = null;
         var _loc3_:ContractItem = null;
         var _loc4_:ItemObject = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:ContractsTypeDefinition = null;
         var _loc8_:Array = null;
         var _loc9_:ContractDefinition = null;
         if(this.mItemObjects != null)
         {
            _loc1_ = ContractsTypeDefinitionManager.getInstance();
            _loc2_ = new Array();
            for each(_loc4_ in this.mItemObjects)
            {
               _loc7_ = _loc1_.getDefinitionBySku(_loc4_.itemDefinition.getContractsTypeSku()) as ContractsTypeDefinition;
               _loc8_ = _loc7_.getContracts();
               for each(_loc9_ in _loc8_)
               {
                  _loc3_ = this.searchContract(_loc2_,_loc9_.getNameSku());
                  if(_loc3_ == null)
                  {
                     _loc3_ = new ContractItem();
                     _loc2_.push(_loc3_);
                  }
                  _loc3_.setContractDefinition(_loc9_,_loc4_.itemDefinition.getTenants(),_loc4_.itemDefinition.type);
               }
            }
            _loc5_ = 0;
            _loc6_ = int(DollarsGame.getProfile().level);
            for each(_loc3_ in _loc2_)
            {
               _loc3_.viewBuild(_loc5_);
               addItem(_loc3_);
               _loc5_++;
            }
            _loc2_ = null;
         }
      }
      
      private function searchContract(param1:Array, param2:String) : ContractItem
      {
         var _loc3_:ContractItem = null;
         for each(_loc3_ in param1)
         {
            if(_loc3_.mContractDef.getNameSku() == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function showPopupParam(param1:Array) : void
      {
         this.mItemObjects = param1;
         super.show();
      }
   }
}

