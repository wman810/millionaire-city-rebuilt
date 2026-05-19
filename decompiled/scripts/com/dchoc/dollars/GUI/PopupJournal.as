package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PopupJournal extends Popup
   {
      
      public static const TYPE_NEWS:int = 0;
      
      public static const TYPE_MAGAZINE:int = 1;
      
      private var mType:int;
      
      public function PopupJournal(param1:int)
      {
         this.mType = param1;
         if(this.mType == TYPE_NEWS)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(NewsPaper.SKU,"popup_journal"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(NewsPaper.MAGAZINE_SKU,"popup_journal"))();
         }
         mCancelButton = new DynamicButton(mBox.getChildByName("Done") as MovieClip);
         mCancelButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SKIP));
         mOkButton = new DynamicButton(mBox.getChildByName("ShareSuccess") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SHARE));
         super();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         this.onClose(null);
         if(this.mType == TYPE_NEWS)
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{"postId":UserDataFacade.POST_JOURNAL});
         }
         else
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{"postId":UserDataFacade.POST_ONE_MILLION});
         }
      }
      
      public function activateButtons() : void
      {
         mCancelButton.enable();
         mOkButton.enable();
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onShare);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         Dollars.getCurrentCursor().changeCursor(mPreviousCursorID);
      }
      
      override public function onClose(param1:MouseEvent = null) : void
      {
         dispatchEvent(new Event(EVENT_CLOSE));
         super.onClose(null);
      }
      
      override public function showPopup() : void
      {
         mPreviousCursorID = Dollars.getCurrentCursor().mCurrentCursorID;
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,this.onClose);
         mCancelButton.disable();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onShare);
         mOkButton.disable();
         startShow(false);
      }
   }
}

