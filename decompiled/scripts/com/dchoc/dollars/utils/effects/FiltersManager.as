package com.dchoc.dollars.utils.effects
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.utils.Dictionary;
   
   public class FiltersManager
   {
      
      private static var smCatalogFilters:Dictionary;
      
      public function FiltersManager()
      {
         super();
      }
      
      public static function catalogAddFilter(param1:String, param2:Array) : void
      {
         if(smCatalogFilters == null)
         {
            smCatalogFilters = new Dictionary(true);
         }
         smCatalogFilters[param1] = param2;
      }
      
      public static function changeColor(param1:MovieClip, param2:Number) : void
      {
         var _loc3_:ColorTransform = new ColorTransform();
         _loc3_.color = param2;
         param1.transform.colorTransform = _loc3_;
      }
      
      public static function setInk(param1:ColorTransform, param2:uint, param3:Number) : ColorTransform
      {
         var _loc4_:ColorTransform = new ColorTransform();
         var _loc5_:ColorTransform = new ColorTransform();
         _loc4_.color = param2;
         _loc5_.redMultiplier = param1.redMultiplier + (_loc4_.redMultiplier - param1.redMultiplier) * param3;
         _loc5_.greenMultiplier = param1.greenMultiplier + (_loc4_.greenMultiplier - param1.greenMultiplier) * param3;
         _loc5_.blueMultiplier = param1.blueMultiplier + (_loc4_.blueMultiplier - param1.blueMultiplier) * param3;
         _loc5_.alphaMultiplier = param1.alphaMultiplier + (_loc4_.alphaMultiplier - param1.alphaMultiplier) * param3;
         _loc5_.redOffset = param1.redOffset + (_loc4_.redOffset - param1.redOffset) * param3;
         _loc5_.greenOffset = param1.greenOffset + (_loc4_.greenOffset - param1.greenOffset) * param3;
         _loc5_.blueOffset = param1.blueOffset + (_loc4_.blueOffset - param1.blueOffset) * param3;
         _loc5_.alphaOffset = param1.alphaOffset + (_loc4_.alphaOffset - param1.alphaOffset) * param3;
         return _loc5_;
      }
      
      public static function catalogGetFilter(param1:String) : Array
      {
         var _loc2_:Array = null;
         if(smCatalogFilters != null)
         {
            _loc2_ = smCatalogFilters[param1];
         }
         return _loc2_;
      }
      
      public static function load() : void
      {
      }
      
      public static function getSaturationFilter(param1:Number) : Array
      {
         param1 /= 100;
         var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
         var _loc3_:Array = [1,0,0,0,0];
         var _loc4_:Array = [0,1,0,0,0];
         var _loc5_:Array = [0,0,1,0,0];
         var _loc6_:Array = [0,0,0,1,0];
         var _loc7_:Array = [0.3,0.59,0.11,0,0];
         var _loc8_:Array = new Array();
         _loc8_ = _loc8_.concat(interpolateArrays(_loc7_,_loc3_,param1));
         _loc8_ = _loc8_.concat(interpolateArrays(_loc7_,_loc4_,param1));
         _loc8_ = _loc8_.concat(interpolateArrays(_loc7_,_loc5_,param1));
         _loc8_ = _loc8_.concat(_loc6_);
         _loc2_.matrix = _loc8_;
         return [_loc2_];
      }
      
      public static function destroy() : void
      {
         smCatalogFilters = null;
      }
      
      private static function interpolateArrays(param1:Array, param2:Array, param3:Number) : Object
      {
         var _loc4_:Array = param1.length >= param2.length ? param1.slice() : param2.slice();
         var _loc5_:uint = _loc4_.length;
         while(_loc5_--)
         {
            _loc4_[_loc5_] = param1[_loc5_] + (param2[_loc5_] - param1[_loc5_]) * param3;
         }
         return _loc4_;
      }
      
      public static function drawRectangleWithBorder(param1:Graphics, param2:int, param3:int, param4:int, param5:int, param6:uint, param7:Number) : void
      {
         param1.clear();
         param1.lineStyle(2,param6);
         param1.beginFill(param6,param7);
         param1.drawRoundRect(param2,param3,param4,param5,20);
         param1.endFill();
      }
   }
}

