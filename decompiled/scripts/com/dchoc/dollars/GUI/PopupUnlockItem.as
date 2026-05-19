package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupUnlockItem extends Popup
   {
      
      private var mItem:Sprite;
      
      protected var mImage:Sprite;
      
      private var isImageLoaded:Boolean;
      
      private var mDef:ItemDefinition;
      
      public function PopupUnlockItem(param1:ItemDefinition)
      {
         var _loc3_:Boolean = false;
         var _loc8_:Sprite = null;
         this.mDef = param1;
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         _loc3_ = Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc2_.DCCash < this.mDef.getUnlockPrice(false);
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_Unlock"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("skipButton") as MovieClip);
         var _loc4_:MovieClip = mBox.getChildByName("actionButton") as MovieClip;
         var _loc5_:MovieClip = mBox.getChildByName("FCButton") as MovieClip;
         if(_loc3_)
         {
            mBox.removeChild(_loc4_);
            mOkButton = new DynamicButton(_loc5_);
            mOkButton.setLabel("" + this.mDef.getUnlockPrice());
         }
         else
         {
            mBox.removeChild(_loc5_);
            mOkButton = new DynamicButton(_loc4_);
            mOkButton.setLabel(TextManager.getText(TextIDs.TID_PLAY_MMA));
         }
         if(this.mDef.type == ItemDefinition.TYPE_WONDERS_ID)
         {
            _loc8_ = mBox.getChildByName("mItem") as Sprite;
            this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_box_house_build_wonder"))();
            mBox.addChild(this.mItem);
            this.mItem.x = _loc8_.x;
            this.mItem.y = _loc8_.y;
            mBox.removeChild(_loc8_);
         }
         else
         {
            this.mItem = mBox.getChildByName("mItem") as Sprite;
         }
         var _loc6_:TextField = mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(_loc6_);
         _loc6_.text = TextManager.replaceParameters(TextIDs.TID_POPUP_EARLY_UNLOCK_TITLE,[TextManager.getText(TextIDs[this.mDef.textID])]);
         var _loc7_:TextField = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(_loc7_);
         if(_loc3_)
         {
            _loc7_.text = TextManager.replaceParameters(TextIDs.TID_EARLY_UNLOCK_POPUP_FBCRED,[TextManager.getText(TextIDs[this.mDef.textID])]);
         }
         else
         {
            _loc7_.text = TextManager.replaceParameters(TextIDs.TID_POPUP_EARLY_UNLOCK_BODY,[TextManager.getText(TextIDs[this.mDef.textID]),"" + this.mDef.getUnlockPrice(false)]);
         }
         TextManager.changColors(_loc7_);
         this.setupItem();
         super();
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onAccept);
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
      }
      
      private function setupItem() : void
      {
         var _loc2_:int = 0;
         var _loc11_:TextField = null;
         var _loc1_:int = 0;
         _loc2_ = 1;
         var _loc3_:int = 2;
         var _loc4_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc5_:Sprite = this.mItem.getChildByName("timeLeft") as Sprite;
         _loc5_.visible = false;
         var _loc6_:MovieClip = this.mItem.getChildByName("icon_XP") as MovieClip;
         _loc6_.stop();
         var _loc7_:int = _loc2_;
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && this.mDef.getConstructionFBCredits() > 0 && (this.mDef.getConstructionCash() == 0 || _loc4_.DCCash < this.mDef.getConstructionCash()))
         {
            _loc7_ = _loc3_;
         }
         else if(this.mDef.getConstructionCash() == 0)
         {
            _loc7_ = _loc1_;
         }
         var _loc8_:TextField = this.mItem.getChildByName("mTitle") as TextField;
         var _loc9_:TextField = this.mItem.getChildByName("mPrize") as TextField;
         TextManager.reformatTextField(_loc8_);
         _loc8_.text = TextManager.getText(TextIDs[this.mDef.textID]);
         TextManager.setTextScaled(_loc8_);
         if(_loc9_ != null)
         {
            if(_loc7_ == _loc1_)
            {
               _loc9_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.mDef.getConstructionCoins(),TextManager.TRUNCATE_MILLIONS,7);
            }
            else if(_loc7_ == _loc3_)
            {
               _loc9_.text = "" + this.mDef.getConstructionFBCredits();
            }
            else
            {
               _loc9_.text = "" + this.mDef.getConstructionCash();
            }
            _loc11_ = TextField(this.mItem.getChildByName("Xp"));
            TextManager.reformatTextField(_loc11_);
            _loc11_.text = TextManager.replaceParameters(TextIDs.TID_POINTS_XP,new Array(TextManager.convertNumberToString(this.mDef.getExperience(),0,0)));
         }
         var _loc10_:MovieClip = this.mItem.getChildByName("gold") as MovieClip;
         _loc10_.gotoAndStop(_loc7_ + 1);
         this.mImage = this.mItem.getChildByName("image") as Sprite;
         this.setupIcon();
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function setupIcon() : void
      {
         var _loc1_:Object = null;
         if(!this.isImageLoaded && PriorityLoader.getInstance().isLoaded(this.mDef.getSkuToLoad()))
         {
            _loc1_ = this.mDef.getIcon(this.mImage,true);
            this.mImage.addChild(_loc1_.grid);
            this.mImage.addChild(_loc1_.icon);
            this.isImageLoaded = true;
         }
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onAccept);
      }
   }
}

