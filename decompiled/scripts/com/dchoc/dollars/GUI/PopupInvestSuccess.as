package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.invests.InvestDefinition;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardSingle;
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
   
   public class PopupInvestSuccess extends Popup
   {
      
      private var mLoader:Loader;
      
      private var mPhoto:Sprite;
      
      private var mThanksButton:DynamicButton = new DynamicButton(mBox.getChildByName("ThanksButton") as MovieClip);
      
      private var mFriend:FriendObject;
      
      private var mImage:Bitmap;
      
      public function PopupInvestSuccess()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_good_result"))();
         mOkButton = new DynamicButton(mBox.getChildByName("skip") as MovieClip);
         this.mThanksButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_SUCCESS_THANKS));
         super();
      }
      
      private function onThanks(param1:MouseEvent) : void
      {
         onClose(null);
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
            "type":UserDataFacade.INVEST_TYPE_THANKS,
            "fExtId":this.mFriend.extId
         });
      }
      
      public function showPopupParams(param1:FriendObject) : void
      {
         var _loc4_:URLRequest = null;
         var _loc5_:LoaderContext = null;
         var _loc6_:Sprite = null;
         super.show();
         this.mFriend = param1;
         this.mPhoto = mBox.getChildByName("photo") as Sprite;
         if(this.mFriend.getPictureURL() != null)
         {
            this.mLoader = new Loader();
            _loc4_ = new URLRequest(this.mFriend.getPictureURL());
            _loc5_ = new LoaderContext();
            this.mLoader.load(_loc4_,_loc5_);
            this.mPhoto.addChild(this.mLoader);
         }
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mThanksButton.start();
         this.mThanksButton.addEventListener(MouseEvent.CLICK,this.onThanks);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_INVEST_SUCCESS_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo")));
         TextField(mBox.getChildByName("TextInfo")).text = TextManager.getText(TextIDs.TID_INVEST_SUCCESS_TEXT);
         var _loc2_:InvestDefinition = InvestDefinitionManager.getInstance().getInvestDefinition();
         var _loc3_:RewardSingle = _loc2_.getReward() as RewardSingle;
         if(_loc3_ is RewardCoins)
         {
            TextField(mBox.getChildByName("Money")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc3_.getAmount(),0,0);
            _loc6_ = mBox.getChildByName("goldicon") as Sprite;
            _loc6_.visible = false;
         }
         startShow(false);
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
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_INVESTMENT_DONE);
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_INVESTMENT);
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mOkButton = null;
         this.mThanksButton.destroy();
         this.mThanksButton = null;
         if(this.mImage != null)
         {
            this.mPhoto.removeChild(this.mImage);
            this.mImage = null;
         }
         mBox.removeChild(this.mPhoto);
         this.mPhoto = null;
         mBox = null;
      }
   }
}

