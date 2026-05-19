package com.dchoc.dollars.GUI.hud
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.GTweenTimeline;
   import com.gskinner.motion.easing.Linear;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class OptionsPanel extends Sprite
   {
      
      private static var doingZoom:Boolean;
      
      private static const TWEEN_LENGTH:Number = 0.05;
      
      private static const ZOOM_STEP:Number = 0.05;
      
      private var mOptionsButton:DynamicButton;
      
      private var mMusicButton:DynamicButton;
      
      private var zoomDistances:Array;
      
      private var mSoundButton:DynamicButton;
      
      private var mOptionsPanel:Sprite;
      
      private var mIsFullScreenTracked:Boolean;
      
      private var mZoomOutButton:DynamicButton;
      
      private var mQualityButton:DynamicButton;
      
      private var mZoomInButton:DynamicButton;
      
      private var zoomIndex:int = 0;
      
      private var mOptionsVisible:Boolean;
      
      private var zoomsNormalScreen:Array = [1,0.75,0.5,0.4];
      
      private var mButtons:Array;
      
      private var zoomValue:int = 0;
      
      private var mFullScreenButton:DynamicButton;
      
      private var zoomsFullScreen:Array = [1,0.75,0.5,0.4];
      
      private var mPositions:Array;
      
      private var mTweenTimeLine:GTweenTimeline;
      
      public function OptionsPanel()
      {
         super();
         this.mOptionsPanel = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"options_panel"))();
         this.mOptionsVisible = false;
         this.mButtons = new Array();
         this.mOptionsButton = new DynamicButton(this.mOptionsPanel["options"]);
         this.mOptionsButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_OPTIONS_SHOW));
         this.mQualityButton = new DynamicButton(this.mOptionsPanel["quality"]);
         this.mQualityButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_QUALITY));
         this.mButtons.push(this.mQualityButton);
         this.mSoundButton = new DynamicButton(this.mOptionsPanel["volume"]);
         this.mSoundButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_SOUND_ON));
         this.mButtons.push(this.mSoundButton);
         this.mMusicButton = new DynamicButton(this.mOptionsPanel["music"]);
         this.mMusicButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MUSIC_ON));
         this.mButtons.push(this.mMusicButton);
         this.mFullScreenButton = new DynamicButton(this.mOptionsPanel["fullscreen"]);
         this.mFullScreenButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_FULLSCREEN));
         this.mButtons.push(this.mFullScreenButton);
         this.mZoomOutButton = new DynamicButton(this.mOptionsPanel["zoomout"]);
         this.mZoomOutButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_ZOOMOUT));
         this.mButtons.push(this.mZoomOutButton);
         this.mZoomInButton = new DynamicButton(this.mOptionsPanel["zoomin"]);
         this.mZoomInButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_ZOOMIN));
         this.mButtons.push(this.mZoomInButton);
         addChild(this.mOptionsPanel);
         this.mPositions = new Array();
         this.mPositions.push(new Point(this.mQualityButton.getButtonMc().x,this.mQualityButton.getButtonMc().y));
         this.mPositions.push(new Point(this.mSoundButton.getButtonMc().x,this.mSoundButton.getButtonMc().y));
         this.mPositions.push(new Point(this.mMusicButton.getButtonMc().x,this.mMusicButton.getButtonMc().y));
         this.mPositions.push(new Point(this.mFullScreenButton.getButtonMc().x,this.mFullScreenButton.getButtonMc().y));
         this.mPositions.push(new Point(this.mZoomOutButton.getButtonMc().x,this.mZoomOutButton.getButtonMc().y));
         this.mPositions.push(new Point(this.mZoomInButton.getButtonMc().x,this.mZoomInButton.getButtonMc().y));
         this.hideOptionsPanel();
      }
      
      public function destroy() : void
      {
         this.mOptionsButton.destroy();
         this.mOptionsButton = null;
         this.mMusicButton.destroy();
         this.mMusicButton = null;
         this.mSoundButton.destroy();
         this.mSoundButton = null;
         this.mQualityButton.destroy();
         this.mQualityButton = null;
         this.mZoomInButton.destroy();
         this.mZoomInButton = null;
         this.mZoomOutButton.destroy();
         this.mZoomOutButton = null;
         this.mFullScreenButton.destroy();
         this.mFullScreenButton = null;
         removeChild(this.mOptionsPanel);
         this.mOptionsPanel = null;
         this.mButtons.length = 0;
         this.mPositions.length = 0;
      }
      
      private function onOptionsClick(param1:MouseEvent) : void
      {
         this.mOptionsVisible = !this.mOptionsVisible;
         if(this.mOptionsVisible)
         {
            this.showOptionsPanel();
            this.mOptionsButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_OPTIONS_HIDE));
         }
         else
         {
            this.hideOptionsPanel();
            this.mOptionsButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_OPTIONS_SHOW));
         }
      }
      
      private function onFullScreenClick(param1:MouseEvent) : void
      {
         if(Tutorial.smTutorialEnd)
         {
            this.resetZoom();
            if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Dollars.smStage.displayState = StageDisplayState.NORMAL;
            }
            else
            {
               Dollars.smStage.displayState = StageDisplayState.FULL_SCREEN;
               if(!this.mIsFullScreenTracked)
               {
                  MyMetrics.sendMetric(MetricConstants.EVENT_FULLSCREEN,MetricConstants.LABEL_ACCEPTED);
                  this.mIsFullScreenTracked = true;
               }
            }
         }
      }
      
      public function onZoomIn(param1:MouseEvent) : void
      {
         this.zoomDistances = this.zoomsNormalScreen;
         if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            this.zoomDistances = this.zoomsFullScreen;
         }
         if(Tutorial.smTutorialEnd)
         {
            if(!doingZoom && DollarsGame.getCurrentWorld().map.scaleX < this.zoomDistances[0])
            {
               this.zoomValue = 0;
               DollarsGame.getCurrentWorld().map.notifyZoomBegin();
               Dollars.smStage.addEventListener(Event.ENTER_FRAME,this.zoomIn);
               doingZoom = true;
               this.zoomChange(false);
            }
         }
      }
      
      public function onZoomOut(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         this.zoomDistances = this.zoomsNormalScreen;
         if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            this.zoomDistances = this.zoomsFullScreen;
         }
         if(Tutorial.smTutorialEnd)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map.scaleX;
            if(!doingZoom && DollarsGame.getCurrentWorld().map.scaleX > this.zoomDistances[this.zoomDistances.length - 1])
            {
               this.zoomValue = 0;
               DollarsGame.getCurrentWorld().map.notifyZoomBegin();
               Dollars.smStage.addEventListener(Event.ENTER_FRAME,this.zoomOut);
               doingZoom = true;
               this.zoomChange(true);
            }
         }
      }
      
      private function zoomOut(param1:Event) : void
      {
         var _loc2_:Map = DollarsGame.getCurrentWorld().map;
         if(_loc2_.scaleX > this.zoomDistances[this.zoomIndex])
         {
            _loc2_.onZoom(-ZOOM_STEP);
         }
         else
         {
            Dollars.smStage.removeEventListener(Event.ENTER_FRAME,this.zoomOut);
            _loc2_.notifyZoomEnd();
            doingZoom = false;
         }
      }
      
      private function onMusicClick(param1:MouseEvent) : void
      {
         if(Config.USE_SOUNDS)
         {
            if(SoundManager.getInstance().isMusicOn())
            {
               SoundManager.getInstance().setMusicOn(false);
               this.mMusicButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MUSIC_OFF));
               this.mMusicButton.changeFrame(2);
            }
            else
            {
               SoundManager.getInstance().setMusicOn(true);
               this.mMusicButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MUSIC_ON));
               this.mMusicButton.changeFrame(1);
            }
         }
      }
      
      private function showOptionsPanel() : void
      {
         var _loc2_:GTween = null;
         var _loc3_:Number = NaN;
         this.buttonsVisibility(null);
         this.mTweenTimeLine = new GTweenTimeline(null,0,null);
         var _loc1_:int = 0;
         while(_loc1_ < this.mButtons.length)
         {
            _loc2_ = new GTween(this.mButtons[_loc1_].getButtonMc(),OptionsPanel.TWEEN_LENGTH,{
               "x":this.mPositions[_loc1_].x,
               "y":this.mPositions[_loc1_].y,
               "alpha":1
            },{"ease":Linear.easeNone});
            _loc3_ = _loc1_ * OptionsPanel.TWEEN_LENGTH;
            this.mTweenTimeLine.addTween(_loc3_,_loc2_);
            _loc1_++;
         }
         this.mTweenTimeLine.calculateDuration();
      }
      
      public function resize() : void
      {
         this.mOptionsPanel.x = (Dollars.smStage.stageWidth - this.mOptionsPanel.width) / 2;
         this.mOptionsPanel.y = Dollars.smStage.stageHeight;
      }
      
      public function resetZoom() : void
      {
         var _loc1_:Map = DollarsGame.getCurrentWorld().map;
         _loc1_.scaleX = 1;
         _loc1_.scaleY = 1;
         _loc1_.cameraStart();
         this.zoomIndex = 0;
      }
      
      private function onQualityClick(param1:MouseEvent) : void
      {
         if(Dollars.smStage.quality.toUpperCase() == StageQuality.LOW.toUpperCase())
         {
            Dollars.changeQuality(StageQuality.HIGH);
         }
         else
         {
            Dollars.changeQuality(StageQuality.LOW);
         }
         Dollars.updateGameConfig();
      }
      
      private function zoomIn(param1:Event) : void
      {
         var _loc2_:Map = DollarsGame.getCurrentWorld().map;
         if(_loc2_.scaleX < this.zoomDistances[this.zoomIndex])
         {
            _loc2_.onZoom(ZOOM_STEP);
         }
         else
         {
            Dollars.smStage.removeEventListener(Event.ENTER_FRAME,this.zoomIn);
            _loc2_.notifyZoomEnd();
            doingZoom = false;
         }
      }
      
      public function end() : void
      {
         this.mOptionsButton.end();
         this.mOptionsButton.removeEventListener(MouseEvent.CLICK,this.onOptionsClick);
         this.mMusicButton.end();
         this.mMusicButton.removeEventListener(MouseEvent.CLICK,this.onMusicClick);
         this.mSoundButton.end();
         this.mSoundButton.removeEventListener(MouseEvent.CLICK,this.onSoundClick);
         this.mQualityButton.end();
         this.mQualityButton.removeEventListener(MouseEvent.CLICK,this.onQualityClick);
         this.mZoomInButton.end();
         this.mZoomInButton.removeEventListener(MouseEvent.CLICK,this.onZoomIn);
         this.mZoomOutButton.end();
         this.mZoomOutButton.removeEventListener(MouseEvent.CLICK,this.onZoomOut);
         this.mFullScreenButton.end();
         this.mFullScreenButton.removeEventListener(MouseEvent.CLICK,this.onFullScreenClick);
      }
      
      public function start() : void
      {
         this.mOptionsButton.addEventListener(MouseEvent.CLICK,this.onOptionsClick);
         this.mOptionsButton.start();
         this.mMusicButton.start();
         this.mMusicButton.addEventListener(MouseEvent.CLICK,this.onMusicClick);
         this.mSoundButton.start();
         this.mSoundButton.addEventListener(MouseEvent.CLICK,this.onSoundClick);
         this.mQualityButton.start();
         this.mQualityButton.addEventListener(MouseEvent.CLICK,this.onQualityClick);
         this.mZoomInButton.start();
         this.mZoomInButton.addEventListener(MouseEvent.CLICK,this.onZoomIn);
         this.mZoomOutButton.start();
         this.mZoomOutButton.addEventListener(MouseEvent.CLICK,this.onZoomOut);
         this.mFullScreenButton.start();
         this.mFullScreenButton.addEventListener(MouseEvent.CLICK,this.onFullScreenClick);
      }
      
      private function zoomChange(param1:Boolean) : int
      {
         if(param1)
         {
            ++this.zoomIndex;
            if(this.zoomIndex > this.zoomDistances.length - 1)
            {
               this.zoomIndex = this.zoomDistances.length - 1;
            }
         }
         else
         {
            --this.zoomIndex;
            if(this.zoomIndex < 0)
            {
               this.zoomIndex = 0;
            }
         }
         return this.zoomIndex;
      }
      
      public function load() : void
      {
         if(Config.USE_SOUNDS)
         {
            if(!SoundManager.getInstance().isMusicOn())
            {
               this.mMusicButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MUSIC_OFF));
               this.mMusicButton.changeFrame(2);
            }
            if(!SoundManager.getInstance().isSfxOn())
            {
               this.mSoundButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_SOUND_OFF));
               this.mSoundButton.changeFrame(2);
            }
         }
      }
      
      private function hideOptionsPanel() : void
      {
         var _loc4_:GTween = null;
         var _loc5_:Number = NaN;
         this.mTweenTimeLine = new GTweenTimeline(null,0,null);
         var _loc1_:Number = this.mOptionsButton.getButtonMc().x;
         var _loc2_:Number = this.mOptionsButton.getButtonMc().y;
         var _loc3_:* = int(this.mButtons.length - 1);
         while(_loc3_ >= 0)
         {
            _loc4_ = new GTween(this.mButtons[_loc3_].getButtonMc(),OptionsPanel.TWEEN_LENGTH,{
               "x":_loc1_,
               "y":_loc2_,
               "alpha":0
            },{"ease":Linear.easeNone});
            _loc5_ = (this.mButtons.length - 1 - _loc3_) * OptionsPanel.TWEEN_LENGTH;
            this.mTweenTimeLine.addTween(_loc5_,_loc4_);
            _loc3_--;
         }
         this.mTweenTimeLine.calculateDuration();
         new GTween(this.mOptionsButton.getButtonMc(),this.mTweenTimeLine.duration,{},{"onComplete":this.buttonsVisibility});
      }
      
      private function buttonsVisibility(param1:GTween) : void
      {
         this.mQualityButton.visible = this.mOptionsVisible;
         this.mSoundButton.visible = this.mOptionsVisible;
         this.mMusicButton.visible = this.mOptionsVisible;
         this.mFullScreenButton.visible = this.mOptionsVisible;
         this.mZoomOutButton.visible = this.mOptionsVisible;
         this.mZoomInButton.visible = this.mOptionsVisible;
      }
      
      private function onSoundClick(param1:MouseEvent) : void
      {
         if(Config.USE_SOUNDS)
         {
            if(SoundManager.getInstance().isSfxOn())
            {
               SoundManager.getInstance().stopAll(!SoundManager.getInstance().isMusicOn(),true);
               SoundManager.getInstance().setSfxOn(false);
               this.mSoundButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_SOUND_OFF));
               this.mSoundButton.changeFrame(2);
            }
            else
            {
               SoundManager.getInstance().setSfxOn(true);
               this.mSoundButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_SOUND_ON));
               this.mSoundButton.changeFrame(1);
            }
         }
      }
   }
}

