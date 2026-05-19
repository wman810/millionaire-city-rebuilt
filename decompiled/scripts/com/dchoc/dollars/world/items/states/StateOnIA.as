package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupTradeBox;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxAbandoned;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxCommerceRival;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxWonder;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.TradeProcess;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.notifications.NotificationSellingEnd;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class StateOnIA extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_IA_ID;
      
      protected static const MODE_NONE:int = 0;
      
      protected static const MODE_WAIT:int = 1;
      
      protected static const MODE_IN_SALE:int = 2;
      
      protected static const MODE_BUYING:int = 3;
      
      protected static const MODE_BOUGHT:int = 4;
      
      private static const INFO_BOX_DESCRIPTION_ID:int = 0;
      
      private static const INFO_BOX_COMMERCE_ID:int = 1;
      
      private static const INFO_BOX_COUNT:int = 2;
      
      private var mInfoBox:InfoBox;
      
      private var mSellPrice:int;
      
      protected var mMode:int = 0;
      
      private var mForSaleSpr:Sprite;
      
      protected var mTime:int;
      
      private var mIsBeingUsedInTutorial:Boolean;
      
      private var mNotificationSell:NotificationSellingEnd;
      
      private var mProgressFillBar:DCFillBar;
      
      private var mTradeProcess:TradeProcess;
      
      private var mProgressBar:Sprite;
      
      public function StateOnIA(param1:StateMachine)
      {
         super(param1);
         this.viewStart();
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      protected function doEnter() : void
      {
      }
      
      override public function exit() : void
      {
         super.exit();
         this.doExit();
         this.viewEnd();
         if(this.mInfoBox != null)
         {
            infoBoxHide();
            this.mInfoBox.close();
            this.mInfoBox.destroy();
            this.mInfoBox = null;
         }
      }
      
      protected function setMode(param1:int) : void
      {
         var _loc5_:Object = null;
         var _loc6_:XML = null;
         var _loc7_:Object = null;
         var _loc2_:Boolean = this.mMode != param1;
         var _loc3_:Boolean = mUIIsMouseOver && doIsMouseOverEnabled();
         var _loc4_:int = this.mMode;
         this.mMode = param1;
         switch(this.mMode)
         {
            case MODE_WAIT:
               this.mForSaleSpr.visible = false;
               this.mTime = RulesFacade.getInstance().settingsGetTimeToPutItemOnSale();
               break;
            case MODE_IN_SALE:
               this.viewForSale();
               this.mForSaleSpr.visible = true;
               this.mTime = RulesFacade.getInstance().settingsGetTimeItemOnSale();
               break;
            case MODE_BUYING:
               if(DollarsGame.getCurrentWorld().getCompanyMine().DCCoins >= this.mSellPrice)
               {
                  this.mForSaleSpr.visible = false;
                  this.mTime = SELL_BAR_TIME;
                  this.mProgressBar.visible = true;
                  this.mProgressFillBar.setValueWithoutBarAnimation(SELL_BAR_TIME - this.mTime);
                  this.mNotificationSell = new NotificationSellingEnd(mItemObject,this.mSellPrice,itemObject.company.world.getCompanyMine());
               }
               break;
            case MODE_BOUGHT:
               if(this.mNotificationSell == null)
               {
                  this.mNotificationSell = new NotificationSellingEnd(mItemObject,this.mSellPrice,itemObject.company.world.getCompanyMine());
               }
               setNotification(this.mNotificationSell);
         }
         if(_loc3_ && !doIsMouseOverEnabled())
         {
            mItemObject.undoMouseOver(true);
         }
         if(isMouseOverEnabled())
         {
            mItemObject.company.world.map.reportMouseOver();
         }
         if(_loc2_)
         {
            _loc5_ = UserDataFacade.securityCreateObj(mGainedExp,mGainedDCCoins,mGainedDCCash);
            _loc6_ = mItemObject.getPersistence(true);
            _loc7_ = {
               "mode":this.mMode,
               "time":this.mTime
            };
            if(this.mMode == MODE_BOUGHT)
            {
               _loc6_.@csid = DollarsGame.getCurrentWorld().getCompanyMine().mSid;
               _loc7_.csid = DollarsGame.getCurrentWorld().getCompanyMine().mSid;
            }
            UserDataFacade.getInstance().updateItem(mItemObject.mSid,"new_mode",_loc7_,_loc6_,_loc5_);
            Debug.trace("item (" + mItemObject.mSid + ") State_onIA: setMode: from " + _loc4_ + " to " + this.mMode);
         }
         gainedReset();
      }
      
      override public function isSelectable() : Boolean
      {
         var _loc1_:Boolean = this.mMode == MODE_IN_SALE;
         if(_loc1_ && !Tutorial.smTutorialEnd)
         {
            _loc1_ = this.mIsBeingUsedInTutorial;
         }
         return _loc1_;
      }
      
      override public function resume() : void
      {
         if(!this.mIsBeingUsedInTutorial)
         {
            if(this.mMode == MODE_WAIT)
            {
               this.setMode(MODE_IN_SALE);
            }
         }
      }
      
      override protected function doDoSelection() : void
      {
         mUIIsSelected = true;
      }
      
      override protected function doDoClick() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.mMode == MODE_IN_SALE)
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
            undoMouseOver();
            _loc1_ = int(mItemObject.getSellPrice());
            _loc2_ = RulesFacade.getInstance().settingsGetManagersPricePercentage();
            _loc1_ -= _loc1_ * _loc2_ / 100;
            DollarsGame.setItemOutlineEnabled(false);
            this.mTradeProcess.addEventListener(TradeProcess.EVENT_TRADE,this.onTrade);
            this.mTradeProcess.startProcess();
         }
      }
      
      override public function suspend() : void
      {
         if(this.mMode == MODE_IN_SALE)
         {
            this.setMode(MODE_WAIT);
         }
      }
      
      override protected function doUndoSelection() : void
      {
         mUIIsSelected = false;
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         if(this.mInfoBox == null)
         {
            this.doInfoBoxShow();
         }
         infoBoxStart();
         if(mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
         {
            if(this.mMode == MODE_IN_SALE)
            {
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_BUY);
            }
         }
      }
      
      private function viewStart() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:DCResourceManager = DCResourceManager.getInstance();
         mItemObject.changeAnim(ItemObject.STATE_NORMAL);
         var _loc2_:ItemDefinition = mItemObject.itemDefinition;
         this.mForSaleSpr = new AssetManager.PopupForSale();
         TextManager.reformatTextField(TextField(this.mForSaleSpr.getChildByName("TopText")));
         TextField(this.mForSaleSpr.getChildByName("TopText")).text = TextManager.getText(TextIDs.TID_PANEL_FOR_SALE);
         this.mForSaleSpr.x = mItemObject.worldSizeX / 2;
         this.mForSaleSpr.y = _loc2_.baseHeight;
         this.viewForSale();
         this.mForSaleSpr.visible = false;
         mItemObject.displayObjectL1.addChild(this.mForSaleSpr);
         _loc4_ = mItemObject.itemDefinition.baseWidth;
         this.mProgressBar = new AssetManager.SellBarOnHouse();
         this.mProgressFillBar = new DCFillBar(this.mProgressBar.getChildByName("FillBar") as MovieClip,0,0);
         this.mProgressBar.x = mItemObject.getBarX();
         this.mProgressBar.y = mItemObject.getBarY();
         this.mProgressFillBar.setMaxValue(SELL_BAR_TIME);
         this.mProgressFillBar.setMinValue(0);
         _loc3_ = this.mProgressBar.width;
         if(_loc3_ > _loc4_)
         {
            this.mProgressBar.scaleX = _loc4_ / _loc3_;
            this.mProgressBar.scaleY = this.mProgressBar.scaleX;
         }
         mItemObject.displayObjectL1.addChild(this.mProgressBar);
         this.mProgressBar.visible = false;
         this.mTradeProcess = new TradeProcess(mItemObject,PopupTradeBox.TYPE_BUY);
      }
      
      private function onTrade(param1:Event) : void
      {
         this.mTradeProcess.removeEventListener(Popup.EVENT_ACCEPT,this.onTrade);
         this.onButtonBuy(null);
      }
      
      override protected function doDoIsMouseOverEnabled() : Boolean
      {
         return this.isSelectable();
      }
      
      protected function doExit() : void
      {
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(this.mInfoBox != null)
         {
            infoBoxEnd();
            this.mInfoBox.close();
            this.mInfoBox.destroy();
            this.mInfoBox = null;
         }
         if(mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         }
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return mItemObject.company.isMine();
      }
      
      protected function onButtonSign(param1:MouseEvent = null) : void
      {
         mItemObject.company.world.getCompanyMine().initItemAfterBuying(mItemObject);
      }
      
      override protected function doInfoBoxShow() : void
      {
         var _loc1_:InfoBox = this.doInfoBoxGetBox();
         _loc1_.setIncome(mItemObject.getIncomeValue(true));
         _loc1_.setAttendance(mItemObject.getPopulation());
         _loc1_.setTimer(mItemObject,mItemObject.incomeTime);
      }
      
      override public function setBehaviorTutorial(param1:int = -1) : void
      {
         this.setMode(MODE_IN_SALE);
         if(param1 == Tutorial.TUTORIAL_STEP_BUY_HOUSE_ID)
         {
            this.mIsBeingUsedInTutorial = true;
         }
      }
      
      protected function onButtonBuy(param1:MouseEvent = null) : void
      {
         this.setMode(MODE_BUYING);
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter(param1);
         if(!Tutorial.smTutorialEnd)
         {
            param1 = true;
         }
         if(param1)
         {
            this.doEnter();
            this.setMode(MODE_IN_SALE);
         }
         else
         {
            this.setMode(this.mMode);
         }
      }
      
      override public function setPersistence(param1:XML) : void
      {
         this.mMode = param1.@mode;
         this.mTime = param1.@time;
         if(this.mMode == MODE_IN_SALE)
         {
            this.mForSaleSpr.visible = true;
         }
      }
      
      override protected function infoBoxRefresh() : void
      {
         var _loc1_:InfoBox = null;
         super.infoBoxRefresh();
         if(mItemObject.itemDefinition.isACommerce())
         {
            _loc1_ = this.doInfoBoxGetBox();
            _loc1_.setIncome(mItemObject.getIncomeValue(true));
            _loc1_.setAttendance(mItemObject.getPopulation());
         }
      }
      
      private function viewForSale() : void
      {
         var _loc2_:TextField = null;
         var _loc1_:int = int(mItemObject.getSellPrice());
         if(_loc1_ != this.mSellPrice)
         {
            this.mSellPrice = _loc1_;
            _loc2_ = this.mForSaleSpr.getChildByName("prize") as TextField;
            _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.mSellPrice,TextManager.TRUNCATE_THOUSAND,6);
         }
      }
      
      private function viewUpdate() : void
      {
         if(this.mMode == MODE_BUYING)
         {
            if(this.mTime > 0)
            {
               this.mProgressFillBar.setValueWithoutBarAnimation(SELL_BAR_TIME - this.mTime);
            }
         }
      }
      
      override protected function doInfoBoxGetBox() : InfoBox
      {
         if(this.mInfoBox == null)
         {
            if(mItemObject.isSuspended)
            {
               this.mInfoBox = new InfoBoxAbandoned(DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition,TextIDs.TID_DISCONNECTED_HOUSE,TextIDs.TID_DISCONNECTED_SOLUTION);
            }
            else if(mItemObject.itemDefinition.isACommerce())
            {
               this.mInfoBox = new InfoBoxCommerceRival(DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition);
            }
            else
            {
               this.mInfoBox = new InfoBoxWonder(DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition);
            }
         }
         return this.mInfoBox;
      }
      
      override public function getPersistence() : XML
      {
         var _loc1_:XML = super.getPersistence();
         _loc1_.@mode = this.mMode;
         _loc1_.@time = this.mTime;
         return _loc1_;
      }
      
      protected function doDoLogicUpdate(param1:int) : void
      {
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         if(DollarsGame.smInstance.mShowPopup || !Tutorial.smTutorialEnd && Tutorial.smTutorialStep <= 5 && this.mMode != MODE_BUYING)
         {
            return;
         }
         super.doLogicUpdate(param1);
         switch(this.mMode)
         {
            case MODE_WAIT:
               break;
            case MODE_IN_SALE:
               if(RulesFacade.getInstance().areRivalCompanySalesTemporal())
               {
                  if(this.mTime <= 0)
                  {
                     this.mTime = 0;
                     if(!mUIIsSelected)
                     {
                        this.setMode(MODE_WAIT);
                        break;
                     }
                     this.mTime = 1;
                  }
               }
               break;
            case MODE_BUYING:
               this.mTime -= param1;
               if(this.mTime <= 0)
               {
                  this.mTime = 0;
                  this.mProgressBar.visible = false;
                  if(this.mIsBeingUsedInTutorial)
                  {
                     this.mIsBeingUsedInTutorial = false;
                  }
                  this.setMode(MODE_BOUGHT);
               }
         }
         this.viewUpdate();
         this.doDoLogicUpdate(param1);
      }
      
      private function viewEnd() : void
      {
         if(this.mForSaleSpr != null)
         {
            mItemObject.displayObjectL1.removeChild(this.mForSaleSpr);
            this.mForSaleSpr = null;
         }
         if(this.mProgressBar != null)
         {
            if(mItemObject.company.showsConstructionBar())
            {
               mItemObject.displayObjectL1.removeChild(this.mProgressBar);
            }
            this.mProgressBar = null;
            this.mProgressFillBar = null;
         }
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return true;
      }
   }
}

