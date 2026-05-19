package com.dchoc.dollars.collectibles
{
   public class CollectibleObject
   {
      
      public static const STATE_PENDING:int = 0;
      
      public static const STATE_COLLECTED:int = 1;
      
      private var mCount:int;
      
      private var mState:int;
      
      private var mDefinition:CollectibleDefinition;
      
      private var mGroupID:String;
      
      public function CollectibleObject(param1:CollectibleDefinition)
      {
         super();
         this.mDefinition = param1;
         this.mState = STATE_PENDING;
      }
      
      public function getCount() : int
      {
         return this.mCount;
      }
      
      public function setState(param1:int) : void
      {
         this.mState = param1;
      }
      
      public function isReward() : Boolean
      {
         return true;
      }
      
      public function setCount(param1:int) : void
      {
         this.mCount = param1;
         if(this.mCount <= 0)
         {
            this.mState = STATE_PENDING;
         }
         else
         {
            this.mState = STATE_COLLECTED;
         }
      }
      
      public function getCollectibleDefinition() : CollectibleDefinition
      {
         return this.mDefinition;
      }
      
      public function Destroy() : void
      {
         this.mDefinition = null;
      }
      
      public function getState() : int
      {
         return this.mState;
      }
   }
}

