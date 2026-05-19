package com.dchoc.dollars.world.items.gui
{
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfluenceIcon extends Sprite
   {
      
      protected var mDOText:TextField;
      
      protected var mEnabled:Boolean;
      
      protected var mDOSprite:Sprite;
      
      protected var mItemObject:ItemObject;
      
      public function InfluenceIcon()
      {
         super();
         this.load();
         this.mEnabled = true;
      }
      
      public function draw() : void
      {
         if(this.mDOSprite == null)
         {
            this.iconDraw();
         }
         this.textDraw();
         if(this.mItemObject != null)
         {
            this.update();
         }
      }
      
      private function load() : void
      {
         this.draw();
      }
      
      public function update(param1:int = 0) : void
      {
         if(this.mItemObject != null)
         {
            this.mDOText.text = "" + param1;
         }
         visible = this.isVisible();
      }
      
      public function getEnabled() : Boolean
      {
         return this.mEnabled;
      }
      
      private function iconDraw() : void
      {
         if(this.mDOSprite == null)
         {
            this.mDOSprite = this.getIconDO();
            addChild(this.mDOSprite);
         }
      }
      
      public function setInfluenceAreaAffectedVisibility(param1:Boolean, param2:ItemDefinition, param3:Boolean = false) : void
      {
         visible = param1;
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
      }
      
      protected function isVisible(param1:ItemDefinition = null) : Boolean
      {
         var _loc2_:Boolean = this.mEnabled;
         if(_loc2_)
         {
            _loc2_ = this.doIsVisible(param1);
         }
         return _loc2_;
      }
      
      protected function textDraw() : void
      {
         if(this.mDOText == null)
         {
            this.mDOText = this.mDOSprite.getChildByName("TextInfo") as TextField;
            addChild(this.mDOText);
         }
      }
      
      protected function getIconDO() : Sprite
      {
         return null;
      }
      
      public function doMouseOver() : void
      {
         visible = this.isVisible();
         if(visible)
         {
            this.update();
         }
      }
      
      protected function doIsVisible(param1:ItemDefinition = null) : Boolean
      {
         return false;
      }
      
      public function destroy() : void
      {
         if(this.mDOSprite != null && contains(this.mDOSprite))
         {
            removeChild(this.mDOSprite);
         }
         this.mDOSprite = null;
         if(this.mDOText != null && contains(this.mDOText))
         {
            removeChild(this.mDOText);
         }
         this.mDOText = null;
      }
      
      public function setItemObject(param1:ItemObject) : void
      {
         this.mItemObject = param1;
         if(this.mItemObject != null)
         {
            this.update();
         }
      }
      
      public function undoMouseOver() : void
      {
         visible = false;
      }
   }
}

