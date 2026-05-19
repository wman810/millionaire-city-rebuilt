package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import com.dchoc.framework.utils.AssetManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ContractBox extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const SKU:String = "Contracts";
      
      private var mArrowLeft:DynamicButton = new DynamicButton(mBox.getChildByName("mArrowLeft") as MovieClip);
      
      private const NUM_ITEMS_PAGE:int = 6;
      
      private var mMaxScrolls:int;
      
      private var mItems:Array;
      
      private var mArrowRight:DynamicButton = new DynamicButton(mBox.getChildByName("mArrowRight") as MovieClip);
      
      private var mTutorialArrow:MovieClip;
      
      private const XINIT:Number = -60;
      
      private const YINIT:Number = -12;
      
      private const XOFFSET:Number = 114;
      
      private const YOFFSET:Number = 147;
      
      private var mNumScrolls:int;
      
      protected var mCurrentContractItem:ContractItem;
      
      private var mScrollRect:Sprite;
      
      public function ContractBox()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_background_contract"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_CONTRACT_POPUP_TITLE);
         this.mScrollRect = new Sprite();
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT - 58,this.YINIT - 74,this.XOFFSET * 3,Dollars.smStage.stageHeight);
         mBox.addChild(this.mScrollRect);
         this.mNumScrolls = 1;
         super();
      }
      
      private static function sortCompareFunctionTime(param1:ContractDefinition, param2:ContractDefinition) : Number
      {
         var _loc3_:Number = param1.getIncomeTime();
         var _loc4_:Number = param2.getIncomeTime();
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      private static function sortCompareFunctionLevel(param1:ContractDefinition, param2:ContractDefinition) : Number
      {
         var _loc3_:Number = param1.level;
         var _loc4_:Number = param2.level;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      private function removeConfirmEventListeners() : void
      {
         var _loc1_:Popup = DollarsGame.smInstance.mPopupConfirm;
         _loc1_.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         _loc1_.removeEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_SKIP_ACTION,MetricConstants.PRODUCT_CONTRACT,null,null,0,1);
            onAccept(null);
            this.onDoContract(true);
         }
      }
      
      private function onExchange(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         onAccept(null);
         this.onDoContract();
      }
      
      public function getContractItemSelected() : ContractItem
      {
         return this.mCurrentContractItem;
      }
      
      private function getItems() : void
      {
         var _loc1_:Rectangle = null;
         this.removeItems();
         this.createItems();
         this.mMaxScrolls = this.mItems.length / this.NUM_ITEMS_PAGE;
         if(this.mItems.length % this.NUM_ITEMS_PAGE > 0)
         {
            ++this.mMaxScrolls;
         }
         if(this.mNumScrolls > this.mMaxScrolls)
         {
            _loc1_ = this.mScrollRect.scrollRect;
            _loc1_.x -= (this.mNumScrolls - this.mMaxScrolls) * 3 * this.XOFFSET;
            this.mScrollRect.scrollRect = _loc1_;
            this.mNumScrolls = this.mMaxScrolls;
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
         this.mScrollRect.x = this.XINIT - 56 * 2;
         this.mScrollRect.y = this.YINIT - 71 * 2;
      }
      
      private function onRight(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls < this.mMaxScrolls)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            _loc2_.x += 3 * this.XOFFSET;
            this.mScrollRect.scrollRect = _loc2_;
            ++this.mNumScrolls;
            if(this.mNumScrolls == this.mMaxScrolls)
            {
               this.mArrowRight.disable();
            }
            if(this.mNumScrolls > 1)
            {
               this.mArrowLeft.enable();
            }
         }
      }
      
      private function onLeft(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls > 1)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            _loc2_.x -= 3 * this.XOFFSET;
            this.mScrollRect.scrollRect = _loc2_;
            --this.mNumScrolls;
            if(this.mNumScrolls == 1)
            {
               this.mArrowLeft.disable();
            }
            if(this.mNumScrolls == this.mMaxScrolls - 1)
            {
               this.mArrowRight.enable();
            }
         }
      }
      
      private function onContract(param1:Event) : void
      {
         var _loc2_:ContractItem = param1.target as ContractItem;
         var _loc3_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mCurrentContractItem = _loc2_;
         if(_loc3_.DCCoins >= _loc2_.getCostCoins())
         {
            onAccept(null);
            this.onDoContract();
         }
         else
         {
            if(this is ContractBoxSingle)
            {
               DollarsGame.smInstance.mPopupConfirm.startAskForHelpFBCredits(this.mCurrentContractItem.getCostCoins());
            }
            else if(this is ContractBoxMultiple)
            {
               DollarsGame.smInstance.mPopupConfirm.startNoAction(this.mCurrentContractItem.getCostCoins());
            }
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         }
         if(!Tutorial.smTutorialEnd && this.mTutorialArrow != null)
         {
            mBox.removeChild(this.mTutorialArrow);
            this.mTutorialArrow = null;
         }
      }
      
      protected function addItem(param1:ContractItem) : void
      {
         var _loc2_:int = int(this.mItems.length);
         param1.x = this.XINIT + this.XOFFSET * (_loc2_ % 3) + this.XOFFSET * 3 * int(_loc2_ / 6);
         param1.y = this.YINIT + this.YOFFSET * (int(_loc2_ / 3) % 2);
         if(param1.getLevel() <= DollarsGame.getProfile().level)
         {
            param1.addEventListener(ContractItem.EVENT_CONTRACT,this.onContract);
            param1.addEventListener(MouseEvent.MOUSE_OVER,this.onItemMouseOver);
            param1.addEventListener(MouseEvent.MOUSE_OUT,this.onItemMouseOut);
            param1.addInfoShow(mBox);
         }
         if(!Tutorial.smTutorialEnd && _loc2_ == 0)
         {
            this.mTutorialArrow = new AssetManager.TutorialArrow();
            this.mTutorialArrow.x = param1.x - param1.width / 2;
            this.mTutorialArrow.y = param1.y - param1.height;
            mBox.addChild(this.mTutorialArrow);
         }
         this.mScrollRect.addChild(param1);
         this.mItems.push(param1);
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":FBCreditsPurchase.SKIP_ACTION_PRICE,
            "orderInfo":{
               "type":FBCreditsPurchase.TYPE_SKIP_ACTION,
               "sku":"contract"
            }
         };
      }
      
      private function onItemMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:ContractItem = param1.target as ContractItem;
         if(_loc2_ != null)
         {
            _loc2_.closeInfoBox();
         }
      }
      
      private function removeItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ContractItem = null;
         if(this.mItems != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mItems.length)
            {
               _loc2_ = this.mItems[_loc1_];
               _loc2_.removeEventListener(ContractItem.EVENT_CONTRACT,this.onContract);
               _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,this.onItemMouseOver);
               _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,this.onItemMouseOut);
               _loc2_.destroy();
               this.mScrollRect.removeChild(_loc2_);
               this.mItems[_loc1_] = null;
               _loc1_++;
            }
         }
         this.mItems = new Array();
      }
      
      protected function createItems() : void
      {
      }
      
      private function onFBCGoOn(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      private function onItemMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:ContractItem = param1.target as ContractItem;
         if(_loc2_ != null)
         {
            _loc2_.showInfoBox(_loc2_.x + _loc2_.width / 2 + this.mScrollRect.x - this.mScrollRect.scrollRect.x - 10);
         }
      }
      
      protected function onDoContract(param1:Boolean = false) : void
      {
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mArrowLeft.end();
         this.mArrowLeft.removeEventListener(MouseEvent.CLICK,this.onLeft);
         this.mArrowRight.end();
         this.mArrowRight.removeEventListener(MouseEvent.CLICK,this.onRight);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(Popup.EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         mCancelButton.destroy();
         mCancelButton = null;
         this.mArrowLeft.destroy();
         this.mArrowLeft = null;
         this.mArrowRight.destroy();
         this.mArrowRight = null;
         mBox.removeChild(this.mScrollRect);
         this.mScrollRect = null;
         mBox = null;
      }
      
      override public function show() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.getButtonMc().addEventListener(MouseEvent.CLICK,onClose);
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
         this.mArrowLeft.start();
         this.mArrowLeft.addEventListener(MouseEvent.CLICK,this.onLeft);
         this.mArrowRight.start();
         this.mArrowRight.addEventListener(MouseEvent.CLICK,this.onRight);
         this.getItems();
         this.startShow();
      }
      
      override protected function startShow(param1:Boolean = true) : void
      {
         mOpen = true;
         mScreenStatus = Dollars.smStage.displayState;
         mBox.scaleX = Popup.TWEEN_MIN_SCALE;
         mBox.scaleY = Popup.TWEEN_MIN_SCALE;
         mBox.alpha = Popup.TWEEN_MIN_ALPHA;
         if(mStartPosition == null)
         {
            mStartPosition = new Point(mBox.x,mBox.y);
         }
         mStartPosition.x = Dollars.smStage.mouseX;
         mStartPosition.y = Dollars.smStage.mouseY;
         mBox.x = mStartPosition.x;
         mBox.y = mStartPosition.y;
         DollarsGame.smInstance.mPopupClip.addChild(mBox);
         mTween = new GTween(mBox,Popup.TWEEN_LENGHT_OUT,{
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
   }
}

