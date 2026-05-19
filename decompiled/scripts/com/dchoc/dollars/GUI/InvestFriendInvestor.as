package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.invests.InvestObject;
   import com.dchoc.dollars.model.ShowPopup;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class InvestFriendInvestor extends Sprite
   {
      
      public static const EVENT_CANCEL_INVEST:String = "EventCancelInvest";
      
      private var mPhoto:Sprite;
      
      private var mCancelButton:DynamicButton;
      
      private var mResultsButton:DynamicButton;
      
      private var mBox:Sprite;
      
      private var mLoader:Loader;
      
      private var mRemindButton:DynamicButton;
      
      private var mInvestor:InvestObject;
      
      private var mPopupResultSuccess:PopupInvestSuccess;
      
      private var mFriend:FriendObject;
      
      private var mSpeedButton:DynamicButton;
      
      private var mImage:Bitmap;
      
      private var mPopupConfirmDestroy:PopupConfirmDestroy;
      
      private var mPopupResultFail:PopupInvestFail;
      
      public function InvestFriendInvestor(param1:InvestObject, param2:FriendObject)
      {
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         super();
         this.mInvestor = param1;
         this.mFriend = param2;
         switch(this.mInvestor.getState())
         {
            case InvestObject.STATE_DONE:
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_box_results"))();
               this.mResultsButton = new DynamicButton(this.mBox.getChildByName("ResultButton") as MovieClip);
               this.mResultsButton.start();
               this.mResultsButton.addEventListener(MouseEvent.CLICK,this.onResults);
               this.mResultsButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_BUTTON_RESULTS));
               break;
            case InvestObject.STATE_DONE_CLAIMED:
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_box_results"))();
               _loc3_ = this.mBox.getChildByName("ResultButton") as MovieClip;
               _loc4_ = this.mBox.getChildByName("alert") as MovieClip;
               this.mBox.removeChild(_loc4_);
               this.mBox.removeChild(_loc3_);
               break;
            case InvestObject.STATE_RUNNING:
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_box_speed"))();
               this.mSpeedButton = new DynamicButton(this.mBox.getChildByName("SpeedButton") as MovieClip);
               this.mSpeedButton.start();
               this.mSpeedButton.addEventListener(MouseEvent.CLICK,this.onSpeed);
               this.mSpeedButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_BUTTON_ASK4SPEED));
               _loc5_ = this.mInvestor.getTimeLeft();
               _loc6_ = TimerUtil.msToDays(_loc5_);
               _loc7_ = 0;
               TextManager.reformatTextField(TextField(this.mBox.getChildByName("days")));
               if(_loc6_ == 0)
               {
                  _loc7_ = TimerUtil.msToHour(_loc5_);
                  _loc5_ -= TimerUtil.hourToMs(_loc7_);
                  if(_loc5_ > 0)
                  {
                     _loc7_++;
                  }
                  TextField(this.mBox.getChildByName("day_number")).text = "" + _loc7_;
                  TextField(this.mBox.getChildByName("days")).text = TextManager.getText(TextIDs.TID_INVEST_HOURS_LEFT);
               }
               else
               {
                  TextField(this.mBox.getChildByName("day_number")).text = "" + _loc6_;
                  TextField(this.mBox.getChildByName("days")).text = TextManager.getText(TextIDs.TID_INVEST_DAYS_LEFT);
               }
               TextField(this.mBox.getChildByName("money")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberRanking(this.mInvestor.getCompanyValue()) + "/" + TextManager.convertNumberToString(InvestDefinitionManager.getInstance().getInvestDefinition().target,TextManager.TRUNCATE_MILLIONS,6);
               TextManager.setTextScaled(TextField(this.mBox.getChildByName("days")));
               break;
            case InvestObject.STATE_WAITING:
            case InvestObject.STATE_EXPIRED:
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_box_remind"))();
               this.mCancelButton = new DynamicButton(this.mBox.getChildByName("CancelButton") as MovieClip);
               this.mCancelButton.start();
               this.mCancelButton.addEventListener(MouseEvent.CLICK,this.onCancel);
               this.mCancelButton.setLabel(TextManager.getText(TextIDs.TID_GEN_BUTTON_CANCEL));
               this.mRemindButton = new DynamicButton(this.mBox.getChildByName("RemindButton") as MovieClip);
               this.mRemindButton.start();
               this.mRemindButton.addEventListener(MouseEvent.CLICK,this.onRemind);
               this.mRemindButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_BUTTON_REMIND));
               if(this.mInvestor.getState() == InvestObject.STATE_EXPIRED)
               {
                  this.mRemindButton.getButtonMc().visible = false;
               }
         }
         addChild(this.mBox);
         this.mPhoto = this.mBox.getChildByName("photo") as Sprite;
         if(this.mFriend != null)
         {
            TextManager.reformatTextField(TextField(this.mBox.getChildByName("Name")));
            TextField(this.mBox.getChildByName("Name")).text = this.mFriend.nameFriend;
         }
      }
      
      private function onCloseCancel(param1:Event) : void
      {
         this.mPopupConfirmDestroy.removeEventListener(Popup.EVENT_CLOSE,this.onCloseCancel);
         this.mPopupConfirmDestroy.removeEventListener(Popup.EVENT_ACCEPT,this.onConfirmCancel);
         this.mPopupConfirmDestroy.destroy();
         this.mPopupConfirmDestroy = null;
      }
      
      private function onRemind(param1:MouseEvent) : void
      {
         if(this.mInvestor.getRemindTimeLeft() == 0)
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
               "type":UserDataFacade.INVEST_TYPE_ON_FRIEND_REMINDER,
               "fExtId":this.mFriend.extId
            });
            this.mInvestor.remind();
         }
         else
         {
            ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,TextManager.replaceParameters(TextIDs.TID_INVEST_REMIND,new Array(TextManager.convertTimeToString(this.mInvestor.getRemindTimeLeft(),true,true))));
         }
      }
      
      public function destroy() : void
      {
         if(this.mResultsButton != null)
         {
            this.mResultsButton.removeEventListener(MouseEvent.CLICK,this.onResults);
            this.mResultsButton.destroy();
            this.mResultsButton = null;
         }
         else if(this.mSpeedButton != null)
         {
            this.mSpeedButton.removeEventListener(MouseEvent.CLICK,this.onSpeed);
            this.mSpeedButton.destroy();
            this.mSpeedButton = null;
         }
         else if(this.mCancelButton != null)
         {
            this.mCancelButton.removeEventListener(MouseEvent.CLICK,this.onCancel);
            this.mCancelButton.destroy();
            this.mCancelButton = null;
            this.mRemindButton.removeEventListener(MouseEvent.CLICK,this.onRemind);
            this.mRemindButton.destroy();
            this.mRemindButton = null;
         }
         this.removeImage();
         if(this.mLoader != null)
         {
            this.mLoader.unload();
         }
         this.mBox.removeChild(this.mPhoto);
         this.mPhoto = null;
         removeChild(this.mBox);
         this.mBox = null;
      }
      
      public function loadImage() : void
      {
         var _loc1_:URLRequest = null;
         var _loc2_:LoaderContext = null;
         if(this.mFriend != null && this.mFriend.getPictureURL() != null)
         {
            this.mLoader = new Loader();
            _loc1_ = new URLRequest(this.mFriend.getPictureURL());
            _loc2_ = new LoaderContext();
            this.mLoader.load(_loc1_,_loc2_);
            this.mPhoto.addChild(this.mLoader);
         }
      }
      
      private function onResults(param1:MouseEvent) : void
      {
         if(this.mInvestor.isSuccesfully())
         {
            this.mPopupResultSuccess = new PopupInvestSuccess();
            this.mPopupResultSuccess.showPopupParams(this.mFriend);
            this.mPopupResultSuccess.addEventListener(Popup.EVENT_CLOSE,this.onCloseSuccess);
         }
         else
         {
            this.mPopupResultFail = new PopupInvestFail();
            this.mPopupResultFail.showPopupParams(this.mFriend);
            this.mPopupResultFail.addEventListener(Popup.EVENT_CLOSE,this.onCloseFail);
         }
      }
      
      private function onCloseFail(param1:Event) : void
      {
         this.mPopupResultFail.removeEventListener(Popup.EVENT_CLOSE,this.onCloseSuccess);
         this.mPopupResultFail.destroy();
         this.mPopupResultFail = null;
         InvestManager.getInstance().applyInvestmentDone(this.mInvestor);
         dispatchEvent(new Event(EVENT_CANCEL_INVEST));
      }
      
      private function onSpeed(param1:MouseEvent) : void
      {
         if(this.mInvestor.getRemindTimeLeft() == 0)
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
               "type":UserDataFacade.INVEST_TYPE_SPEED,
               "fExtId":this.mFriend.extId
            });
            this.mInvestor.remind();
         }
         else
         {
            ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,TextManager.replaceParameters(TextIDs.TID_INVEST_WAIT,new Array(TextManager.convertTimeToString(this.mInvestor.getRemindTimeLeft(),true,true))));
         }
      }
      
      private function onCloseSuccess(param1:Event) : void
      {
         this.mPopupResultSuccess.removeEventListener(Popup.EVENT_CLOSE,this.onCloseSuccess);
         this.mPopupResultSuccess.destroy();
         this.mPopupResultSuccess = null;
         InvestManager.getInstance().applyInvestmentDone(this.mInvestor);
         dispatchEvent(new Event(EVENT_CANCEL_INVEST));
      }
      
      public function removeImage() : void
      {
         if(this.mImage != null)
         {
            this.mPhoto.removeChild(this.mImage);
            this.mImage = null;
         }
      }
      
      private function onConfirmCancel(param1:Event) : void
      {
         this.onCloseCancel(null);
         if(this.mInvestor.getState() == InvestObject.STATE_WAITING)
         {
            MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_CANCEL);
         }
         else
         {
            MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_MISS);
         }
         InvestManager.getInstance().cancelInvestment(this.mInvestor);
         dispatchEvent(new Event(EVENT_CANCEL_INVEST));
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         if(this.mPopupConfirmDestroy == null)
         {
            this.mPopupConfirmDestroy = new PopupConfirmDestroy();
            this.mPopupConfirmDestroy.showPopUp(Dollars.getCurrentCursor().mCurrentCursorID,TextManager.getText(TextIDs.TID_INVEST_CANCEL_TEXT));
            this.mPopupConfirmDestroy.addEventListener(Popup.EVENT_CLOSE,this.onCloseCancel);
            this.mPopupConfirmDestroy.addEventListener(Popup.EVENT_ACCEPT,this.onConfirmCancel);
         }
      }
   }
}

