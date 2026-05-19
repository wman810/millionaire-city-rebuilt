package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   
   public class NeighborObject extends FriendObject
   {
      
      private var mCompanyValue:Number;
      
      private var mSuperUpgradeTimeToAllowReminding:Number;
      
      private var mInvestReward:Boolean;
      
      private var mInvestCompanyValue:int = -1;
      
      private var mCollectibleWishList:Array;
      
      private var mInvestTimer:int;
      
      private var mExp:Number;
      
      public function NeighborObject()
      {
         super();
         this.mSuperUpgradeTimeToAllowReminding = -1;
      }
      
      public function set exp(param1:Number) : void
      {
         this.mExp = param1;
      }
      
      public function set wishList(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(this.mCollectibleWishList == null)
            {
               this.mCollectibleWishList = new Array();
            }
            while(_loc2_ < param1.length)
            {
               this.mCollectibleWishList.push(String(param1[_loc2_]));
               _loc2_++;
            }
         }
      }
      
      public function get exp() : Number
      {
         return this.mExp;
      }
      
      public function resetSuperUpgradeTimeToAllowRemaining() : void
      {
         this.setSuperUpgradeTimeToAllowRemaining(UserDataFacade.getInstance().timerGetTimeSinceGetUniverse() + RulesFacade.getInstance().socialGetSuperUpgradesTimeToAllowReminding());
      }
      
      public function removeCollectibleFromList(param1:String) : void
      {
         var _loc2_:int = 0;
         if(this.mCollectibleWishList)
         {
            _loc2_ = this.mCollectibleWishList.indexOf(param1);
            if(_loc2_ > -1)
            {
               this.mCollectibleWishList.splice(_loc2_,1);
            }
         }
      }
      
      public function collectibleWished(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(this.mCollectibleWishList)
         {
            _loc2_ = this.mCollectibleWishList.indexOf(param1);
            return _loc2_ > -1;
         }
         return false;
      }
      
      public function getSuperUpgradeTimeToAllowRemaining() : Number
      {
         var _loc1_:Number = this.mSuperUpgradeTimeToAllowReminding - UserDataFacade.getInstance().timerGetTimeSinceGetUniverse();
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set companyValue(param1:Number) : void
      {
         this.mCompanyValue = param1;
      }
      
      public function get companyValue() : Number
      {
         return this.mCompanyValue;
      }
      
      public function setSuperUpgradeTimeToAllowRemaining(param1:Number) : void
      {
         this.mSuperUpgradeTimeToAllowReminding = param1;
      }
      
      override public function setIsPartner(param1:Boolean) : void
      {
         mIsPartner = param1;
      }
      
      public function get wishList() : Array
      {
         return this.mCollectibleWishList;
      }
      
      override public function isPartner() : Boolean
      {
         return (mIsPartner || isAdvisor()) && Config.USE_SUPERUPGRADES;
      }
      
      public function hasPartnershipBeenRequested() : Boolean
      {
         return !mIsPartner && this.mSuperUpgradeTimeToAllowReminding > -1;
      }
   }
}

