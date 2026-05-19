package com.dchoc.dollars.model.services
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   
   public class ServiceDefinition extends Definition
   {
      
      private var mPriceCoins:int;
      
      private var mOfferPriceCoins:int;
      
      private var mWaitingTime:Number;
      
      private var mTimeAvailable:Number;
      
      private var mHasWaitingTime:Boolean;
      
      private var mContractId:int;
      
      private var mPriceCash:int;
      
      private var mUsesCount:int;
      
      private var mContractName:String;
      
      private var mTimeExtra:Number;
      
      private var mPriceFBCredits:int;
      
      private var mOfferPriceFBCredits:int;
      
      private var mWaitingTimeMaxExponent:int;
      
      private var mOfferPriceCash:int;
      
      private var mWaitingTimeLeft:Number;
      
      private var mWaitingTimeBase:Number;
      
      public function ServiceDefinition(param1:uint)
      {
         super(param1);
         this.mWaitingTimeLeft = 0;
         this.mUsesCount = 0;
      }
      
      public function setTimeExtra(param1:Number) : void
      {
         this.mTimeExtra = TimerUtil.minToMs(param1);
      }
      
      public function getWaitingTime() : Number
      {
         return this.mWaitingTime;
      }
      
      public function getPriceFBCredits() : int
      {
         return this.mPriceFBCredits;
      }
      
      public function contract() : void
      {
         if(this.getHasWaitingTime())
         {
            this.mWaitingTimeLeft = this.getWaitingTime();
            ++this.mUsesCount;
            if(this.mUsesCount > this.getWaitingTimeMaxExponent())
            {
               this.mUsesCount = this.getWaitingTimeMaxExponent();
            }
         }
      }
      
      public function getOfferPriceCash() : int
      {
         return this.mOfferPriceCash;
      }
      
      public function setPriceFBCredits(param1:int) : void
      {
         this.mPriceFBCredits = param1;
      }
      
      public function getTimeExtra() : Number
      {
         return this.mTimeExtra;
      }
      
      public function setWaitingTimeLeft(param1:Number) : void
      {
         this.mWaitingTimeLeft = param1;
      }
      
      public function setOfferPriceCash(param1:int) : void
      {
         this.mOfferPriceCash = param1;
      }
      
      override public function fromXML(param1:XML) : void
      {
         this.setTimeAvailable(Number(param1.@timeDuration));
         this.setTimeExtra(Number(param1.@timeExtra));
         this.setPriceCoins(int(param1.@priceCoins));
         this.setPriceCash(int(param1.@priceCash));
         this.setPriceFBCredits(int(param1.@priceFBC));
         this.setOfferPriceCoins(this.getPriceCoins());
         this.setOfferPriceCash(int(param1.@offerPriceCash));
         this.setOfferPriceFBCredits(int(param1.@offerPriceFBC));
         var _loc2_:Number = TimerUtil.hourToMs(int(param1.@timeExpired));
         this.setWaitingTime(_loc2_);
         this.setHasWaitingTime(_loc2_ > 0);
         this.setWaitingTimeBase(int(param1.@timeExpiredBase));
         this.setWaitingTimeMaxExponent(int(param1.@timeExpiredMax));
      }
      
      private function getWaitingTimeMaxExponent() : int
      {
         return this.mWaitingTimeMaxExponent;
      }
      
      private function setWaitingTimeMaxExponent(param1:int) : void
      {
         this.mWaitingTimeMaxExponent = param1;
      }
      
      public function getWaitingTimeLeft() : Number
      {
         return this.mWaitingTimeLeft;
      }
      
      private function getWaitingTimeBase() : int
      {
         return this.mWaitingTimeBase;
      }
      
      public function getPriceCoins() : int
      {
         return this.mPriceCoins;
      }
      
      public function setTimeAvailable(param1:Number) : void
      {
         this.mTimeAvailable = TimerUtil.hourToMs(param1);
      }
      
      public function setPriceCoins(param1:int) : void
      {
         this.mPriceCoins = param1;
      }
      
      public function isAvailable() : Boolean
      {
         var _loc1_:Number = this.mWaitingTimeLeft;
         if(_loc1_ > 0)
         {
            _loc1_ -= UserDataFacade.getInstance().timerGetTimeSinceGetUniverse();
            if(_loc1_ < 0)
            {
               this.mWaitingTimeLeft = 0;
            }
         }
         return this.mWaitingTimeLeft == 0;
      }
      
      public function cheatTime(param1:Number) : void
      {
         if(Config.CHEATS_ENABLED && this.getHasWaitingTime())
         {
            this.mWaitingTimeLeft -= param1;
            if(this.mWaitingTimeLeft < 0)
            {
               this.mWaitingTimeLeft = 0;
            }
         }
      }
      
      public function setHasWaitingTime(param1:Boolean) : void
      {
         this.mHasWaitingTime = param1;
      }
      
      public function getContractId() : int
      {
         return this.mContractId;
      }
      
      public function getHasWaitingTime() : Boolean
      {
         return this.mHasWaitingTime;
      }
      
      public function getTimeAvailable() : Number
      {
         return this.mTimeAvailable;
      }
      
      public function setContractId(param1:int) : void
      {
         this.mContractId = param1;
      }
      
      public function setPriceCash(param1:int) : void
      {
         this.mPriceCash = param1;
      }
      
      public function getOfferPriceFBCredits() : int
      {
         return this.mOfferPriceFBCredits;
      }
      
      public function setOfferPriceFBCredits(param1:int) : void
      {
         this.mOfferPriceFBCredits = param1;
      }
      
      private function setWaitingTimeBase(param1:int) : void
      {
         this.mWaitingTimeBase = param1;
      }
      
      public function setUsesCount(param1:int) : void
      {
         this.mUsesCount = param1;
      }
      
      public function isLockable() : Boolean
      {
         return this.mWaitingTimeBase > 0;
      }
      
      public function setOfferPriceCoins(param1:int) : void
      {
         this.mOfferPriceCoins = param1;
      }
      
      public function getPriceCash() : int
      {
         return this.mPriceCash;
      }
      
      public function setWaitingTime(param1:Number) : void
      {
         this.mWaitingTime = param1;
      }
      
      public function getOfferPriceCoins() : int
      {
         return this.mOfferPriceCoins;
      }
   }
}

