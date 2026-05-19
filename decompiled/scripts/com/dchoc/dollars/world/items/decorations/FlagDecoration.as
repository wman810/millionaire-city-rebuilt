package com.dchoc.dollars.world.items.decorations
{
   import com.dchoc.dollars.utils.effects.Flag;
   
   public class FlagDecoration extends ItemDecoration
   {
      
      private var mFlag:Flag;
      
      public function FlagDecoration(param1:int)
      {
         super(param1);
      }
      
      override public function clone() : ItemDecoration
      {
         var _loc1_:FlagDecoration = new FlagDecoration(mType);
         _loc1_.cloneValues(this);
         return _loc1_;
      }
      
      public function setPosition(param1:SkinDecoration = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.mFlag != null)
         {
            if(param1 == null)
            {
               param1 = mItemObject.decorationsGetDecorationByType(ItemDecoration.TYPE_SKIN_ID) as SkinDecoration;
            }
            _loc2_ = 58;
            _loc3_ = -105;
            if(param1 != null)
            {
               _loc3_ = param1.flagOffY + 45;
            }
            this.mFlag.x = _loc2_;
            this.mFlag.y = _loc3_;
         }
      }
      
      override protected function setDO(param1:Boolean = true) : void
      {
         super.setDO(false);
         if(mParent != null)
         {
            this.unDraw();
            this.mFlag = new Flag(mDO);
            this.setPosition();
            this.mFlag.start();
            mParent.addChild(this.mFlag);
         }
      }
      
      override protected function unDraw() : void
      {
         if(this.mFlag != null)
         {
            if(mParent != null)
            {
               mParent.removeChild(this.mFlag);
            }
            this.mFlag.destroy();
         }
         this.mFlag = null;
      }
   }
}

