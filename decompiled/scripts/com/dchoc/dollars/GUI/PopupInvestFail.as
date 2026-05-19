package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.utils.poll.PollManager;
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
   
   public class PopupInvestFail extends Popup
   {
      
      private var mLoader:Loader;
      
      private var mPhoto:Sprite;
      
      private var mFriend:FriendObject;
      
      private var mImage:Bitmap;
      
      public function PopupInvestFail()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_bad_result"))();
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         super();
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mOkButton = null;
         if(this.mImage != null)
         {
            this.mPhoto.removeChild(this.mImage);
            this.mImage = null;
         }
         mBox.removeChild(this.mPhoto);
         this.mPhoto = null;
         mBox = null;
      }
      
      public function showPopupParams(param1:FriendObject) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         super.show();
         this.mFriend = param1;
         this.mPhoto = mBox.getChildByName("photo") as Sprite;
         if(this.mFriend.getPictureURL() != null)
         {
            this.mLoader = new Loader();
            _loc2_ = new URLRequest(this.mFriend.getPictureURL());
            _loc3_ = new LoaderContext();
            this.mLoader.load(_loc2_,_loc3_);
            this.mPhoto.addChild(this.mLoader);
         }
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_INVEST_NO_SUCCESS_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo")));
         TextField(mBox.getChildByName("TextInfo")).text = TextManager.getText(TextIDs.TID_INVEST_NO_SUCCESS_TEXT);
         startShow(false);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_INVESTMENT);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
   }
}

