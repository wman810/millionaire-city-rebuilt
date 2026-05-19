package com.dchoc.dollars.GUI.shop
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ShopTabDefinition extends Definition
   {
      
      private var mIndex:int;
      
      private var mUsesIconOnItemShop:Boolean;
      
      public function ShopTabDefinition(param1:uint)
      {
         super(param1);
      }
      
      public function getUsesIconOnItemShop() : Boolean
      {
         return this.mUsesIconOnItemShop;
      }
      
      public function get index() : int
      {
         return this.mIndex;
      }
      
      public function getIconOnItemShopDO() : Sprite
      {
         var _loc2_:TextField = null;
         var _loc1_:Sprite = null;
         if(this.mUsesIconOnItemShop)
         {
            _loc1_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,sku))();
            _loc2_ = TextField(_loc1_.getChildByName("Caption"));
            TextManager.reformatTextField(_loc2_);
            _loc2_.text = TextManager.getText(TextIDs.TID_GEN_NEW);
            TextManager.setTextScaled(_loc2_);
         }
         return _loc1_;
      }
      
      public function set index(param1:int) : void
      {
         this.mIndex = param1;
      }
      
      public function setUsesIconOnItemShop(param1:Boolean) : void
      {
         this.mUsesIconOnItemShop = param1;
      }
   }
}

