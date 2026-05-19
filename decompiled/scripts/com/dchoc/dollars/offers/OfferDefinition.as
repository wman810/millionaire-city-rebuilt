package com.dchoc.dollars.offers
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class OfferDefinition extends Definition
   {
      
      private var mAmount:Number;
      
      private var mOfferType:String;
      
      public function OfferDefinition(param1:int)
      {
         super(param1);
      }
      
      public function set amount(param1:Number) : void
      {
         this.mAmount = param1;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return false;
      }
      
      public function get offerType() : String
      {
         return this.mOfferType;
      }
      
      public function get amount() : Number
      {
         return this.mAmount;
      }
      
      public function set offerType(param1:String) : void
      {
         this.mOfferType = param1;
      }
   }
}

