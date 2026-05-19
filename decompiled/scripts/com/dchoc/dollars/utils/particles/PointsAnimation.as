package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.utils.text.TextManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.filters.GlowFilter;
   
   public class PointsAnimation extends Particles
   {
      
      public static const TYPE_XP:uint = 0;
      
      public static const TYPE_COINS:uint = 1;
      
      public static const TYPE_GOLD:uint = 2;
      
      public static const TYPE_PLOTS:uint = 3;
      
      private static const TWEEN_LENGTH:Number = 2;
      
      private static const TWEEN_Y_OFFSET:Number = 60;
      
      private static const TWEEN_ALPHA:Number = 0.5;
      
      public function PointsAnimation(param1:int, param2:uint, param3:int, param4:int)
      {
         var _loc5_:String = null;
         var _loc6_:GlowFilter = null;
         super();
         x = param3;
         y = param4;
         switch(param2)
         {
            case TYPE_XP:
               mFormat.color = 16776554;
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_XP,new Array("+" + param1));
               _loc6_ = new GlowFilter(14573056,255,2,2,2,3);
               break;
            case TYPE_COINS:
               mFormat.color = 16777215;
               if(param1 < 0)
               {
                  _loc6_ = new GlowFilter(10485760,255,2,2,2,3);
                  param1 *= -1;
                  _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_COINS,new Array("-" + TextManager.getText(TextIDs.TID_COIN_SYMBOL) + param1));
                  break;
               }
               _loc6_ = new GlowFilter(2398208,255,2,2,2,3);
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_COINS,new Array("+" + TextManager.getText(TextIDs.TID_COIN_SYMBOL) + param1));
               break;
            case TYPE_GOLD:
               mFormat.color = 16777215;
               if(param1 < 0)
               {
                  _loc6_ = new GlowFilter(10485760,255,2,2,2,3);
                  _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_GOLD,new Array(param1.toString()));
                  break;
               }
               _loc6_ = new GlowFilter(2398208,255,2,2,2,3);
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_GOLD,new Array("+" + param1));
               break;
            case TYPE_PLOTS:
               mFormat.color = 16777215;
               if(param1 < 0)
               {
                  _loc6_ = new GlowFilter(10485760,255,2,2,2,3);
                  _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_PLOTS,new Array("" + param1));
                  break;
               }
               _loc6_ = new GlowFilter(2398208,255,2,2,2,3);
               _loc5_ = TextManager.replaceParameters(TextIDs.TID_POINTS_PLOTS,new Array("+" + param1));
         }
         mTextField.filters = [_loc6_];
         mTextField.defaultTextFormat = mFormat;
         mTextField.text = _loc5_;
         mTextField.height = mTextField.textHeight;
         addChild(mTextField);
      }
      
      private function endTween(param1:GTween) : void
      {
         param1.end();
         param1 = null;
         mAlive = false;
      }
      
      override public function destroy() : void
      {
         if(this.contains(mTextField))
         {
            removeChild(mTextField);
         }
         mTextField = null;
         mFormat = null;
      }
      
      override public function start() : void
      {
         new GTween(this,PointsAnimation.TWEEN_LENGTH,{
            "y":this.y - PointsAnimation.TWEEN_Y_OFFSET,
            "alpha":PointsAnimation.TWEEN_ALPHA
         },{
            "ease":Linear.easeNone,
            "onComplete":this.endTween
         });
      }
   }
}

