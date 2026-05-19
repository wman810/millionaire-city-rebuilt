package com.dchoc.dollars.utils.animations
{
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class BitmapDataFactory
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:BitmapDataFactory;
      
      private var mCollection:Array;
      
      public function BitmapDataFactory()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: BitmapDataFactory Error: Instantiation failed: Use BitmapDataFactory.getInstance() instead of new.");
         }
         this.mCollection = new Array();
      }
      
      public static function getInstance() : BitmapDataFactory
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new BitmapDataFactory();
            smAllowed = false;
         }
         return smInstance;
      }
      
      public function getAnimationContainerCombined(param1:String, param2:String, param3:String, param4:String) : Object
      {
         var _loc6_:MovieClip = null;
         var _loc7_:Bitmap = null;
         var _loc8_:MovieClip = null;
         var _loc5_:String = param1 + param2 + param3;
         if(this.mCollection[_loc5_] == null)
         {
            _loc6_ = new (DCResourceManager.getInstance().getSWFClass(param1,param2))();
            _loc7_ = new Bitmap(DCResourceManager.getInstance().get(param3));
            _loc7_.smoothing = true;
            _loc8_ = _loc6_.getChildByName(param4) as MovieClip;
            if(_loc8_ != null)
            {
               _loc8_.addChild(_loc7_);
            }
            this.mCollection[_loc5_] = this.generateAnimation(_loc6_);
            _loc6_ = null;
            _loc7_ = null;
            _loc8_ = null;
         }
         return this.mCollection[_loc5_];
      }
      
      public function getAnimationContainer(param1:String, param2:String) : Object
      {
         var _loc4_:MovieClip = null;
         var _loc3_:String = param1 + param2;
         if(this.mCollection[_loc3_] == null)
         {
            _loc4_ = new (DCResourceManager.getInstance().getSWFClass(param1,param2))();
            this.mCollection[_loc3_] = this.generateAnimation(_loc4_);
            _loc4_ = null;
         }
         return this.mCollection[_loc3_];
      }
      
      private function generateAnimation(param1:MovieClip) : Object
      {
         var _loc3_:BitmapData = null;
         var _loc4_:Rectangle = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:Matrix = new Matrix();
         var _loc5_:Vector.<BitmapData> = new Vector.<BitmapData>(param1.totalFrames,true);
         var _loc6_:Vector.<Rectangle> = new Vector.<Rectangle>(param1.totalFrames,true);
         var _loc9_:String = Dollars.smStage.quality;
         Dollars.smStage.quality = StageQuality.HIGH;
         var _loc10_:int = 0;
         while(_loc10_ < param1.totalFrames)
         {
            param1.gotoAndStop(_loc10_ + 1);
            _loc4_ = param1.getBounds(param1);
            _loc4_.x = Math.round(_loc4_.x);
            _loc4_.y = Math.round(_loc4_.y);
            _loc4_.width = Math.round(_loc4_.width);
            _loc4_.height = Math.round(_loc4_.height);
            _loc7_ = _loc4_.width;
            if(_loc7_ == 0)
            {
               _loc7_ = 1;
            }
            _loc8_ = _loc4_.height;
            if(_loc8_ == 0)
            {
               _loc8_ = 1;
            }
            _loc3_ = new BitmapData(_loc7_,_loc8_,true,16777215);
            _loc2_.identity();
            _loc2_.translate(_loc4_.x * -1,_loc4_.y * -1);
            _loc3_.draw(param1,_loc2_);
            _loc5_[_loc10_] = _loc3_;
            _loc6_[_loc10_] = _loc4_;
            _loc10_++;
         }
         Dollars.smStage.quality = _loc9_;
         return {
            "frames":_loc5_,
            "bounds":_loc6_
         };
      }
   }
}

