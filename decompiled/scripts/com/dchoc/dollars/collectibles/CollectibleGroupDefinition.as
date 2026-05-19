package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   
   public class CollectibleGroupDefinition extends Definition
   {
      
      public static const STATE_INCOMPLETED:int = 0;
      
      public static const STATE_PENDING_TO_GET_REWARD:int = 1;
      
      public static const STATE_COMPLETED:int = 2;
      
      private var mRewardSku:String;
      
      private var mIcon:String;
      
      private var mTextID:String;
      
      private var mRequirement:String;
      
      private var mOrder:int;
      
      private var mState:int;
      
      private var mCollectableReward:CollectibleObject;
      
      private var mCommerce:Boolean;
      
      private var mTradeIn:Boolean;
      
      public function CollectibleGroupDefinition(param1:int)
      {
         super(param1);
         this.mState = STATE_INCOMPLETED;
      }
      
      public function get order() : int
      {
         return this.mOrder;
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return true;
      }
      
      public function getIconDO() : DisplayObject
      {
         return new (DCResourceManager.getInstance().getSWFClass(mSku,"gift"))();
      }
      
      public function get requirements() : String
      {
         return this.mRequirement;
      }
      
      public function setIsCommerceGroup(param1:Boolean) : void
      {
         this.mCommerce = param1;
      }
      
      public function set rewardSku(param1:String) : void
      {
         this.mRewardSku = param1;
      }
      
      public function setCanBeReclaimed(param1:Boolean) : void
      {
         this.mTradeIn = param1;
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function set requirements(param1:String) : void
      {
         this.mRequirement = param1;
      }
      
      public function set order(param1:int) : void
      {
         this.mOrder = param1;
      }
      
      public function getCanbeReclaimed() : Boolean
      {
         return this.mTradeIn;
      }
      
      public function get rewardSku() : String
      {
         return this.mRewardSku;
      }
      
      public function set icon(param1:String) : void
      {
         this.mIcon = param1;
      }
      
      public function get icon() : String
      {
         return this.mIcon;
      }
      
      public function IsCommerceGroup() : Boolean
      {
         return this.mCommerce;
      }
   }
}

