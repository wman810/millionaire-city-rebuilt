package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class NewsPaper extends Popup
   {
      
      public static const SKU:String = "NewsPaper";
      
      public static const MAGAZINE_SKU:String = "Magazine";
      
      private var mNews:MovieClip;
      
      private var mUserName:String;
      
      private var mJournal:PopupJournal;
      
      private var mPhotoImage:DisplayObject;
      
      private var mMyPhoto:Sprite;
      
      private var mType:int;
      
      public function NewsPaper(param1:int)
      {
         var _loc3_:Loader = null;
         var _loc4_:URLRequest = null;
         var _loc5_:LoaderContext = null;
         this.mType = param1;
         if(this.mType == PopupJournal.TYPE_NEWS)
         {
            this.mNews = new (DCResourceManager.getInstance().getSWFClass(SKU,"newspaper"))();
         }
         else
         {
            this.mNews = new (DCResourceManager.getInstance().getSWFClass(MAGAZINE_SKU,"newspaper"))();
         }
         this.mJournal = new PopupJournal(this.mType);
         this.mNews.stop();
         this.mUserName = UserDataFacade.getInstance().mUserName;
         if(this.mPhotoImage != null)
         {
            this.mMyPhoto.removeChild(this.mPhotoImage);
            this.mPhotoImage = null;
         }
         var _loc2_:String = FriendsManager.mNeighborMyself.getPictureURL();
         if(_loc2_ != null)
         {
            _loc3_ = new Loader();
            _loc4_ = new URLRequest(_loc2_);
            _loc5_ = new LoaderContext();
            _loc3_.load(_loc4_,_loc5_);
            this.mPhotoImage = _loc3_;
         }
         this.resize();
         super(false);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mJournal.destroy();
         this.mJournal = null;
         this.mNews = null;
      }
      
      public function start() : void
      {
         mPreviousCursorID = Dollars.getCurrentCursor().mCurrentCursorID;
         super.show();
         DollarsGame.smInstance.mPopupClip.addChild(this.mNews);
         this.mNews.gotoAndPlay(1);
         this.mNews.addEventListener(Event.ENTER_FRAME,this.updateAnim);
         var _loc1_:String = MetricConstants.EVENT_FACEBOOK_FEED_MILLION;
         if(this.mType == PopupJournal.TYPE_NEWS)
         {
            _loc1_ = MetricConstants.EVENT_FACEBOOK_FEED_JOURNAL;
         }
         MyMetrics.sendMetricNG(MetricConstants.EVENT_POPUP,MetricConstants.LABEL_FB_SHOWN,_loc1_);
      }
      
      private function closeNews(param1:Event) : void
      {
         this.mJournal.removeEventListener(EVENT_CLOSE,this.closeNews);
         this.mNews.addEventListener(Event.ENTER_FRAME,this.goBack);
         this.mNews.gotoAndStop(20);
      }
      
      private function goBack(param1:Event) : void
      {
         this.mNews.prevFrame();
         if(this.mNews.currentFrame == 1)
         {
            this.mNews.removeEventListener(Event.ENTER_FRAME,this.goBack);
            if(mNeedsToDealWithMap)
            {
               DollarsGame.getCurrentWorld().enable();
               smIsAnyPopupOpen = false;
            }
            super.close();
            DollarsGame.smInstance.mPopupClip.removeChild(this.mNews);
            dispatchEvent(new Event(EVENT_CLOSE));
            Dollars.getCurrentCursor().changeCursor(mPreviousCursorID);
         }
      }
      
      private function updateAnim(param1:Event) : void
      {
         var _loc2_:Sprite = this.mNews.getChildAt(0) as Sprite;
         if(this.mPhotoImage != null)
         {
            this.mMyPhoto = _loc2_.getChildByName("foto") as Sprite;
            this.mMyPhoto.addChild(this.mPhotoImage);
            this.mMyPhoto.mouseChildren = false;
         }
         if(this.mType == PopupJournal.TYPE_NEWS)
         {
            TextManager.reformatTextField(TextField(_loc2_.getChildByName("text")));
            TextField(_loc2_.getChildByName("text")).text = this.mUserName;
         }
         if(this.mNews.currentFrame == this.mNews.totalFrames - 15)
         {
            this.mJournal.showPopup();
            DollarsGame.smInstance.mPopupClip.setChildIndex(this.mJournal.mBackground,0);
            DollarsGame.smInstance.mPopupClip.setChildIndex(this.mJournal.getForm(),1);
            DollarsGame.smInstance.mPopupClip.setChildIndex(this.mNews,2);
         }
         if(this.mNews.currentFrame == this.mNews.totalFrames)
         {
            this.mNews.stop();
            this.mNews.removeEventListener(Event.ENTER_FRAME,this.updateAnim);
            this.mJournal.addEventListener(Popup.EVENT_CLOSE,this.closeNews);
            this.mJournal.activateButtons();
         }
      }
      
      override public function resize() : void
      {
         this.mNews.x = Dollars.smStage.stageWidth >> 1;
         this.mNews.y = Dollars.smStage.stageHeight >> 1;
      }
   }
}

