package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupBecameFan extends Popup
   {
      
      public function PopupBecameFan()
      {
         var _loc6_:Sprite = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"popup_fan"))();
         mOkButton = new DynamicButton(mBox.getChildByName("fan") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_FAN));
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         var _loc1_:TextField = TextField(mBox.getChildByName("Caption"));
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = TextManager.getText(TextIDs.TID_FAN_TITLE);
         TextManager.setTextScaled(_loc1_);
         var _loc2_:TextField = TextField(mBox.getChildByName("TextInfo"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs.TID_FAN_TEXT_1);
         TextManager.setTextScaled(_loc2_);
         var _loc3_:Sprite = mBox.getChildByName("gift") as Sprite;
         var _loc4_:ItemDefinition = ItemDefinitionManager.getInstance().getItemDefinitionFan();
         var _loc5_:TextField = TextField(_loc3_.getChildByName("mTitle"));
         TextManager.reformatTextField(_loc5_);
         _loc5_.text = TextManager.getText(TextIDs[_loc4_.textID]);
         TextManager.setTextScaled(_loc5_);
         if(DCResourceManager.getInstance().getSWFClass(_loc4_.sku,"icon_02") != null)
         {
            _loc6_ = new (DCResourceManager.getInstance().getSWFClass(_loc4_.sku,"icon_02"))();
            _loc3_.addChild(_loc6_);
            _loc6_.x = -_loc6_.width / 2 - 3;
            _loc6_.y = 7;
         }
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.becameFan);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function becameFan(param1:MouseEvent) : void
      {
         onClose(null);
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_BECAME_FAN);
      }
      
      override public function showPopup() : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.becameFan);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow();
      }
   }
}

