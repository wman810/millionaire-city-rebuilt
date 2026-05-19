package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.invests.InvestObject;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
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
   
   public class PopupInvestAccept extends Popup
   {
      
      private var mPhoto:Sprite;
      
      private var mTextInfo:TextField;
      
      private var mRemind:Boolean;
      
      private var mLoader:Loader;
      
      private var mInvestor:InvestObject;
      
      private var mThanksButton:DynamicButton = new DynamicButton(mBox.getChildByName("ThanksButton") as MovieClip);
      
      private var mTitle:TextField;
      
      private var mImage:Bitmap;
      
      private var mFriend:FriendObject;
      
      private var mShare:Boolean;
      
      public function PopupInvestAccept(param1:Boolean, param2:Boolean = false, param3:InvestObject = null)
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_accept"))();
         mOkButton = new DynamicButton(mBox.getChildByName("skip") as MovieClip);
         this.mShare = param1;
         this.mRemind = param2;
         this.mInvestor = param3;
         if(this.mRemind)
         {
            this.mThanksButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_BUTTON_ASK4SPEED));
         }
         else if(this.mShare)
         {
            this.mThanksButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SHARE));
         }
         else
         {
            this.mThanksButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_OK));
         }
         super();
      }
      
      private function onThanks(param1:MouseEvent) : void
      {
         onClose(null);
         if(this.mFriend != null && this.mShare)
         {
            if(this.mRemind)
            {
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
                  "type":UserDataFacade.INVEST_TYPE_ON_FRIEND_REMINDER,
                  "fExtId":this.mFriend.extId
               });
               this.mInvestor.remind();
            }
            else if(this.mShare)
            {
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
                  "type":UserDataFacade.INVEST_TYPE_COMPLETE,
                  "fExtId":this.mFriend.extId
               });
            }
         }
      }
      
      public function showPopupParams(param1:FriendObject) : void
      {
         var _loc3_:URLRequest = null;
         var _loc4_:LoaderContext = null;
         super.show();
         this.mFriend = param1;
         this.mPhoto = mBox.getChildByName("photo") as Sprite;
         if(this.mFriend != null && this.mFriend.getPictureURL() != null)
         {
            this.mLoader = new Loader();
            _loc3_ = new URLRequest(this.mFriend.getPictureURL());
            _loc4_ = new LoaderContext();
            this.mLoader.load(_loc3_,_loc4_);
            this.mPhoto.addChild(this.mLoader);
         }
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_INVEST_POPUP1_TITLE);
         var _loc2_:Array = new Array(3);
         _loc2_[0] = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(InvestDefinitionManager.getInstance().getInvestDefinition().target,0,0);
         _loc2_[1] = String(TimerUtil.msToDays(InvestDefinitionManager.getInstance().getInvestDefinition().getTime()));
         this.mTextInfo = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(this.mTextInfo);
         this.mTextInfo.text = TextManager.replaceParameters(TextIDs.TID_INVEST_NEWUSER1,_loc2_);
         startShow(false);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mThanksButton.start();
         this.mThanksButton.addEventListener(MouseEvent.CLICK,this.onThanks);
      }
      
      public function setTitle(param1:String) : void
      {
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = param1;
         TextManager.setTextScaled(this.mTitle);
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mThanksButton.end();
         this.mThanksButton.removeEventListener(MouseEvent.CLICK,this.onThanks);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mOkButton = null;
         this.mThanksButton.destroy();
         this.mThanksButton = null;
         if(this.mImage != null && this.mPhoto != null)
         {
            this.mPhoto.removeChild(this.mImage);
            this.mImage = null;
         }
         mBox.removeChild(this.mPhoto);
         this.mPhoto = null;
         mBox = null;
      }
      
      public function setTextInfo(param1:String) : void
      {
         TextManager.reformatTextField(this.mTextInfo);
         this.mTextInfo.text = param1;
         TextManager.changColors(this.mTextInfo);
         TextManager.setTextScaled(this.mTextInfo);
      }
   }
}

