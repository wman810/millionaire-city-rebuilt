package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupProgerss extends Popup
   {
      
      public function PopupProgerss()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wellcome_back"))();
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_PROGRESS_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function showPopupParams(param1:int, param2:int, param3:int, param4:int) : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_01")));
         TextField(mBox.getChildByName("TextInfo_01")).text = TextManager.replaceParameters(TextIDs.TID_PROGRESS_RANKING,new Array("" + param1));
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_02")));
         TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.replaceParameters(TextIDs.TID_PROGRESS_HELP,new Array("" + param2));
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_04")));
         TextField(mBox.getChildByName("TextInfo_04")).text = TextManager.replaceParameters(TextIDs.TID_PROGRESS_BUILDING,new Array("" + param3));
         startShow();
      }
   }
}

