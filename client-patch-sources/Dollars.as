package
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.climate.ClimateManager;
   import com.dchoc.dollars.utils.screenshots.Screenshot;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.System;
   import com.gskinner.motion.plugins.ColorTransformPlugin;
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
   
   public class Dollars extends Sprite
   {
      
      private static var smBitmap:Bitmap;
      
      public static var smStage:Stage;
      
      private static var smQuality:String;
      
      public static var smWelcomeDone:Boolean;
      
      private static var smBitmapData:BitmapData;
      
      private static var smInstance:Dollars;
      
      private static var smScreenshot:Screenshot;
      
      public static var smFrameTick:int;
      
      private static var smSecure:Boolean;
      
      public static const TEXTS_URL:String = Config.DIR_DATA + "Locale/";
      
      private static var mEncryptionMagicNumber:Number = 0;
      
      private static const MAX_DELTA_TIME_MS:int = Config.DEBUG_MODE ? 200 : 500;
      
      private static var smVisible:Boolean = true;
      
      private var mBackground:Shape;
      
      private var mStateMachine:StateMachine;
      
      private var mBackgroundColor:uint = 16777215;
      
      private var mGameTime:Number;
      
      private var mPaused:Boolean;
      
      private var mDollarsGame:DollarsGame;
      
      public function Dollars()
      {
         var _loc2_:ContextMenu = null;
         super();
         if(smInstance == null)
         {
            smInstance = this;
         }
         smStage = stage;
         smStage.tabChildren = false;
         var _loc1_:Object = smStage.root.loaderInfo.parameters;
         Security.allowInsecureDomain("*");
         Security.allowDomain("*");
         UserDataFacade.getInstance().login();
         mEncryptionMagicNumber = System.currentTimeMillis();
         this.mGameTime = System.currentTimeMillis();
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOAD_START,0);
         Debug.startConsole(stage);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrameLogin);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this.mBackground = new Shape();
         backgroundSetColor(16777215);
         addChild(this.mBackground);
         if(Config.DEBUG_MODE)
         {
            SWFProfiler.init(stage,this);
         }
         else
         {
            _loc2_ = new ContextMenu();
            _loc2_.hideBuiltInItems();
            this.contextMenu = _loc2_;
         }
         if(!Config.OFFLINE_GAMEPLAY_MODE)
         {
            Config.FACEBOOK_CREDITS_AS_CURRENCY = _loc1_.useFrictionlessFacebookCredits == "true";
            Config.SECURE_PROTOCOL = _loc1_.server.indexOf("https") > -1;
         }
         Config.FACEBOOK_CREDITS_TO_BUY_GOLD = Config.FACEBOOK_CREDITS_AS_CURRENCY;
         this.mStateMachine = new StateMachine(this);
         this.mDollarsGame = new DollarsGame(this.mStateMachine);
         Debug.startDebug(stage,this);
         ColorTransformPlugin.install();
      }
      
      public static function backgroundResize() : void
      {
         smInstance.backgroundDraw();
      }
      
      public static function getMagicEncryptionNumber() : Number
      {
         return mEncryptionMagicNumber;
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
      
      public static function getQuality() : String
      {
         return smStage.quality.toUpperCase();
      }
      
      public static function checkIsFullScreen() : void
      {
         if(smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            smStage.displayState = StageDisplayState.NORMAL;
         }
      }
      
      private static function getBoolToBin(param1:Boolean) : String
      {
         if(param1)
         {
            return "1";
         }
         return "0";
      }
      
      public static function showGameKeepingPopups() : void
      {
         showGame(DollarsGame.smInstance.getStateMachine().getMainClip());
      }
      
      public static function isFocusGame() : Boolean
      {
         return smVisible;
      }
      
      public static function hideGame(param1:Sprite = null, param2:Boolean = true) : void
      {
         Debug.trace("Dollars.hideGame() mVisible = " + smVisible);
         if(param1 != null && smVisible)
         {
            smVisible = false;
            if(smScreenshot == null)
            {
               smScreenshot = new Screenshot();
               smBitmap = new Bitmap();
            }
            if(param1 == null)
            {
               param1 = smInstance;
            }
            smScreenshot.takeScreenshot(param1,-param1.x,-param1.y,Config.SCREEN_WIDTH,Config.SCREEN_HEIGHT);
            smBitmapData = smScreenshot.getBitmapScreenshot();
            smBitmap.bitmapData = smBitmapData;
            smInstance.mStateMachine.currentState.hide(param2);
            param1.addChild(smBitmap);
         }
      }
      
      public static function focusGame(param1:Boolean) : void
      {
         smVisible = param1;
      }
      
      public static function playChilds(param1:DisplayObjectContainer) : void
      {
         if(param1 is MovieClip)
         {
            MovieClip(param1).play();
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            if(param1.getChildAt(_loc2_) is DisplayObjectContainer)
            {
               playChilds(param1.getChildAt(_loc2_) as DisplayObjectContainer);
            }
            _loc2_++;
         }
      }
      
      public static function changeQuality(param1:String) : void
      {
         if(param1.toUpperCase() == StageQuality.HIGH.toUpperCase())
         {
            smStage.quality = param1;
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
      
      public static function backgroundSetColor(param1:uint) : void
      {
         smInstance.mBackgroundColor = param1;
         smInstance.backgroundDraw();
      }
      
      public static function getCurrentCursor() : Cursor
      {
         return smInstance.mStateMachine.getCurrentCursor();
      }
      
      public static function stopChild(param1:DisplayObjectContainer) : void
      {
         if(param1 is MovieClip)
         {
            MovieClip(param1).stop();
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            if(param1.getChildAt(_loc2_) is DisplayObjectContainer)
            {
               stopChild(param1.getChildAt(_loc2_) as DisplayObjectContainer);
            }
            _loc2_++;
         }
      }
      
      public static function showGame(param1:Sprite = null, param2:Boolean = true) : void
      {
         Debug.trace("Dollars.showGame() mVisible = " + smVisible);
         if(param1 != null && !smVisible)
         {
            if(param1 == null)
            {
               param1 = smInstance;
            }
            param1.removeChild(smBitmap);
            smInstance.mStateMachine.currentState.show(param2);
            smVisible = true;
         }
      }
      
      public static function updateGameConfig() : void
      {
         var _loc1_:String = getBoolToBin(SoundManager.getInstance().isSfxOn());
         var _loc2_:String = getBoolToBin(SoundManager.getInstance().isMusicOn());
         var _loc3_:String = getBoolToBin(smStage.quality.toLowerCase() == StageQuality.HIGH.toLowerCase());
         UserDataFacade.getInstance().updateProfile("gameConfig",{
            "sound":_loc1_,
            "music":_loc2_,
            "quality":_loc3_
         });
      }
      
      public static function println(param1:String) : void
      {
         trace(param1);
      }
      
      public static function hideGameKeepingPopups() : void
      {
         hideGame(DollarsGame.smInstance.getStateMachine().getMainClip(),false);
      }
      
      private function pause() : void
      {
         smInstance.mPaused = true;
      }
      
      private function logicUpdate(param1:int) : void
      {
         if(!this.mPaused)
         {
            this.mStateMachine.logicUpdate(param1);
            UserDataFacade.getInstance().logicUpdate(param1);
         }
      }
      
      private function saveQuality() : void
      {
      }
      
      public function onKeyUp(param1:KeyboardEvent) : void
      {
         if(Debug.DEBUG)
         {
            Debug.onKeyUp(param1);
         }
         if(Config.DEBUG_MODE)
         {
            switch(param1.keyCode)
            {
               case 80:
                  if(this.isPaused())
                  {
                     this.resume();
                     break;
                  }
                  this.pause();
                  break;
               case 82:
                  DollarsGame.getProfile().setFacebookCredits(DollarsGame.getProfile().facebookCredits + 500,DollarsGame.getProfile().facebookCreditsNotSpent + 10);
                  break;
               case 83:
                  DollarsGame.getProfile().setFacebookCredits(DollarsGame.getProfile().facebookCredits - 10,DollarsGame.getProfile().facebookCreditsNotSpent - 1);
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
                  UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_LIST_RELOAD);
                  FriendsManager.reload();
                  break;
               case 86:
                  FBCreditsPurchase.getInstance().endPurchaseProcess(FBCreditsPurchase.RESPONSE_NO_RESPONSE,false);
                  break;
               case 88:
                  FBCreditsPurchase.getInstance().endPurchaseProcess(FBCreditsPurchase.RESPONSE_NEED_CREDITS);
                  break;
               case 87:
                  FBCreditsPurchase.getInstance().endPurchaseProcess(FBCreditsPurchase.RESPONSE_OK);
            }
         }
      }
      
      private function resume() : void
      {
         this.mPaused = false;
      }
      
      private function backgroundDraw() : void
      {
         this.mBackground.cacheAsBitmap = false;
         var _loc1_:Graphics = this.mBackground.graphics;
         _loc1_.clear();
         _loc1_.beginFill(this.mBackgroundColor);
         _loc1_.drawRect(0,0,Dollars.smStage.stageWidth,Dollars.smStage.stageHeight);
         _loc1_.endFill();
         this.mBackground.cacheAsBitmap = true;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = System.currentTimeMillis();
         var _loc3_:int = _loc2_ - this.mGameTime;
         this.mGameTime = _loc2_;
         if(_loc3_ > MAX_DELTA_TIME_MS)
         {
            _loc3_ = MAX_DELTA_TIME_MS;
         }
         if(_loc3_ < 1)
         {
            _loc3_ = 1;
         }
         ++smFrameTick;
         if(smFrameTick > 1000)
         {
            smFrameTick = 0;
         }
         this.logicUpdate(_loc3_);
      }
      
      private function onEnterFrameLogin(param1:Event) : void
      {
         var _loc2_:Number = System.currentTimeMillis();
         var _loc3_:int = _loc2_ - this.mGameTime;
         this.mGameTime = _loc2_;
         if(_loc3_ > MAX_DELTA_TIME_MS)
         {
            _loc3_ = MAX_DELTA_TIME_MS;
         }
         if(_loc3_ < 1)
         {
            _loc3_ = 1;
         }
         UserDataFacade.getInstance().logicUpdate(_loc3_);
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
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(getCurrentCursor() != null)
         {
            getCurrentCursor().setPosition(smStage.mouseX,smStage.mouseY);
         }
      }
      
      public function isPaused() : Boolean
      {
         return this.mPaused;
      }
   }
}

