package com.dchoc.dollars.freeGift
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class FreeGiftDefinition extends Definition
   {
      
      private var mValue:String;
      
      private var mUnlockCondition:String;
      
      private var mGiftAction:String;
      
      private var mTextID:String;
      
      private var mGiftType:String;
      
      private var mUnlockValue:int;
      
      private var mOrder:int;
      
      private var mMaxAmount:int;
      
      public function FreeGiftDefinition(param1:int)
      {
         super(param1);
      }
      
      public function get giftAction() : String
      {
         return this.mGiftAction;
      }
      
      public function set giftAction(param1:String) : void
      {
         this.mGiftAction = param1;
      }
      
      public function get unlockValue() : int
      {
         return this.mUnlockValue;
      }
      
      public function get order() : int
      {
         return this.mOrder;
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function get giftType() : String
      {
         return this.mGiftType;
      }
      
      public function set unlockValue(param1:int) : void
      {
         this.mUnlockValue = param1;
      }
      
      public function set giftType(param1:String) : void
      {
         this.mGiftType = param1;
      }
      
      public function get maxAmount() : int
      {
         return this.mMaxAmount;
      }
      
      public function set value(param1:String) : void
      {
         this.mValue = param1;
      }
      
      public function set order(param1:int) : void
      {
         this.mOrder = param1;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return false;
      }
      
      public function get value() : String
      {
         return this.mValue;
      }
      
      public function set unlockCondition(param1:String) : void
      {
         this.mUnlockCondition = param1;
      }
      
      public function get unlockCondition() : String
      {
         return this.mUnlockCondition;
      }
      
      public function set maxAmount(param1:int) : void
      {
         this.mMaxAmount = param1;
      }
   }
}

