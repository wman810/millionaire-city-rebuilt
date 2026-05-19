package com.dchoc.dollars.world.contracts
{
   import com.dchoc.dollars.utils.crypto.EncryptionUtils;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   
   public class ContractDefinition extends Definition
   {
      
      public static const MAGIC_PRIME_ENCRYPTION_NUMBER:Number = 1526589487;
      
      public static const MAGIC_PRIME_ENCRYPTION_KEY:Number = 12479897;
      
      private var mCostCoins:int;
      
      private var mContractName:String;
      
      private var mPopulation:int;
      
      private var mTimeSku:String;
      
      private var mIncomeCoins:int;
      
      private var mIncomeXP:int;
      
      private var mIncomeTime:Number;
      
      private var mIconSku:String;
      
      public function ContractDefinition(param1:uint)
      {
         super(param1);
      }
      
      override protected function calculateChecksum() : int
      {
         return EncryptionUtils.calculateChecksumFrom([this.mCostCoins,this.mIncomeCoins,this.mIncomeXP,this.mPopulation]);
      }
      
      public function getIncomeTime() : int
      {
         return this.mIncomeTime;
      }
      
      public function getIncomeXP() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mIncomeXP,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function setIncomeTime(param1:String) : void
      {
         this.mTimeSku = param1;
         var _loc2_:Number = Number(param1);
         this.mIncomeTime = TimerUtil.hourToMs(_loc2_);
      }
      
      override public function build() : void
      {
         var _loc1_:ContractNameDefinition = ContractNameDefinitionManager.getInstance().getDefinitionBySku(this.mContractName) as ContractNameDefinition;
         if(_loc1_ != null)
         {
            tid = _loc1_.tid;
         }
      }
      
      public function setIncomeCoins(param1:int) : void
      {
         this.mIncomeCoins = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getTimeSku() : String
      {
         return this.mTimeSku;
      }
      
      public function setIconSku(param1:String) : void
      {
         this.mIconSku = param1;
      }
      
      public function setNameSku(param1:String) : void
      {
         this.mContractName = param1;
      }
      
      public function setIncomeXP(param1:int) : void
      {
         this.mIncomeXP = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getNameSku() : String
      {
         return this.mContractName;
      }
      
      public function setCostCoins(param1:int) : void
      {
         this.mCostCoins = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getIncomeCoins() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mIncomeCoins,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getIconSku() : String
      {
         return this.mIconSku;
      }
      
      public function getCostCoins() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mCostCoins,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
   }
}

