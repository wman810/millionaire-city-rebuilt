package com.dchoc.dollars.GUI.storage
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.freeGift.FreeGiftPrize;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.storage.StoredItem;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class PopupStorage extends Popup
   {
      
      public static const EVENT_USE_ITEM:String = "useStorageItem";
      
      private static const ITEMS_PER_PAGE:Number = 4;
      
      private static const SCROLL_SPEED:Number = 1;
      
      private var mItemContentHeight:int;
      
      private var mArrowLeft:DynamicButton = new DynamicButton(mBox["arrow_left"]);
      
      private var mIncrement:Number;
      
      private var mStoragedItems:Vector.<StorageItemContent>;
      
      private var mItemContentWidth:int;
      
      private var mPageWidth:int;
      
      private var mContainerWidth:int;
      
      private var mContainer:Sprite;
      
      private var mArrowRight:DynamicButton = new DynamicButton(mBox["arrow_right"]);
      
      private var mIsOpen:Boolean = false;
      
      private var mTextInfoBox:MovieClip;
      
      private var mScroll:Number;
      
      private var mTitle:TextField = mBox["Title"];
      
      private var mScrollDistance:int;
      
      private var mMaxScroll:int;
      
      private var mOpenBox:PopupBoxOpen;
      
      public function PopupStorage()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.STORAGE_SWF,"popup_storage"))();
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_STORAGE_TITLE);
         TextManager.setTextScaled(this.mTitle);
         this.mTextInfoBox = mBox["text_info"];
         var _loc1_:TextField = this.mTextInfoBox["text_info"];
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = TextManager.getText(TextIDs.TID_STORAGE_EMPTY);
         TextManager.setTextScaled(_loc1_);
         this.mContainer = mBox["popup_area"];
         this.mContainerWidth = this.mContainer.width;
         this.mContainer.scrollRect = new Rectangle(0,0,this.mContainer.width,this.mContainer.height);
         mCancelButton = new DynamicButton(mBox["mClose"]);
         this.getStorageItems();
         this.mScroll = 0;
         this.mScrollDistance = 0;
         super();
      }
      
      override public function destroy() : void
      {
         this.destroyStorageItems();
         this.mTitle = null;
         mTextBox = null;
         mCancelButton = null;
         this.mContainer = null;
         this.mArrowLeft.destroy();
         this.mArrowRight.destroy();
         this.mArrowLeft = null;
         this.mArrowRight = null;
         this.mScroll = 0;
         this.mScrollDistance = 0;
         super.destroy();
      }
      
      private function scrollLeft(param1:MouseEvent = null) : void
      {
         if(this.mContainer.scrollRect.x <= 0)
         {
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         else if(this.mScrollDistance == 0)
         {
            this.mScroll = -SCROLL_SPEED;
            this.mScrollDistance = (this.mItemContentWidth + this.mIncrement) * ITEMS_PER_PAGE;
         }
         if(this.mContainer.scrollRect.x - this.mScrollDistance <= 0)
         {
            this.mArrowLeft.disable();
         }
         if(this.mStoragedItems.length > ITEMS_PER_PAGE)
         {
            this.mArrowRight.enable();
         }
      }
      
      public function logicUpdate(param1:Number) : void
      {
         var _loc4_:StorageItemContent = null;
         if(this.mOpenBox != null)
         {
            if(!this.mOpenBox.isOpen())
            {
               this.mOpenBox.destroy();
               this.mOpenBox = null;
            }
         }
         if(StorageManager.getInstance().hasChanged())
         {
            this.destroyStorageItems();
            this.getStorageItems();
         }
         var _loc2_:int = this.mScroll * param1;
         this.mScrollDistance -= Math.abs(_loc2_);
         if(this.mScrollDistance <= 0)
         {
            if(_loc2_ < 0)
            {
               _loc2_ -= this.mScrollDistance;
            }
            else
            {
               _loc2_ += this.mScrollDistance;
            }
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         var _loc3_:Rectangle = this.mContainer.scrollRect;
         _loc3_.x += _loc2_;
         this.mContainer.scrollRect = _loc3_;
         for each(_loc4_ in this.mStoragedItems)
         {
            _loc4_.setupIcon();
         }
         if(this.mIsOpen)
         {
            DollarsGame.getCurrentRole().toolsBar.setVaultAlert(false);
         }
      }
      
      private function getStorageItems() : void
      {
         var _loc2_:StorageItemContent = null;
         var _loc5_:StoredItem = null;
         this.mStoragedItems = new Vector.<StorageItemContent>();
         var _loc1_:Array = StorageManager.getInstance().getItems();
         var _loc3_:Sprite = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.STORAGE_SWF,"storage_box"))();
         this.mItemContentWidth = _loc3_.width;
         this.mItemContentHeight = _loc3_.height;
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc5_ = _loc1_[_loc4_];
            _loc2_ = new StorageItemContent(_loc5_);
            this.mContainer.addChild(_loc2_);
            if(_loc2_.isItem())
            {
               if(_loc5_.mAction == StoredItem.ACTION_OPENBOX)
               {
                  _loc2_.addEventListener(EVENT_USE_ITEM,this.onOpenBox);
               }
               else
               {
                  _loc2_.addEventListener(EVENT_USE_ITEM,this.onCloseStorage);
               }
               this.mStoragedItems.push(_loc2_);
            }
            _loc4_++;
         }
         this.setStorageItemPosition();
         this.disableArrows();
      }
      
      private function refreshStorageItems() : void
      {
         var _loc1_:StorageItemContent = null;
         var _loc2_:* = 0;
         while(_loc2_ < this.mStoragedItems.length)
         {
            _loc1_ = this.mStoragedItems[_loc2_];
            if(_loc1_.mStoredItem.getAmount() == 0)
            {
               _loc1_.destroy();
               mBox.removeChild(_loc1_);
               this.mStoragedItems.splice(_loc2_,1);
               _loc2_--;
            }
            else
            {
               _loc1_.buildAvailableText();
            }
            _loc2_++;
         }
         this.setStorageItemPosition();
      }
      
      private function disableArrows() : void
      {
         if(this.mContainer.scrollRect.x <= 0)
         {
            this.mArrowLeft.disable();
         }
         if(this.mStoragedItems.length > ITEMS_PER_PAGE && this.mContainer.scrollRect.x + this.mPageWidth < this.mMaxScroll)
         {
            this.mArrowRight.enable();
         }
         else
         {
            this.mArrowRight.disable();
         }
      }
      
      private function destroyStorageItems() : void
      {
         var _loc1_:StorageItemContent = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.mStoragedItems.length)
         {
            _loc1_ = this.mStoragedItems[_loc2_];
            if(_loc1_.mStoredItem.mAction == StoredItem.ACTION_OPENBOX)
            {
               _loc1_.removeEventListener(EVENT_USE_ITEM,this.onOpenBox);
            }
            else
            {
               _loc1_.removeEventListener(EVENT_USE_ITEM,this.onCloseStorage);
            }
            if(this.mContainer.contains(_loc1_))
            {
               this.mContainer.removeChild(_loc1_);
            }
            _loc1_.destroy();
            delete this.mStoragedItems[_loc2_];
            _loc2_++;
         }
         this.mStoragedItems = null;
      }
      
      private function onCloseStorage(param1:Event) : void
      {
         var _loc2_:StorageItemContent = null;
         var _loc3_:ItemDefinition = null;
         super.onClose(null);
         _loc2_ = param1.target as StorageItemContent;
         if(_loc2_ != null)
         {
            switch(_loc2_.mStoredItem.mAction)
            {
               case StoredItem.ACTION_MOVE:
                  DollarsGame.getCurrentRole().toolsBar.setToolMove("move");
                  break;
               case StoredItem.ACTION_PLACE:
                  _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(_loc2_.mStoredItem.mSku) as ItemDefinition;
                  DollarsGame.getCurrentRole().toolsBar.setToolBuild(_loc3_,true,UserDataFacade.getInstance().cmdCreateNewItemFromStorage(),false,"storage");
                  break;
               case StoredItem.ACTION_RENT_ACCELERATOR:
                  DollarsGame.getCurrentRole().toolsBar.setToolRentAccelerator(_loc2_.mStoredItem.mType);
            }
         }
      }
      
      private function onOpenBox(param1:Event) : void
      {
         var _loc3_:FreeGiftPrize = null;
         var _loc2_:StorageItemContent = param1.target as StorageItemContent;
         if(_loc2_.mStoredItem.mAction == StoredItem.ACTION_OPENBOX)
         {
            _loc3_ = FreeGiftDefinitionManager.getInstance().openBox(_loc2_.mStoredItem.mSku);
            if(_loc3_ != null)
            {
               StorageManager.getInstance().removeItem(_loc2_.mStoredItem.mSku);
               this.mOpenBox = new PopupBoxOpen(_loc3_);
            }
         }
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onCloseStorage);
         this.mArrowLeft.end();
         this.mArrowLeft.removeEventListener(MouseEvent.CLICK,this.scrollLeft);
         this.mArrowRight.end();
         this.mArrowRight.removeEventListener(MouseEvent.CLICK,this.scrollRight);
      }
      
      private function scrollRight(param1:MouseEvent = null) : void
      {
         if(this.mContainer.scrollRect.x + this.mPageWidth >= this.mMaxScroll)
         {
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         else if(this.mScrollDistance == 0)
         {
            this.mScroll = SCROLL_SPEED;
            this.mScrollDistance = (this.mItemContentWidth + this.mIncrement) * ITEMS_PER_PAGE;
         }
         if(this.mContainer.scrollRect.x + this.mPageWidth + this.mScrollDistance >= this.mMaxScroll)
         {
            this.mArrowRight.disable();
         }
         this.mArrowLeft.enable();
      }
      
      public function isStorageOpen() : Boolean
      {
         return this.mIsOpen;
      }
      
      private function setStorageItemPosition() : void
      {
         var _loc1_:int = 0;
         if(this.mStoragedItems.length > 0)
         {
            this.mTextInfoBox.visible = false;
            if(this.mStoragedItems.length <= ITEMS_PER_PAGE)
            {
               this.mIncrement = (this.mContainerWidth - this.mItemContentWidth * this.mStoragedItems.length) / (this.mStoragedItems.length + 1);
            }
            else
            {
               this.mIncrement = (this.mContainerWidth - this.mItemContentWidth * ITEMS_PER_PAGE) / (ITEMS_PER_PAGE + 1);
            }
            this.mIncrement = Math.ceil(this.mIncrement);
            _loc1_ = 0;
            while(_loc1_ < this.mStoragedItems.length)
            {
               this.mStoragedItems[_loc1_].x = (this.mItemContentWidth + this.mIncrement) * _loc1_ + this.mIncrement;
               this.mStoragedItems[_loc1_].y = this.mContainer.height - this.mItemContentHeight >> 1;
               _loc1_++;
            }
            this.mMaxScroll = (this.mItemContentWidth + this.mIncrement) * this.mStoragedItems.length + this.mIncrement;
            this.mPageWidth = (this.mItemContentWidth + this.mIncrement) * ITEMS_PER_PAGE + this.mIncrement;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
         this.mIsOpen = true;
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
         this.mIsOpen = false;
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,this.onCloseStorage);
         this.mArrowLeft.start();
         this.mArrowLeft.addEventListener(MouseEvent.CLICK,this.scrollLeft);
         this.mArrowRight.start();
         this.mArrowRight.addEventListener(MouseEvent.CLICK,this.scrollRight);
         this.disableArrows();
      }
   }
}

