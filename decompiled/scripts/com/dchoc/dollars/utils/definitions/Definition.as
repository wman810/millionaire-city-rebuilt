package com.dchoc.dollars.utils.definitions
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   
   public class Definition
   {
      
      public static const NAME_DEFAULT:String = "default";
      
      protected var mType:uint;
      
      protected var mChecksum:int;
      
      public var mResourcesRequested:Boolean;
      
      private var mLevel:int;
      
      private var mFeedImg:String;
      
      private var mTid:int;
      
      protected var mSku:String;
      
      private var mTidsCount:int;
      
      public function Definition(param1:uint)
      {
         super();
         this.mType = param1;
         this.mTidsCount = 1;
         this.mResourcesRequested = false;
      }
      
      public function get type() : uint
      {
         return this.mType;
      }
      
      public function setFeedImg(param1:String) : void
      {
         this.mFeedImg = param1;
      }
      
      public function isDefault() : Boolean
      {
         return false;
      }
      
      public function getSkuToLoad() : String
      {
         return this.mSku;
      }
      
      protected function calculateChecksum() : int
      {
         return 0;
      }
      
      public function get level() : int
      {
         return this.mLevel;
      }
      
      public function fromXML(param1:XML) : void
      {
      }
      
      public function get tid() : int
      {
         return this.mTid;
      }
      
      public function get sku() : String
      {
         return this.mSku;
      }
      
      public function set tid(param1:int) : void
      {
         this.mTid = param1;
      }
      
      public function createChecksum() : void
      {
         this.mChecksum = this.calculateChecksum();
      }
      
      public function needsToLoadSWF() : Boolean
      {
         return true;
      }
      
      public function setTidsCount(param1:int) : void
      {
         this.mTidsCount = param1;
      }
      
      public function set level(param1:int) : void
      {
         this.mLevel = param1;
      }
      
      protected function checkChecksum() : void
      {
         var _loc1_:Boolean = this.mChecksum == this.calculateChecksum();
         UserDataFacade.chk = UserDataFacade.chk || !_loc1_;
      }
      
      public function getFeedImg() : String
      {
         return this.mFeedImg;
      }
      
      public function set type(param1:uint) : void
      {
         this.mType = param1;
      }
      
      public function getTidsCount() : int
      {
         return this.mTidsCount;
      }
      
      public function set sku(param1:String) : void
      {
         this.mSku = param1;
      }
      
      public function build() : void
      {
      }
   }
}

