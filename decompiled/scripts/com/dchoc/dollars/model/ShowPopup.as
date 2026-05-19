package com.dchoc.dollars.model
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmDestroy;
   import com.dchoc.dollars.GUI.PopupConnection;
   import com.dchoc.dollars.GUI.PopupMessage;
   import com.dchoc.dollars.GUI.PopupMessageSmall;
   import com.dchoc.dollars.GUI.PopupOutOfSync;
   import com.dchoc.dollars.GUI.payment.PopupPaymentFail;
   import com.dchoc.dollars.flow.DollarsGame;
   import flash.events.Event;
   
   public class ShowPopup
   {
      
      private static var mActionOk:Function;
      
      private static var mParamsOk:Object;
      
      private static var mActionCancel:Function;
      
      private static var mParamsCancel:Object;
      
      private static var mPopup:Popup;
      
      public static const POPUP_MSG:int = 0;
      
      public static const POPUP_MSG_SMALL:int = 2;
      
      public static const POPUP_CONFIRM:int = 3;
      
      public static const POPUP_CONECTION:int = 4;
      
      public static const POPUP_GAME_PLAY_CONECTION:int = 5;
      
      public static const POPUP_OUT_OF_SYNC:int = 6;
      
      public static const POPUP_PAYMENT_FAIL:int = 7;
      
      public static const POPUP_FAKE_CREDITS:int = 8;
      
      public function ShowPopup()
      {
         super();
      }
      
      private static function onAccept(param1:Event) : void
      {
         mPopup.removeEventListener(Popup.EVENT_ACCEPT,onAccept);
         mPopup.removeEventListener(Popup.EVENT_CLOSE,onClose);
         if(mPopup is PopupConfirmDestroy)
         {
            mPopup.destroy();
            mPopup = null;
         }
         if(mActionOk != null)
         {
            if(mParamsOk != null)
            {
               mActionOk(mParamsOk);
            }
            else
            {
               mActionOk();
            }
         }
      }
      
      public static function setActionCancel(param1:Function, param2:Object) : void
      {
         mActionCancel = param1;
         mParamsCancel = param2;
      }
      
      private static function onClose(param1:Event) : void
      {
         mPopup.removeEventListener(Popup.EVENT_ACCEPT,onAccept);
         mPopup.removeEventListener(Popup.EVENT_CLOSE,onClose);
         if(mPopup is PopupConfirmDestroy)
         {
            mPopup.destroy();
            mPopup = null;
         }
         if(mActionCancel != null)
         {
            if(mParamsCancel != null)
            {
               mActionCancel(mParamsCancel);
            }
            else
            {
               mActionCancel();
            }
         }
      }
      
      public static function close() : void
      {
         mPopup.onClose(null);
      }
      
      public static function setActionOk(param1:Function, param2:Object) : void
      {
         mActionOk = param1;
         mParamsOk = param2;
      }
      
      public static function show(param1:int, param2:String) : void
      {
         if(param1 == POPUP_MSG)
         {
            mPopup = DollarsGame.smInstance.mPopupMsg;
            PopupMessage(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_MSG_SMALL)
         {
            mPopup = DollarsGame.smInstance.mPopupMsgSmall;
            PopupMessageSmall(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_CONECTION)
         {
            mPopup = DollarsGame.smInstance.mPopupConection;
            PopupConnection(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_GAME_PLAY_CONECTION)
         {
            mPopup = DollarsGame.smInstance.mPopupGamePlayConection;
            PopupConnection(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_OUT_OF_SYNC)
         {
            mPopup = DollarsGame.smInstance.mPopupOutOfSync;
            PopupOutOfSync(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_PAYMENT_FAIL)
         {
            if(DollarsGame.smInstance.mPopupPaymentFail == null)
            {
               DollarsGame.smInstance.mPopupPaymentFail = new PopupPaymentFail();
            }
            mPopup = DollarsGame.smInstance.mPopupPaymentFail;
            PopupPaymentFail(mPopup).showPopupParams(param2);
         }
         else if(param1 == POPUP_FAKE_CREDITS)
         {
            mPopup = DollarsGame.smInstance.mPopupMsg;
            PopupMessage(mPopup).showPopupParams(param2,PopupMessage.NO_ICON);
         }
         else
         {
            mPopup = new PopupConfirmDestroy();
            PopupConfirmDestroy(mPopup).showPopUp(Dollars.getCurrentCursor().mCurrentCursorID,param2);
         }
         mPopup.addEventListener(Popup.EVENT_ACCEPT,onAccept);
         mPopup.addEventListener(Popup.EVENT_CLOSE,onClose);
      }
   }
}

