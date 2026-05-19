package com.dchoc.dollars.storage
{
   import com.dchoc.dollars.utils.crypto.EncryptionUtils;
   
   public class StoredItem
   {
      
      public static const MAGIC_PRIME_ENCRYPTION_NUMBER:Number = Dollars.getMagicEncryptionNumber();
      
      public static const MAGIC_PRIME_ENCRYPTION_KEY:Number = 987654321;
      
      public static const ACTION_MOVE:String = "move";
      
      public static const ACTION_OPENBOX:String = "openBox";
      
      public static const ACTION_PLACE:String = "place";
      
      public static const ACTION_RENT_ACCELERATOR:String = "rentAccelerator";
      
      public var mOrder:int;
      
      public var mTid:String;
      
      public var mAction:String;
      
      private var mAmount:int;
      
      public var mType:String;
      
      private var mMaxAmount:int;
      
      public var mSku:String;
      
      public function StoredItem(param1:String, param2:int, param3:String, param4:int, param5:String, param6:String, param7:int)
      {
         super();
         this.mSku = param1;
         this.setAmount(param2);
         this.setMaxAmount(param4);
         this.mType = param3;
         this.mTid = param5;
         this.mAction = param6;
         this.mOrder = param7;
      }
      
      public function getMaxAmount() : int
      {
         return EncryptionUtils.decrypt(0,this.mMaxAmount,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function setMaxAmount(param1:int) : void
      {
         this.mMaxAmount = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getAmount() : int
      {
         return EncryptionUtils.decrypt(0,this.mAmount,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function setAmount(param1:int) : void
      {
         this.mAmount = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
   }
}

