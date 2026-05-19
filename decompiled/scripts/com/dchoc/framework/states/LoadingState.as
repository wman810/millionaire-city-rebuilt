package com.dchoc.framework.states
{
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import com.dchoc.framework.utils.DCUtils;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class LoadingState extends FSMState
   {
      
      public static const SKIN_SIMPLE_ID:int = 0;
      
      public static const SKIN_BACKGROUND_IMAGE_ID:int = 1;
      
      public static const SKIN_DEFAULT_ID:int = SKIN_BACKGROUND_IMAGE_ID;
      
      protected var mLoadingBar:MovieClip;
      
      protected var mAdvanceToFrameBar:int;
      
      protected var mLoading:DisplayObjectContainer;
      
      private var mLoadingXml:XML;
      
      protected var mPercent:int;
      
      protected var mAdvanceToFrame:int;
      
      private var mLoadingStr:String = "Loading";
      
      private const LOADING_TEXT_FILE:String = "Locale/loadingText";
      
      private var mMode:int;
      
      private var mBackground:Sprite;
      
      public function LoadingState(param1:StateMachine)
      {
         super(param1,true);
         TextManager.lang = "EN";
         var _loc2_:String = Config.getRoot() + this.LOADING_TEXT_FILE;
         if(!MyMetrics.envIsProduction() || Config.OFFLINE_GAMEPLAY_MODE)
         {
            _loc2_ += "_stage";
         }
         Debug.trace("*********************** LoadingText path: " + _loc2_);
         _loc2_ += ".xml";
         var _loc3_:URLLoader = new URLLoader();
         var _loc4_:URLRequest = new URLRequest(_loc2_);
         var _loc5_:LoaderContext = new LoaderContext();
         _loc5_.checkPolicyFile = true;
         _loc3_.load(_loc4_);
         _loc3_.addEventListener(Event.COMPLETE,this.onComplete);
         this.mBackground = new Sprite();
         this.backgroundDraw();
         this.skinSetId(SKIN_DEFAULT_ID);
      }
      
      private function loadText(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:TextField = null;
         for each(_loc2_ in this.mLoadingXml.line)
         {
            if(TextManager.lang == _loc2_.@file)
            {
               break;
            }
         }
         TextManager.getInstance().removeEventListener(TextManager.EVENT_TEXT_LOADED,this.loadText);
         TextManager.smChangeFont = false;
         if("@changeFont" in _loc2_)
         {
            TextManager.smChangeFont = Boolean(int(_loc2_.@changeFont));
         }
         TextManager.smAlign = TextManager.ALIGN_LEFT;
         if("@align" in _loc2_)
         {
            TextManager.smAlign = String(_loc2_.@align).toUpperCase();
         }
         if("@text" in _loc2_)
         {
            this.mLoadingStr = _loc2_.@text;
            _loc3_ = TextField(this.mLoading.getChildByName("Text_Title"));
            _loc3_.text = this.mLoadingStr;
            TextManager.reformatTextField(_loc3_);
            _loc3_.visible = true;
         }
      }
      
      public function setPercent(param1:int) : void
      {
         this.mPercent = param1;
         var _loc2_:int = int(this.mLoadingBar.totalFrames * param1 / 100);
         ++this.mAdvanceToFrameBar;
         if(this.mAdvanceToFrameBar > _loc2_)
         {
            this.mAdvanceToFrameBar = _loc2_;
         }
         this.mLoadingBar.gotoAndStop(this.mAdvanceToFrameBar);
      }
      
      override public function logicUpdate(param1:int) : void
      {
      }
      
      private function backgroundDraw() : void
      {
         var _loc1_:Graphics = this.mBackground.graphics;
         _loc1_.clear();
         _loc1_.beginFill(16777215,0);
         _loc1_.drawRect(-Dollars.smStage.stageWidth / 2,-Dollars.smStage.stageHeight / 2,Dollars.smStage.stageWidth,Dollars.smStage.stageHeight);
         _loc1_.endFill();
      }
      
      private function onResize(param1:Event) : void
      {
         DCUtils.centerClip(this.mLoading);
         this.backgroundDraw();
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter();
         mMainClip.addChild(this.mLoading);
         DCUtils.centerClip(this.mLoading);
         Dollars.smStage.addEventListener(Event.RESIZE,this.onResize);
         this.setPercent(0);
         this.backgroundDraw();
         this.mLoading.addChildAt(this.mBackground,0);
      }
      
      override public function exit() : void
      {
         super.exit();
         mMainClip.removeChild(this.mLoading);
         this.mLoading.removeChild(this.mBackground);
         Dollars.smStage.removeEventListener(Event.RESIZE,this.onResize);
      }
      
      public function skinSetId(param1:int) : void
      {
         this.skinDestroy();
         this.mMode = param1;
         switch(param1)
         {
            case SKIN_BACKGROUND_IMAGE_ID:
               this.mLoading = new AssetManager.Loading_Background();
               break;
            case SKIN_SIMPLE_ID:
               this.mLoading = new AssetManager.Loading_Simple();
               break;
            default:
               this.mLoading = new AssetManager.Loading_Background();
         }
         this.mLoading.addChildAt(this.mBackground,0);
         this.mLoadingBar = this.mLoading["Fill_Bar"];
         this.mLoadingBar.stop();
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         this.mLoadingXml = new XML(_loc2_.data);
         _loc2_.removeEventListener(Event.COMPLETE,this.onComplete);
         var _loc3_:Object = Dollars.smStage.root.loaderInfo.parameters;
         var _loc4_:String = _loc3_.lang;
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            _loc4_ = "en_US";
         }
         for each(_loc5_ in this.mLoadingXml.line)
         {
            _loc6_ = _loc5_.@lang;
            _loc7_ = "";
            if(Config.USE_LOCALE && _loc4_ != null && _loc4_.length > 0)
            {
               if(_loc4_.indexOf(_loc6_) > -1 || _loc4_.indexOf(_loc6_.toLowerCase()) > -1)
               {
                  TextManager.lang = _loc5_.@file;
                  _loc7_ = _loc6_;
               }
            }
            else
            {
               _loc7_ = "EN";
            }
            if(_loc6_ == _loc7_)
            {
               break;
            }
         }
         if(_loc7_ == "")
         {
            _loc7_ = "EN";
            TextManager.lang = "EN";
         }
         TextManager.getInstance().addEventListener(TextManager.EVENT_TEXT_LOADED,this.loadText);
         TextManager.init();
      }
      
      private function skinDestroy() : void
      {
         this.mLoading = null;
         this.mLoadingBar = null;
         this.mAdvanceToFrame = 0;
         this.mAdvanceToFrameBar = 0;
      }
   }
}

