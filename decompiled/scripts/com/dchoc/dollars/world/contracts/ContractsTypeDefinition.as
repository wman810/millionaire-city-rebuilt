package com.dchoc.dollars.world.contracts
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.text.TextManager;
   
   public class ContractsTypeDefinition extends Definition
   {
      
      private var mContracts:Array;
      
      private var mContractsSkus:String;
      
      public function ContractsTypeDefinition(param1:uint)
      {
         super(param1);
      }
      
      public function getContracts() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.mContracts == null)
         {
            this.mContracts = new Array();
            _loc1_ = this.mContractsSkus.split(",");
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = TextManager.trim(_loc2_);
               this.mContracts.push(ContractDefinitionManager.getInstance().getDefinitionBySku(_loc3_));
            }
         }
         return this.mContracts;
      }
      
      public function setContractsSkus(param1:String) : void
      {
         this.mContractsSkus = param1;
      }
   }
}

