package com.dchoc.framework.GUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class DCGuiUtils
   {
      
      public function DCGuiUtils()
      {
         super();
      }
      
      public static function setTextAndResizeBackground(param1:Sprite, param2:String, param3:String = "Text") : void
      {
         var _loc5_:int = 0;
         var _loc6_:DisplayObjectContainer = null;
         var _loc4_:TextField = param1.getChildByName(param3) as TextField;
         if(_loc4_ != null)
         {
            _loc5_ = _loc4_.width;
            _loc4_.text = param2;
            if(_loc4_.defaultTextFormat.align == "center")
            {
               _loc4_.x += (_loc4_.width - _loc5_) / 2;
            }
            _loc4_.width = _loc4_.textWidth + 5;
            _loc6_ = param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND) as DisplayObjectContainer;
            if(_loc6_ != null)
            {
               _loc6_.width += _loc4_.width - _loc5_;
            }
         }
      }
   }
}

