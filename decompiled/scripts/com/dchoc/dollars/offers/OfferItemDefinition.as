package com.dchoc.dollars.offers
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class OfferItemDefinition extends Definition
   {
      
      private var mOfferSku:String;
      
      public function OfferItemDefinition(param1:int)
      {
         super(param1);
      }
      
      public function get offerSku() : String
      {
         return this.mOfferSku;
      }
      
      public function set offerSku(param1:String) : void
      {
         this.mOfferSku = param1;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return false;
      }
   }
}

