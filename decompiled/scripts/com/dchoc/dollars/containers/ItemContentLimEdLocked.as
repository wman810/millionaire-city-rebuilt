package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ItemContentLimEdLocked extends ItemContentLocked
   {
      
      private var mBuyButton:Sprite;
      
      public function ItemContentLimEdLocked(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      override protected function setupBox() : void
      {
         super.setupBox();
         mSoldOutBox.visible = true;
         var _loc1_:TextField = mSoldOutBox["sold_out"];
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = "Sold Out";
         TextManager.setTextScaled(_loc1_);
         var _loc2_:MovieClip = mBox["locked"];
         _loc2_.visible = false;
         _loc2_ = mBox["counter"];
         _loc2_.visible = false;
         _loc2_ = mBox["timeLeft"];
         _loc2_.visible = false;
         _loc2_ = mBox["unlock_FC"];
         _loc2_.visible = false;
         _loc2_ = mBox["fan"];
         _loc2_.visible = false;
      }
   }
}

