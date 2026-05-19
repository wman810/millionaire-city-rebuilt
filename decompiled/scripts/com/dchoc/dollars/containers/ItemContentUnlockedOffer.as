package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   
   public class ItemContentUnlockedOffer extends ItemContentUnlocked
   {
      
      public function ItemContentUnlockedOffer(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      override protected function getBox() : Sprite
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box_promoted"))();
      }
      
      override protected function setupBox() : void
      {
         var _loc5_:MovieClip = null;
         var _loc7_:Bitmap = null;
         super.setupBox();
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc2_:MovieClip = mButton.getButtonMc()["ButtonText"]["offer"];
         var _loc3_:MovieClip = mButton.getButtonMc()["ButtonText"]["old_prize"];
         var _loc4_:MovieClip = mBox["bundle"];
         _loc2_.visible = false;
         _loc3_.visible = false;
         _loc4_.visible = false;
         if(mDef.offerDef != null)
         {
            if(mDef.offerDef.offerType == OfferManager.TYPE_DISCOUNT)
            {
               TextManager.reformatTextField(_loc2_["text"],false);
               _loc2_.visible = true;
               _loc3_.visible = true;
               if(mType == TYPE_FBC)
               {
                  _loc2_["text"].text = mDef.getConstructionFBCredits();
                  mButton = new DynamicButton(mBox["unlock_FC"],TextFormatAlign.LEFT);
                  mButton.setLabel("" + mDef.getConstructionFBCredits(false));
               }
               else if(mType == TYPE_CASH)
               {
                  _loc2_["text"].text = mDef.getConstructionCash();
                  mButton = new DynamicButton(mBox["unlock_FC"],TextFormatAlign.LEFT);
                  mButton.setLabel("" + mDef.getConstructionCash(false));
               }
            }
            else if(mDef.offerDef.offerType == OfferManager.TYPE_BUNDLE)
            {
               _loc4_.visible = true;
               if(mType == TYPE_FBC)
               {
                  mButton.setLabel("" + mDef.getConstructionFBCredits());
               }
               else if(mType == TYPE_CASH)
               {
                  mButton.setLabel("" + mDef.getConstructionCash());
               }
            }
         }
         _loc5_ = mButton.getButtonMc()["ButtonText"];
         var _loc6_:Sprite = _loc5_["icon"];
         mBox["amount"].visible = false;
         if(mType == TYPE_FBC)
         {
            _loc7_ = new Bitmap(DCResourceManager.getInstance().get("fbc"));
         }
         else if(mType == TYPE_CASH)
         {
            _loc7_ = new Bitmap(DCResourceManager.getInstance().get("gold"));
         }
         _loc7_.x = _loc6_.x;
         _loc7_.y = _loc6_.y;
         _loc5_.addChild(_loc7_);
      }
   }
}

