package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupMission;
   import com.dchoc.dollars.GUI.PopupReward;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class MissionsBox extends Popup
   {
      
      public static const SKU:String = "missions";
      
      private var mReward:PopupReward;
      
      private var mBoxWidth:int;
      
      private var mScrollOffset:int = 15;
      
      private var mDescription:PopupMission;
      
      private var mItems:Array;
      
      private var mMaxScrolls:int;
      
      private var mArrowUp:DynamicButton;
      
      private var mScrollingEnabled:Boolean;
      
      private const XINIT:Number = -194.4;
      
      private const YINIT:Number = -109.3;
      
      private const XOFFSET:Number = 20;
      
      private const YOFFSET:Number = 57;
      
      private var mScrollRect:Sprite;
      
      private var mNumScrolls:int;
      
      private var mDestinyPosition:int = 0;
      
      private var mArrowDown:DynamicButton;
      
      private var mLaunchEmailMessage:Boolean;
      
      private var mCurrentItem:int;
      
      public function MissionsBox()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_missions_background_menu"))();
         super();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mArrowUp = new DynamicButton(mBox.getChildByName("mArrowUp") as MovieClip);
         this.mArrowDown = new DynamicButton(mBox.getChildByName("mArrowDown") as MovieClip);
         this.mScrollRect = new Sprite();
         mBox.addChild(this.mScrollRect);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Missions")));
         TextField(mBox.getChildByName("Missions")).text = TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_MISSIONS);
         TextManager.setTextScaled(TextField(mBox.getChildByName("Missions")));
         this.mBoxWidth = mBox.width;
         this.mScrollingEnabled = true;
         this.showPopup();
         changeCursor();
      }
      
      public function searchMission(param1:String, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Rectangle = null;
         var _loc6_:MissionItem = null;
         var _loc3_:MissionObject = MissionObjectManager.getInstance().getMissionBySku(param1);
         if(_loc3_ != null)
         {
            _loc4_ = MissionObjectManager.getInstance().getMissions().indexOf(_loc3_);
            if(_loc4_ > -1)
            {
               _loc5_ = this.mScrollRect.scrollRect;
               _loc5_.y += int(_loc4_ / 4) * this.YOFFSET * 4;
               this.mScrollRect.scrollRect = _loc5_;
               this.mNumScrolls += int(_loc4_ / 4);
               if(param2)
               {
                  _loc6_ = this.mItems[_loc4_];
                  if(_loc6_ != null)
                  {
                     _loc6_.dispatchEvent(new Event(MissionItem.EVENT_SHOW_DESCRIPTION));
                  }
               }
            }
         }
      }
      
      private function showDescription(param1:Event) : void
      {
         var _loc2_:MissionItem = param1.target as MissionItem;
         var _loc3_:MissionObject = _loc2_.missionObject;
         MissionObjectManager.getInstance().openDescription(_loc3_);
         if(_loc3_.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_INFORMATIVE)
         {
            _loc3_.changeState(MissionObject.STATE_REACHED);
            this.getItems();
         }
         _loc2_.setAlertVisible(false);
      }
      
      override protected function close() : void
      {
         super.close();
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         DollarsGame.getCurrentWorld().map.enable();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         _loc1_.mPopupClip.removeChild(mBox);
         this.mArrowUp.end();
         this.mArrowDown.end();
         this.mArrowUp.removeEventListener(MouseEvent.CLICK,this.scrollDown);
         this.mArrowDown.removeEventListener(MouseEvent.CLICK,this.scrollUp);
         dispatchEvent(new Event(Popup.EVENT_CLOSE));
         this.removeItems();
         DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
         if(this.mLaunchEmailMessage)
         {
            _loc1_.mPopupMsgSmall.showPopupParams(TextManager.getText(TextIDs.TID_MISSION64_EMAIL_ADVICE));
         }
      }
      
      private function removeItems() : void
      {
         var _loc1_:int = 0;
         if(this.mItems != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mItems.length)
            {
               this.mScrollRect.removeChild(this.mItems[_loc1_]);
               MissionItem(this.mItems[_loc1_]).destroy();
               this.mItems[_loc1_] = null;
               _loc1_++;
            }
            this.mItems = null;
         }
      }
      
      private function getItems(param1:Array = null) : void
      {
         var _loc2_:int = 0;
         var _loc4_:MissionItem = null;
         this.removeItems();
         if(param1 == null)
         {
            param1 = MissionObjectManager.getInstance().getMissions();
         }
         if(param1.length == 0)
         {
            onClose(null);
            return;
         }
         this.mItems = new Array();
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT - 5,this.mBoxWidth,this.YOFFSET * 4);
         var _loc3_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            param1[_loc2_].removeFlagNew();
            _loc4_ = new MissionItem(param1[_loc2_],_loc3_ + MissionObjectManager.getInstance().getMissionsGivenCount() + 1);
            _loc4_.x = this.XINIT + this.XOFFSET;
            _loc4_.y = this.YINIT + _loc2_ * this.YOFFSET;
            this.mScrollRect.addChild(_loc4_);
            if(_loc4_.state == MissionObject.STATE_UNLOCKED)
            {
               _loc4_.addEventListener(MissionItem.EVENT_SHOW_DESCRIPTION,this.showDescription);
               _loc3_++;
            }
            else if(_loc4_.state == MissionObject.STATE_REACHED)
            {
               _loc4_.addEventListener(MissionItem.EVENT_REWARD,this.applyReward);
            }
            this.mItems.push(_loc4_);
            _loc2_++;
         }
         this.mScrollRect.x = this.XINIT - this.XOFFSET;
         this.mScrollRect.y = this.YINIT - 5;
         this.mNumScrolls = 1;
         this.mMaxScrolls = this.mItems.length / 4;
         if(this.mItems.length % 4 > 0)
         {
            ++this.mMaxScrolls;
         }
         this.mArrowUp.disable();
         this.mArrowDown.disable();
         if(this.mNumScrolls < this.mMaxScrolls)
         {
            this.mArrowDown.enable();
         }
      }
      
      private function scrollUp(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls < this.mMaxScrolls && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            this.mDestinyPosition = _loc2_.y + 4 * this.YOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
         }
      }
      
      private function scrollDownEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y -= this.mScrollOffset;
         if(_loc2_.y <= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
            --this.mNumScrolls;
            if(this.mNumScrolls == 1)
            {
               this.mArrowUp.disable();
            }
            if(this.mNumScrolls == this.mMaxScrolls - 1)
            {
               this.mArrowDown.enable();
            }
            this.mScrollingEnabled = true;
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function scrollDown(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = null;
         if(this.mNumScrolls > 1 && this.mScrollingEnabled)
         {
            _loc2_ = this.mScrollRect.scrollRect;
            this.mDestinyPosition = _loc2_.y - 4 * this.YOFFSET;
            this.mScrollingEnabled = false;
            mBox.addEventListener(Event.ENTER_FRAME,this.scrollDownEvent);
         }
      }
      
      override public function showPopup() : void
      {
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         var _loc2_:Array = MissionObjectManager.getInstance().getMissions();
         if(_loc2_.length == 0)
         {
            _loc1_.mPopupMsgSmall.showPopupParams(TextManager.getText(TextIDs.TID_MORE_MISSIONS_SOON));
         }
         else
         {
            super.show();
            DollarsGame.getCurrentWorld().map.disable();
            mCancelButton.start();
            mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
            _loc1_.mPopupClip.addChild(mBox);
            this.mArrowUp.start();
            this.mArrowDown.start();
            this.mArrowUp.addEventListener(MouseEvent.CLICK,this.scrollDown);
            this.mArrowDown.addEventListener(MouseEvent.CLICK,this.scrollUp);
            this.getItems(_loc2_);
            startShow();
         }
         this.mLaunchEmailMessage = false;
      }
      
      private function scrollUpEvent(param1:Event) : void
      {
         var _loc2_:Rectangle = this.mScrollRect.scrollRect;
         _loc2_.y += this.mScrollOffset;
         if(_loc2_.y >= this.mDestinyPosition)
         {
            _loc2_.y = this.mDestinyPosition;
            mBox.removeEventListener(Event.ENTER_FRAME,this.scrollUpEvent);
            ++this.mNumScrolls;
            if(this.mNumScrolls == this.mMaxScrolls)
            {
               this.mArrowDown.disable();
            }
            if(this.mNumScrolls > 1)
            {
               this.mArrowUp.enable();
            }
            this.mScrollingEnabled = true;
         }
         this.mScrollRect.scrollRect = _loc2_;
      }
      
      private function restructBox(param1:Event) : void
      {
         var _loc2_:MissionObject = this.mReward.missionObject;
         this.mReward.removeEventListener(Popup.EVENT_CLOSE,this.restructBox);
         this.mReward = null;
         this.getItems();
      }
      
      private function applyReward(param1:Event) : void
      {
         var _loc2_:MissionItem = param1.target as MissionItem;
         _loc2_.missionObject.applyReward();
         this.mReward = new PopupReward(_loc2_.missionObject);
         this.mReward.addEventListener(Popup.EVENT_CLOSE,this.restructBox);
      }
   }
}

