package
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.climate.ClimateManager;
   import com.dchoc.dollars.utils.screenshots.Screenshot;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.System;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageDisplayState;
   import flash.display.StageQuality;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   
   [SWF(width="760",height="594",backgroundColor="0xffffff",frameRate="25",allowScriptAccess="always",allowfullscreen="true")]
   public class Dollars extends Sprite
   {
      
      public static var smStage:Stage;
      
      private static var smInstance:Dollars;
      
      private static var smQuality:String;
      
      private static var smScreenshot:Screenshot;
      
      private static var smBitmap:Bitmap;
      
      private static var smBitmapData:BitmapData;
      
      public static const TEXTS_URL:String = Config.DIR_DATA + "Locale/";
      
      private static var mEncryptionMagicNumber:Number = 0;
      
      public static var smWelcomeDone:Boolean = false;
      
      private static const MAX_DELTA_TIME_MS:int = Config.DEBUG_MODE ? 200 : 500;
      
      private static var smVisible:Boolean = true;
      
      private var mGameTime:Number;
      
      private var mStateMachine:StateMachine;
      
      private var mBackground:Shape;
      
      private var mBackgroundColor:uint = 16777215;
      
      private var mPaused:Boolean;
      
      private var mDollarsGame:DollarsGame;
      
      public function Dollars()
      {
         var cm:ContextMenu = null;
         super();
         mEncryptionMagicNumber = System.currentTimeMillis();
         Security.allowDomain("*");
         stage.scaleMode = StageScaleMode.SHOW_ALL;
         stage.align = StageAlign.TOP_LEFT;
         smStage = stage;
         smStage.tabChildren = false;
         var flashVars:Object = smStage.root.loaderInfo.parameters;
         if(flashVars["debugMode"] == "1" || flashVars["debugMode"] == "true")
         {
            Config.DEBUG_MODE = true;
            Config.DEBUG_CONSOLE = true;
         }
         if(flashVars["climateMode"] == "1" || flashVars["climateMode"] == "true")
         {
            Config.USE_CLIMATE = true;
         }
         if(flashVars["oldItemDesigns"] == "1" || flashVars["oldItemDesigns"] == "true")
         {
            Config.USE_OLD_ITEM_DESIGNS = true;
         }
         MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOAD_START,0);
         Debug.startConsole(stage);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         UserDataFacade.getInstance().login();
         this.mGameTime = System.currentTimeMillis();
         addEventListener(Event.ENTER_FRAME,this.onEnterFrameLogin);
         if(smInstance == null)
         {
            smInstance = this;
         }
         this.mBackground = new Shape();
         backgroundSetColor(16777215);
         addChild(this.mBackground);
         if(Config.DEBUG_MODE)
         {
            SWFProfiler.init(stage,this);
         }
         else
         {
            cm = new ContextMenu();
            cm.hideBuiltInItems();
            this.contextMenu = cm;
         }
         Config.XML_VERSION = flashVars["xml_version"];
         Config.USER_LEVEL = flashVars["usr_level"];
         this.mStateMachine = new StateMachine(this);
         this.mDollarsGame = new DollarsGame(this.mStateMachine);
      }
      
      public static function getMagicEncryptionNumber() : Number
      {
         return mEncryptionMagicNumber;
      }
      
      public static function changeQuality(quality:String) : void
      {
         if(quality.toUpperCase() == StageQuality.HIGH.toUpperCase())
         {
            smStage.quality = quality;
            if(Config.USE_CLIMATE)
            {
               ClimateManager.getInstance().enable = true;
            }
            if(DollarsGame.getCurrentWorld() != null)
            {
               DollarsGame.getCurrentWorld().getCompanyMine().changeQuality(true);
               if(DollarsGame.getCurrentWorld().map.getTopLayer() != null)
               {
                  DollarsGame.getCurrentWorld().map.getTopLayer().changeQuality(true);
               }
            }
         }
         else
         {
            smStage.quality = StageQuality.LOW;
            if(Config.USE_CLIMATE)
            {
               ClimateManager.getInstance().enable = false;
            }
            if(DollarsGame.getCurrentWorld() != null)
            {
               DollarsGame.getCurrentWorld().getCompanyMine().changeQuality(false);
               if(DollarsGame.getCurrentWorld().map.getTopLayer() != null)
               {
                  DollarsGame.getCurrentWorld().map.getTopLayer().changeQuality(false);
               }
            }
         }
         smQuality = smStage.quality;
      }
      
      public static function getQuality() : String
      {
         return smStage.quality.toUpperCase();
      }
      
      public static function backgroundSetColor(color:uint) : void
      {
         smInstance.mBackgroundColor = color;
         smInstance.backgroundDraw();
      }
      
      public static function backgroundResize() : void
      {
         smInstance.backgroundDraw();
      }
      
      public static function updateGameConfig() : void
      {
         var soundStr:String = getBoolToBin(SoundManager.getInstance().isSfxOn());
         var musicStr:String = getBoolToBin(SoundManager.getInstance().isMusicOn());
         var qualityStr:String = getBoolToBin(smStage.quality.toLowerCase() == StageQuality.HIGH.toLowerCase());
         UserDataFacade.getInstance().updateProfile("gameConfig",{
            "sound":soundStr,
            "music":musicStr,
            "quality":qualityStr
         });
      }
      
      private static function getBoolToBin(eval:Boolean) : String
      {
         if(eval)
         {
            return "1";
         }
         return "0";
      }
      
      public static function println(str:String) : void
      {
         trace(str);
      }
      
      public static function getCurrentCursor() : Cursor
      {
         return smInstance.mStateMachine.getCurrentCursor();
      }
      
      public static function checkIsFullScreen() : void
      {
         if(smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            smStage.displayState = StageDisplayState.NORMAL;
         }
      }
      
      public static function stopChild(currentParent:DisplayObjectContainer) : void
      {
         if(currentParent is MovieClip)
         {
            MovieClip(currentParent).stop();
         }
         for(var i:int = 0; i < currentParent.numChildren; i++)
         {
            if(currentParent.getChildAt(i) is DisplayObjectContainer)
            {
               stopChild(currentParent.getChildAt(i) as DisplayObjectContainer);
            }
         }
      }
      
      public static function playChilds(currentParent:DisplayObjectContainer) : void
      {
         if(currentParent is MovieClip)
         {
            MovieClip(currentParent).play();
         }
         for(var i:int = 0; i < currentParent.numChildren; i++)
         {
            if(currentParent.getChildAt(i) is DisplayObjectContainer)
            {
               playChilds(currentParent.getChildAt(i) as DisplayObjectContainer);
            }
         }
      }
      
      public static function hideGameKeepingPopups() : void
      {
         hideGame(DollarsGame.smInstance.getStateMachine().getMainClip(),false);
      }
      
      public static function showGameKeepingPopups() : void
      {
         showGame(DollarsGame.smInstance.getStateMachine().getMainClip());
      }
      
      public static function hideGame(stage:Sprite = null, popups:Boolean = true) : void
      {
         Debug.trace("Dollars.hideGame() mVisible = " + smVisible);
         if(stage != null && smVisible)
         {
            smVisible = false;
            if(smScreenshot == null)
            {
               smScreenshot = new Screenshot();
               smBitmap = new Bitmap();
            }
            if(stage == null)
            {
               stage = smInstance;
            }
            smScreenshot.takeScreenshot(stage,-stage.x,-stage.y,Config.SCREEN_WIDTH,Config.SCREEN_HEIGHT);
            smBitmapData = smScreenshot.getBitmapScreenshot();
            smBitmap.bitmapData = smBitmapData;
            smInstance.mStateMachine.currentState.hide(popups);
            stage.addChild(smBitmap);
         }
      }
      
      public static function showGame(stage:Sprite = null, popups:Boolean = true) : void
      {
         Debug.trace("Dollars.showGame() mVisible = " + smVisible);
         if(stage != null && !smVisible)
         {
            if(stage == null)
            {
               stage = smInstance;
            }
            stage.removeChild(smBitmap);
            smInstance.mStateMachine.currentState.show(popups);
            smVisible = true;
         }
      }
      
      public static function toggleVisibility() : void
      {
         if(smVisible)
         {
            smInstance.mStateMachine.currentState.hide();
         }
         else
         {
            smInstance.mStateMachine.currentState.show();
         }
         smVisible = !smVisible;
      }
      
      private function backgroundDraw() : void
      {
         this.mBackground.cacheAsBitmap = false;
         var graphics:Graphics = this.mBackground.graphics;
         graphics.clear();
         graphics.beginFill(this.mBackgroundColor);
         graphics.drawRect(0,0,Dollars.smStage.stageWidth,Dollars.smStage.stageHeight);
         graphics.endFill();
         this.mBackground.cacheAsBitmap = true;
      }
      
      private function onMouseMove(e:MouseEvent) : void
      {
         if(getCurrentCursor() != null)
         {
            getCurrentCursor().setPosition(smStage.mouseX,smStage.mouseY);
         }
      }
      
      private function onEnterFrameLogin(event:Event) : void
      {
         var timeMillis:Number = System.currentTimeMillis();
         var deltaTime:int = timeMillis - this.mGameTime;
         this.mGameTime = timeMillis;
         if(deltaTime > MAX_DELTA_TIME_MS)
         {
            deltaTime = MAX_DELTA_TIME_MS;
         }
         if(deltaTime < 1)
         {
            deltaTime = 1;
         }
         UserDataFacade.getInstance().logicUpdate(deltaTime);
         if(UserDataFacade.getInstance().isLogged())
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrameLogin);
            this.mStateMachine.changeState(this.mDollarsGame);
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SESSION_STARTED,MetricConstants.LABEL_ON_FLASH);
            this.mDollarsGame.init();
            this.mGameTime = System.currentTimeMillis();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var timeMillis:Number = System.currentTimeMillis();
         var deltaTime:int = timeMillis - this.mGameTime;
         this.mGameTime = timeMillis;
         if(deltaTime > MAX_DELTA_TIME_MS)
         {
            deltaTime = MAX_DELTA_TIME_MS;
         }
         if(deltaTime < 1)
         {
            deltaTime = 1;
         }
         this.logicUpdate(deltaTime);
      }
      
      private function logicUpdate(deltaTime:int) : void
      {
         if(!this.mPaused)
         {
            this.mStateMachine.logicUpdate(deltaTime);
            UserDataFacade.getInstance().logicUpdate(deltaTime);
         }
      }
      
      private function saveQuality() : void
      {
      }
      
      public function isPaused() : Boolean
      {
         return this.mPaused;
      }
      
      private function pause() : void
      {
         smInstance.mPaused = true;
      }
      
      private function resume() : void
      {
         this.mPaused = false;
      }
      
      public function onKeyUp(e:KeyboardEvent) : void
      {
         if(Debug.DEBUG)
         {
            Debug.onKeyUp(e);
         }
         if(Config.DEBUG_MODE)
         {
            switch(e.keyCode)
            {
               case 80:
                  if(this.isPaused())
                  {
                     this.resume();
                  }
                  else
                  {
                     this.pause();
                  }
                  break;
               case 84:
                  if(this.isPaused())
                  {
                     this.mPaused = false;
                     this.logicUpdate(25);
                     this.mPaused = true;
                  }
                  break;
               case 85:
                  DollarsGame.smInstance.reduceHelpTime();
                  break;
               case 86:
                  hideGameKeepingPopups();
                  break;
               case 87:
                  showGameKeepingPopups();
                  break;
               case 88:
                  DollarsGame.smInstance.messagesAddMessage(DollarsGame.MESSAGES_FREE_GIFT + ":fgift_001");
                  DollarsGame.smInstance.messagesAddMessage(DollarsGame.MESSAGES_FREE_GIFT + ":fgift_002");
            }
         }
      }
   }
}

