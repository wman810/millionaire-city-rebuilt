package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class MissionItem extends Sprite
   {
      
      public static const EVENT_REWARD:String = "EventReward";
      
      public static const EVENT_SHOW_DESCRIPTION:String = "EventShowDescription";
      
      private var mCurrentFrame:int;
      
      private var mTextColor:uint;
      
      private var mRewardButton:DynamicButton;
      
      private const OFFSET:Number = 50;
      
      private var mItem:MovieClip;
      
      private var mCount:int;
      
      private var mReadMoreButton:DynamicButton;
      
      private var mTitle:TextField;
      
      private var mAlert:MovieClip;
      
      private const SCALE:Number = 0.05;
      
      private var mMissionArrow:MovieClip;
      
      private var mProgress:MovieClip;
      
      private var mBack:MovieClip;
      
      private var mMissionObject:MissionObject;
      
      public function MissionItem(param1:MissionObject, param2:int)
      {
         var _loc3_:Bitmap = null;
         var _loc4_:Sprite = null;
         super();
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            this.mItem = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"Mission_menu_ok_01"))();
         }
         else
         {
            this.mItem = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"Mission_menu_ok_02"))();
         }
         _loc3_ = new Bitmap(DCResourceManager.getInstance().get(param1.missionDefinition.eventType));
         _loc4_ = this.mItem["item"]["icon"];
         this.mItem["item"].addChild(_loc3_);
         _loc3_.scaleX = 0.8;
         _loc3_.scaleY = 0.8;
         _loc3_.x = _loc4_.x - _loc3_.width / 2;
         _loc3_.y = _loc4_.y - _loc3_.height / 2 - 5;
         _loc3_.smoothing = true;
         _loc4_.visible = false;
         var _loc5_:MovieClip = this.mItem.getChildByName("alert") as MovieClip;
         _loc5_.stop();
         _loc5_.visible = false;
         var _loc6_:MovieClip = this.mItem.getChildByName("alert_ok") as MovieClip;
         _loc6_.stop();
         _loc6_.visible = false;
         var _loc7_:int = param1.getAlertID();
         if(_loc7_ != -1)
         {
            if(_loc7_ == ToolsBar.BOSS_ALERT_NEW_MISSION)
            {
               this.mAlert = _loc5_;
            }
            else
            {
               this.mAlert = _loc6_;
            }
            this.mAlert.visible = true;
            this.mAlert.play();
         }
         this.mBack = this.mItem.getChildByName("item") as MovieClip;
         this.mBack.stop();
         this.mMissionObject = param1;
         this.mRewardButton = new DynamicButton(this.mItem.getChildByName("GetReward") as MovieClip);
         this.mRewardButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_GET_REWARD));
         this.mReadMoreButton = new DynamicButton(this.mItem.getChildByName("ReadMore") as MovieClip);
         this.mReadMoreButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_READ_MORE));
         this.mProgress = this.mItem.getChildByName("BoxPercent") as MovieClip;
         this.mCount = param2;
         addChild(this.mItem);
         this.setUpInfo(this.mCount);
         if(this.mMissionObject.missionDefinition.getEventSku() == "nameCity" && DollarsGame.getProfile().firstMission)
         {
            this.mMissionArrow = new AssetManager.SuperupgradeArrow();
            this.mMissionArrow.rotationZ += 180;
            this.mMissionArrow.scaleX = 0.7;
            this.mMissionArrow.scaleY = 0.7;
            this.mMissionArrow.x = this.mReadMoreButton.getButtonMc().x - 40;
            this.mMissionArrow.y = this.mReadMoreButton.getButtonMc().y - 5;
            this.mItem.addChild(this.mMissionArrow);
         }
         if(this.mMissionObject.missionDefinition.getEventSku() == "nameCity" && this.mMissionObject.state == MissionObject.STATE_REACHED)
         {
            this.mMissionArrow = new AssetManager.SuperupgradeArrow();
            this.mMissionArrow.rotationZ += 180;
            this.mMissionArrow.scaleX = 0.7;
            this.mMissionArrow.scaleY = 0.7;
            this.mMissionArrow.x = this.mReadMoreButton.getButtonMc().x - 40;
            this.mMissionArrow.y = this.mReadMoreButton.getButtonMc().y - 5;
            this.mItem.addChild(this.mMissionArrow);
         }
      }
      
      public function get missionObject() : MissionObject
      {
         return this.mMissionObject;
      }
      
      public function get state() : int
      {
         return this.mMissionObject.state;
      }
      
      private function onRead(param1:MouseEvent) : void
      {
         if(this.mMissionArrow != null)
         {
            this.mItem.removeChild(this.mMissionArrow);
            this.mMissionArrow = null;
            DollarsGame.getCurrentRole().toolsBar.removeMissionArrow();
         }
         dispatchEvent(new Event(EVENT_SHOW_DESCRIPTION));
      }
      
      public function destroy() : void
      {
         this.mRewardButton.destroy();
         this.mRewardButton = null;
         this.mItem.removeChild(this.mProgress);
         this.mProgress = null;
         if(this.mAlert != null)
         {
            this.mAlert = null;
            this.mMissionObject.setAlertID(-1);
         }
         this.mMissionObject = null;
         this.mItem = null;
      }
      
      public function setUpInfo(param1:int) : void
      {
         var _loc4_:TextField = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc2_:String = this.mMissionObject.missionDefinition.getTextTitle();
         var _loc3_:Sprite = this.mItem.getChildByName("locked") as Sprite;
         this.mProgress.visible = false;
         this.mRewardButton.start();
         this.mRewardButton.getButtonMc().visible = false;
         this.mReadMoreButton.start();
         this.mReadMoreButton.getButtonMc().visible = false;
         if(this.mMissionObject.state == MissionObject.STATE_UNLOCKED)
         {
            this.mCurrentFrame = 2;
            this.mBack.gotoAndStop(2);
            this.mTextColor = 12866;
            this.mProgress.visible = this.mMissionObject.missionDefinition.showProgress();
            _loc3_.visible = false;
            if(this.mProgress.visible)
            {
               _loc4_ = this.mProgress.getChildByName("Numbers") as TextField;
               _loc4_.text = this.mMissionObject.getProgressAsString();
            }
            if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
            {
               _loc2_ += " ." + param1;
            }
            else
            {
               _loc2_ = param1 + ". " + _loc2_;
            }
            this.mReadMoreButton.getButtonMc().visible = true;
            this.mReadMoreButton.addEventListener(MouseEvent.CLICK,this.onRead);
         }
         else if(this.mMissionObject.state == MissionObject.STATE_REACHED)
         {
            this.mCurrentFrame = 3;
            this.mBack.gotoAndStop(3);
            this.mRewardButton.addEventListener(MouseEvent.CLICK,this.applyReward);
            this.mTextColor = 13056;
            this.mRewardButton.visible = true;
            _loc2_ = _loc2_;
            _loc3_.visible = false;
         }
         else if(this.mMissionObject.state == MissionObject.STATE_LOCKED)
         {
            this.mCurrentFrame = 1;
            this.mBack.gotoAndStop(1);
            this.mTextColor = 12866;
            this.mProgress.visible = false;
            this.mRewardButton.visible = false;
            if(this.missionObject.missionDefinition.hasUnlockSku())
            {
               _loc6_ = MissionObjectManager.getInstance().getMissionsGivenCount() + this.missionObject.getUnlockMissionID() + 1;
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_DEFINITION_MISSION,new Array("" + _loc6_));
            }
            else
            {
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_DEFINITION_LEVEL,new Array("" + this.missionObject.missionDefinition.unlockLevel));
            }
            TextManager.reformatTextField(TextField(_loc3_.getChildByName("Locked")));
            TextField(_loc3_.getChildByName("Locked")).text = _loc5_;
         }
         this.mTitle = this.mItem.getChildByName("TextInfo") as TextField;
         if(this.mTitle != null)
         {
            TextManager.reformatTextField(this.mTitle);
            this.mTitle.text = _loc2_;
            trace("text: " + this.mTitle.text);
            TextManager.setTextScaled(this.mTitle,false);
            this.mTitle.textColor = this.mTextColor;
            this.mTitle.useRichTextClipboard;
         }
      }
      
      public function setAlertVisible(param1:Boolean) : void
      {
         if(this.mAlert != null)
         {
            this.mAlert.visible = param1;
            if(param1)
            {
               this.mAlert.play();
            }
            else
            {
               this.mAlert.stop();
            }
         }
      }
      
      private function applyReward(param1:MouseEvent) : void
      {
         this.mRewardButton.removeEventListener(MouseEvent.CLICK,this.applyReward);
         dispatchEvent(new Event(EVENT_REWARD));
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().playSound(ModelConfig.SOUND_INCOME,1,0,0);
         }
         MyMetrics.sendMetric(MetricConstants.EVENT_MISSION_DONE,MetricConstants.LABEL_MISSIONS_MISSION_DONE + " " + this.mMissionObject.missionDefinition.missionName);
      }
   }
}

