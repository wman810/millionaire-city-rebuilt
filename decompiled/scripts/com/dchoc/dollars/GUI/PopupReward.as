package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.newsfeeds.NewsFeedViewManager;
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedsIDs;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardItem;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class PopupReward extends Popup
   {
      
      private var mImageInstance:Sprite;
      
      private var mBmp:Bitmap;
      
      private var mMissionObject:MissionObject;
      
      public function PopupReward(param1:MissionObject)
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"popup_well_done"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("Done") as MovieClip);
         mOkButton = new DynamicButton(mBox.getChildByName("ShareSuccess") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SHARE));
         var _loc2_:TextField = mBox["TextInfo"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = param1.missionDefinition.getTextTitle();
         TextManager.setTextScaled(_loc2_,false);
         var _loc3_:TextField = mBox["Caption"];
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs.TID_MISSION_COMPLETED);
         TextManager.setTextScaled(_loc3_,false);
         NewsFeedViewManager.getInstance().setupNewsFeedPrePopup(mBox,NewsFeedsIDs.SKU_MISSION_REWARD);
         this.mMissionObject = param1;
         super();
         this.showPopup();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         onClose(null);
         var _loc2_:String = this.mMissionObject.missionDefinition.getTextTitle();
         var _loc3_:String = this.mMissionObject.missionDefinition.getFeedImg();
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
            "postId":UserDataFacade.POST_GET_REWARD,
            "missionName":_loc2_,
            "feedImg":_loc3_,
            "product":MetricConstants.EVENT_FACEBOOK_FEED_MISSION_DONE
         });
      }
      
      private function loadImage(param1:String) : void
      {
         var _loc2_:Loader = new Loader();
         var _loc3_:URLRequest = new URLRequest(param1);
         var _loc4_:LoaderContext = new LoaderContext();
         _loc2_.load(_loc3_,_loc4_);
         this.mImageInstance.addChild(_loc2_);
         this.mImageInstance.visible = true;
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onShare);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         var _loc1_:Reward = this.mMissionObject.getReward();
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function get missionObject() : MissionObject
      {
         return this.mMissionObject;
      }
      
      override public function showPopup() : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:Sprite = null;
         super.show();
         this.mImageInstance = mBox.getChildByName("image") as Sprite;
         if(this.mImageInstance != null)
         {
            if(this.mBmp != null && this.mImageInstance.contains(this.mBmp))
            {
               this.mImageInstance.removeChild(this.mBmp);
               this.mBmp = null;
            }
            this.mImageInstance.visible = false;
            this.loadImage(Config.getRoot() + ModelConfig.DIR_FEEDS + this.mMissionObject.missionDefinition.getFeedImg());
         }
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onShare);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         var _loc1_:Reward = this.mMissionObject.getReward();
         var _loc2_:TextField = mBox.getChildByName("TextInfo2") as TextField;
         if(_loc1_ is RewardItem)
         {
            TextManager.reformatTextField(_loc2_);
            _loc2_.text = TextManager.getText(TextIDs.TID_MISSION_REWARD_ITEM);
            TextManager.setTextScaled(_loc2_,false);
         }
         else
         {
            mBox.removeChild(_loc2_);
         }
         _loc3_ = mBox.getChildByName("container") as Sprite;
         _loc4_ = _loc1_.draw();
         var _loc5_:Number = _loc3_.width / _loc4_.width;
         var _loc6_:Number = _loc3_.height / _loc4_.height;
         var _loc7_:Number = _loc5_ < _loc6_ ? _loc5_ : _loc6_;
         if(_loc7_ > 1)
         {
            _loc7_ = 1;
         }
         _loc4_.scaleX = _loc7_;
         _loc4_.scaleY = _loc7_;
         mBox.addChild(_loc4_);
         var _loc8_:Rectangle = _loc4_.getBounds(mBox);
         var _loc9_:Rectangle = _loc3_.getBounds(mBox);
         _loc4_.x += _loc9_.x - _loc8_.x + (_loc3_.width - _loc4_.width) / 2;
         _loc4_.y += _loc9_.y - _loc8_.y + (_loc3_.height - _loc4_.height) / 2;
         _loc3_.visible = false;
         startShow(false);
      }
   }
}

