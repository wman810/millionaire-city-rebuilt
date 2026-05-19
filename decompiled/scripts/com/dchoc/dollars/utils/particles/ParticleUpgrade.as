package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   
   public class ParticleUpgrade extends MovieClip
   {
      
      private static const UPGRADE_TYPE_SWFS:Array = [Config.getRoot() + ModelConfig.HOUSE_UPGRADED_SWF,Config.getRoot() + ModelConfig.HOUSE_SUPER_UPGRADED_SWF];
      
      private const RAFAGA_TIMER_OWNER:int = 5000;
      
      private var mAreaWidth:int;
      
      private var mParticles:Array;
      
      private const RAFAGA_TIMER_VISIT:int = 30000;
      
      private var mTimer:Array;
      
      private const MAX_PARTILCES:int = 4;
      
      private var mAreaHeight:int;
      
      private const CONSTANT:int = 9;
      
      private const TIMER:int = 300;
      
      private const WAIT_TIMER_VISIT:int = 10000;
      
      private const WAIT_TIMER_OWNER:int = 40000;
      
      private var mStart:Boolean;
      
      private var mWaitTime:int;
      
      private var mRafagaTime:int;
      
      public function ParticleUpgrade(param1:int, param2:int, param3:int)
      {
         var _loc5_:MovieClip = null;
         super();
         this.mAreaWidth = param1;
         this.mAreaHeight = param2;
         this.mParticles = new Array();
         this.mTimer = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < this.MAX_PARTILCES)
         {
            _loc5_ = new (DCResourceManager.getInstance().getSWFClass(UPGRADE_TYPE_SWFS[param3],"star_upgrade"))();
            _loc5_.stop();
            this.mParticles.push(_loc5_);
            this.mTimer.push(0);
            _loc4_++;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.mStart)
         {
            if(this.mRafagaTime > 0)
            {
               this.mRafagaTime -= param1;
               if(this.mRafagaTime <= 0)
               {
                  this.mRafagaTime = 0;
                  if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
                  {
                     this.mWaitTime = this.WAIT_TIMER_VISIT;
                  }
                  else
                  {
                     this.mWaitTime = this.WAIT_TIMER_OWNER;
                  }
               }
               this.checkParticles(param1,true);
            }
            else if(this.mWaitTime > 0)
            {
               this.mWaitTime -= param1;
               if(this.mWaitTime <= 0)
               {
                  this.mWaitTime = 0;
                  if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
                  {
                     this.mRafagaTime = this.RAFAGA_TIMER_VISIT;
                  }
                  else
                  {
                     this.mRafagaTime = this.RAFAGA_TIMER_OWNER;
                  }
               }
               this.checkParticles(param1,false);
            }
         }
      }
      
      private function checkParticles(param1:int, param2:Boolean) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.MAX_PARTILCES)
         {
            _loc3_ = this.mParticles[_loc4_];
            if(this.mTimer[_loc4_] > 0 && param2)
            {
               this.mTimer[_loc4_] -= param1;
               if(this.mTimer[_loc4_] <= 0)
               {
                  this.createNewParticle(_loc3_);
               }
            }
            else if(_loc3_.currentFrame == _loc3_.totalFrames)
            {
               _loc3_.gotoAndStop(1);
               removeChild(_loc3_);
               this.mTimer[_loc4_] = int(Math.random() * this.CONSTANT + 1) * this.TIMER;
            }
            _loc4_++;
         }
      }
      
      public function end() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.MAX_PARTILCES)
         {
            this.mTimer[_loc1_] = 0;
            if(contains(this.mParticles[_loc1_]))
            {
               removeChild(this.mParticles[_loc1_]);
            }
            _loc1_++;
         }
         this.mStart = false;
      }
      
      public function start() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.MAX_PARTILCES)
         {
            this.mTimer[_loc1_] = int(Math.random() * this.CONSTANT + 1) * this.TIMER;
            _loc1_++;
         }
         this.mStart = true;
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
         {
            this.mRafagaTime = this.RAFAGA_TIMER_VISIT;
         }
         else
         {
            this.mRafagaTime = this.RAFAGA_TIMER_OWNER;
         }
      }
      
      private function createNewParticle(param1:MovieClip) : void
      {
         param1.gotoAndPlay(1);
         param1.x = Math.random() * this.mAreaWidth;
         param1.y = Math.random() * this.mAreaHeight;
         addChild(param1);
      }
   }
}

