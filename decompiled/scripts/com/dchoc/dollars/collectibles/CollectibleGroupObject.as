package com.dchoc.dollars.collectibles
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class CollectibleGroupObject extends EventDispatcher
   {
      
      public static const STATE_LOCKED:int = 0;
      
      public static const STATE_INCOMPLETED:int = 1;
      
      public static const STATE_PENDING_TO_GET_REWARD:int = 2;
      
      public static const STATE_COMPLETED:int = 3;
      
      private var mCollectibles:Dictionary;
      
      private var mDefinition:CollectibleGroupDefinition;
      
      private var mState:int;
      
      private var mCollectibleGroupInfluence:String;
      
      private var mRewardDefinition:CollectibleRewardDefinition;
      
      private var mCompleted:Boolean;
      
      public function CollectibleGroupObject(param1:CollectibleGroupDefinition, param2:int = 0)
      {
         var _loc3_:Dictionary = null;
         super();
         this.mDefinition = param1;
         this.mState = param2;
         this.mCollectibles = new Dictionary();
         this.mCollectibleGroupInfluence = this.mDefinition.requirements;
         if(!this.mDefinition.requirements)
         {
            this.mState = STATE_INCOMPLETED;
         }
         else
         {
            _loc3_ = CollectibleManager.getInstance().getCollectibleGroupsInfluences();
            _loc3_[this.mDefinition.requirements] = this.mDefinition.sku;
         }
      }
      
      public function changeState(param1:int) : void
      {
         switch(param1)
         {
            case STATE_INCOMPLETED:
               if(this.mCompleted)
               {
                  this.mState = STATE_PENDING_TO_GET_REWARD;
                  dispatchEvent(new Event(CollectibleManager.EVENT_COLLECTIBLE_GROUP_COMPLETE));
                  break;
               }
               this.mState = param1;
               break;
            case STATE_COMPLETED:
            case STATE_LOCKED:
            case STATE_PENDING_TO_GET_REWARD:
               this.mState = param1;
         }
      }
      
      public function isComplete() : Boolean
      {
         return this.mCompleted;
      }
      
      public function initializeCollectible(param1:CollectibleObject) : void
      {
         this.mCollectibles[param1.getCollectibleDefinition().sku] = param1;
      }
      
      public function getCollectibleGroupDefinition() : CollectibleGroupDefinition
      {
         return this.mDefinition;
      }
      
      public function registerCollectible(param1:String, param2:Boolean = false) : void
      {
         var _loc3_:CollectibleObject = this.mCollectibles[param1] as CollectibleObject;
         _loc3_.setState(CollectibleObject.STATE_COLLECTED);
         if(CollectibleManager.getInstance().canCollectibleBeKept(param1) && param2)
         {
            _loc3_.setCount(_loc3_.getCount() + 1);
         }
         this.checkState();
         if(this.mCompleted && this.mState != STATE_LOCKED && !param2 && this.mState != STATE_COMPLETED)
         {
            this.changeState(STATE_PENDING_TO_GET_REWARD);
            dispatchEvent(new Event(CollectibleManager.EVENT_COLLECTIBLE_GROUP_COMPLETE));
         }
      }
      
      public function inGroup(param1:String) : Boolean
      {
         var _loc2_:CollectibleObject = this.mCollectibles[param1] as CollectibleObject;
         return _loc2_.getState() == CollectibleObject.STATE_COLLECTED;
      }
      
      public function getState() : int
      {
         return this.mState;
      }
      
      public function getCollectibleBySku(param1:String) : CollectibleObject
      {
         return this.mCollectibles[param1];
      }
      
      public function checkState() : void
      {
         var _loc2_:CollectibleObject = null;
         var _loc1_:Boolean = true;
         for each(_loc2_ in this.mCollectibles)
         {
            if(_loc2_.getState() == CollectibleObject.STATE_PENDING)
            {
               _loc1_ = false;
            }
         }
         this.mCompleted = _loc1_;
      }
      
      public function getCollectibles() : Dictionary
      {
         return this.mCollectibles;
      }
      
      public function tradeIn(param1:Boolean = false) : void
      {
         var _loc4_:CollectibleObject = null;
         var _loc5_:CollectibleGroupObject = null;
         if(param1)
         {
            for each(_loc4_ in this.mCollectibles)
            {
               _loc4_.setCount(_loc4_.getCount() - 1);
            }
         }
         if(this.mDefinition.getCanbeReclaimed())
         {
            this.checkState();
            if(!this.mCompleted)
            {
               this.changeState(STATE_INCOMPLETED);
            }
            else
            {
               this.changeState(STATE_PENDING_TO_GET_REWARD);
            }
         }
         else
         {
            this.changeState(STATE_COMPLETED);
         }
         var _loc2_:Dictionary = CollectibleManager.getInstance().getCollectibleGroupsInfluences();
         var _loc3_:String = _loc2_[this.mDefinition.sku] as String;
         if(_loc3_)
         {
            _loc5_ = CollectibleManager.getInstance().getCollectibleGroupByGroupSku(_loc3_);
            _loc5_.changeState(STATE_INCOMPLETED);
         }
      }
      
      public function wouldThisCollectibleCompleteTheGroup(param1:CollectibleDefinition) : Boolean
      {
         var _loc3_:CollectibleDefinition = null;
         var _loc4_:CollectibleObject = null;
         var _loc2_:Boolean = false;
         for each(_loc4_ in this.mCollectibles)
         {
            _loc3_ = _loc4_.getCollectibleDefinition();
            if(_loc3_ == param1)
            {
               if(_loc4_.getCount() > 0)
               {
                  _loc2_ = false;
                  break;
               }
               _loc2_ = true;
            }
            else if(_loc4_.getCount() == 0)
            {
               _loc2_ = false;
               break;
            }
         }
         return _loc2_;
      }
      
      public function destroy() : void
      {
      }
   }
}

