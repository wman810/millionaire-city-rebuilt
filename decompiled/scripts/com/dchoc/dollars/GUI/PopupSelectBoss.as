package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Back;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupSelectBoss extends Popup
   {
      
      private var mAnim:MovieClip;
      
      private var mBoss1:DynamicButton;
      
      private var mBoss2:DynamicButton;
      
      private var mParent:DisplayObjectContainer;
      
      public function PopupSelectBoss(param1:DisplayObjectContainer)
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_select_advisor"))();
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_TUTORIAL_SELECT_ADVISOR);
         this.mBoss1 = new DynamicButton(mBox.getChildByName("select_boss_01") as MovieClip);
         this.mBoss2 = new DynamicButton(mBox.getChildByName("select_boss_02") as MovieClip);
         this.mParent = param1;
         super(false);
      }
      
      private function onBossClick1(param1:MouseEvent) : void
      {
         this.mAnim = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_select_advisor_boss_01"))();
         DollarsGame.getProfile().bossGenre = Profile.BOSS_MALE;
         this.close();
      }
      
      override protected function close() : void
      {
         this.mAnim.x = Dollars.smStage.stageWidth / 2;
         this.mAnim.y = Dollars.smStage.stageHeight / 2;
         this.mAnim.addEventListener(Event.ENTER_FRAME,this.checkAnim);
         this.mBoss1.end();
         this.mBoss1.removeEventListener(MouseEvent.CLICK,this.onBossClick1);
         this.mBoss2.end();
         this.mBoss2.removeEventListener(MouseEvent.CLICK,this.onBossClick2);
         this.mParent.removeChild(mBox);
         this.mParent.addChild(this.mAnim);
      }
      
      override public function showPopup() : void
      {
         this.mBoss1.start();
         this.mBoss1.addEventListener(MouseEvent.CLICK,this.onBossClick1);
         this.mBoss2.start();
         this.mBoss2.addEventListener(MouseEvent.CLICK,this.onBossClick2);
         this.mParent.addChild(mBox);
         this.startShow();
      }
      
      private function onBossClick2(param1:MouseEvent) : void
      {
         DollarsGame.getProfile().bossGenre = Profile.BOSS_FEMALE;
         this.mAnim = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_select_advisor_boss_02"))();
         this.close();
      }
      
      private function checkAnim(param1:Event) : void
      {
         var _loc3_:TextField = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.mAnim.numChildren)
         {
            if(this.mAnim.getChildAt(_loc2_) is TextField)
            {
               _loc3_ = this.mAnim.getChildAt(_loc2_) as TextField;
               _loc3_.text = TextManager.getText(TextIDs.TID_TUTORIAL_SELECT_ADVISOR);
               break;
            }
            _loc2_++;
         }
         if(this.mAnim.currentFrame == this.mAnim.totalFrames)
         {
            this.mAnim.stop();
            this.mAnim.removeEventListener(Event.ENTER_FRAME,this.checkAnim);
            this.mParent.removeChild(this.mAnim);
            dispatchEvent(new Event(EVENT_CLOSE));
         }
      }
      
      override public function destroy() : void
      {
         this.mBoss1.destroy();
         this.mBoss1 = null;
         this.mBoss2.destroy();
         this.mBoss2 = null;
         this.mAnim = null;
         mBox = null;
      }
      
      override protected function startShow(param1:Boolean = true) : void
      {
         mBox.scaleX = Popup.TWEEN_MIN_SCALE;
         mBox.scaleY = Popup.TWEEN_MIN_SCALE;
         mBox.alpha = Popup.TWEEN_MIN_ALPHA;
         mTween = new GTween(mBox,Popup.TWEEN_LENGHT_IN,{
            "scaleX":1,
            "scaleY":1,
            "x":mEndPosition.x,
            "y":mEndPosition.y,
            "alpha":1
         },{"ease":Back.easeInOut});
         changeCursor();
      }
   }
}

