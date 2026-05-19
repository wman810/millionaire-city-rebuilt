package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.hud.HudOwner;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupName extends PopupMissionEditText
   {
      
      private var mNameField:TextField;
      
      public function PopupName(param1:MissionObject)
      {
         super(param1);
         this.mNameField = mBox.getChildByName("NameUser") as TextField;
         TextManager.reformatTextField(this.mNameField);
         this.mNameField.text = TextManager.getText(TextIDs.TID_CLICK_HERE);
         this.mNameField.addEventListener(Event.CHANGE,this.checkName);
         this.mNameField.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
         this.mNameField.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
         this.mNameField.addEventListener(MouseEvent.CLICK,this.onNameClick);
         this.mNameField.restrict = "A-Z a-z 0-9 \'À-ü";
      }
      
      private function checkName(param1:Event) : void
      {
         if(this.mNameField.text.length < this.mNameField.maxChars)
         {
            if(DollarsGame.getProfile().cityname != this.mNameField.text && this.mNameField.text != "" && TextManager.trim(this.mNameField.text) != "")
            {
               mOkButton.enable();
            }
            else
            {
               mOkButton.disable();
            }
         }
      }
      
      override public function showPopupParams(param1:String, param2:String) : void
      {
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.saveName);
         mOkButton.disable();
         super.showPopupParams(param1,param2);
      }
      
      override protected function endButtons() : void
      {
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.saveName);
         super.endButtons();
      }
      
      private function saveName(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(DollarsGame.getProfile().cityname != this.mNameField.text)
         {
            _loc2_ = TextManager.trim(this.mNameField.text);
            DollarsGame.getProfile().cityname = _loc2_;
            DollarsGame.getProfileUniverse().cityname = _loc2_;
            missionChangeState(MissionObject.STATE_REACHED);
            this.mNameField.removeEventListener(Event.CHANGE,this.checkName);
            onAccept(null);
            HudOwner(DollarsGame.getCurrentWorld().role.hud).setCityName(_loc2_);
            DollarsGame.smInstance.mPlane.removePlane();
            DollarsGame.smInstance.mPlane.setPlane(DollarsGame.getProfileUniverse().planeSku);
            DollarsGame.smInstance.mPlane.start(_loc2_);
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mNameField = null;
      }
      
      override protected function doGetBoxName() : String
      {
         return "Name";
      }
      
      private function onNameClick(param1:MouseEvent) : void
      {
         this.mNameField.removeEventListener(MouseEvent.CLICK,this.onNameClick);
         this.mNameField.text = "";
      }
   }
}

