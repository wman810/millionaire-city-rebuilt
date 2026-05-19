package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.PopupInstantBuild;
   import com.dchoc.dollars.GUI.PopupTradeBox;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxConstruction;
   import com.dchoc.dollars.GUI.instantBuild.PopupInstantBuildSecondStep;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.notifications.NotificationConstructionEnd;
   import com.dchoc.framework.states.StateMachine;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class StateOnConstructionOwner extends StateOnConstruction
   {
      
      private var mConstructionInfo:InfoBoxConstruction;
      
      public function StateOnConstructionOwner(param1:StateMachine, param2:int = -1)
      {
         super(param1,param2);
         this.load();
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
         {
            if(this.isInstantBuildAllowed())
            {
               if(mItemObject.itemDefinition.getConstructionTime() >= RulesFacade.getInstance().settingsGetHelpConstructionMinTime())
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_WONDER);
               }
               else
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_INSTANT_BUILD);
               }
            }
         }
         if(!mItemObject.isSuspended && mTime < mMaxTime && Tutorial.smTutorialEnd)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map.getWorldXToScreen(mItemObject.worldX) + mItemObject.worldSizeX;
            _loc3_ = DollarsGame.getCurrentWorld().map.getWorldYToScreen(mItemObject.worldY) + mItemObject.worldSizeY / 2;
            this.mConstructionInfo = new InfoBoxConstruction(DollarsGame.smInstance.mGameClip,mItemObject.itemDefinition);
            setTimeout(this.mConstructionInfo.show,StateOnConstruction.TOOLTIP_DELAY,mItemObject.itemDefinition,_loc2_,_loc3_,mItemObject.worldSizeX);
         }
      }
      
      private function instantBuildConfirmClose(param1:Event = null) : void
      {
         var _loc2_:PopupTradeBox = DollarsGame.smInstance.mPopupInstantBuild;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.instantBuildDoAccept);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.instantBuildConfirmClose);
         var _loc3_:PopupConfirm = DollarsGame.smInstance.mPopupConfirm;
         _loc3_.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.instantBuildDoAccept);
         DollarsGame.getCurrentWorld().enable();
         if(Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_INSTANT_BUILD_ID && mTime == 0)
         {
            Tutorial.removeHouseArrow(mItemObject);
         }
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         if(mItemObject.isSuspended)
         {
            return true;
         }
         return super.doIsDestroyable();
      }
      
      private function eventInstantBuild(param1:Event = null) : void
      {
         this.instantBuildFBC();
      }
      
      override protected function doExit() : void
      {
         if(mUIIsSelected)
         {
            mItemObject.company.world.role.toolsBar.unattachItem(mItemObject);
         }
         if(mUIIsSelected)
         {
            undoSelection();
         }
         if(mUIIsMouseOver)
         {
            undoMouseOver();
         }
         this.unattachCompany();
         this.instantBuildEnd();
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         }
         if(this.mConstructionInfo != null)
         {
            this.mConstructionInfo.close();
            this.mConstructionInfo.destroy();
            this.mConstructionInfo = null;
         }
      }
      
      override protected function doEnter() : void
      {
         mUIIsSelected = false;
         this.attachCompany();
      }
      
      private function secondStepAcceptFBC(param1:Event = null) : void
      {
         var _loc2_:PopupInstantBuildSecondStep = DollarsGame.smInstance.mPopupInstantBuildSecondStep;
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_CASH,this.secondStepAcceptCash);
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.secondStepAcceptFBC);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.secondStepClose);
         this.eventInstantBuild(param1);
      }
      
      override public function doEnterFirstTime() : void
      {
         super.doEnterFirstTime();
         mItemObject.doMouseOver();
         var _loc1_:Map = mItemObject.company.world.map;
         _loc1_.setToolItemMouseOver(mItemObject);
      }
      
      private function isInstantBuildAllowed() : Boolean
      {
         return mTime < mMaxTime && !mItemObject.isSuspended;
      }
      
      private function instantBuildSecondStep(param1:Event) : void
      {
         this.removeWondersEventlisteners();
         var _loc2_:PopupInstantBuildSecondStep = DollarsGame.smInstance.mPopupInstantBuildSecondStep;
         _loc2_.start(mTime,mItemObject.itemDefinition);
         _loc2_.addEventListener(PopupInstantBuildSecondStep.EVENT_BUY_CASH,this.secondStepAcceptCash);
         _loc2_.addEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.secondStepAcceptFBC);
         _loc2_.addEventListener(Popup.EVENT_CLOSE,this.secondStepClose);
      }
      
      private function instantBuildStart(param1:Event) : void
      {
         var _loc3_:PopupConfirm = null;
         var _loc4_:PopupTradeBox = null;
         DollarsGame.smInstance.mPopupWonders.removeEventListener(Popup.EVENT_ACCEPT,this.instantBuildStart);
         var _loc2_:int = RulesFacade.getInstantBuildPrice(mTime,mItemObject.itemDefinition.getInstantBuildFactor());
         if(DollarsGame.getCurrentWorld().getCompanyMine().DCCoins < _loc2_)
         {
            _loc3_ = DollarsGame.smInstance.mPopupConfirm;
            _loc3_.startAskForHelpFBCredits(_loc2_);
            _loc3_.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.instantBuildDoAccept);
            _loc3_.addEventListener(Popup.EVENT_CLOSE,this.instantBuildConfirmClose);
         }
         else
         {
            _loc4_ = DollarsGame.smInstance.mPopupInstantBuild;
            _loc4_.start();
            _loc4_.changePrize(_loc2_);
            _loc4_.addEventListener(Popup.EVENT_ACCEPT,this.instantBuildDoAccept);
            _loc4_.addEventListener(Popup.EVENT_CLOSE,this.instantBuildConfirmClose);
         }
         DollarsGame.getCurrentWorld().disable();
      }
      
      private function secondStepClose(param1:Event = null) : void
      {
         var _loc2_:PopupInstantBuildSecondStep = DollarsGame.smInstance.mPopupInstantBuildSecondStep;
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_CASH,this.secondStepAcceptCash);
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.secondStepAcceptFBC);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.secondStepClose);
         DollarsGame.getCurrentWorld().enable();
         MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_CANCEL,mItemObject.itemDefinition.itemName,null,null,0,0);
         if(Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_INSTANT_BUILD_ID && mTime == 0)
         {
            Tutorial.removeHouseArrow(mItemObject);
         }
      }
      
      private function secondStepAcceptCash(param1:Event = null) : void
      {
         var _loc2_:PopupInstantBuildSecondStep = DollarsGame.smInstance.mPopupInstantBuildSecondStep;
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_CASH,this.secondStepAcceptCash);
         _loc2_.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.secondStepAcceptFBC);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.secondStepClose);
         this.instantBuildCash();
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return super.doIsMouseOverEnabled();
      }
      
      private function instantBuildDoAccept(param1:Event = null) : void
      {
         var _loc2_:PopupTradeBox = DollarsGame.smInstance.mPopupInstantBuild;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.instantBuildDoAccept);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.instantBuildConfirmClose);
         var _loc3_:PopupConfirm = DollarsGame.smInstance.mPopupConfirm;
         _loc3_.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.instantBuildDoAccept);
         this.instantBuildCash();
      }
      
      private function instantBuildFBC(param1:Event = null) : void
      {
         MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_INSTANT_BUILD,MetricConstants.LABEL_ECONOMY_BUY_INSTANT_BUILD,null,null,0,mItemObject.itemDefinition.getInstantBuildFBC());
         MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_FBC,mItemObject.itemDefinition.itemName,null,null,0,0);
         setMode(MODE_INSTANT_BUILD);
         mTime = 0;
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_INSTANT_BUILD);
         this.instantBuildConfirmClose();
         this.instantBuildClose(null);
      }
      
      private function load() : void
      {
      }
      
      private function instantBuildCash() : void
      {
         var _loc1_:int = RulesFacade.getInstantBuildPrice(mTime,mItemObject.itemDefinition.getInstantBuildFactor());
         mItemObject.company.DCCoins -= _loc1_;
         gainedAccumDCCoins(-_loc1_);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_INSTANT_BUILD,MetricConstants.LABEL_ECONOMY_BUY_INSTANT_BUILD,null,null,_loc1_,0);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_CASH,mItemObject.itemDefinition.itemName,null,null,0,0);
         setMode(MODE_INSTANT_BUILD);
         mTime = 0;
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_INSTANT_BUILD);
         this.instantBuildConfirmClose();
      }
      
      private function instantBuildClose(param1:Event = null) : void
      {
         this.removeWondersEventlisteners();
         if(param1 != null)
         {
            DollarsGame.getCurrentWorld().enable();
            MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_CANCEL,mItemObject.itemDefinition.itemName,null,null,0,0);
         }
      }
      
      private function instantBuildEnd() : void
      {
         this.instantBuildClose();
      }
      
      override protected function doDoLogicUpdate(param1:int) : void
      {
         var _loc3_:Boolean = false;
         if(this.mConstructionInfo != null && this.doIsMouseOverEnabled())
         {
            this.mConstructionInfo.setTimer(mItemObject,mTime);
         }
         var _loc2_:Number = (mMaxTime - time) * 100 / mMaxTime;
         if(mTime <= 0)
         {
            _loc3_ = false;
            setNotification(new NotificationConstructionEnd(mItemObject,_loc3_));
         }
      }
      
      override protected function doDoClick() : void
      {
         if(this.isInstantBuildAllowed())
         {
            DollarsGame.setItemOutlineEnabled(false);
            switch(mItemObject.itemDefinition.getInstantBuildType())
            {
               case ItemDefinition.INSTANT_BUILD_CASH:
                  this.instantBuildStart(null);
                  break;
               case ItemDefinition.INSTANT_BUILD_A4H:
               case ItemDefinition.INSTANT_BUILD_FBC_A4H:
               case ItemDefinition.INSTANT_BUILD_CASH_FBC_A4H:
                  DollarsGame.getCurrentWorld().disable();
                  DollarsGame.smInstance.mPopupWonders.loadFriends(mItemObject.sid);
                  DollarsGame.smInstance.mPopupWonders.showPopupParams(mItemObject.itemDefinition);
                  if(mItemObject.itemDefinition.getInstantBuildType() == ItemDefinition.INSTANT_BUILD_FBC_A4H)
                  {
                     DollarsGame.smInstance.mPopupWonders.addEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.eventInstantBuild);
                  }
                  else if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
                  {
                     DollarsGame.smInstance.mPopupWonders.addEventListener(Popup.EVENT_ACCEPT,this.instantBuildSecondStep);
                  }
                  else
                  {
                     DollarsGame.smInstance.mPopupWonders.addEventListener(Popup.EVENT_ACCEPT,this.instantBuildStart);
                  }
                  DollarsGame.smInstance.mPopupWonders.addEventListener(Popup.EVENT_CLOSE,this.instantBuildClose);
                  DollarsGame.smInstance.mPopupWonders.addEventListener(PopupInstantBuild.EVENT_ASKHELP,this.onAskHelp);
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_START,mItemObject.itemDefinition.itemName,null,null,0,0);
                  break;
               default:
                  this.instantBuildStart(null);
            }
         }
      }
      
      override public function demolish(param1:Boolean = false) : void
      {
         onCancel(null);
      }
      
      override protected function doDoSelection() : void
      {
         if(!mUIIsSelected)
         {
            mUIIsSelected = true;
         }
      }
      
      override public function attachCompany() : void
      {
         if(mItemObject.company.showsConstructionBar())
         {
            if(Tutorial.smTutorialStep != Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID && this.mConstructionInfo != null)
            {
               this.mConstructionInfo.close();
               this.mConstructionInfo.destroy();
               this.mConstructionInfo = null;
            }
         }
      }
      
      private function removeWondersEventlisteners() : void
      {
         if(mItemObject.itemDefinition.getInstantBuildType() == ItemDefinition.INSTANT_BUILD_FBC_A4H)
         {
            DollarsGame.smInstance.mPopupWonders.removeEventListener(PopupInstantBuildSecondStep.EVENT_BUY_FBC,this.eventInstantBuild);
         }
         else
         {
            DollarsGame.smInstance.mPopupWonders.removeEventListener(Popup.EVENT_ACCEPT,this.instantBuildSecondStep);
         }
         DollarsGame.smInstance.mPopupWonders.removeEventListener(Popup.EVENT_CLOSE,this.instantBuildClose);
         DollarsGame.smInstance.mPopupWonders.removeEventListener(PopupInstantBuild.EVENT_ASKHELP,this.onAskHelp);
      }
      
      override public function destroy() : void
      {
         this.doExit();
         this.mConstructionInfo = null;
         super.destroy();
      }
      
      private function onAskHelp(param1:Event) : void
      {
         this.removeWondersEventlisteners();
         var _loc2_:Object = new Object();
         _loc2_.sid = mItemObject.sid;
         _loc2_.name = TextManager.getText(TextIDs[mItemObject.itemDefinition.textID]);
         _loc2_.sku = mItemObject.itemDefinition.sku;
         _loc2_.type = mItemObject.itemDefinition.type;
         _loc2_.feedImg = mItemObject.itemDefinition.getFeedImg();
         _loc2_.product = MetricConstants.EVENT_FACEBOOK_FEED_HELP;
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_ASK_FOR_HELP,_loc2_);
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_ASK_FOR_HELP);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_INSTANT_BUILD_FUNNEL,MetricConstants.LABEL_INSTANT_BUILD_A4H,mItemObject.itemDefinition.itemName,null,null,0,0);
         if(param1 != null)
         {
            DollarsGame.getCurrentWorld().enable();
         }
      }
      
      override protected function doUndoSelection() : void
      {
         if(mUIIsSelected)
         {
            setNotification(null);
            mUIIsSelected = false;
         }
      }
      
      override public function unattachCompany() : void
      {
         this.doUndoMouseOver();
      }
   }
}

