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
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   
   public class ItemContentUnlocked extends ItemContent
   {
      
      public static const TYPE_CASH:uint = 0;
      
      public static const TYPE_COINS:uint = 1;
      
      public static const TYPE_FBC:uint = 2;
      
      private var mIsMouseOver:Boolean;
      
      public var mType:uint;
      
      private var mInfo:InfoBox;
      
      private var mTutorialArrow:MovieClip;
      
      public function ItemContentUnlocked(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      private function showInfoBox(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:DollarsGame = null;
         if(!this.mIsMouseOver)
         {
            _loc2_ = mContainer.getX() - mContainer.getScrolledX();
            _loc3_ = x + width + Dollars.smStage.stageWidth / 2 + _loc2_ - 15;
            _loc4_ = DollarsGame.smInstance;
            switch(mDef.type)
            {
               case ItemDefinition.TYPE_HOUSES_ID:
               case ItemDefinition.TYPE_BUNDLE_ID:
                  this.mInfo = new ShopMenuInfoHouse(_loc4_.mPopupClip,mDef);
                  break;
               case ItemDefinition.TYPE_COMMERCES_ID:
                  this.mInfo = new ShopMenuInfoCommerce(_loc4_.mPopupClip,mDef);
                  break;
               case ItemDefinition.TYPE_DECORATIONS_ID:
                  this.mInfo = new ShopMenuInfoDeco(_loc4_.mPopupClip,mDef);
                  break;
               case ItemDefinition.TYPE_WONDERS_ID:
                  this.mInfo = new ShopMenuInfoWonder(_loc4_.mPopupClip,mDef);
                  break;
               case ItemDefinition.TYPE_CLUBS_ID:
                  this.mInfo = new ShopMenuInfoClub(_loc4_.mPopupClip,mDef);
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
         if(!Tutorial.smTutorialEnd)
         {
            mButton.disable();
            if(Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID && mDef.sku == "houses_001_001" || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && mId == 0 && mDef.type == ItemDefinition.TYPE_DECORATIONS_ID)
            {
               mButton.enable();
               mButton.start();
               mButton.addEventListener(MouseEvent.CLICK,this.getItem);
               this.mTutorialArrow.x = mBox.width / 2;
               this.mTutorialArrow.y = mBox.height - mButton.getButtonMc().height - 10;
            }
         }
         else
         {
            mButton.start();
            if((mDef.type == ItemDefinition.TYPE_WONDERS_ID || mDef.type == ItemDefinition.TYPE_CLUBS_ID) && DollarsGame.getCurrentWorld().getCompanyMine().registerOccurrenceGetAmount(mDef.sku) > 0)
            {
               mButton.disable();
            }
            else
            {
               mButton.addEventListener(MouseEvent.CLICK,this.getItem);
            }
         }
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
         var _loc1_:Company = null;
         var _loc2_:MovieClip = null;
         var _loc4_:Bitmap = null;
         var _loc6_:String = null;
         super.setupBox();
         _loc1_ = DollarsGame.getCurrentWorld().getCompanyMine();
         mButton = new DynamicButton(mBox["unlock_FC"]);
         _loc2_ = mButton.getButtonMc()["ButtonText"];
         var _loc3_:Sprite = _loc2_["icon"];
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && mDef.getConstructionFBCredits() > 0 && (mDef.getConstructionCash() == 0 || _loc1_.DCCash < mDef.getConstructionCash()))
         {
            this.mType = TYPE_FBC;
            mButton.setLabel("" + mDef.getConstructionFBCredits());
            _loc4_ = new Bitmap(DCResourceManager.getInstance().get("fbc"));
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
            _loc2_.addChild(_loc4_);
         }
         else if(mDef.getConstructionCash() == 0)
         {
            this.mType = TYPE_COINS;
            if(mDef.getConstructionCoins() == 0)
            {
               _loc6_ = TextManager.getText(TextIDs.TID_GEN_FREE);
            }
            else
            {
               _loc6_ = TextManager.convertNumberToString(mDef.getConstructionCoins(),TextManager.TRUNCATE_MILLIONS,7);
            }
            mButton.setLabel(_loc6_);
            _loc4_ = new Bitmap(DCResourceManager.getInstance().get("cash"));
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
            _loc2_.addChild(_loc4_);
         }
         else
         {
            this.mType = TYPE_CASH;
            mButton.setLabel("" + mDef.getConstructionCash());
            _loc4_ = new Bitmap(DCResourceManager.getInstance().get("gold"));
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
            _loc2_.addChild(_loc4_);
         }
         _loc2_.removeChild(_loc3_);
         var _loc5_:TextField = mBox["Xp"];
         if(_loc5_ != null)
         {
            if(mDef.getExperience() > 0)
            {
               TextManager.reformatTextField(_loc5_,false);
               _loc5_.text = TextManager.replaceParameters(TextIDs.TID_POINTS_XP,new Array(TextManager.convertNumberToString(mDef.getExperience(),0,0)));
            }
            else
            {
               _loc5_.visible = false;
               mBox["icon_XP"].visible = false;
            }
         }
         mButton.getButtonMc()["ButtonText"]["offer"].visible = false;
         mButton.getButtonMc()["ButtonText"]["old_prize"].visible = false;
         mImage.addEventListener(MouseEvent.MOUSE_OVER,this.showInfoBox);
         mImage.addEventListener(MouseEvent.MOUSE_OUT,this.closeInfoBox);
         if(!Tutorial.smTutorialEnd && !mDef.getIsFeatured() && (Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID && mDef.sku == "houses_001_001" || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && mId == 0 && mDef.type == ItemDefinition.TYPE_DECORATIONS_ID))
         {
            this.mTutorialArrow = new AssetManager.TutorialArrow();
            this.mTutorialArrow.mouseEnabled = false;
            this.mTutorialArrow.enabled = false;
            addChild(this.mTutorialArrow);
         }
      }
      
      private function getItem(param1:MouseEvent) : void
      {
         if(!Tutorial.smTutorialEnd)
         {
            removeChild(this.mTutorialArrow);
            this.mTutorialArrow = null;
         }
         dispatchEvent(new Event(BUY_ITEM));
      }
      
      override protected function getBox() : Sprite
      {
         if(mDef.type == ItemDefinition.TYPE_CLUBS_ID)
         {
            return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box_crew"))();
         }
         if(mDef.type == ItemDefinition.TYPE_WONDERS_ID)
         {
            return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box_wonder"))();
         }
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box"))();
      }
   }
}

