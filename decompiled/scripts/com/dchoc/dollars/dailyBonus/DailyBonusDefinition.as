package com.dchoc.dollars.dailyBonus
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   
   public class DailyBonusDefinition extends Definition
   {
      
      public static const TYPE_COINS:String = "coins";
      
      public static const TYPE_CASH:String = "cash";
      
      public static const TYPE_EXP:String = "exp";
      
      public static const TYPE_ITEM:String = "item";
      
      private var mBonusType:String;
      
      private var mGroup:int;
      
      private var mValue:String;
      
      private var mChances:Number;
      
      private var mDate:Number;
      
      public function DailyBonusDefinition(param1:int)
      {
         super(param1);
      }
      
      public function get bonusType() : String
      {
         return this.mBonusType;
      }
      
      public function set bonusType(param1:String) : void
      {
         this.mBonusType = param1;
      }
      
      public function set value(param1:String) : void
      {
         this.mValue = param1;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return true;
      }
      
      public function set chances(param1:Number) : void
      {
         this.mChances = param1;
      }
      
      public function get chances() : Number
      {
         return this.mChances;
      }
      
      public function setDate(param1:String) : void
      {
         if(param1 != "")
         {
            this.mDate = TimerUtil.getDateInMs(param1);
         }
         else
         {
            this.mDate = 0;
         }
      }
      
      public function get value() : String
      {
         return this.mValue;
      }
      
      public function getDate() : Number
      {
         return this.mDate;
      }
      
      public function set group(param1:int) : void
      {
         this.mGroup = param1;
      }
      
      public function get group() : int
      {
         return this.mGroup;
      }
   }
}

