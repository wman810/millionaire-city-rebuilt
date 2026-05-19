package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupServicePresentation extends Popup
   {
      
      private static const TID_START_ID:int = TextIDs.TID_MOVE_HELP_TITLE;
      
      private static const TID_TITLE_OFF:int = 0;
      
      private static const TID_TEXT_1_OFF:int = 1;
      
      private static const TID_TEXT_2_OFF:int = 2;
      
      private static const TID_COUNT:int = 3;
      
      private var mSku:String;
      
      public function PopupServicePresentation()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wellcome_crane_operator"))();
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
         DollarsGame.getProfile().servicesSetShowPresentation(this.mSku);
         var _loc1_:int = DollarsGame.getCurrentWorld().map.currentTool.getDefaultCursorID();
         Dollars.getCurrentCursor().changeCursor(_loc1_);
      }
      
      public function showPopupParams(param1:String) : void
      {
         var _loc3_:int = 0;
         super.show();
         this.mSku = param1;
         var _loc2_:int = DollarsGame.getProfile().servicesGetIdFromSku(param1);
         if(Config.DEBUG_ASSERTS && _loc2_ == -1)
         {
            Debug.trace("############# ERROR in PopupServicePresentation.showPopup(): Index not found for sku = " + param1);
         }
         else
         {
            _loc3_ = TID_START_ID + _loc2_ * TID_COUNT;
            TextManager.reformatTextField(TextField(mBox.getChildByName("title")));
            TextField(mBox.getChildByName("title")).text = TextManager.getText(_loc3_ + TID_TITLE_OFF);
            TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_01")));
            TextField(mBox.getChildByName("TextInfo_01")).text = TextManager.getText(_loc3_ + TID_TEXT_1_OFF);
            TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_02")));
            TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.getText(_loc3_ + TID_TEXT_2_OFF);
         }
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow();
      }
   }
}

