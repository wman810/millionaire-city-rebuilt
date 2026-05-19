package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleDefinitionManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.collectibles.CollectiblePendingManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class PopupPendingCollectiblesList extends Popup
   {
      
      public static const EVENT_PENDING_COLLECTIBLE_REMOVED:String = "EventPendingCollectibleRemoved";
      
      public static const EVENT_CLOSE_POPUP:String = "EventClosePopup";
      
      public static const EVENT_CHECK_EMPTY_LIST:String = "EventCheckEmptyList";
      
      private var mOpenCollecitons:Boolean;
      
      private var mScrollOffset:Number;
      
      private var mMaxScrolls:int;
      
      private var mItems:Array;
      
      private var mArrowUp:DynamicButton;
      
      private var mScrollingEnabled:Boolean;
      
      private var mScrollRect:Sprite;
      
      private const NUM_VISIBLE_ITEMS:int = 4;
      
      private const XINIT:Number = -189.65;
      
      private const YINIT:Number = -154.85;
      
      private const XOFFSET:Number = 389.8;
      
      private const YOFFSET:Number = 88.05;
      
      private var mNumScrolls:int;
      
      private var mDestinyPosition:Number;
      
      private var mArrowDown:DynamicButton;
      
      private var mTitle:TextField = mBox.getChildByName("Caption") as TextField;
      
      public function PopupPendingCollectiblesList()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_gifts_background"))();
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_PENDING_GIFT_TITLE);
         TextManager.setTextScaled(this.mTitle);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mArrowUp = new DynamicButton(mBox.getChildByName("mArrowUp") as MovieClip);
         this.mArrowDown = new DynamicButton(mBox.getChildByName("mArrowDown") as MovieClip);
         this.mScrollRect = new Sprite();
         this.mScrollRect.x = this.XINIT;
         this.mScrollRect.y = this.YINIT;
         mBox.addChild(this.mScrollRect);
         this.getCollectibleRequests();
         addEventListener(EVENT_CLOSE_POPUP,this.onClosePopup);
         addEventListener(EVENT_CHECK_EMPTY_LIST,this.onCheckList);
         super();
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
            _loc3_ = CollectiblePendingManager.getInstance().getNumberOfPendingCollectibles();
            _loc4_ = this.mNumScrolls * this.NUM_VISIBLE_ITEMS;
            _loc5_ = _loc3_ - _loc4_ > 1 ? this.NUM_VISIBLE_ITEMS : 1;
            this.mDestinyPosition = _loc2_.y + _loc5_ * this.YOFFSET;
            this.mScrollingEnabled = false;
            addEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
         }
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
      
      private function scrollDownEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y -= this.mScrollOffset;
         if(_loc2_.y <= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            removeEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
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
      
      private function onScrollDown(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.mNumScrolls > 1 && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            _loc3_ = CollectiblePendingManager.getInstance().getNumberOfPendingCollectibles();
            _loc4_ = (this.mNumScrolls - 1) * this.NUM_VISIBLE_ITEMS;
            _loc5_ = _loc3_ - _loc4_ > 1 ? this.NUM_VISIBLE_ITEMS : 1;
            this.mDestinyPosition = _loc2_.y - _loc5_ * this.YOFFSET;
            this.mScrollingEnabled = false;
            addEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
         }
      }
      
      private function removeCollectibles() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ItemPendingCollectibleUnit = null;
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
      
      private function onClosePopup(param1:Event) : void
      {
         removeEventListener(EVENT_CLOSE_POPUP,this.onClosePopup);
         this.mOpenCollecitons = true;
         onClose(null);
      }
      
      private function onCheckList(param1:Event) : void
      {
         if(this.mItems.length <= 0)
         {
            dispatchEvent(new Event(EVENT_CLOSE_POPUP));
         }
      }
      
      private function getCollectibleRequests() : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:CollectibleDefinition = null;
         var _loc6_:CollectibleObject = null;
         var _loc7_:ItemPendingCollectibleUnit = null;
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT,this.XOFFSET,this.YOFFSET * this.NUM_VISIBLE_ITEMS - 2);
         this.removeCollectibles();
         this.mItems = new Array();
         var _loc1_:Array = CollectiblePendingManager.getInstance().getPendingCollectibles();
         var _loc2_:int = 0;
         for each(_loc3_ in _loc1_)
         {
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.split(":");
               _loc5_ = CollectibleDefinitionManager.getInstance().getDefinitionBySku(String(_loc4_[1])) as CollectibleDefinition;
               _loc6_ = new CollectibleObject(_loc5_);
               _loc7_ = new ItemPendingCollectibleUnit(_loc6_,String(_loc4_[0]));
               _loc7_.start();
               _loc7_.x = this.XINIT;
               _loc7_.y = this.YINIT + _loc2_ * this.YOFFSET;
               this.mScrollRect.addChild(_loc7_);
               this.mItems.push(_loc7_);
               _loc2_++;
            }
         }
         this.mScrollingEnabled = true;
         this.mScrollOffset = this.YOFFSET / 4;
         this.mNumScrolls = 1;
         this.mMaxScrolls = this.mItems.length / this.NUM_VISIBLE_ITEMS;
         if(this.mItems.length % this.NUM_VISIBLE_ITEMS > 0)
         {
            ++this.mMaxScrolls;
         }
         this.refreshArrows();
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
         this.mOpenCollecitons = false;
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function scrollUpEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y += this.mScrollOffset;
         if(_loc2_.y >= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            removeEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
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
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onClosePopup);
         this.mArrowUp.end();
         this.mArrowUp.removeEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mArrowDown.end();
         this.mArrowDown.removeEventListener(MouseEvent.CLICK,this.onScrollUp);
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,this.onClosePopup);
         this.mArrowUp.start();
         this.mArrowUp.addEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mArrowDown.start();
         this.mArrowDown.addEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.refreshArrows();
      }
   }
}

