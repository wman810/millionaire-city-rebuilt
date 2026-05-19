package com.dchoc.dollars.world.items.decorations
{
   public class SkinDecoration extends ItemDecoration
   {
      
      private var mFlagOffY:int;
      
      public function SkinDecoration(param1:int)
      {
         super(param1);
      }
      
      override protected function checkChangeShadowRows() : Boolean
      {
         return true;
      }
      
      override public function clone() : ItemDecoration
      {
         var _loc1_:SkinDecoration = new SkinDecoration(mType);
         _loc1_.cloneValues(this);
         return _loc1_;
      }
      
      public function get flagOffY() : int
      {
         return this.mFlagOffY;
      }
      
      override protected function setDO(param1:Boolean = true) : void
      {
         super.setDO(param1);
         if(mDO != null)
         {
         }
      }
   }
}

