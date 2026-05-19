package com.dchoc.dollars.utils.behaviors
{
   import com.dchoc.dollars.utils.animations.ItemSprite;
   
   public class BehaviorComposite extends Behavior
   {
      
      private var mChildren:Array;
      
      public function BehaviorComposite(param1:int = 0, param2:int = -1)
      {
         super(param1,param2);
         this.mChildren = new Array();
      }
      
      public function addBehavior(param1:Behavior) : void
      {
         this.mChildren.push(param1);
         if(param1.getEndTime() > getEndTime())
         {
            setEndTime(param1.getEndTime());
         }
      }
      
      public function removeBehavior(param1:Behavior) : void
      {
         var _loc2_:int = this.mChildren.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.mChildren.splice(_loc2_,1);
         }
      }
      
      override protected function doIsFinished() : Boolean
      {
         var _loc3_:Behavior = null;
         var _loc1_:Boolean = true;
         var _loc2_:* = int(this.mChildren.length - 1);
         while(_loc2_ > -1 && _loc1_)
         {
            _loc3_ = this.mChildren[_loc2_];
            if(!_loc3_.isFinished())
            {
               _loc1_ = false;
            }
            _loc2_--;
         }
         return _loc1_;
      }
      
      override public function destroy() : void
      {
         var _loc1_:Behavior = null;
         super.destroy();
         for each(_loc1_ in this.mChildren)
         {
            _loc1_.destroy();
         }
         this.mChildren.splice(0,this.mChildren.length);
         this.mChildren = null;
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         var _loc3_:Behavior = null;
         var _loc2_:Boolean = true;
         for each(_loc3_ in this.mChildren)
         {
            _loc3_.logicUpdate(param1);
            if(!_loc3_.isFinished())
            {
               _loc2_ = false;
            }
         }
         if(_loc2_)
         {
            end();
         }
      }
      
      override public function setDO(param1:ItemSprite) : void
      {
         var _loc2_:Behavior = null;
         for each(_loc2_ in this.mChildren)
         {
            _loc2_.setDO(param1);
         }
      }
      
      override public function reset() : void
      {
         var _loc1_:Behavior = null;
         super.reset();
         for each(_loc1_ in this.mChildren)
         {
            _loc1_.reset();
         }
      }
   }
}

