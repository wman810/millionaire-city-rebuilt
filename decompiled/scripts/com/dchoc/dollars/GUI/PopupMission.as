package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class PopupMission extends Popup
   {
      
      protected var mMission:MissionObject;
      
      public function PopupMission(param1:MissionObject, param2:Boolean = true)
      {
         var _loc4_:Sprite = null;
         var _loc5_:Sprite = null;
         var _loc3_:String = "popup_mission_" + this.doGetBoxName() + "_0" + (DollarsGame.getProfile().bossGenre + 1);
         if(param1.missionDefinition.imageIsRequired)
         {
            _loc3_ += "_image_01";
         }
         mBox = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,_loc3_))();
         if(param1.missionDefinition.imageIsRequired)
         {
            _loc4_ = mBox.getChildByName("image_01") as Sprite;
            if(_loc4_ != null)
            {
               _loc5_ = param1.missionDefinition.getImageDO();
               if(_loc5_ != null)
               {
                  _loc4_.addChild(_loc5_);
               }
            }
         }
         mCancelButton = new DynamicButton(mBox.getChildByName("Done") as MovieClip);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Reward")));
         TextField(mBox.getChildByName("Reward")).text = TextManager.getText(TextIDs.TID_GEN_REWARD) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS);
         this.mMission = param1;
         super(param2);
      }
      
      public function showPopupParams(param1:String, param2:String) : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:Sprite = null;
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         var _loc3_:Reward = this.mMission.getReward();
         _loc4_ = mBox.getChildByName("container") as Sprite;
         _loc5_ = _loc3_.draw();
         var _loc6_:Number = _loc4_.width / _loc5_.width;
         var _loc7_:Number = _loc4_.height / _loc5_.height;
         var _loc8_:Number = _loc6_ < _loc7_ ? _loc6_ : _loc7_;
         if(_loc8_ > 1)
         {
            _loc8_ = 1;
         }
         _loc5_.scaleX = _loc8_;
         _loc5_.scaleY = _loc8_;
         mBox.addChild(_loc5_);
         var _loc9_:Rectangle = _loc5_.getBounds(mBox);
         var _loc10_:Rectangle = _loc4_.getBounds(mBox);
         _loc5_.x += _loc10_.x - _loc9_.x + (_loc4_.width - _loc5_.width) / 2;
         _loc5_.y += _loc10_.y - _loc9_.y + (_loc4_.height - _loc5_.height) / 2;
         _loc4_.visible = false;
         var _loc11_:TextField = mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(_loc11_);
         _loc11_.text = param1;
         TextManager.setTextScaled(_loc11_,false);
         var _loc12_:TextField = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(_loc12_);
         _loc12_.text = param2;
         TextManager.setTextScaled(_loc12_,false);
         startShow();
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         super.endButtons();
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         this.destroy();
      }
      
      override public function destroy() : void
      {
         this.mMission.destroy();
         this.mMission = null;
         mBox = null;
         mCancelButton = null;
      }
      
      protected function doGetBoxName() : String
      {
         return "background";
      }
   }
}

