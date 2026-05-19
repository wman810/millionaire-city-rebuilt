package com.dchoc.dollars.GUI.hireCrew
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Utils;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class CrewItemContent extends Sprite implements FBCreditsPurchaseInterface
   {
      
      public static const CREW_HIRED:int = 0;
      
      public static const CREW_BOUGHT:int = 1;
      
      public static const CREW_FREE:int = 2;
      
      private var mCrewIndex:int;
      
      private var mButton:DynamicButton;
      
      private var mItemObject:ItemObject;
      
      private var mPrice:int;
      
      private var mFriendName:TextField;
      
      private var mBox:Sprite;
      
      private var mFriend:FriendObject;
      
      private var mImage:DisplayObject;
      
      private var mFooter:MovieClip;
      
      private var mCaption:TextField;
      
      private var mStatus:int;
      
      public function CrewItemContent(param1:ItemObject, param2:int, param3:FriendObject, param4:int, param5:int)
      {
         var _loc7_:String = null;
         var _loc8_:MovieClip = null;
         super();
         this.mItemObject = param1;
         this.mCrewIndex = param4;
         this.mStatus = param2;
         this.mPrice = param5;
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,"crew_box"))();
         addChild(this.mBox);
         this.mCaption = this.mBox["caption"];
         this.mImage = this.mBox["avatar"];
         this.mFooter = this.mBox["footer"];
         this.mFriendName = this.mBox["friend_name"];
         TextManager.reformatTextField(this.mCaption);
         this.mCaption.text = TextManager.getText(TextIDs[CrewMechanicsManager.getInstance().getJobsTIDs(this.mItemObject.getConstructionCrewSku())[param4]]);
         TextManager.setTextScaled(this.mCaption);
         var _loc6_:MovieClip = new MovieClip();
         if(this.mStatus == CrewItemContent.CREW_HIRED)
         {
            this.setFooterText(param3.nameFriend);
            _loc6_.addChild(param3.loadImage());
         }
         else if(this.mStatus == CrewItemContent.CREW_BOUGHT)
         {
            this.setFooterText(TextManager.getText(TextIDs[CrewMechanicsManager.getInstance().getWorkerTID(this.mItemObject.getConstructionCrewSku())]));
            _loc6_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,"profesional"))();
         }
         else
         {
            this.mFriendName.visible = false;
            _loc6_.addChild(FriendsManager.silhouette());
            _loc7_ = "button_gold_icon";
            if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
            {
               _loc7_ = "button_fc_icon";
            }
            _loc8_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,_loc7_))();
            this.mFooter = Utils.swapMovieClips(this.mBox,this.mFooter,_loc8_) as MovieClip;
            this.mButton = new DynamicButton(this.mFooter);
            this.mButton.setLabel("" + this.mPrice);
            this.mButton.start();
            this.mButton.addEventListener(MouseEvent.CLICK,this.onBuyCrew);
         }
         this.mImage = Utils.swapMovieClips(this.mBox,this.mImage,_loc6_);
         this.mImage.addEventListener(MouseEvent.CLICK,this.onHireCrew);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.buyCrew(true);
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_CREW,MetricConstants.PRODUCT_CREW,"quantity: 1",null,0,this.mPrice);
         }
      }
      
      public function buyCrew(param1:Boolean) : int
      {
         if(param1)
         {
            UserDataFacade.getInstance().updateItem(this.mItemObject.sid,"buy_crew",{
               "sku":1,
               "position":"" + this.mCrewIndex
            });
         }
         this.mStatus = CrewItemContent.CREW_BOUGHT;
         this.mBox.removeChild(this.mButton.getButtonMc());
         this.mButton.removeEventListener(MouseEvent.CLICK,this.onBuyCrew);
         this.mButton.end();
         this.mButton.destroy();
         this.mButton = null;
         var _loc2_:MovieClip = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,"profesional"))();
         this.mImage = Utils.swapMovieClips(this.mBox,this.mImage,_loc2_);
         this.setFooterText(TextManager.getText(TextIDs[CrewMechanicsManager.getInstance().getWorkerTID(this.mItemObject.getConstructionCrewSku())]));
         this.mItemObject.getCrewBought().push(this.mCrewIndex);
         this.mItemObject.updateCrew();
         return this.mCrewIndex;
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mPrice,
            "orderInfo":{
               "sku":this.mItemObject.itemDefinition.sku,
               "qty":1,
               "type":FBCreditsPurchase.TYPE_BUY_CREW
            }
         };
      }
      
      public function getStatus() : int
      {
         return this.mStatus;
      }
      
      private function setFooterText(param1:String) : void
      {
         TextManager.reformatTextField(this.mFriendName);
         this.mFriendName.text = param1;
         TextManager.setTextScaled(this.mFriendName);
         this.mFriendName.visible = true;
         this.mFooter.visible = false;
      }
      
      private function onHireCrew(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_CREW_REQUEST,{"sid":this.mItemObject.sid});
      }
      
      private function onBuyCrew(param1:MouseEvent) : void
      {
         var _loc2_:Company = null;
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            if(_loc2_.DCCash < this.mPrice)
            {
               DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,this.mPrice);
            }
            else
            {
               _loc2_.DCCash -= this.mPrice;
               this.buyCrew(true);
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_CREW,MetricConstants.PRODUCT_CREW,"quantity: 1",null,0,this.mPrice);
            }
         }
      }
      
      public function destroy() : void
      {
         this.mItemObject = null;
         this.mCrewIndex = -1;
         this.mStatus = -1;
         this.mCaption = null;
         this.mFooter = null;
         this.mImage.removeEventListener(MouseEvent.CLICK,this.onHireCrew);
         this.mImage = null;
         if(this.mButton != null)
         {
            this.mButton.removeEventListener(MouseEvent.CLICK,this.onBuyCrew);
            this.mButton.end();
            this.mButton.destroy();
            this.mButton = null;
         }
         this.mFriend = null;
         this.mBox = null;
      }
   }
}

