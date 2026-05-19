package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoClub;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoCommerce;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoDeco;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoHouse;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoWonder;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.BundleDefinition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormatAlign;
   import flash.utils.setTimeout;
   
   public class ItemContentUnlockedBundle extends ItemContent
   {
      
      private var mIsMouseOver:Boolean;
      
      public var mType:uint;
      
      private var mInfo:InfoBox;
      
      public function ItemContentUnlockedBundle(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      private function showInfoBox(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:DollarsGame = null;
         var _loc5_:BundleDefinition = null;
         if(!this.mIsMouseOver)
         {
            _loc2_ = mContainer.getX() - mContainer.getScrolledX();
            _loc3_ = x + width + Dollars.smStage.stageWidth / 2 + _loc2_ - 15;
            _loc4_ = DollarsGame.smInstance;
            _loc5_ = mDef as BundleDefinition;
            switch(mDef.type)
            {
               case ItemDefinition.TYPE_HOUSES_ID:
               case ItemDefinition.TYPE_BUNDLE_ID:
                  this.mInfo = new ShopMenuInfoHouse(_loc4_.mPopupClip,_loc5_.getItemDefinition(0));
                  break;
               case ItemDefinition.TYPE_COMMERCES_ID:
                  this.mInfo = new ShopMenuInfoCommerce(_loc4_.mPopupClip,_loc5_.getItemDefinition(0));
                  break;
               case ItemDefinition.TYPE_DECORATIONS_ID:
                  this.mInfo = new ShopMenuInfoDeco(_loc4_.mPopupClip,_loc5_.getItemDefinition(0));
                  break;
               case ItemDefinition.TYPE_WONDERS_ID:
                  this.mInfo = new ShopMenuInfoWonder(_loc4_.mPopupClip,_loc5_.getItemDefinition(0));
                  break;
               case ItemDefinition.TYPE_CLUBS_ID:
                  this.mInfo = new ShopMenuInfoClub(_loc4_.mPopupClip,_loc5_.getItemDefinition(0));
            }
            setTimeout(this.mInfo.show,ItemContent.TOOLTIP_DELAY,mDef,_loc3_,y + height / 2 + Dollars.smStage.stageHeight / 2,width - 20);
            this.mInfo.setIncome(mDef.getIncomeValue());
            this.mInfo.setTimer(null,mDef.getIncomeTime());
            this.mIsMouseOver = true;
         }
      }
      
      private function closeInfoBox(param1:MouseEvent) : void
      {
         if(this.mIsMouseOver)
         {
            this.mInfo.close();
            this.mInfo.destroy();
            this.mInfo = null;
            this.mIsMouseOver = false;
         }
      }
      
      override public function start() : void
      {
         mButton.enable();
         mButton.start();
         mButton.addEventListener(MouseEvent.CLICK,this.getItem);
      }
      
      override public function end() : void
      {
         if(this.mInfo != null)
         {
            this.mInfo.close();
         }
         if(mButton != null)
         {
            mButton.end();
            mButton.removeEventListener(MouseEvent.CLICK,this.getItem);
         }
         mImage.removeEventListener(MouseEvent.MOUSE_OVER,this.showInfoBox);
         mImage.removeEventListener(MouseEvent.MOUSE_OUT,this.closeInfoBox);
      }
      
      override protected function setupBox() : void
      {
         var _loc5_:MovieClip = null;
         var _loc7_:Bitmap = null;
         super.setupBox();
         var _loc1_:BundleDefinition = mDef as BundleDefinition;
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         mButton = new DynamicButton(mBox["unlock_FC"],TextFormatAlign.LEFT);
         var _loc3_:MovieClip = mButton.getButtonMc()["ButtonText"]["offer"];
         var _loc4_:MovieClip = mButton.getButtonMc()["ButtonText"]["old_prize"];
         TextManager.reformatTextField(_loc3_["text"],false);
         _loc5_ = mButton.getButtonMc()["ButtonText"];
         var _loc6_:Sprite = _loc5_["icon"];
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            _loc3_["text"].text = _loc1_.getConstructionFBCredits();
            _loc7_ = new Bitmap(DCResourceManager.getInstance().get("fbc"));
            _loc7_.x = _loc6_.x;
            _loc7_.y = _loc6_.y;
            _loc5_.addChild(_loc7_);
         }
         else
         {
            _loc3_["text"].text = _loc1_.getConstructionCash();
            _loc7_ = new Bitmap(DCResourceManager.getInstance().get("gold"));
            _loc7_.x = _loc6_.x;
            _loc7_.y = _loc6_.y;
            _loc5_.addChild(_loc7_);
         }
         _loc5_.removeChild(_loc6_);
         mButton = new DynamicButton(mBox["unlock_FC"],TextFormatAlign.LEFT);
         mButton.setLabel("" + _loc1_.getOriginalPrice());
         var _loc8_:TextField = mBox["amount"];
         TextManager.reformatTextField(_loc8_,false);
         _loc8_.text = "x" + _loc1_.getItemAmount(0);
         if(_loc1_.getExperience() > 0)
         {
            if(mBox["Xp"] != null)
            {
               TextManager.reformatTextField(mBox["Xp"],false);
               mBox["Xp"].text = TextManager.replaceParameters(TextIDs.TID_POINTS_XP,new Array(TextManager.convertNumberToString(_loc1_.getExperience(),0,0)));
            }
         }
         else
         {
            mBox["Xp"].visible = false;
            mBox["icon_XP"].visible = false;
         }
         mBox["bundle"].visible = false;
         mImage.addEventListener(MouseEvent.MOUSE_OVER,this.showInfoBox);
         mImage.addEventListener(MouseEvent.MOUSE_OUT,this.closeInfoBox);
      }
      
      private function getItem(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(BUY_ITEM));
      }
      
      override protected function getBox() : Sprite
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box_promoted"))();
      }
   }
}

