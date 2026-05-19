package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupMissionEditText extends PopupMission
   {
      
      private var mMissionObject:MissionObject;
      
      public function PopupMissionEditText(param1:MissionObject)
      {
         super(param1);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         mOkButton = new DynamicButton(mBox.getChildByName("Done") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_DONE));
         TextManager.reformatTextField(TextField(mBox.getChildByName("Reward")));
         TextField(mBox.getChildByName("Reward")).text = TextManager.getText(TextIDs.TID_GEN_REWARD) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS);
         this.mMissionObject = param1;
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
      }
      
      override public function showPopupParams(param1:String, param2:String) : void
      {
         super.showPopupParams(param1,param2);
      }
      
      public function missionChangeState(param1:uint) : void
      {
         this.mMissionObject.changeState(param1);
      }
      
      override protected function close() : void
      {
         super.close();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mOkButton = null;
      }
      
      protected function onMouseOut(param1:MouseEvent) : void
      {
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
      }
   }
}

