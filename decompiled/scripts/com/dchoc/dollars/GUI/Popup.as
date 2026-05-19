package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.World;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Back;
   import com.gskinner.motion.easing.Linear;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class Popup extends EventDispatcher
   {
      
      private static var smPopupsOpen:int;
      
      public static var smIsAnyPopupOpen:Boolean;
      
      public static const EVENT_ACCEPT:String = "EventAccept";
      
      public static const EVENT_CLOSE:String = "EventClose";
      
      protected static const TWEEN_LENGHT_IN:Number = 0.35;
      
      protected static const TWEEN_LENGHT_OUT:Number = 0.2;
      
      protected static const TWEEN_MIN_SCALE:Number = 0;
      
      protected static const TWEEN_MIN_ALPHA:Number = 0.2;
      
      protected var mOkButton:DynamicButton;
      
      protected var mNeedsToUpdateOutline:Boolean;
      
      protected var mTween:GTween;
      
      protected var mScreenStatus:String;
      
      protected var mPreviousCursorID:int;
      
      protected var mOpen:Boolean;
      
      protected var mCancelButton:DynamicButton;
      
      protected var mBox:Sprite;
      
      protected var mDrawBackground:Boolean;
      
      protected var mNeedsToDealWithMap:Boolean;
      
      protected var mTextBox:TextField;
      
      protected var mAccepted:Boolean;
      
      protected var mEndPosition:Point;
      
      public var mBackground:Sprite;
      
      protected var mStartPosition:Point;
      
      public function Popup(param1:Boolean = true)
      {
         super();
         this.mDrawBackground = param1;
         if(this.mBox != null)
         {
            this.mBox.x = Dollars.smStage.stageWidth / 2;
            this.mBox.y = Dollars.smStage.stageHeight / 2;
            this.mStartPosition = new Point(this.mBox.x,this.mBox.y);
            this.mEndPosition = new Point(this.mBox.x,this.mBox.y);
         }
         Dollars.smStage.addEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
      }
      
      public function destroy() : void
      {
         Dollars.smStage.removeEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
      }
      
      public function show() : void
      {
         if(Tutorial.smTutorialEnd)
         {
            ++smPopupsOpen;
            DollarsGame.smInstance.mShowPopup = true;
         }
         var _loc1_:World = DollarsGame.getCurrentWorld();
         this.mNeedsToDealWithMap = _loc1_ != null && _loc1_.map.mouseEnabled;
         if(this.mNeedsToDealWithMap)
         {
            _loc1_.disable();
            smIsAnyPopupOpen = true;
         }
         this.drawBackground();
         this.mAccepted = false;
         this.mNeedsToUpdateOutline = true;
      }
      
      public function onAccept(param1:MouseEvent) : void
      {
         this.mAccepted = true;
         this.onClose(null);
      }
      
      public function changeCursor() : void
      {
         var _loc1_:Cursor = Dollars.getCurrentCursor();
         if(_loc1_ != null)
         {
            _loc1_.changeCursor(Cursor.CURSOR_SELECT);
         }
      }
      
      public function getForm() : Sprite
      {
         return this.mBox;
      }
      
      public function resize() : void
      {
         this.onResize(null);
      }
      
      protected function startButtons() : void
      {
      }
      
      protected function closePopup(param1:GTween) : void
      {
         this.mTween = null;
         this.close();
      }
      
      public function isOpen() : Boolean
      {
         return this.mOpen;
      }
      
      public function onClose(param1:MouseEvent = null) : void
      {
         var _loc2_:Sprite = null;
         this.endButtons();
         if(this.mNeedsToDealWithMap)
         {
            DollarsGame.getCurrentWorld().enable();
            smIsAnyPopupOpen = false;
         }
         if(this.mDrawBackground && this.mBackground != null)
         {
            _loc2_ = DollarsGame.smInstance.mPopupClip;
            _loc2_.removeChild(this.mBackground);
            this.mBackground = null;
         }
         if(this.mScreenStatus != Dollars.smStage.displayState)
         {
            this.resetStartPosition();
         }
         this.mTween = new GTween(this.mBox,Popup.TWEEN_LENGHT_OUT,{
            "scaleX":Popup.TWEEN_MIN_SCALE,
            "scaleY":Popup.TWEEN_MIN_SCALE,
            "x":this.mStartPosition.x,
            "y":this.mStartPosition.y,
            "alpha":Popup.TWEEN_MIN_ALPHA
         },{
            "ease":Linear.easeNone,
            "onComplete":this.closePopup
         });
      }
      
      protected function drawBackground() : void
      {
         var _loc1_:Sprite = null;
         if(this.mDrawBackground)
         {
            if(this.mBackground == null)
            {
               this.mBackground = new Sprite();
            }
            else
            {
               this.mBackground.graphics.clear();
            }
            this.mBackground.graphics.beginFill(0,0.2);
            this.mBackground.graphics.drawRect(0,0,Dollars.smStage.stageWidth,Dollars.smStage.stageHeight);
            this.mBackground.graphics.endFill();
            _loc1_ = DollarsGame.smInstance.mPopupClip;
            _loc1_.addChild(this.mBackground);
         }
      }
      
      public function resetStartPosition() : void
      {
         this.mStartPosition.x = this.mBox.x;
         this.mStartPosition.y = this.mBox.y;
      }
      
      protected function endButtons() : void
      {
      }
      
      public function showPopup() : void
      {
      }
      
      protected function close() : void
      {
         this.mOpen = false;
         if(this.mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         if(this.mNeedsToUpdateOutline)
         {
            DollarsGame.setItemOutlineEnabled(true);
         }
         if(Tutorial.smTutorialEnd)
         {
            --smPopupsOpen;
            if(smPopupsOpen < 0)
            {
               smPopupsOpen = 0;
            }
            DollarsGame.smInstance.mShowPopup = smPopupsOpen > 0;
         }
      }
      
      public function startPopup(param1:GTween) : void
      {
         this.startButtons();
      }
      
      protected function onResize(param1:Event) : void
      {
         if(this.mBox != null)
         {
            this.mBox.x = Dollars.smStage.stageWidth / 2;
            this.mBox.y = Dollars.smStage.stageHeight / 2;
            if(this.mEndPosition == null)
            {
               this.mEndPosition = new Point(this.mBox.x,this.mBox.y);
            }
            else
            {
               this.mEndPosition.x = this.mBox.x;
               this.mEndPosition.y = this.mBox.y;
            }
         }
      }
      
      protected function startShow(param1:Boolean = true) : void
      {
         this.mOpen = true;
         this.mScreenStatus = Dollars.smStage.displayState;
         this.mBox.scaleX = Popup.TWEEN_MIN_SCALE;
         this.mBox.scaleY = Popup.TWEEN_MIN_SCALE;
         this.mBox.alpha = Popup.TWEEN_MIN_ALPHA;
         if(this.mStartPosition == null)
         {
            this.mStartPosition = new Point(this.mBox.x,this.mBox.y);
         }
         if(param1)
         {
            this.mStartPosition.x = Dollars.smStage.mouseX;
            this.mStartPosition.y = Dollars.smStage.mouseY;
         }
         else
         {
            this.resetStartPosition();
         }
         this.mBox.x = this.mStartPosition.x;
         this.mBox.y = this.mStartPosition.y;
         DollarsGame.smInstance.mPopupClip.addChild(this.mBox);
         this.mTween = new GTween(this.mBox,Popup.TWEEN_LENGHT_IN,{
            "scaleX":1,
            "scaleY":1,
            "x":this.mEndPosition.x,
            "y":this.mEndPosition.y,
            "alpha":1
         },{
            "ease":Back.easeOut,
            "onComplete":this.startPopup
         });
         this.changeCursor();
      }
   }
}

