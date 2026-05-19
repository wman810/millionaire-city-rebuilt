package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CRMCustomizerDefinition;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class PopupHelpFriend extends Popup
   {
      
      private static var smFriend:FriendObject;
      
      private var mFriendInstance:Sprite;
      
      private var mBackgroundReminder:Sprite;
      
      private var mImage:Sprite;
      
      private var mAdvisor:Sprite;
      
      private var mPhotoImage:Bitmap;
      
      private var mDef:CRMCustomizerDefinition;
      
      private var mPhotoInstance:Sprite;
      
      private var mIsVisit:Boolean;
      
      private var mSkipButton:DynamicButton;
      
      public function PopupHelpFriend(param1:CRMCustomizerDefinition)
      {
         var _loc5_:Sprite = null;
         var _loc6_:int = 0;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_reminder"))();
         this.mDef = param1;
         this.mIsVisit = this.mDef.actionButtonAction == ActionsLibrary.VISIT_FRIEND || this.mDef.actionButtonAction == ActionsLibrary.UPGRADE_FRIENDS;
         this.mFriendInstance = mBox.getChildByName("friend") as Sprite;
         this.mPhotoInstance = this.mFriendInstance.getChildByName("photo") as Sprite;
         if(this.mIsVisit)
         {
            this.loadImage();
         }
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         mCancelButton = new DynamicButton(mBox.getChildByName("skipButton") as MovieClip);
         if(this.mDef.actionButtonAction == "none")
         {
            mCancelButton.visible = false;
            mOkButton.visible = false;
         }
         this.mSkipButton = new DynamicButton(mBox.getChildByName("skipButton2") as MovieClip);
         this.mSkipButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SKIP));
         if(this.mDef.actionButtonAction != "none")
         {
            this.mSkipButton.visible = false;
         }
         this.mAdvisor = mBox.getChildByName("advisor") as Sprite;
         var _loc2_:String = "reminder_advisor1";
         var _loc3_:String = "reminder_advisor2";
         var _loc4_:String = this.mDef.advisor;
         if(_loc4_ == _loc2_ && DollarsGame.getProfile().bossGenre == Profile.BOSS_FEMALE)
         {
            _loc4_ = _loc3_;
         }
         if(_loc4_ != _loc2_ && _loc4_ != null)
         {
            _loc5_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,_loc4_))();
            _loc5_.x = this.mAdvisor.x;
            _loc5_.y = this.mAdvisor.y;
            _loc5_.scaleX = this.mAdvisor.scaleX;
            _loc5_.scaleY = this.mAdvisor.scaleY;
            _loc6_ = mBox.getChildIndex(this.mAdvisor);
            mBox.addChild(_loc5_);
            mBox.swapChildren(_loc5_,this.mAdvisor);
            mBox.removeChild(this.mAdvisor);
         }
         super();
      }
      
      public static function loadFriend() : Boolean
      {
         var _loc2_:* = undefined;
         smFriend = null;
         var _loc1_:Vector.<NeighborObject> = FriendsManager.getNeightbors();
         while(true)
         {
            _loc2_ = int(Math.random() * (_loc1_.length - 1));
            smFriend = _loc1_[_loc2_];
            if(smFriend == null)
            {
               break;
            }
            if(!smFriend.isMyself())
            {
               return smFriend != null;
            }
         }
         return false;
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mOkButton = null;
         mCancelButton.destroy();
         mCancelButton = null;
         if(this.mPhotoImage != null)
         {
            this.mPhotoInstance.removeChild(this.mPhotoImage);
            this.mPhotoImage = null;
         }
         mBox = null;
      }
      
      override public function showPopup() : void
      {
         var _loc6_:Sprite = null;
         super.show();
         drawBackground();
         mAccepted = false;
         var _loc1_:TextField = TextField(mBox.getChildByName("TextInfo_01"));
         var _loc2_:TextField = TextField(mBox.getChildByName("TextInfo_02"));
         var _loc3_:TextField = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(_loc1_);
         TextManager.reformatTextField(_loc2_);
         TextManager.reformatTextField(_loc3_);
         var _loc4_:Sprite = mBox.getChildByName("collisionbox") as Sprite;
         _loc4_.visible = false;
         if(this.mDef.helpImage != null)
         {
            this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,this.mDef.helpImage))();
            mBox.addChild(this.mImage);
            this.mImage.x = _loc4_.x;
            this.mImage.y = _loc4_.y;
         }
         if(this.mDef.background != null)
         {
            this.mBackgroundReminder = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,this.mDef.background))();
            _loc6_ = mBox.getChildByName("background") as Sprite;
            _loc6_.addChild(this.mBackgroundReminder);
         }
         if(this.mIsVisit)
         {
            if(smFriend == null)
            {
               _loc3_.text = TextManager.replaceParameters(this.mDef.title,new Array(""));
               _loc2_.text = TextManager.replaceParameters(this.mDef.text,new Array(""));
               _loc2_.y += (_loc2_.height - _loc2_.textHeight) / 2;
               _loc1_.visible = false;
            }
            else
            {
               _loc3_.text = TextManager.replaceParameters(this.mDef.title,new Array(smFriend.nameFriend));
               _loc2_.text = TextManager.replaceParameters(this.mDef.text,new Array(smFriend.nameFriend));
               _loc2_.y += (_loc2_.height - _loc2_.textHeight) / 2;
               _loc1_.visible = false;
            }
         }
         else
         {
            _loc3_.text = this.mDef.title;
            _loc1_.text = this.mDef.text;
            if(this.mDef.helpImage == null)
            {
               _loc1_.y += (_loc1_.height - _loc1_.textHeight) / 2;
            }
            _loc2_.visible = false;
            this.mFriendInstance.visible = false;
         }
         TextManager.setTextScaled(_loc3_,false);
         TextManager.setTextScaled(_loc1_,false);
         TextManager.setTextScaled(_loc2_,false);
         mOkButton.setLabel(this.mDef.actionButtonLabel);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mSkipButton.start();
         this.mSkipButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.doAction);
         startShow(false);
         var _loc5_:Object = this.mDef.crmParams[CRMCustomizerDefinition.TRACKING_ONDISPLAY];
         if(_loc5_ != null)
         {
            MyMetrics.sendMetric(_loc5_.event,_loc5_.label,null,_loc5_.product,0,0,_loc5_.group);
         }
      }
      
      private function loadImage() : void
      {
         var _loc2_:Loader = null;
         var _loc3_:URLRequest = null;
         var _loc4_:LoaderContext = null;
         var _loc1_:String = null;
         if(smFriend == null)
         {
            Debug.trace("smFriend null");
            return;
         }
         if(this.mPhotoImage != null)
         {
            this.mPhotoInstance.removeChild(this.mPhotoImage);
            this.mPhotoImage = null;
         }
         _loc1_ = smFriend.getPictureURL();
         if(_loc1_ != null)
         {
            _loc2_ = new Loader();
            _loc3_ = new URLRequest(_loc1_);
            _loc4_ = new LoaderContext();
            _loc2_.load(_loc3_,_loc4_);
            this.mPhotoInstance.addChild(_loc2_);
            this.mPhotoInstance.mouseChildren = false;
         }
      }
      
      private function doAction(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         onClose(null);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.doAction);
         if(this.mDef.actionButtonAction != "none")
         {
            if(this.mIsVisit)
            {
               _loc3_ = -1;
               if(smFriend != null)
               {
                  _loc3_ = smFriend.userId;
               }
               if(_loc3_ > -1)
               {
                  ActionsLibrary.getInstance().launchAction(this.mDef.actionButtonAction,[_loc3_,true]);
               }
            }
            else
            {
               ActionsLibrary.getInstance().launchAction(this.mDef.actionButtonAction,[this.mDef.actionButtonParams,true]);
            }
         }
         var _loc2_:Object = this.mDef.crmParams[CRMCustomizerDefinition.TRACKING_ONCLICK];
         if(_loc2_ != null)
         {
            MyMetrics.sendMetric(_loc2_.event,_loc2_.label,null,_loc2_.product,0,0,_loc2_.group);
         }
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.doAction);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
   }
}

