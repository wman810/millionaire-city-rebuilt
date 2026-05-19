package com.dchoc.dollars.world.items.gui
{
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfluenceIconCommerce extends InfluenceIcon
   {
      
      public function InfluenceIconCommerce()
      {
         super();
         mEnabled = false;
      }
      
      override protected function textDraw() : void
      {
         if(mDOText == null)
         {
            mDOText = mDOSprite.getChildByName("TextInfo") as TextField;
            addChild(mDOText);
         }
      }
      
      override protected function getIconDO() : Sprite
      {
         return new AssetManager.InfluenceIconCommerce();
      }
      
      override protected function doIsVisible(param1:ItemDefinition = null) : Boolean
      {
         return mItemObject != null && mItemObject.currentState == null;
      }
   }
}

