package com.dchoc.dollars.utils.particles.climate
{
   import com.dchoc.dollars.map.Map;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.utils.setInterval;
   
   public class ClimateManager extends Sprite
   {
      
      private static var smInstance:ClimateManager;
      
      public static const TYPE_SNOW:int = 0;
      
      public static const TYPE_RAIN:int = 1;
      
      private var mWidth:Number;
      
      private var mCheckTimerId:int;
      
      private var mType:int;
      
      private var mTimerEnabled:Boolean;
      
      private var mFlakes:Array;
      
      private var mMap:Map;
      
      private var mHeight:Number;
      
      private const MAX_FLAKES:uint = 2000;
      
      private var mEnabled:Boolean;
      
      public function ClimateManager()
      {
         super();
      }
      
      public static function getInstance() : ClimateManager
      {
         if(smInstance == null)
         {
            smInstance = new ClimateManager();
         }
         return smInstance;
      }
      
      public function get enable() : Boolean
      {
         return this.mEnabled;
      }
      
      public function set enable(param1:Boolean) : void
      {
         this.mTimerEnabled = true;
         this.mEnabled = param1 && this.mTimerEnabled;
         if(!param1)
         {
            graphics.clear();
         }
      }
      
      public function init(param1:Number, param2:Number, param3:Map, param4:int = 0) : void
      {
         this.mWidth = param1;
         this.mHeight = param2;
         this.mMap = param3;
         this.mType = param4;
         this.mFlakes = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < this.MAX_FLAKES)
         {
            if(param4 == TYPE_SNOW)
            {
               this.mFlakes.push(new Flake(this.mWidth,this.mHeight,this.mMap));
            }
            else
            {
               this.mFlakes.push(new Drop(this.mWidth,this.mHeight,this.mMap));
            }
            _loc5_++;
         }
         this.mCheckTimerId = -1;
         this.checkTimer();
         var _loc6_:Date = new Date();
         var _loc7_:Number = _loc6_.hours % 2;
         var _loc8_:Number = _loc7_ * 3600000 + _loc6_.milliseconds + _loc6_.seconds * 1000 + _loc6_.minutes * 60000;
         var _loc9_:int = 7200000 - _loc8_;
         setInterval(this.checkTimer,_loc9_);
      }
      
      private function checkTimer() : void
      {
         this.enable = false;
         var _loc1_:Date = new Date();
         var _loc2_:int = _loc1_.hours;
         this.mTimerEnabled = _loc2_ % 4 < 2;
         if(this.mTimerEnabled && Dollars.smStage.quality.toUpperCase() == StageQuality.HIGH.toUpperCase())
         {
            this.enable = true;
         }
         if(this.mCheckTimerId > -1)
         {
            this.mCheckTimerId = setInterval(this.checkTimer,7200000);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Flake = null;
         var _loc4_:Drop = null;
         if(this.mEnabled)
         {
            graphics.clear();
            _loc2_ = 0;
            while(_loc2_ < this.MAX_FLAKES)
            {
               if(this.mType == TYPE_SNOW)
               {
                  _loc3_ = this.mFlakes[_loc2_];
                  _loc3_.logicUpdate(param1);
                  if(!_loc3_.isAlive)
                  {
                     _loc3_ = null;
                     this.mFlakes[_loc2_] = new Flake(this.mWidth,this.mHeight,this.mMap);
                  }
               }
               else
               {
                  _loc4_ = this.mFlakes[_loc2_];
                  _loc4_.logicUpdate(param1);
                  if(!_loc4_.isAlive)
                  {
                     _loc3_ = null;
                     this.mFlakes[_loc2_] = new Drop(this.mWidth,this.mHeight,this.mMap);
                  }
               }
               _loc2_++;
            }
         }
      }
   }
}

