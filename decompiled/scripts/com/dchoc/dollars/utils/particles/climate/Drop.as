package com.dchoc.dollars.utils.particles.climate
{
   import com.dchoc.dollars.map.Map;
   import flash.display.Graphics;
   
   public class Drop
   {
      
      private var size:Number;
      
      private var width:Number;
      
      private var height:Number;
      
      private var wind:Number;
      
      public var isAlive:Boolean;
      
      private var map:Map;
      
      private var gravity:Number;
      
      private var x:Number;
      
      private var y:Number;
      
      private var alpha:Number;
      
      public function Drop(param1:Number, param2:Number, param3:Map)
      {
         super();
         this.width = param1;
         this.height = param2;
         this.x = -200 + Math.random() * 1.5 * this.width;
         this.y = -200 + Math.random() * 1.5 * this.height;
         this.alpha = 0.1 + Math.random();
         this.gravity = 13 + Math.random() * 5;
         this.wind = Math.random() * (1.9 * 2);
         this.size = 0.5 + Math.random() * 2.5;
         this.isAlive = true;
         this.map = param3;
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc5_:Graphics = null;
         this.x += this.wind;
         this.y += this.gravity;
         var _loc2_:uint = 255;
         if(this.y > this.height || this.x > this.width)
         {
            this.isAlive = false;
            return;
         }
         var _loc3_:Number = this.map.getWorldXToScreen(this.x);
         var _loc4_:Number = this.map.getWorldYToScreen(this.y);
         if(_loc4_ > 0 && _loc3_ > 0 && _loc4_ <= Dollars.smStage.stageHeight && _loc3_ <= Dollars.smStage.stageWidth && this.y >= 0 && this.x >= 0)
         {
            _loc5_ = ClimateManager.getInstance().graphics;
            _loc5_.lineStyle(this.size,_loc2_,this.alpha);
            _loc5_.moveTo(this.x,this.y);
            _loc5_.lineTo(this.x + 1,this.y + 4);
         }
      }
   }
}

