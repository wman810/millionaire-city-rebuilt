package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   
   public class ContractBoxSingle extends ContractBox
   {
      
      private var mItemObject:ItemObject;
      
      public function ContractBoxSingle()
      {
         super();
      }
      
      override protected function onDoContract(param1:Boolean = false) : void
      {
         this.mItemObject.setContractSku(mCurrentContractItem.mContractDef.sku);
         this.mItemObject.getCurrentState().eventsProcess({"cmd":StateOnRent.CMD_SIGN_CONTRACT});
      }
      
      override protected function createItems() : void
      {
         var _loc2_:Array = null;
         var _loc3_:ContractDefinition = null;
         var _loc4_:int = 0;
         var _loc5_:ContractItem = null;
         var _loc1_:ContractsTypeDefinition = ContractsTypeDefinitionManager.getInstance().getDefinitionBySku(this.mItemObject.itemDefinition.getContractsTypeSku()) as ContractsTypeDefinition;
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.getContracts();
            if(_loc2_ != null)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc2_.length)
               {
                  _loc5_ = new ContractItem();
                  _loc5_.setContractDefinition(_loc2_[_loc4_] as ContractDefinition,this.mItemObject.itemDefinition.getTenants(),this.mItemObject.itemDefinition.type);
                  _loc5_.viewBuild(_loc4_);
                  addItem(_loc5_);
                  _loc4_++;
               }
            }
         }
      }
      
      public function showPopupParam(param1:ItemObject) : void
      {
         this.mItemObject = param1;
         super.show();
      }
   }
}

