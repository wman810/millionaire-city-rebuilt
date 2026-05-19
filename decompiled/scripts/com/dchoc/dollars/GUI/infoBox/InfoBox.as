package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Back;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class InfoBox extends Sprite
   {
      
      protected static const TWEEN_IN_LENGHT:Number = 0.35;
      
      protected static const TWEEN_OUT_LENGHT:Number = 0.25;
      
      protected static const TWEEN_MIN_SCALE_X:Number = 0.2;
      
      protected static const TWEEN_MIN_SCALE_Y:Number = 0.2;
      
      protected static const TWEEN_MIN_ALPHA:Number = 0;
      
      protected static var smResLoaded:Boolean = false;
      
      protected var mBoxLeft:Sprite;
      
      protected var mVisible:Boolean;
      
      protected var mItemDefinition:ItemDefinition;
      
      protected var mBox:Sprite;
      
      protected var mBoxLeftIcon01:Sprite;
      
      protected var mBoxLeftIcon02:Sprite;
      
      protected var mBoxRight:Sprite;
      
      protected var mParent:DisplayObjectContainer;
      
      protected var mBoxRightIcon01:Sprite;
      
      protected var mBoxRightIcon02:Sprite;
      
      protected var mTween:GTween;
      
      public function InfoBox(param1:DisplayObjectContainer)
      {
         super();
         this.setUpBox(this.mBoxLeft);
         this.setUpBox(this.mBoxRight);
         this.mBox = this.mBoxRight;
         addChild(this.mBox);
         this.mParent = param1;
      }
      
      public function setCustomText(param1:String, param2:String) : void
      {
      }
      
      public function setItemDefinition(param1:ItemDefinition) : void
      {
         this.mItemDefinition = param1;
      }
      
      public function setTimer(param1:ItemObject, param2:Number) : void
      {
      }
      
      public function getItemDefinition() : ItemDefinition
      {
         return this.mItemDefinition;
      }
      
      public function updateInfo(param1:Sprite) : void
      {
      }
      
      protected function zoomIn(param1:Event) : void
      {
      }
      
      public function closeTween(param1:GTween) : void
      {
         if(this.mParent.contains(this))
         {
            this.mParent.removeChild(this);
            this.setItemDefinition(null);
         }
         this.mVisible = false;
         this.mTween = null;
      }
      
      public function setExp(param1:int) : void
      {
      }
      
      public function setAttendance(param1:int) : void
      {
      }
      
      public function isVisible() : Boolean
      {
         return this.mVisible;
      }
      
      public function setIncome(param1:int) : void
      {
      }
      
      protected function setUpBox(param1:Sprite) : void
      {
      }
      
      public function destroy() : void
      {
         this.mBoxLeft = null;
         this.mBoxRight = null;
         this.mBox = null;
         this.mBoxLeftIcon01 = null;
         this.mBoxLeftIcon02 = null;
         this.mBoxRightIcon01 = null;
         this.mBoxRightIcon02 = null;
      }
      
      public function show(param1:ItemDefinition, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:Point = null;
         this.setItemDefinition(param1);
         if(this.mBoxLeft != null && this.mBoxRight != null)
         {
            y = param3;
            x = param2;
            _loc5_ = this.mParent.localToGlobal(new Point(param2,param3));
            if(_loc5_.x + this.mBoxRight.width > Dollars.smStage.stageWidth)
            {
               this.updateInfo(this.mBoxLeft);
               x = param2 - param4;
            }
            else
            {
               this.updateInfo(this.mBoxRight);
            }
            this.mParent.addChild(this);
            this.mBox.scaleX = InfoBox.TWEEN_MIN_SCALE_X;
            this.mBox.scaleY = InfoBox.TWEEN_MIN_SCALE_Y;
            this.mBox.alpha = InfoBox.TWEEN_MIN_ALPHA;
            this.mTween = new GTween(this.mBox,InfoBox.TWEEN_IN_LENGHT,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },{"ease":Back.easeOut});
            this.mVisible = true;
         }
      }
      
      public function close() : void
      {
         this.mTween = new GTween(this.mBox,InfoBox.TWEEN_OUT_LENGHT,{
            "scaleX":InfoBox.TWEEN_MIN_SCALE_X,
            "scaleY":InfoBox.TWEEN_MIN_SCALE_Y,
            "alpha":InfoBox.TWEEN_MIN_ALPHA
         },{
            "ease":Back.easeOut,
            "onComplete":this.closeTween
         });
      }
   }
}

