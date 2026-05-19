package com.dchoc.dollars.flow
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupSelectBoss;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.FSMState;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class RonaldsCity extends FSMState
   {
      
      public static const SKU:String = "IntroSplash";
      
      private var mPopupSelectBoss:PopupSelectBoss;
      
      private var mSplashMc:MovieClip;
      
      private var mIntroFinished:Boolean;
      
      private var mTimerID:int;
      
      private const TIMER_INIT_INTRO:int = 1000;
      
      public function RonaldsCity(param1:StateMachine)
      {
         super(param1,true,true);
         this.load();
      }
      
      override public function destroy() : void
      {
         this.exit();
         Dollars.smStage.removeEventListener(Event.RESIZE,this.onResize);
         this.mSplashMc.dispose();
         this.mSplashMc = null;
         this.mPopupSelectBoss.destroy();
         this.mPopupSelectBoss = null;
      }
      
      private function checkAnimEnd(param1:Event) : void
      {
         if(this.mSplashMc.currentFrame == this.mSplashMc.totalFrames)
         {
            this.mSplashMc.stop();
            this.mSplashMc.removeEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
            this.mPopupSelectBoss.showPopup();
            MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_ADVISOR_POPUP);
            this.mPopupSelectBoss.addEventListener(Popup.EVENT_CLOSE,this.closeSelectBoss);
         }
      }
      
      private function onClick(param1:MouseEvent = null) : void
      {
         var _loc2_:FSMState = null;
         if(this.mIntroFinished)
         {
            _loc2_ = DollarsGame.smInstance;
            getStateMachine().setNextState(_loc2_);
         }
      }
      
      private function load() : void
      {
         this.mSplashMc = new (DCResourceManager.getInstance().getSWFClass(SKU,"Splash"))();
         this.mPopupSelectBoss = new PopupSelectBoss(mPopupClip);
         Dollars.smStage.addEventListener(Event.RESIZE,this.onResize);
      }
      
      private function onResize(param1:Event) : void
      {
         if(this.mSplashMc != null)
         {
            this.mSplashMc.x = Dollars.smStage.stageWidth / 2;
            this.mSplashMc.y = Dollars.smStage.stageHeight / 2;
         }
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter(param1);
         mGameClip.addChild(this.mSplashMc);
         this.mSplashMc.addEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         this.mSplashMc.x = Dollars.smStage.stageWidth / 2;
         this.mSplashMc.y = Dollars.smStage.stageHeight / 2;
      }
      
      private function closeSelectBoss(param1:Event) : void
      {
         this.mPopupSelectBoss.removeEventListener(Popup.EVENT_CLOSE,this.closeSelectBoss);
         this.mIntroFinished = true;
         mGameClip.mouseEnabled = true;
         var _loc2_:Object = new Object();
         _loc2_.p1 = String(1);
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_SELECT_ADVISOR,_loc2_);
         this.onClick();
      }
      
      override public function exit() : void
      {
         super.exit();
         Dollars.smStage.removeEventListener(Event.RESIZE,this.onResize);
         if(this.mSplashMc != null)
         {
            mGameClip.removeChild(this.mSplashMc);
            this.mSplashMc = null;
         }
         this.mPopupSelectBoss.destroy();
         this.mPopupSelectBoss = null;
         DollarsGame.smInstance.startTutorial();
      }
   }
}

