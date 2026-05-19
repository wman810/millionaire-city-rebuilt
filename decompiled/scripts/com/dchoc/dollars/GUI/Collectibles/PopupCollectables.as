package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.TabButton;
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class PopupCollectables extends Popup
   {
      
      public static const TAB_VAULT:int = 0;
      
      public static const TAB_COLLECTIONS:int = 1;
      
      private var mFBCreditsField:TextField;
      
      private var mTabs:Array = new Array();
      
      private var mMaxScrolls:int;
      
      private var mVaultText:TextField;
      
      private var mScrollingEnabled:Boolean;
      
      private var mHelpButton:DynamicButton;
      
      private var mScrollRect:Sprite;
      
      private var mCurrentTab:int = 1;
      
      private const YOFFSET:Number = 179.95;
      
      private var mNumScrolls:int;
      
      private var mDestinyPosition:Number;
      
      private var mVault:TabButton;
      
      private var mScrollOffset:Number;
      
      private var mItems:Array;
      
      private var mArrowUp:DynamicButton;
      
      private var mTutorialArrow:MovieClip;
      
      private var mArrowDown:DynamicButton;
      
      private const XINIT:Number = -289.3;
      
      private var mItemsEnhanced:Boolean;
      
      private const XOFFSET:Number = 598.95;
      
      private var mFBCreditsNotSpent:int;
      
      private var mFBCreditsNotSpentField:TextField;
      
      private var mCollections:TabButton;
      
      private const YINIT:Number = -112.05;
      
      private var mFBCredits:int;
      
      private var mTitle:TextField;
      
      private var mHelpPopup:PopupHelpCollectibles;
      
      public function PopupCollectables()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_background_collectables"))();
         var _loc1_:MovieClip = mBox as MovieClip;
         _loc1_.stop();
         var _loc2_:MovieClip = mBox["counter_fbc"];
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mFBCreditsField = _loc2_.getChildByName("counter") as TextField;
            this.mFBCreditsNotSpentField = _loc2_.getChildByName("Facebook_Credits_2") as TextField;
         }
         else
         {
            _loc2_.visible = false;
         }
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         this.mTitle.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_TITLE);
         TextManager.reformatTextField(this.mTitle);
         mBox.addChild(this.mTitle);
         TextManager.setTextScaled(this.mTitle);
         this.mScrollRect = new Sprite();
         this.mScrollRect.x = this.XINIT;
         this.mScrollRect.y = this.YINIT;
         mBox.addChild(this.mScrollRect);
         this.mArrowUp = new DynamicButton(mBox.getChildByName("mArrowUp") as MovieClip);
         this.mArrowDown = new DynamicButton(mBox.getChildByName("mArrowDown") as MovieClip);
         var _loc3_:MovieClip = mBox.getChildByName("Commerces") as MovieClip;
         this.mVault = new TabButton(mBox.getChildByName("Commerces") as MovieClip);
         if(Config.COLLECTIBLE_COMMERCES_FEATURE)
         {
            this.mVault.setLabel(TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_COMMERCE_BUTTON02));
         }
         else
         {
            this.mVault.setLabel(TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_BUTTON02));
         }
         mBox.addChild(this.mVault);
         this.mVaultText = mBox.getChildByName("jueves") as TextField;
         TextManager.reformatTextField(this.mVaultText);
         mBox.addChild(this.mVaultText);
         this.mHelpButton = new DynamicButton(mBox.getChildByName("Buttonhelp") as MovieClip);
         this.mHelpButton.setTip(TextManager.getText(TextIDs.TID_INVEST_HELP_TITLE));
         this.mTutorialArrow = new AssetManager.TutorialArrow();
         this.mTutorialArrow.rotation = -45;
         mBox.addChild(this.mTutorialArrow);
         this.mTutorialArrow.x = this.mHelpButton.getButtonMc().x;
         this.mTutorialArrow.y = this.mHelpButton.getButtonMc().y;
         this.mHelpPopup = new PopupHelpCollectibles(PopupHelpCollectibles.STATE_PREV);
         this.mCollections = new TabButton(mBox.getChildByName("Decorations") as MovieClip);
         if(Config.COLLECTIBLE_COMMERCES_FEATURE)
         {
            this.mCollections.setLabel(TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_HOUSE_BUTTON01));
         }
         else
         {
            this.mCollections.setLabel(TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_BUTTON01));
         }
         mBox.addChild(this.mCollections);
         if(!DollarsGame.getProfile().collectiblesGetFirstShown())
         {
            DollarsGame.getProfile().collectiblesSetFirstShown(true);
         }
         this.getGroups();
         super();
         this.showPopup();
      }
      
      public function updateItem(param1:String) : void
      {
      }
      
      private function getCommerceCollections() : Object
      {
         var _loc5_:CollectibleGroupObject = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         for each(_loc5_ in CollectibleManager.getInstance().getCollectibleGroups())
         {
            if(_loc5_.getCollectibleGroupDefinition().IsCommerceGroup())
            {
               if(_loc5_.getState() == CollectibleGroupObject.STATE_LOCKED)
               {
                  _loc1_.push(_loc5_);
               }
               else if(_loc5_.getState() == CollectibleGroupObject.STATE_COMPLETED)
               {
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         _loc1_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         _loc2_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         _loc3_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         return {
            "lockedCollections":_loc1_,
            "unlockedCollections":_loc2_,
            "completedCollections":_loc3_
         };
      }
      
      public function onUpdate(param1:Event) : void
      {
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && this.mFBCredits != DollarsGame.getProfile().facebookCredits)
         {
            this.setFBCredits();
            this.setFBCreditsNotSpent();
         }
      }
      
      public function setFBCreditsNotSpent() : void
      {
         this.mFBCreditsNotSpent = DollarsGame.getProfile().facebookCreditsNotSpent;
         if(this.mFBCreditsNotSpent < 1)
         {
            this.mFBCreditsNotSpentField.visible = false;
         }
         else
         {
            this.mFBCreditsNotSpentField.visible = true;
            this.mFBCreditsNotSpentField.text = "+" + this.mFBCreditsNotSpent;
            TextManager.setTextScaled(this.mFBCreditsNotSpentField);
         }
      }
      
      private function removeItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ItemGroupCollectible = null;
         if(this.mItems != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mItems.length)
            {
               _loc2_ = this.mItems[_loc1_];
               this.mScrollRect.removeChild(_loc2_);
               this.mItems[_loc1_] = null;
               _loc1_++;
            }
         }
      }
      
      public function setFBCredits() : void
      {
         this.mFBCredits = DollarsGame.getProfile().facebookCredits;
         this.mFBCreditsField.text = TextManager.convertNumberToString(this.mFBCredits,TextManager.TRUNCATE_THOUSAND,3);
         TextManager.setTextScaled(this.mFBCreditsField);
      }
      
      public function refreshGroups() : void
      {
         var _loc1_:int = this.mNumScrolls;
         this.getGroups();
         this.mNumScrolls = _loc1_;
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         var _loc3_:int = (this.mNumScrolls - 1) * 2;
         _loc2_.y += this.YOFFSET * _loc3_;
         var _loc4_:int = int(this.mItems.length);
         var _loc5_:int = _loc4_ - _loc3_ > 1 ? 2 : 1;
         if(_loc5_ == 1 && _loc4_ > 1)
         {
            _loc2_.y -= this.YOFFSET;
         }
         this.mScrollRect.scrollRect = _loc2_;
         this.mArrowUp.disable();
         this.mArrowDown.disable();
         if(this.mNumScrolls > 1)
         {
            this.mArrowUp.enable();
         }
         if(this.mNumScrolls < this.mMaxScrolls)
         {
            this.mArrowDown.enable();
         }
      }
      
      private function fillTabs(param1:Object) : void
      {
         var _loc4_:ItemGroupCollectible = null;
         var _loc5_:CollectibleGroupObject = null;
         this.mItemsEnhanced = DollarsGame.getProfile().collectiblesGetHelpShown();
         var _loc2_:Dictionary = CollectibleManager.getInstance().getCollectibleGroups();
         var _loc3_:int = 0;
         var _loc6_:Array = param1.unlockedCollections as Array;
         var _loc7_:Array = param1.lockedCollections as Array;
         var _loc8_:Array = param1.completedCollections as Array;
         var _loc9_:int = 0;
         for each(_loc5_ in _loc6_)
         {
            this.mItemsEnhanced = this.mItemsEnhanced && _loc3_ == 0;
            _loc4_ = new ItemGroupCollectible(_loc3_,_loc5_,this.mItemsEnhanced);
            _loc4_.x = this.XINIT;
            _loc4_.y = this.YINIT + _loc3_ * this.YOFFSET;
            this.mScrollRect.addChild(_loc4_);
            this.mItems.push(_loc4_);
            _loc3_++;
            _loc9_++;
         }
         for each(_loc5_ in _loc7_)
         {
            this.mItemsEnhanced = this.mItemsEnhanced && _loc3_ == 0;
            _loc4_ = new ItemGroupCollectible(_loc3_,_loc5_,this.mItemsEnhanced);
            _loc4_.x = this.XINIT;
            _loc4_.y = this.YINIT + _loc3_ * this.YOFFSET;
            this.mScrollRect.addChild(_loc4_);
            this.mItems.push(_loc4_);
            _loc3_++;
            _loc9_++;
         }
         for each(_loc5_ in _loc8_)
         {
            this.mItemsEnhanced = this.mItemsEnhanced && _loc3_ == 0;
            _loc4_ = new ItemGroupCollectible(_loc3_,_loc5_,this.mItemsEnhanced);
            _loc4_.x = this.XINIT;
            _loc4_.y = this.YINIT + _loc3_ * this.YOFFSET;
            this.mScrollRect.addChild(_loc4_);
            this.mItems.push(_loc4_);
            _loc3_++;
            _loc9_++;
         }
         if(_loc9_ > 0)
         {
            this.mVaultText.visible = false;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
         this.mTutorialArrow.visible = !DollarsGame.getProfile().collectiblesGetHelpShown();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.setFBCredits();
            this.setFBCreditsNotSpent();
         }
         DollarsGame.getProfile().addEventListener(Event.CHANGE,this.onUpdate);
      }
      
      public function launchTutorial() : void
      {
         this.mHelpPopup.showPopup();
      }
      
      private function scrollUpEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y += this.mScrollOffset;
         if(_loc2_.y >= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
            ++this.mNumScrolls;
            if(this.mNumScrolls == this.mMaxScrolls)
            {
               this.mArrowDown.disable();
            }
            if(this.mNumScrolls > 1)
            {
               this.mArrowUp.enable();
            }
            this.mScrollingEnabled = true;
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function onGoToCollections(param1:MouseEvent) : void
      {
         this.mCurrentTab = TAB_COLLECTIONS;
         this.mVault.unselect();
         this.mCollections.select();
         this.getGroups();
      }
      
      public function chageTab(param1:int) : void
      {
         this.mCurrentTab = param1;
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onClosePopup);
         this.mArrowUp.end();
         this.mArrowUp.removeEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mHelpButton.end();
         this.mHelpButton.removeEventListener(MouseEvent.CLICK,this.onHelp);
         this.mArrowDown.end();
         this.mArrowDown.removeEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mVault.end();
         this.mVault.removeEventListener(MouseEvent.CLICK,this.onGoToVault);
         this.mCollections.end();
         this.mCollections.removeEventListener(MouseEvent.CLICK,this.onGoToCollections);
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mHelpButton.start();
         this.mHelpButton.addEventListener(MouseEvent.CLICK,this.onHelp);
         this.mArrowUp.start();
         this.mArrowUp.addEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mArrowDown.start();
         this.mArrowDown.addEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mVault.start();
         this.mVault.addEventListener(MouseEvent.CLICK,this.onGoToVault);
         this.mCollections.start();
         this.mCollections.addEventListener(MouseEvent.CLICK,this.onGoToCollections);
         this.refreshArrows();
         switch(this.mCurrentTab)
         {
            case TAB_COLLECTIONS:
               this.onGoToCollections(null);
               break;
            case TAB_VAULT:
               this.onGoToVault(null);
               break;
            default:
               this.onGoToCollections(null);
         }
      }
      
      private function onHelp(param1:MouseEvent) : void
      {
         this.launchTutorial();
         if(this.mTutorialArrow.visible)
         {
            this.mTutorialArrow.visible = false;
            DollarsGame.getProfile().collectiblesSetHelpShown(true);
            this.mItemsEnhanced = true;
            this.refreshGroups();
         }
      }
      
      private function getGroups() : void
      {
         var _loc3_:ItemGroupCollectible = null;
         var _loc4_:CollectibleGroupObject = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT,this.XOFFSET,this.YOFFSET * 2);
         this.removeItems();
         this.mItems = new Array();
         var _loc1_:Dictionary = CollectibleManager.getInstance().getCollectibleGroups();
         var _loc2_:int = 0;
         var _loc5_:MovieClip = mBox.getChildByName("bg") as MovieClip;
         this.mVaultText.visible = true;
         if(Config.COLLECTIBLE_COMMERCES_FEATURE)
         {
            switch(this.mCurrentTab)
            {
               case TAB_COLLECTIONS:
                  _loc7_ = this.getCollections();
                  this.mVaultText.text = TextManager.getText(TextIDs.TID_COLLECTIBLE_EMPTY_COLLECTIONS);
                  _loc5_.gotoAndStop(1);
                  this.fillTabs(_loc7_);
                  break;
               case TAB_VAULT:
                  _loc7_ = this.getCommerceCollections();
                  this.mVaultText.text = TextManager.getText(TextIDs.TID_COLLECTIBLE_EMPTY_VAULT);
                  _loc5_.gotoAndStop(2);
                  this.fillTabs(_loc7_);
            }
         }
         else
         {
            _loc7_ = this.getCollections();
            switch(this.mCurrentTab)
            {
               case TAB_COLLECTIONS:
                  this.mVaultText.visible = true;
                  this.mVaultText.text = TextManager.getText(TextIDs.TID_COLLECTIBLE_EMPTY_COLLECTIONS);
                  _loc5_.gotoAndStop(1);
                  _loc8_ = _loc7_.unlockedCollections as Array;
                  _loc9_ = _loc7_.lockedCollections as Array;
                  _loc6_ = 0;
                  for each(_loc4_ in _loc8_)
                  {
                     _loc3_ = new ItemGroupCollectible(_loc2_,_loc4_,this.mItemsEnhanced);
                     _loc3_.x = this.XINIT;
                     _loc3_.y = this.YINIT + _loc2_ * this.YOFFSET;
                     this.mScrollRect.addChild(_loc3_);
                     this.mItems.push(_loc3_);
                     _loc2_++;
                     _loc6_++;
                  }
                  for each(_loc4_ in _loc9_)
                  {
                     _loc3_ = new ItemGroupCollectible(_loc2_,_loc4_,this.mItemsEnhanced);
                     _loc3_.x = this.XINIT;
                     _loc3_.y = this.YINIT + _loc2_ * this.YOFFSET;
                     this.mScrollRect.addChild(_loc3_);
                     this.mItems.push(_loc3_);
                     _loc2_++;
                     _loc6_++;
                  }
                  if(_loc6_ > 0)
                  {
                     this.mVaultText.visible = false;
                  }
                  break;
               case TAB_VAULT:
                  this.mVaultText.visible = true;
                  this.mVaultText.text = TextManager.getText(TextIDs.TID_COLLECTIBLE_EMPTY_VAULT);
                  _loc5_.gotoAndStop(2);
                  _loc6_ = 0;
                  _loc10_ = _loc7_.completedCollections as Array;
                  for each(_loc4_ in _loc10_)
                  {
                     _loc3_ = new ItemGroupCollectible(_loc2_,_loc4_,this.mItemsEnhanced);
                     _loc3_.x = this.XINIT;
                     _loc3_.y = this.YINIT + _loc2_ * this.YOFFSET;
                     this.mScrollRect.addChild(_loc3_);
                     this.mItems.push(_loc3_);
                     _loc2_++;
                     _loc6_++;
                  }
                  if(_loc6_ > 0)
                  {
                     this.mVaultText.visible = false;
                  }
            }
         }
         this.mScrollingEnabled = true;
         this.mScrollOffset = this.YOFFSET / 4;
         this.mNumScrolls = 1;
         this.mMaxScrolls = this.mItems.length / 2;
         if(this.mItems.length % 2 > 0)
         {
            ++this.mMaxScrolls;
         }
         this.refreshArrows();
      }
      
      private function refreshArrows() : void
      {
         this.mArrowUp.disable();
         this.mArrowDown.disable();
         if(this.mNumScrolls < this.mMaxScrolls)
         {
            this.mArrowDown.enable();
         }
      }
      
      private function onScrollDown(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.mNumScrolls > 1 && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            _loc3_ = int(this.mItems.length);
            _loc4_ = (this.mNumScrolls - 1) * 2;
            _loc5_ = _loc3_ - _loc4_ > 1 ? 2 : 1;
            this.mDestinyPosition = _loc2_.y - _loc5_ * this.YOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
         }
      }
      
      private function getCollections() : Object
      {
         var _loc5_:CollectibleGroupObject = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         for each(_loc5_ in CollectibleManager.getInstance().getCollectibleGroups())
         {
            if(!_loc5_.getCollectibleGroupDefinition().IsCommerceGroup())
            {
               if(_loc5_.getState() == CollectibleGroupObject.STATE_LOCKED)
               {
                  _loc1_.push(_loc5_);
               }
               else if(_loc5_.getState() == CollectibleGroupObject.STATE_COMPLETED)
               {
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         _loc1_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         _loc2_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         _loc3_.sort(CollectibleManager.getInstance().sortCompareOrderInShop);
         return {
            "lockedCollections":_loc1_,
            "unlockedCollections":_loc2_,
            "completedCollections":_loc3_
         };
      }
      
      private function scrollDownEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y -= this.mScrollOffset;
         if(_loc2_.y <= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
            --this.mNumScrolls;
            if(this.mNumScrolls == 1)
            {
               this.mArrowUp.disable();
            }
            if(this.mNumScrolls == this.mMaxScrolls - 1)
            {
               this.mArrowDown.enable();
            }
            this.mScrollingEnabled = true;
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function onScrollUp(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.mNumScrolls < this.mMaxScrolls && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            _loc3_ = int(this.mItems.length);
            _loc4_ = this.mNumScrolls * 2;
            _loc5_ = _loc3_ - _loc4_ > 1 ? 2 : 1;
            this.mDestinyPosition = _loc2_.y + _loc5_ * this.YOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
         }
      }
      
      private function onClosePopup(param1:MouseEvent) : void
      {
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         onClose(null);
      }
      
      override protected function close() : void
      {
         DollarsGame.getProfile().removeEventListener(Event.CHANGE,this.onUpdate);
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function onGoToVault(param1:MouseEvent) : void
      {
         this.mCurrentTab = TAB_VAULT;
         this.mCollections.unselect();
         this.mVault.select();
         this.getGroups();
      }
   }
}

