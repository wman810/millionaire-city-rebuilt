package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NoteRain extends Sprite
   {
      
      public static const EVENT_RAIN_END:String = "EventRainEnd";
      
      public static const BACKGROUND:int = 0;
      
      public static const FOREGROUND:int = 1;
      
      public static const ALL:int = 2;
      
      private var mRain:Array;
      
      private var mCreateParticles:Boolean;
      
      private var mLayer:int;
      
      private var mMaxParticles:int;
      
      private var mParent:DisplayObjectContainer;
      
      private var mSpeed:Array;
      
      private var mIsRaining:Boolean;
      
      public function NoteRain(param1:int, param2:int)
      {
         super();
         this.mMaxParticles = param2;
         this.mLayer = param1;
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function start(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         if(!this.mIsRaining)
         {
            this.mRain = new Array(this.mMaxParticles);
            this.mSpeed = new Array(this.mMaxParticles);
            addEventListener(Event.ENTER_FRAME,this.update);
            this.mCreateParticles = true;
            _loc2_ = 0;
            while(_loc2_ < this.mMaxParticles)
            {
               this.createNewPartilce(_loc2_);
               _loc2_++;
            }
            param1.addChild(this);
            this.mParent = param1;
            this.mIsRaining = true;
         }
         else
         {
            this.mCreateParticles = true;
            this.mIsRaining = true;
         }
      }
      
      private function update(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mMaxParticles)
         {
            if(this.mRain[_loc2_] != null)
            {
               this.mRain[_loc2_].y += this.mSpeed[_loc2_];
               if(DollarsGame.smInstance.getVersion() >= 10)
               {
                  this.mRain[_loc2_].rotationX += 10;
                  this.mRain[_loc2_].rotationZ += 5;
               }
               else
               {
                  this.mRain[_loc2_].rotation += 5;
               }
               if(this.mRain[_loc2_].y > Dollars.smStage.stageHeight + Dollars.smStage.stageHeight / 4)
               {
                  this.mRain[_loc2_].removeChildAt(0);
                  removeChild(this.mRain[_loc2_]);
                  this.mRain[_loc2_] = null;
                  this.mSpeed[_loc2_] = null;
                  if(this.mCreateParticles)
                  {
                     this.createNewPartilce(_loc2_);
                  }
               }
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.mMaxParticles)
         {
            if(this.mRain[_loc2_] != null)
            {
               break;
            }
            _loc2_++;
         }
         if(_loc2_ == this.mMaxParticles)
         {
            dispatchEvent(new Event(EVENT_RAIN_END));
         }
      }
      
      public function stop() : void
      {
         if(this.mIsRaining)
         {
            this.mCreateParticles = false;
            addEventListener(EVENT_RAIN_END,DollarsGame.smInstance.finishRain);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      public function end() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.update);
         this.mRain = null;
         this.mSpeed = null;
         this.mIsRaining = false;
         if(this.mParent.contains(this))
         {
            this.mParent.removeChild(this);
         }
      }
      
      private function createNewPartilce(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Sprite = new Sprite();
         var _loc4_:int = Math.random() * 5 * 10;
         if(this.mLayer == BACKGROUND)
         {
            _loc3_ = int(Math.random() * 2) + 2;
         }
         else if(this.mLayer == FOREGROUND)
         {
            _loc3_ = int(Math.random() * 2);
         }
         else
         {
            _loc3_ = int(Math.random() * 4);
         }
         switch(_loc3_)
         {
            case 0:
               _loc2_ = new AssetManager.Note();
               break;
            case 1:
               _loc2_ = new AssetManager.Note1();
               break;
            case 2:
               _loc2_ = new AssetManager.Note2();
               break;
            case 3:
               _loc2_ = new AssetManager.Note3();
               break;
            case 4:
               _loc2_ = new AssetManager.Note4();
         }
         this.mSpeed[param1] = 5 + Math.random() * 10;
         this.mRain[param1] = _loc2_;
         _loc2_.y = -(_loc2_.height + 10) - Math.random() * (Dollars.smStage.stageHeight / 2);
         _loc2_.x = Math.random() * (Dollars.smStage.stageWidth + 200) - 100;
         if(DollarsGame.smInstance.getVersion() >= 10)
         {
            _loc2_.rotationX += Math.random() * 360;
            _loc2_.rotationZ += Math.random() * 360;
         }
         else
         {
            _loc2_.rotation += Math.random() * 360;
         }
         addChild(_loc2_);
      }
   }
}

