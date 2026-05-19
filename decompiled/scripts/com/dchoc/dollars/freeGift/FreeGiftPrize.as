package com.dchoc.dollars.freeGift
{
   public class FreeGiftPrize
   {
      
      public static const TYPE_CASH:String = "cash";
      
      public static const TYPE_EXP:String = "exp";
      
      public static const TYPE_GOLD:String = "gold";
      
      public static const TYPE_MOVE:String = "move";
      
      public static const TYPE_ITEM:String = "item";
      
      public var mTid:String;
      
      public var mValue:String;
      
      public var mType:String;
      
      public var mSource:String;
      
      public var mSku:String;
      
      public var mResname:String;
      
      public function FreeGiftPrize(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String)
      {
         super();
         this.mSku = param1;
         this.mSource = param2;
         this.mType = param3;
         this.mValue = param4;
         this.mResname = param5;
         this.mTid = param6;
      }
   }
}

