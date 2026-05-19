package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.flow.DollarsGame;
   import flash.display.Sprite;
   
   public class ParticlesManager
   {
      
      private static var smParticleClip:Sprite;
      
      private static var smMapX:Number;
      
      private static var smMapY:Number;
      
      private static var smParticles:Array = new Array();
      
      public function ParticlesManager()
      {
         super();
      }
      
      public static function killPartilce() : void
      {
         var _loc2_:Particles = null;
         var _loc1_:int = 0;
         while(_loc1_ < smParticles.length)
         {
            _loc2_ = smParticles[_loc1_];
            _loc2_.kill();
            _loc1_++;
         }
         update(10000);
      }
      
      public static function addParticle(param1:Particles, param2:Boolean = true) : void
      {
         if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
         {
            smParticles.push(param1);
            DollarsGame.getCurrentWorld().map.addChild(param1);
            if(param2)
            {
               reallocateParticle(param1);
            }
            param1.start();
         }
      }
      
      public static function update(param1:int) : void
      {
         var _loc2_:* = 0;
         while(_loc2_ < smParticles.length)
         {
            smParticles[_loc2_].update(param1);
            if(!smParticles[_loc2_].isAlive())
            {
               removeParticle(smParticles[_loc2_]);
               smParticles[_loc2_].destroy();
               smParticles.splice(_loc2_,1);
               _loc2_--;
            }
            _loc2_++;
         }
      }
      
      public static function removeParticle(param1:Particles) : void
      {
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         if(DollarsGame.getCurrentWorld().map.contains(param1))
         {
            DollarsGame.getCurrentWorld().map.removeChild(param1);
         }
         else if(smParticleClip.contains(param1))
         {
            smParticleClip.removeChild(param1);
         }
      }
      
      public static function reset() : void
      {
         var _loc1_:Particles = null;
         for each(_loc1_ in smParticles)
         {
            removeParticle(_loc1_);
            _loc1_.destroy();
         }
         smParticles.splice(0,smParticles.length);
      }
      
      private static function reallocateParticle(param1:Particles) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Particles = null;
         var _loc2_:int = smParticles.indexOf(param1);
         if(_loc2_ > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < smParticles.length - 1)
            {
               _loc4_ = smParticles[_loc3_];
               if(!(_loc4_ is ParticleAnimation) && (param1.y >= _loc4_.y && param1.y < _loc4_.y + _loc4_.height || _loc4_.y >= param1.y && _loc4_.y < param1.y + param1.height) && (param1.x >= _loc4_.x && param1.x < _loc4_.x + _loc4_.width || _loc4_.x >= param1.x && _loc4_.x < param1.x + param1.width))
               {
                  param1.y = _loc4_.y + _loc4_.height;
               }
               _loc3_++;
            }
         }
      }
      
      public static function init() : void
      {
         smParticleClip = new Sprite();
         smParticleClip.mouseEnabled = false;
         DollarsGame.smInstance.mGameClip.addChild(smParticleClip);
      }
   }
}

