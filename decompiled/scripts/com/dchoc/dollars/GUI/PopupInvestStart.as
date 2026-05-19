package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.invests.InvestDefinition;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.rewards.RewardSingle;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.world.companies.Company;
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
   
   public class PopupInvestStart extends Popup
   {
      
      private var mFriendPhoto:Sprite;
      
      private var mFriend:FriendObject;
      
      private var mImage:Bitmap;
      
      private var mInvestButton:DynamicButton = new DynamicButton(mBox.getChildByName("InvestButton") as MovieClip);
      
      public function PopupInvestStart()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"popup_investment_start"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         this.mInvestButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_INVEST));
         super();
      }
      
      private function onExchange(param1:Event) : void
      {
         this.onCancelExchange(null);
         InvestManager.getInstance().investInFriend(this.mFriend);
         onAccept(null);
      }
      
      private function onCancelExchange(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
      }
      
      public function showPopupParams(param1:FriendObject) : void
      {
         var _loc6_:Loader = null;
         var _loc7_:URLRequest = null;
         var _loc8_:LoaderContext = null;
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mInvestButton.start();
         this.mInvestButton.addEventListener(MouseEvent.CLICK,this.onInvest);
         startShow(false);
         this.mFriend = param1;
         if(this.mFriend != null && this.mFriend.getPictureURL() != null)
         {
            _loc6_ = new Loader();
            _loc7_ = new URLRequest(this.mFriend.getPictureURL());
            _loc8_ = null;
            _loc8_ = new LoaderContext();
            _loc6_.load(_loc7_,_loc8_);
            this.mFriendPhoto.addChildAt(_loc6_,1);
         }
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_INVEST_POPUP1_TITLE);
         var _loc2_:Array = new Array(5);
         var _loc3_:InvestDefinition = InvestDefinitionManager.getInstance().getInvestDefinition();
         var _loc4_:RewardSingle = _loc3_.getReward() as RewardSingle;
         _loc2_[0] = this.mFriend.nameFriend;
         _loc2_[1] = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc3_.getCostDCCoins(),0,0);
         _loc2_[2] = TimerUtil.msToDays(_loc3_.getTime());
         _loc2_[3] = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc3_.target,0,0);
         _loc2_[4] = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc4_.getAmount(),0,0);
         var _loc5_:TextField = TextField(mBox.getChildByName("TextInfo"));
         TextManager.reformatTextField(_loc5_);
         _loc5_.text = TextManager.replaceParameters(TextIDs.TID_INVEST_POPUP1_TEXT,_loc2_);
         TextManager.changColors(_loc5_);
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mInvestButton.end();
         this.mInvestButton.removeEventListener(MouseEvent.CLICK,this.onInvest);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         mCancelButton.destroy();
         mCancelButton = null;
         this.mInvestButton.destroy();
         this.mInvestButton = null;
         mBox = null;
      }
      
      private function onInvest(param1:MouseEvent) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:InvestDefinition = InvestDefinitionManager.getInstance().getInvestDefinition();
         if(_loc2_.DCCoins < _loc3_.getCostDCCoins())
         {
            DollarsGame.smInstance.mPopupConfirm.startAskForHelpFBCredits(_loc3_.getCostDCCoins());
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
         }
         else
         {
            InvestManager.getInstance().investInFriend(this.mFriend);
            onAccept(param1);
         }
      }
   }
}

