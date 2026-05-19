package com.dchoc.dollars.world.items.notifications
{
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.states.StateItemObject;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Notification extends StateItemObject
   {
      
      private var mButtonSignEnd:MovieClip;
      
      private var mButtonSign:DisplayObject;
      
      public var mEffectiveMode:Boolean;
      
      public function Notification(param1:StateMachine, param2:Boolean = true)
      {
         super(param1);
         this.mEffectiveMode = param2;
         this.load();
      }
      
      private function onChangeAnim(param1:MouseEvent = null) : void
      {
         if(this.mButtonSign != null)
         {
            this.mButtonSign.removeEventListener(MouseEvent.CLICK,this.onChangeAnim);
            if(mItemObject.displayObjectL1 != null && mItemObject.displayObjectL1.contains(this.mButtonSign))
            {
               mItemObject.displayObjectL1.removeChild(this.mButtonSign);
            }
         }
         this.mButtonSignEnd.addEventListener(Event.ENTER_FRAME,this.checkEnd);
         this.mButtonSignEnd.gotoAndPlay(1);
         mItemObject.displayObjectL1.addChild(this.mButtonSignEnd);
      }
      
      private function checkEnd(param1:Event) : void
      {
         if(this.mButtonSignEnd.currentFrame == this.mButtonSignEnd.totalFrames)
         {
            this.mButtonSignEnd.removeEventListener(Event.ENTER_FRAME,this.checkEnd);
            this.onAccept();
         }
      }
      
      private function load() : void
      {
         if(this.mEffectiveMode)
         {
            this.mButtonSign = this.getButtonClass();
         }
         this.mButtonSignEnd = this.getButtonEndClass();
      }
      
      protected function onAccept(param1:MouseEvent = null) : void
      {
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return false;
      }
      
      protected function getButtonEndClass() : MovieClip
      {
         return null;
      }
      
      protected function getButtonClass() : DisplayObject
      {
         return null;
      }
      
      public function blocksState() : Boolean
      {
         return true;
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         var _loc2_:ItemDefinition = null;
         _loc2_ = mItemObject.itemDefinition;
         if(this.mEffectiveMode)
         {
            if(this.mButtonSignEnd == null)
            {
               this.mButtonSign.addEventListener(MouseEvent.CLICK,this.onAccept);
            }
            else
            {
               this.mButtonSign.addEventListener(MouseEvent.CLICK,this.onChangeAnim);
            }
            this.mButtonSign.x = _loc2_.baseWidth >> 1;
            this.mButtonSign.y = _loc2_.baseHeight >> 1;
            mItemObject.displayObjectL1.addChild(this.mButtonSign);
         }
         else if(this.mButtonSignEnd == null)
         {
            this.onAccept();
         }
         else
         {
            this.onChangeAnim();
         }
         if(this.mButtonSignEnd != null)
         {
            this.mButtonSignEnd.x = _loc2_.baseWidth >> 1;
            this.mButtonSignEnd.y = _loc2_.baseHeight >> 1;
         }
      }
      
      override public function destroy() : void
      {
         this.exit();
         if(this.mEffectiveMode)
         {
            this.mButtonSign = null;
         }
         this.mButtonSignEnd = null;
      }
      
      override public function exit() : void
      {
         if(this.mButtonSign != null)
         {
            this.mButtonSign.removeEventListener(MouseEvent.CLICK,this.onChangeAnim);
            this.mButtonSign.removeEventListener(MouseEvent.CLICK,this.onAccept);
            if(mItemObject.displayObjectL1 != null && mItemObject.displayObjectL1.contains(this.mButtonSign))
            {
               mItemObject.displayObjectL1.removeChild(this.mButtonSign);
            }
         }
         if(this.mButtonSignEnd != null)
         {
            this.mButtonSignEnd.removeEventListener(Event.ENTER_FRAME,this.checkEnd);
            if(mItemObject.displayObjectL1 != null && mItemObject.displayObjectL1.contains(this.mButtonSignEnd))
            {
               mItemObject.displayObjectL1.removeChild(this.mButtonSignEnd);
            }
         }
      }
   }
}

