package com.dchoc.dollars.utils.screenshots
{
   import com.adobe.images.JPGEncoder;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Rectangle;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   
   public class Screenshot
   {
      
      private var mBitmapScreenshotCutByteArray:ByteArray = null;
      
      private var mBitmapScreenshot:BitmapData = null;
      
      public function Screenshot()
      {
         super();
      }
      
      public function getBitmapScreenshot() : BitmapData
      {
         return this.mBitmapScreenshot;
      }
      
      public function save(param1:String, param2:int = 85) : Boolean
      {
         var _loc3_:JPGEncoder = null;
         var _loc4_:ByteArray = null;
         if(!Config.OFFLINE_GAMEPLAY_MODE)
         {
            return true;
         }
         _loc3_ = new JPGEncoder(param2);
         _loc4_ = _loc3_.encode(this.mBitmapScreenshot);
         new FileReference().save(_loc4_,"shot.jpg");
         return true;
      }
      
      public function takeScreenshot(param1:DisplayObjectContainer, param2:int, param3:int, param4:int, param5:int, param6:int = 1) : void
      {
         this.mBitmapScreenshot = new BitmapData(param1.width,param1.height);
         this.mBitmapScreenshot.draw(param1);
         var _loc7_:Rectangle = new Rectangle(param2,param3,param4,param5);
         this.mBitmapScreenshotCutByteArray = this.mBitmapScreenshot.getPixels(_loc7_);
         this.mBitmapScreenshot = new BitmapData(param4,param5);
         this.mBitmapScreenshotCutByteArray.position = 0;
         this.mBitmapScreenshot.setPixels(new Rectangle(0,0,param4,param5),this.mBitmapScreenshotCutByteArray);
      }
   }
}

