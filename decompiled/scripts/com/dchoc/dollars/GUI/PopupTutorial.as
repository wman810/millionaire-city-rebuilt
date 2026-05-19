package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.AssetManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Back;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class PopupTutorial extends Popup
   {
      
      private var mSteps:TextField;
      
      protected var mShareSuccessButton:DynamicButton;
      
      private var mNextButtonAnim:MovieClip;
      
      private var mTitleBox:TextField;
      
      private var timerID:int;
      
      private var mParent:DisplayObjectContainer;
      
      public function PopupTutorial(param1:DisplayObjectContainer)
      {
         super();
         mDrawBackground = false;
         this.mParent = param1;
         this.createBox();
      }
      
      override protected function onResize(param1:Event) : void
      {
         if(mBox != null)
         {
            if(mEndPosition == null)
            {
               mEndPosition = new Point(mBox.x,mBox.y);
            }
            else
            {
               mEndPosition.x = mBox.x;
               mEndPosition.y = mBox.y;
            }
         }
      }
      
      override protected function startShow(param1:Boolean = true) : void
      {
         mOpen = true;
         mBox.scaleX = Popup.TWEEN_MIN_SCALE;
         mBox.scaleY = Popup.TWEEN_MIN_SCALE;
         mBox.alpha = Popup.TWEEN_MIN_ALPHA;
         DollarsGame.smInstance.mPopupClip.addChild(mBox);
         mTween = new GTween(mBox,Popup.TWEEN_LENGHT_IN,{
            "scaleX":1,
            "scaleY":1,
            "x":mEndPosition.x,
            "y":mEndPosition.y,
            "alpha":1
         },{"ease":Back.easeInOut});
         changeCursor();
      }
      
      public function showPopUp(param1:*, param2:*, param3:int) : void
      {
         super.show();
         if(mBox != null)
         {
            this.mParent.addChild(mBox);
            mOkButton.start();
            mOkButton.addEventListener(MouseEvent.CLICK,onClose);
            if(this.mShareSuccessButton != null)
            {
               this.mShareSuccessButton.start();
               this.mShareSuccessButton.addEventListener(MouseEvent.CLICK,this.onShareSuccess);
            }
            if(param2 is int)
            {
               mTextBox.text = TextManager.getText(param2 as int);
            }
            else
            {
               mTextBox.text = param2 as String;
            }
            if(param1 is int)
            {
               this.mTitleBox.text = TextManager.getText(param1 as int);
            }
            else
            {
               this.mTitleBox.text = param1 as String;
            }
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
            this.mSteps.visible = true;
            if(param3 >= Tutorial.TUTORIAL_STEP_COUNT || param3 == 0)
            {
               this.mSteps.visible = false;
            }
            this.mSteps.text = TextManager.replaceParameters(TextIDs.TID_TUTORIAL_STEP,new Array("" + param3,"" + 8));
            this.startShow(false);
         }
      }
      
      private function nextButtonUnattach() : void
      {
         this.mNextButtonAnim.removeEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         if(mOkButton.getButtonMc().contains(this.mNextButtonAnim))
         {
            mOkButton.getButtonMc().removeChild(this.mNextButtonAnim);
         }
      }
      
      public function hideButton() : void
      {
         mOkButton.visible = false;
         if(this.mShareSuccessButton != null)
         {
            this.mShareSuccessButton.visible = false;
         }
      }
      
      public function changeButtonText(param1:int) : void
      {
         mOkButton.setLabel(TextManager.getText(param1));
      }
      
      public function enable() : void
      {
         mOkButton.enable();
         if(this.mShareSuccessButton != null)
         {
            this.mShareSuccessButton.enable();
         }
      }
      
      private function checkAnimEnd(param1:Event) : void
      {
         if(this.mNextButtonAnim.currentFrame == this.mNextButtonAnim.totalFrames)
         {
            this.nextButtonUnattach();
         }
      }
      
      private function onShareSuccess(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
            "postId":UserDataFacade.POST_END_TUTORIAL,
            "product":MetricConstants.EVENT_FACEBOOK_FEED_LEVEL_UP
         });
         onClose(param1);
      }
      
      public function playAnim() : void
      {
         this.mNextButtonAnim.gotoAndPlay(1);
         this.mNextButtonAnim.addEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         mOkButton.getButtonMc().addChild(this.mNextButtonAnim);
         this.mNextButtonAnim.y = -mOkButton.getButtonMc().y + mBox.height / 3;
      }
      
      public function disable() : void
      {
         mOkButton.disable();
         if(this.mShareSuccessButton != null)
         {
            this.mShareSuccessButton.disable();
         }
      }
      
      private function createBox(param1:int = -1) : void
      {
         if(mBox != null)
         {
            this.destroy();
         }
         var _loc2_:String = "popup_tutorial";
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            _loc2_ += "_01";
         }
         else
         {
            _loc2_ += "_02";
         }
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,_loc2_))();
         mBox.x = mBox.width / 2 - 30;
         mBox.y = mBox.height / 2;
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_NEXT));
         mTextBox = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(mTextBox);
         this.mSteps = mBox.getChildByName("Step") as TextField;
         TextManager.reformatTextField(this.mSteps);
         TextManager.setTextScaled(this.mSteps);
         this.mTitleBox = mBox.getChildByName("Tutorial") as TextField;
         TextManager.reformatTextField(this.mTitleBox);
         this.mNextButtonAnim = new AssetManager.NextButtonAnim();
         this.mNextButtonAnim.stop();
         mBox.y += 50;
         mStartPosition = new Point(mBox.x,mBox.y);
         mEndPosition = new Point(mBox.x,mBox.y);
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         if(this.mShareSuccessButton != null)
         {
            this.mShareSuccessButton.end();
            this.mShareSuccessButton.removeEventListener(MouseEvent.CLICK,this.onShareSuccess);
         }
         if(this.mParent.contains(mBox))
         {
            this.mParent.removeChild(mBox);
         }
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         this.timerID = setTimeout(this.popupClosed,200);
      }
      
      override public function destroy() : void
      {
         if(this.mShareSuccessButton != null)
         {
            this.mShareSuccessButton.destroy();
            this.mShareSuccessButton = null;
         }
         mBox.removeChild(mTextBox);
         mBox.removeChild(this.mSteps);
         mBox.removeChild(this.mTitleBox);
         this.nextButtonUnattach();
         this.mNextButtonAnim = null;
         mTextBox = null;
         this.mSteps = null;
         this.mTitleBox = null;
         mOkButton.destroy();
         mOkButton = null;
         mBox = null;
      }
      
      private function popupClosed() : void
      {
         clearTimeout(this.timerID);
         dispatchEvent(new Event(EVENT_ACCEPT));
      }
   }
}

