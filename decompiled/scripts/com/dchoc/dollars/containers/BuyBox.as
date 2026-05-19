package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.TabButton;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.bundles.PopupConfirmBundle;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinition;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.BundleDefinition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class BuyBox extends ItemContainer
   {
      
      public static const BOX_TYPE_NONE:int = -1;
      
      private var mScrollingEnabled:Boolean = true;
      
      private var mGoldInit:int;
      
      private var mAreas:Dictionary;
      
      private var mFBCreditsBalance:TextField;
      
      private const YOFFSET:Number = 190.1;
      
      private var mNumScrolls:int;
      
      private var mDestinyPosition:int = 0;
      
      private var mOffersEnabled:Boolean;
      
      private var mOldButton:TabButton;
      
      private var mSelectedTab:int;
      
      private var mItems:Array;
      
      private var mAlertOffers:MovieClip;
      
      private const XINIT:Number = -190.3;
      
      private var mCurrentBalanceNotSpent:int;
      
      private var mRole:Role;
      
      private var mOfferTimeLeft:TextField;
      
      private var mMaxScrolls:int;
      
      private var mFeaturedMC:MovieClip;
      
      private var mShopTabButtons:Array;
      
      private var mScrollRect:Sprite;
      
      private var mShowing:Boolean;
      
      private const SPECIAL_TAB_NEW_ITEM_ID:int = 0;
      
      private const MAX_ITEMS_PAGE:uint = 8;
      
      private const NEWITEM_X:Number = -260.3;
      
      private var mVisitButton:DynamicButton;
      
      private var mCaption:TextField;
      
      private var mFeatured:FeaturedItemsBox;
      
      private var mOfferText:TextField;
      
      private var mArrowLeft:DynamicButton;
      
      private var mItemDef:ItemDefinition;
      
      private var mScrollOffset:int = 60;
      
      private const YINIT:Number = -105;
      
      private const XOFFSET:Number = 135;
      
      private var mFBCreditsNotSpent:TextField;
      
      private var mArrowRight:DynamicButton;
      
      private var mCurrentBalance:int;
      
      private var mRonald:Sprite;
      
      private var mOffer:MovieClip;
      
      private var mCindy:Sprite;
      
      public function BuyBox(param1:Role)
      {
         var _loc4_:ShopTabDefinition = null;
         var _loc5_:String = null;
         var _loc6_:MovieClip = null;
         var _loc7_:DisplayObjectContainer = null;
         var _loc8_:MovieClip = null;
         var _loc9_:Loader = null;
         var _loc10_:URLRequest = null;
         var _loc11_:LoaderContext = null;
         var _loc12_:TabButton = null;
         this.mItems = new Array();
         mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"shop"))();
         var _loc2_:Sprite = mBox["counter_fbc"];
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mFBCreditsBalance = _loc2_["counter"];
            this.mFBCreditsNotSpent = _loc2_["Facebook_Credits_2"];
            this.mCurrentBalance = -1;
            this.mCurrentBalanceNotSpent = -1;
            this.setFBC();
         }
         else
         {
            _loc2_.visible = false;
         }
         this.mArrowLeft = new DynamicButton(mBox.getChildByName("mArrowLeft") as MovieClip);
         this.mArrowRight = new DynamicButton(mBox.getChildByName("mArrowRight") as MovieClip);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mCaption = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mCaption,false);
         this.mCaption.text = TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_HOUSES);
         TextManager.setTextScaled(this.mCaption);
         this.mShopTabButtons = new Array();
         var _loc3_:Array = ShopTabDefinitionManager.getInstance().getDefinitions();
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = _loc4_.sku;
            _loc6_ = mBox.getChildByName(_loc5_) as MovieClip;
            _loc7_ = mBox;
            if(_loc6_ == null)
            {
               _loc5_ = "area_" + _loc5_;
               _loc8_ = mBox.getChildByName(_loc5_) as MovieClip;
               if(_loc8_ != null)
               {
                  this.areasRegisterArea(_loc4_.sku,_loc8_);
                  _loc6_ = _loc8_.getChildByName(_loc4_.sku) as MovieClip;
                  _loc7_ = _loc8_;
               }
               if(_loc4_.sku == "new_items" && _loc4_.getFeedImg() != null)
               {
                  _loc9_ = new Loader();
                  _loc10_ = new URLRequest(Config.getRoot() + ModelConfig.DIR_FEEDS + _loc4_.getFeedImg());
                  _loc11_ = new LoaderContext(true);
                  _loc9_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.setImage);
                  _loc9_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
                  _loc9_.load(_loc10_,_loc11_);
               }
            }
            if(_loc6_ != null)
            {
               _loc12_ = new TabButton(_loc6_);
               _loc7_.addChild(_loc12_);
               _loc12_.setLabel(TextManager.getText(_loc4_.tid));
               this.mShopTabButtons.push(_loc12_);
            }
            else
            {
               this.mShopTabButtons.push(null);
            }
         }
         this.mSelectedTab = ItemDefinition.TYPE_HOUSES_ID;
         this.mRole = param1;
         this.mNumScrolls = 1;
         this.mScrollRect = new Sprite();
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT,this.XOFFSET * 4,this.YOFFSET * 2);
         this.mOffer = mBox["offer_day"];
         this.mOffer.visible = false;
         this.mOfferText = this.mOffer["text1"];
         this.mOfferText.text = TextManager.getText(TextIDs.TID_TITLE_OFFERS);
         TextManager.setTextScaled(this.mOfferText);
         this.mOfferTimeLeft = this.mOffer["text2"];
         TextManager.reformatTextField(this.mOfferTimeLeft);
         this.mOffersEnabled = false;
         super(this.mScrollRect);
      }
      
      public function stop() : void
      {
         var _loc1_:TabButton = null;
         mBox.removeEventListener(Event.ENTER_FRAME,this.pageRightEvent);
         mBox.removeEventListener(Event.ENTER_FRAME,this.pageLeftEvent);
         this.mScrollingEnabled = true;
         this.mArrowLeft.end();
         this.mArrowRight.end();
         mCancelButton.end();
         this.mArrowLeft.removeEventListener(MouseEvent.CLICK,this.pageRight);
         this.mArrowRight.removeEventListener(MouseEvent.CLICK,this.pageLeft);
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.closeBox);
         for each(_loc1_ in this.mShopTabButtons)
         {
            if(_loc1_ != null)
            {
               _loc1_.removeEventListener(MouseEvent.CLICK,this.changeTab);
            }
         }
         this.removeItems();
         this.removeFeatured();
      }
      
      private function pageLeftEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.x += this.mScrollOffset;
         if(_loc2_.x >= this.mDestinyPosition)
         {
            _loc2_.x = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.pageLeftEvent);
            this.mScrollingEnabled = true;
            ++this.mNumScrolls;
            this.checkScrollEnable();
            this.loadPageResources(this.mNumScrolls - 1);
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function getItems(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:ItemDefinition = null;
         var _loc6_:ItemContent = null;
         var _loc4_:int = 0;
         this.removeItems();
         this.mItems = new Array();
         _loc3_ = ItemDefinitionManager.getInstance().getDefinitions(param1);
         if(_loc3_ != null)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if(ItemDefinition(_loc3_[_loc2_]).isAllowedToBeInShop())
               {
                  _loc5_ = _loc3_[_loc2_] as ItemDefinition;
                  _loc6_ = this.checkContentState(_loc4_,_loc3_[_loc2_]);
                  _loc6_.x = this.XINIT + this.XOFFSET * (_loc4_ % 4) + this.XOFFSET * 4 * int(_loc4_ / 8);
                  _loc6_.y = this.YINIT + this.YOFFSET * (int(_loc4_ / 4) % 2);
                  this.mItems.push(_loc6_);
                  this.mScrollRect.addChild(_loc6_);
                  _loc4_++;
               }
               _loc2_++;
            }
         }
         this.mScrollRect.x = this.XINIT;
         this.mScrollRect.y = this.YINIT;
         this.mMaxScrolls = this.mItems.length / 8;
         if(this.mItems.length % 8 > 0)
         {
            ++this.mMaxScrolls;
         }
         this.loadPageResources(0);
      }
      
      public function checkFeaturedContentState(param1:FeaturedItemContent) : void
      {
         var _loc2_:ItemDefinition = param1.mDef;
         if(DollarsGame.getCurrentRole().usesMaxExp())
         {
            param1.setState(FeaturedItemContent.STATE_ENABLED);
            param1.addEventListener(ItemContent.BUY_ITEM,this.buyItem);
         }
         else if(_loc2_.isLocked())
         {
            param1.setState(FeaturedItemContent.STATE_LOCKED);
         }
         else if(DollarsGame.getProfile().DCCoins < _loc2_.getConstructionCoins() || DollarsGame.getProfile().DCCash < _loc2_.getConstructionCash())
         {
            param1.setState(FeaturedItemContent.STATE_DISABLED);
         }
         else
         {
            param1.setState(FeaturedItemContent.STATE_ENABLED);
         }
         param1.setUpBox(mBox);
      }
      
      private function loadPageResources(param1:int) : void
      {
         var _loc2_:int = param1 * 8;
         while(_loc2_ < param1 * 8 + 8 && _loc2_ < this.mItems.length)
         {
            ItemDefinitionManager.getInstance().requestLoadResourcesByDefinition(this.mItems[_loc2_].mDef,PriorityLoader.QUEUE_ASYNC);
            _loc2_++;
         }
      }
      
      public function goToTab(param1:int) : void
      {
         this.mShopTabButtons[param1].dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function setImage(param1:Event) : void
      {
         var _loc2_:Loader = param1.target.loader as Loader;
         var _loc3_:Bitmap = Bitmap(_loc2_.content);
         var _loc4_:MovieClip = MovieClip(this.mAreas["new_items"]);
         _loc4_["image"].addChild(_loc3_);
      }
      
      private function mDebugRectangle() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(16711680);
         _loc1_.graphics.drawRect(0,0,this.XOFFSET,this.YOFFSET);
         _loc1_.graphics.endFill();
         return _loc1_;
      }
      
      private function onExchange(param1:Event) : void
      {
         this.onCancelExchange(null);
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:int = Math.abs(_loc2_.DCCash - this.mGoldInit);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_CONVERT_GOLD_SHOP,MetricConstants.PRODUCT_ITEM,this.mItemDef.itemName,null,0,_loc3_);
         this.buyItem(null);
      }
      
      private function pageLeft(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls < this.mMaxScrolls && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            this.mDestinyPosition = _loc2_.x + 4 * this.XOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.pageLeftEvent);
         }
      }
      
      override public function onClose(param1:MouseEvent = null) : void
      {
         var _loc2_:Sprite = null;
         endButtons();
         if(mNeedsToDealWithMap)
         {
            DollarsGame.getCurrentWorld().enable();
            smIsAnyPopupOpen = false;
         }
         if(mDrawBackground && mBackground != null)
         {
            _loc2_ = DollarsGame.smInstance.mPopupClip;
            _loc2_.removeChild(mBackground);
            mBackground = null;
         }
         if(mScreenStatus != Dollars.smStage.displayState)
         {
            resetStartPosition();
         }
         mTween = new GTween(mBox,0.25,{
            "scaleX":Popup.TWEEN_MIN_SCALE,
            "scaleY":Popup.TWEEN_MIN_SCALE,
            "x":mStartPosition.x,
            "y":mStartPosition.y,
            "alpha":Popup.TWEEN_MIN_ALPHA
         },{
            "ease":Linear.easeNone,
            "onComplete":closePopup
         });
      }
      
      private function updateItemContent(param1:ItemContent) : void
      {
         var _loc2_:uint = uint(param1.mId);
         var _loc3_:ItemDefinition = param1.mDef;
         var _loc4_:int = this.mScrollRect.getChildIndex(param1);
         this.mScrollRect.removeChild(param1);
         var _loc5_:ItemContent = this.checkContentState(_loc2_,_loc3_);
         _loc5_.x = param1.x;
         _loc5_.y = param1.y;
         this.mScrollRect.addChildAt(_loc5_,_loc4_);
         _loc4_ = this.mItems.indexOf(param1);
         this.mItems[_loc4_] = null;
         this.mItems[_loc4_] = _loc5_;
      }
      
      public function start(param1:Boolean) : void
      {
         var _loc4_:TabButton = null;
         var _loc5_:Boolean = false;
         var _loc6_:MovieClip = null;
         var _loc7_:MovieClip = null;
         super.show();
         OfferManager.getInstance().mFlagNewFreeItems = false;
         this.mArrowLeft.start();
         this.mArrowRight.start();
         mCancelButton.start();
         var _loc2_:int = 0;
         ItemDefinitionManager.getInstance().update();
         var _loc3_:Array = ShopTabDefinitionManager.getInstance().getDefinitions();
         for each(_loc4_ in this.mShopTabButtons)
         {
            if(_loc4_ != null)
            {
               _loc4_.start();
               _loc4_.enable();
               _loc4_.unselect();
               _loc5_ = true;
               if(param1 && _loc2_ > ItemDefinition.TYPE_WONDERS_ID)
               {
                  _loc5_ = false;
               }
               else if(this.getDefinitionsCount(_loc2_) == 0)
               {
                  if(_loc2_ == ItemDefinition.TYPE_COUNT)
                  {
                     _loc6_ = MovieClip(this.mAreas["new_items"]);
                     _loc6_.removeChildAt(0);
                     _loc7_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"area_comming_soon"))();
                     _loc6_.addChild(_loc7_);
                     _loc5_ = true;
                  }
                  else
                  {
                     _loc5_ = false;
                  }
                  _loc4_.disable();
               }
               else if(_loc2_ == ItemDefinition.TYPE_HOUSES_ID || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && _loc2_ == ItemDefinition.TYPE_DECORATIONS_ID || Tutorial.smTutorialEnd)
               {
                  _loc4_.enable();
                  _loc4_.addEventListener(MouseEvent.CLICK,this.changeTab);
               }
               else
               {
                  _loc4_.disable();
               }
               this.areasSetAreaEnable(_loc2_,_loc5_);
            }
            _loc2_++;
         }
         this.mArrowLeft.addEventListener(MouseEvent.CLICK,this.pageRight);
         this.mArrowRight.addEventListener(MouseEvent.CLICK,this.pageLeft);
         mCancelButton.addEventListener(MouseEvent.CLICK,this.closeBox);
         this.mOldButton = null;
         if(!Tutorial.smTutorialEnd)
         {
            Tutorial.removeToolbarArrow(DollarsGame.getCurrentRole().toolsBar.getDisplayObject());
            if(Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && this.mSelectedTab != ItemDefinition.TYPE_DECORATIONS_ID)
            {
               Tutorial.addArrowToDecorations(this.mShopTabButtons[ItemDefinition.TYPE_DECORATIONS_ID] as TabButton);
            }
         }
         this.mShowing = true;
         this.mShopTabButtons[this.mSelectedTab].dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.getFeatured();
         mBox.addChild(this.mScrollRect);
         this.setOffers();
         if(!Tutorial.smTutorialEnd)
         {
            mCancelButton.disable();
            mCancelButton.getButtonMc().filters = FiltersManager.getSaturationFilter(0);
         }
         else
         {
            mCancelButton.enable();
            mCancelButton.getButtonMc().filters = null;
         }
         this.startShow();
      }
      
      private function setFBC() : void
      {
         if(this.mCurrentBalance != DollarsGame.getProfile().facebookCredits)
         {
            this.mCurrentBalance = DollarsGame.getProfile().facebookCredits;
            this.mFBCreditsBalance.text = TextManager.convertNumberToString(DollarsGame.getProfile().facebookCredits,TextManager.TRUNCATE_THOUSAND,3);
            TextManager.setTextScaled(this.mFBCreditsBalance);
         }
         if(this.mCurrentBalanceNotSpent != DollarsGame.getProfile().facebookCreditsNotSpent)
         {
            this.mCurrentBalanceNotSpent = DollarsGame.getProfile().facebookCreditsNotSpent;
            if(this.mCurrentBalanceNotSpent < 1)
            {
               this.mFBCreditsNotSpent.visible = false;
            }
            else
            {
               this.mFBCreditsNotSpent.visible = true;
               this.mFBCreditsNotSpent.text = "+" + this.mCurrentBalanceNotSpent;
            }
            TextManager.setTextScaled(this.mFBCreditsNotSpent);
         }
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         Debug.trace("image not loaded");
      }
      
      private function getShopDefinitions(param1:int) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:ItemDefinition = null;
         var _loc2_:Array = ItemDefinitionManager.getInstance().getDefinitions(param1);
         var _loc3_:Array = new Array();
         if(_loc2_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = _loc2_[_loc4_];
               if(_loc5_.isAllowedToBeInShop())
               {
                  _loc3_.push(_loc5_);
               }
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      private function onCancelExchange(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
      }
      
      private function areasRegisterArea(param1:String, param2:DisplayObject) : void
      {
         if(this.mAreas == null)
         {
            this.areasLoad();
         }
         this.mAreas[param1] = param2;
      }
      
      override protected function startShow(param1:Boolean = true) : void
      {
         mOpen = true;
         mScreenStatus = Dollars.smStage.displayState;
         mBox.scaleX = Popup.TWEEN_MIN_SCALE;
         mBox.scaleY = Popup.TWEEN_MIN_SCALE;
         mBox.alpha = Popup.TWEEN_MIN_ALPHA;
         mStartPosition.x = Dollars.smStage.mouseX;
         mStartPosition.y = Dollars.smStage.mouseY;
         mBox.x = mStartPosition.x;
         mBox.y = mStartPosition.y;
         DollarsGame.smInstance.mPopupClip.addChild(mBox);
         mTween = new GTween(mBox,0.25,{
            "scaleX":1,
            "scaleY":1,
            "x":mEndPosition.x,
            "y":mEndPosition.y,
            "alpha":1
         },{
            "ease":Linear.easeNone,
            "onComplete":startPopup
         });
         changeCursor();
      }
      
      private function onUnlockItemByCash(param1:Event) : void
      {
         this.updateItemContent(param1.target as ItemContentLocked);
      }
      
      private function areasLoad() : void
      {
         if(this.mAreas == null)
         {
            this.mAreas = new Dictionary(true);
         }
      }
      
      private function areasSetAreaEnable(param1:int, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:ShopTabDefinition = ShopTabDefinitionManager.getInstance().getDefinitionById(param1) as ShopTabDefinition;
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.sku;
         }
         if(_loc3_ != null && this.mAreas[_loc3_] != null)
         {
            this.mAreas[_loc3_].visible = param2;
         }
      }
      
      private function areasDestroy() : void
      {
         this.mAreas = null;
      }
      
      private function removeItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ItemContent = null;
         if(this.mItems != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mItems.length)
            {
               _loc2_ = this.mItems[_loc1_];
               this.mScrollRect.removeChild(_loc2_);
               _loc2_.removeEventListener(ItemContent.BUY_ITEM,this.buyItem);
               _loc2_.removeEventListener(ItemContent.EVENT_UNLOCK_ITEM,this.onUnlockItem);
               _loc2_.destroy();
               this.mItems[_loc1_] = null;
               _loc1_++;
            }
            this.mItems = null;
         }
      }
      
      private function setOffers() : void
      {
         if(this.mOffer.visible && !this.mOffersEnabled)
         {
            this.mOffer.visible = false;
         }
         if(!this.mOffer.visible && this.mOffersEnabled)
         {
            this.mOffer.visible = true;
            this.mOfferTimeLeft.text = CustomizerManager.getInstance().getOfferTimeLeft();
            TextManager.setTextScaled(this.mOfferTimeLeft);
         }
      }
      
      private function getFeatured() : void
      {
         if(this.mFeatured == null)
         {
            this.mFeatured = new FeaturedItemsBox();
            this.mFeaturedMC = mBox.getChildByName("area_featured") as MovieClip;
            this.mFeaturedMC.addChild(this.mFeatured);
         }
      }
      
      private function onVisit(param1:MouseEvent) : void
      {
         this.onClose(null);
         DollarsGame.visitUniverse(UserDataFacade.getInstance().mNPCSArray[0]);
      }
      
      private function onUnlockItem(param1:Event) : void
      {
         this.closeBox(null);
      }
      
      public function placeItem(param1:ItemDefinition) : void
      {
         this.mRole.toolsBar.setToolBuild(param1);
         this.mRole.toolsBar.unselectButton();
         DollarsGame.getCurrentWorld().map.setBuildGrid();
         this.onClose(null);
      }
      
      private function onAddGold(param1:MouseEvent) : void
      {
         DollarsGame.addGold();
      }
      
      public function getSelectedTab() : String
      {
         return ShopTabDefinitionManager.getInstance().getDefinitionById(this.mSelectedTab).sku;
      }
      
      public function checkContentState(param1:uint, param2:ItemDefinition) : ItemContent
      {
         var _loc3_:ItemContent = null;
         if(DollarsGame.getCurrentRole().usesMaxExp())
         {
            _loc3_ = new ItemContentUnlocked(this,param1,param2);
            _loc3_.addEventListener(ItemContent.BUY_ITEM,this.buyItem);
         }
         else if(param2.isLocked())
         {
            if(param2.getSaleMode() == ItemDefinition.SALE_MODE_LIM_ED)
            {
               if(param2.getUnitsAmount() == 0)
               {
                  _loc3_ = new ItemContentLimEdLocked(this,param1,param2);
               }
               else if(param2.getUnlockPrice() > 0)
               {
                  _loc3_ = new ItemContentLockedByCash(this,param1,param2);
               }
               else
               {
                  _loc3_ = new ItemContentLocked(this,param1,param2);
               }
            }
            else if(param2.getUnlockPrice() > 0)
            {
               _loc3_ = new ItemContentLockedByCash(this,param1,param2);
            }
            else
            {
               if(param2.getUnlockConditionID() == ItemDefinition.UNLOCK_CONDITION_FAN_ID && !DollarsGame.getProfile().isFan)
               {
                  _loc3_ = new ItemContentLockedFan(this,param1,param2);
               }
               else if(param2.getUnlockConditionID() == ItemDefinition.UNLOCK_CONDITION_CROSS_ID)
               {
                  _loc3_ = new ItemContentLockCrossPromotion(this,param1,param2);
               }
               else
               {
                  _loc3_ = new ItemContentLocked(this,param1,param2);
               }
               _loc3_.addEventListener(ItemContent.EVENT_UNLOCK_ITEM,this.onUnlockItem);
            }
         }
         else if(param2 is BundleDefinition)
         {
            _loc3_ = new ItemContentUnlockedBundle(this,param1,param2);
            _loc3_.addEventListener(ItemContent.BUY_ITEM,this.buyItem);
            this.mOffersEnabled = true;
         }
         else if(param2.offerDef != null)
         {
            _loc3_ = new ItemContentUnlockedOffer(this,param1,param2);
            _loc3_.addEventListener(ItemContent.BUY_ITEM,this.buyItem);
            this.mOffersEnabled = true;
         }
         else
         {
            _loc3_ = new ItemContentUnlocked(this,param1,param2);
            _loc3_.addEventListener(ItemContent.BUY_ITEM,this.buyItem);
         }
         _loc3_.start();
         return _loc3_;
      }
      
      private function buyItem(param1:Event) : void
      {
         if(param1 != null)
         {
            this.mItemDef = ItemContent(param1.target).mDef;
         }
         if(this.mItemDef.type == ItemDefinition.TYPE_BUNDLE_ID)
         {
            new PopupConfirmBundle(this.mItemDef as BundleDefinition);
         }
         else
         {
            this.placeItem(this.mItemDef);
            this.mItemDef = null;
            if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID)
            {
               this.mRole.toolsBar.disableButton(ToolsBar.BUILD_BUTTON);
               Tutorial.createBuildHouseArrow();
               DollarsGame.getCurrentWorld().map.mouseEnabled = true;
            }
            if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION)
            {
               this.mRole.toolsBar.disableButton(ToolsBar.BUILD_BUTTON);
               Tutorial.addDecoration();
               DollarsGame.getCurrentWorld().map.mouseEnabled = true;
               this.mSelectedTab = ItemDefinition.TYPE_HOUSES_ID;
            }
         }
      }
      
      private function closeBox(param1:MouseEvent) : void
      {
         this.onClose(param1);
         this.mRole.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         if(!Tutorial.smTutorialEnd)
         {
            Tutorial.removeArrowFromDecorations(this.mShopTabButtons[2] as TabButton);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Company = null;
         var _loc3_:int = 0;
         var _loc4_:ItemContent = null;
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.setFBC();
         }
         if(this.mItems != null)
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            _loc3_ = (this.mNumScrolls - 1) * 8;
            while(_loc3_ < (this.mNumScrolls - 1) * 8 + 8 && _loc3_ < this.mItems.length)
            {
               _loc4_ = this.mItems[_loc3_];
               _loc4_.setupIcon();
               if(!_loc4_.mDef.isLocked() && _loc4_ is ItemContentLocked || Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc4_.mDef.getConstructionCash() > _loc2_.DCCash && _loc4_ is ItemContentUnlocked && ItemContentUnlocked(_loc4_).mType != ItemContentUnlocked.TYPE_FBC || Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc4_.mDef.getUnlockPrice(false) > _loc2_.DCCash && _loc4_ is ItemContentLockedByCash && !ItemContentLockedByCash(_loc4_).mUnlockWithFBCredits || _loc4_ is ItemContentUnlockedOffer && _loc4_.mDef.offerDef == null)
               {
                  this.updateItemContent(_loc4_);
                  if(_loc4_ is ItemContentUnlockedOffer || _loc4_ is ItemContentUnlockedBundle)
                  {
                     this.mOffersEnabled = true;
                  }
               }
               _loc3_++;
            }
            if(this.mFeatured != null)
            {
               this.mFeatured.logicUpdate(param1);
            }
            if(this.mOffersEnabled && CustomizerManager.getInstance().isOfferExpired())
            {
               this.mOffersEnabled = false;
               this.setOffers();
            }
            else if(!this.mOffersEnabled && !CustomizerManager.getInstance().isOfferExpired())
            {
               this.mOffersEnabled = true;
               this.setOffers();
            }
         }
      }
      
      private function pageRight(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls > 1 && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            this.mDestinyPosition = _loc2_.x - 4 * this.XOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.pageRightEvent);
         }
      }
      
      private function removeFeatured() : void
      {
         if(this.mFeatured != null)
         {
            this.mFeatured.cleanBox();
            this.mFeaturedMC.removeChild(this.mFeatured);
            this.mFeatured = null;
         }
      }
      
      public function searchItem(param1:String) : void
      {
         var _loc3_:ShopTabDefinition = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc2_:ItemDefinition = ItemDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDefinition;
         if(_loc2_ != null)
         {
            if(_loc2_.getIsFeatured())
            {
               _loc3_ = ShopTabDefinitionManager.getInstance().getDefinitionBySku("featured") as ShopTabDefinition;
               this.goToTab(_loc3_.index);
            }
            else if(_loc2_.shopTab != "")
            {
               _loc3_ = ShopTabDefinitionManager.getInstance().getDefinitionBySku(_loc2_.shopTab) as ShopTabDefinition;
               this.goToTab(_loc3_.index);
            }
            else
            {
               _loc4_ = this.getShopDefinitions(_loc2_.type);
               _loc5_ = _loc4_.indexOf(_loc2_);
               this.goToTab(_loc2_.type);
               _loc6_ = _loc5_ / 8;
               _loc7_ = this.mScrollRect.scrollRect;
               _loc7_.x += _loc6_ * this.XOFFSET * 4;
               this.mScrollRect.scrollRect = _loc7_;
               this.mNumScrolls += _loc6_;
               this.checkScrollEnable();
               this.loadPageResources(_loc6_);
            }
         }
         else
         {
            this.goToTab(0);
         }
      }
      
      private function pageRightEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.x -= this.mScrollOffset;
         if(_loc2_.x <= this.mDestinyPosition)
         {
            _loc2_.x = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.pageRightEvent);
            this.mScrollingEnabled = true;
            --this.mNumScrolls;
            this.checkScrollEnable();
            this.loadPageResources(this.mNumScrolls + 1);
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function checkScrollEnable() : void
      {
         if(this.mNumScrolls == 1)
         {
            this.mArrowLeft.disable();
         }
         if(this.mNumScrolls == 2)
         {
            this.mArrowLeft.enable();
         }
         if(this.mNumScrolls == this.mMaxScrolls)
         {
            this.mArrowRight.disable();
         }
         if(this.mNumScrolls == this.mMaxScrolls - 1)
         {
            this.mArrowRight.enable();
         }
      }
      
      private function getDefinitionsCount(param1:int) : int
      {
         var _loc2_:Array = this.getShopDefinitions(param1);
         return _loc2_.length;
      }
      
      private function changeTab(param1:MouseEvent) : void
      {
         if(!this.mScrollingEnabled)
         {
            return;
         }
         var _loc2_:TabButton = param1.target as TabButton;
         if(!Tutorial.smTutorialEnd && (Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID && _loc2_ != this.mShopTabButtons[0]) || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && _loc2_ != this.mShopTabButtons[2] && _loc2_ != this.mShopTabButtons[0])
         {
            return;
         }
         if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && this.mOldButton == this.mShopTabButtons[2])
         {
            return;
         }
         if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION && _loc2_ == this.mShopTabButtons[2])
         {
            Tutorial.removeArrowFromDecorations(this.mShopTabButtons[2] as TabButton);
         }
         if(this.mOldButton != _loc2_)
         {
            if(this.mOldButton != null)
            {
               this.mOldButton.unselect();
            }
            _loc2_.select();
            this.mSelectedTab = this.mShopTabButtons.indexOf(_loc2_);
            this.getItems(this.mSelectedTab);
            this.mOldButton = _loc2_;
            if(!this.mShowing)
            {
               this.mNumScrolls = 1;
               this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT,this.XOFFSET * 4,this.YOFFSET * 2);
            }
            else
            {
               this.mShowing = false;
            }
            this.mArrowLeft.disable();
            this.mArrowRight.disable();
            if(this.mMaxScrolls > this.mNumScrolls && Tutorial.smTutorialEnd)
            {
               this.mArrowRight.enable();
            }
            if(this.mNumScrolls > 1)
            {
               this.mArrowLeft.enable();
            }
         }
      }
      
      override protected function close() : void
      {
         super.close();
         this.stop();
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         this.stop();
      }
   }
}

