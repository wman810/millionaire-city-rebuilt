package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class DynamicItem extends Sprite
   {
      
      public static const STATE_STARTING:int = 0;
      
      public static const STATE_SHOWING:int = 1;
      
      public static const STATE_FINISHING:int = 2;
      
      public static const STATE_FOCUSED:int = 3;
      
      private var mIsBeingShowed:Boolean;
      
      private var mItemCreationTime:Number;
      
      private var mScrollOffset:int = 2;
      
      private var mMaxItemCreationTime:Number = RulesFacade.getInstance().shopNewItemTimer();
      
      private var mScrollingEnabled:Boolean;
      
      private var yPos:int;
      
      private var mItem:FeaturedItemContent;
      
      private var mFinishingShowing:Boolean;
      
      private var mState:int;
      
      private var xOffset:int;
      
      private var yOffset:int;
      
      private var xPos:int;
      
      public function DynamicItem(param1:int, param2:int, param3:int, param4:int, param5:ItemDefinition)
      {
         super();
         this.scrollRect = new Rectangle(0,0,param3,param4);
         this.xPos = param1;
         this.yPos = param2;
         this.xOffset = param3;
         this.yOffset = param4;
         this.mFinishingShowing = false;
         this.mState = STATE_STARTING;
         mouseChildren = false;
         this.load(param5);
      }
      
      public function changeState(param1:int) : void
      {
         this.mState = param1;
         switch(this.mState)
         {
            case STATE_STARTING:
               break;
            case STATE_SHOWING:
               this.mItemCreationTime = this.mMaxItemCreationTime;
               break;
            case STATE_FINISHING:
               this.mFinishingShowing = true;
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         this.mItem.setUpIcon();
         switch(this.mState)
         {
            case STATE_STARTING:
               if(this.isBoundReached())
               {
                  this.changeState(STATE_SHOWING);
               }
               this.scroll();
               break;
            case STATE_SHOWING:
               if(this.mItemCreationTime > 0)
               {
                  this.mItemCreationTime = Math.max(0,this.mItemCreationTime - param1);
                  if(this.mItemCreationTime <= 0)
                  {
                     this.changeState(STATE_FINISHING);
                  }
               }
               break;
            case STATE_FINISHING:
               this.scroll();
         }
      }
      
      public function isOutOfBounds() : Boolean
      {
         return this.scrollRect.x > 2 * this.xOffset;
      }
      
      public function scroll() : void
      {
         var _loc1_:Rectangle = this.scrollRect;
         _loc1_.x += this.mScrollOffset;
         this.scrollRect = _loc1_;
      }
      
      public function setShowingStatus(param1:Boolean) : void
      {
         this.mScrollingEnabled = param1;
      }
      
      public function fixView() : void
      {
         this.scrollRect.x = this.xOffset - 5;
      }
      
      public function isFinishing() : Boolean
      {
         return this.mFinishingShowing;
      }
      
      public function load(param1:ItemDefinition) : void
      {
         this.mItem = new FeaturedItemContent(0,param1);
         this.mItem.x = this.xPos;
         this.mItem.y = this.yPos;
         this.mItemCreationTime = 0;
         DollarsGame.smInstance.mBuyBox.checkFeaturedContentState(this.mItem);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.OverFunction);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.OutFunction);
         this.addChild(this.mItem);
      }
      
      private function mDebugRectangle(param1:int, param2:int) : void
      {
         this.graphics.beginFill(65280);
         this.graphics.drawRect(param1,param2,10,10);
         this.graphics.endFill();
      }
      
      private function OutFunction(param1:MouseEvent) : void
      {
         switch(this.mState)
         {
            case STATE_SHOWING:
               this.mItemCreationTime = this.mMaxItemCreationTime;
         }
      }
      
      public function unLoad() : void
      {
         this.removeChild(this.mItem);
         this.removeEventListener(MouseEvent.MOUSE_OVER,this.OverFunction);
         this.removeEventListener(MouseEvent.MOUSE_OUT,this.OutFunction);
      }
      
      private function OverFunction(param1:MouseEvent) : void
      {
         switch(this.mState)
         {
            case STATE_SHOWING:
               this.mItemCreationTime = 0;
         }
      }
      
      public function isBoundReached() : Boolean
      {
         return this.scrollRect.x > this.xOffset - 5;
      }
   }
}

