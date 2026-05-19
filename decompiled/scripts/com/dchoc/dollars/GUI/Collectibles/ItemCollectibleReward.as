package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoCommerce;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoDeco;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoHouse;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoWonder;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinition;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinitionManager;
   import com.dchoc.dollars.collectibles.CollectibleGroupDefinition;
   import com.dchoc.dollars.collectibles.CollectibleGroupDefinitionManager;
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ItemCollectibleReward extends Sprite
   {
      
      public static const TYPE_INSTANT:int = 0;
      
      public static const TYPE_PLACE:int = 1;
      
      private var mType:int;
      
      private var mExperienceTextField:TextField;
      
      private var mDef:ItemDefinition;
      
      protected var mBox:Sprite;
      
      private var mClaimButton:DynamicButton;
      
      private var mIsMouseOver:Boolean;
      
      private var mId:int;
      
      protected var mTitle:TextField;
      
      private var mCashTextField:TextField;
      
      private var mImage:MovieClip;
      
      private var mCollectibleGroup:CollectibleGroupObject;
      
      private var mTextCompleted:MovieClip;
      
      private var mInfo:InfoBox;
      
      private var mPopupFeed:PopupPartner;
      
      public function ItemCollectibleReward(param1:Sprite, param2:CollectibleGroupObject, param3:int)
      {
         super();
         this.mCollectibleGroup = param2;
         this.mBox = param1;
         this.mType = TYPE_INSTANT;
         this.mId = param3;
         this.load();
      }
      
      private function showInfoBox(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!this.mIsMouseOver)
         {
            _loc2_ = this.mBox.x + this.mBox.width / 2 + Dollars.smStage.stageWidth / 2 - 240;
            _loc4_ = Dollars.smStage.stageHeight / 2 + this.mId % 2 * this.mBox.height;
            _loc5_ = Dollars.smStage.stageHeight / 2 + (this.mId + 1) % 2 * this.mBox.height;
            if(Math.abs(mouseY - _loc4_) < Math.abs(mouseY - _loc5_))
            {
               _loc3_ = _loc4_;
            }
            else
            {
               _loc3_ = _loc5_;
            }
            this.mInfo.show(this.mDef,_loc2_,_loc3_,this.mBox.width - 20);
            this.mInfo.setIncome(this.mDef.getIncomeValue());
            this.mInfo.setTimer(null,this.mDef.getIncomeTime());
            this.mIsMouseOver = true;
         }
      }
      
      public function destroy() : void
      {
         this.mTitle = null;
         this.mClaimButton.destroy();
      }
      
      public function changeType(param1:int) : void
      {
         this.mType = param1;
      }
      
      public function start() : void
      {
         this.mClaimButton.start();
         switch(this.mCollectibleGroup.getState())
         {
            case CollectibleGroupObject.STATE_PENDING_TO_GET_REWARD:
               this.mClaimButton.addEventListener(MouseEvent.CLICK,this.onClaimReward);
               break;
            case CollectibleGroupObject.STATE_INCOMPLETED:
               this.mClaimButton.disable();
               break;
            case CollectibleGroupObject.STATE_COMPLETED:
               this.mClaimButton.visible = false;
               break;
            case CollectibleGroupObject.STATE_LOCKED:
               this.mClaimButton.visible = false;
         }
      }
      
      private function onClaimReward(param1:MouseEvent) : void
      {
         PopupCollectibleManager.getInstance().claimReward(this.mCollectibleGroup);
      }
      
      public function end() : void
      {
         this.mClaimButton.end();
         switch(this.mCollectibleGroup.getState())
         {
            case CollectibleGroupObject.STATE_PENDING_TO_GET_REWARD:
               this.mClaimButton.removeEventListener(MouseEvent.CLICK,this.onClaimReward);
         }
         if(this.mImage != null)
         {
            this.mImage.removeEventListener(MouseEvent.MOUSE_OVER,this.showInfoBox);
            this.mImage.removeEventListener(MouseEvent.MOUSE_OUT,this.closeInfoBox);
         }
      }
      
      private function closeInfoBox(param1:MouseEvent) : void
      {
         if(this.mIsMouseOver)
         {
            this.mInfo.close();
            this.mIsMouseOver = false;
         }
      }
      
      private function load() : void
      {
         var _loc6_:DollarsGame = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:CollectibleGroupDefinition = null;
         var _loc13_:CollectibleRewardDefinition = null;
         var _loc14_:TextField = null;
         var _loc15_:ShopTabDefinition = null;
         var _loc1_:CollectibleRewardDefinition = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku) as CollectibleRewardDefinition;
         var _loc2_:MovieClip = this.mBox.getChildByName("gift") as MovieClip;
         var _loc3_:MovieClip = this.mBox.getChildByName("mark") as MovieClip;
         this.mTitle = this.mBox.getChildByName("mTitle") as TextField;
         TextManager.reformatTextField(this.mTitle);
         if(_loc1_.rewardType == CollectibleRewardDefinition.TYPE_ITEM)
         {
            this.mDef = ItemDefinitionManager.getInstance().getDefinitionBySku(_loc1_.sku) as ItemDefinition;
            this.mTitle.text = TextManager.getText(TextIDs[this.mDef.textID]);
            this.loadIcon();
            _loc6_ = DollarsGame.smInstance;
            switch(this.mDef.type)
            {
               case ItemDefinition.TYPE_HOUSES_ID:
                  this.mInfo = new ShopMenuInfoHouse(_loc6_.mPopupClip,this.mDef);
                  break;
               case ItemDefinition.TYPE_COMMERCES_ID:
                  this.mInfo = new ShopMenuInfoCommerce(_loc6_.mPopupClip,this.mDef);
                  break;
               case ItemDefinition.TYPE_DECORATIONS_ID:
                  this.mInfo = new ShopMenuInfoDeco(_loc6_.mPopupClip,this.mDef);
                  break;
               case ItemDefinition.TYPE_WONDERS_ID:
                  this.mInfo = new ShopMenuInfoWonder(_loc6_.mPopupClip,this.mDef);
            }
            this.mIsMouseOver = false;
         }
         else
         {
            this.mTitle.text = TextManager.getText(TextIDs[_loc1_.textID]);
            this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku))();
            this.scaleImage();
            if(_loc1_.rewardType == CollectibleRewardDefinition.TYPE_SET)
            {
               _loc7_ = _loc1_.Value.split(":");
               _loc8_ = _loc7_[0];
               _loc9_ = _loc7_[1];
               _loc10_ = _loc7_[2];
               this.mExperienceTextField = this.mImage.getChildByName("experience") as TextField;
               TextManager.reformatTextField(this.mExperienceTextField);
               this.mExperienceTextField.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_REWARD_EXP,new Array(_loc10_));
               TextManager.setTextScaled(this.mExperienceTextField);
               this.mCashTextField = this.mImage.getChildByName("Cash") as TextField;
               TextManager.reformatTextField(this.mCashTextField);
               this.mCashTextField.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_REWARD_CASH,new Array(_loc9_));
               TextManager.setTextScaled(this.mCashTextField);
            }
            this.mBox.addChild(this.mImage);
         }
         this.mTextCompleted = this.mBox.getChildByName("collection_complete") as MovieClip;
         this.mBox.removeChild(this.mTextCompleted);
         this.mTextCompleted.visible = false;
         var _loc4_:MovieClip = this.mBox.getChildByName("Lock") as MovieClip;
         var _loc5_:TextField = _loc4_.getChildByName("LockedText") as TextField;
         TextManager.reformatTextField(_loc5_);
         switch(this.mCollectibleGroup.getState())
         {
            case CollectibleGroupObject.STATE_INCOMPLETED:
               if(this.mImage != null)
               {
                  this.mImage.alpha = 0.5;
               }
               _loc4_.visible = false;
               break;
            case CollectibleGroupObject.STATE_LOCKED:
               _loc11_ = this.mCollectibleGroup.getCollectibleGroupDefinition().requirements;
               _loc12_ = CollectibleGroupDefinitionManager.getInstance().getDefinitionBySku(_loc11_) as CollectibleGroupDefinition;
               _loc13_ = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(_loc12_.rewardSku) as CollectibleRewardDefinition;
               _loc5_.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_REQUIRED_UNLOCK,new Array(TextManager.getText(TextIDs[_loc13_.textID])));
               if(this.mImage != null)
               {
                  this.mImage.alpha = 0.5;
               }
               break;
            case CollectibleGroupObject.STATE_COMPLETED:
               this.mTextCompleted.visible = true;
            case CollectibleGroupObject.STATE_PENDING_TO_GET_REWARD:
               _loc4_.visible = false;
         }
         _loc2_.visible = false;
         _loc3_.visible = false;
         if(this.mTextCompleted.visible)
         {
            this.mBox.addChild(this.mTextCompleted);
            _loc14_ = this.mTextCompleted.getChildByName("collection_completed_text") as TextField;
            TextManager.reformatTextField(_loc14_);
            _loc14_.text = TextManager.getText(TextIDs.COLLECTION_COMPLETED);
            TextManager.setTextScaled(_loc14_);
         }
         (this.mBox as MovieClip).stop();
         this.mClaimButton = new DynamicButton(this.mBox.getChildByName("claim") as MovieClip);
         if(this.mCollectibleGroup.getCollectibleGroupDefinition().IsCommerceGroup())
         {
            this.mClaimButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_COLLECTION_COMPLETED_TRADE_BUTTON));
         }
         else
         {
            this.mClaimButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_COLLECTION_COMPLETED_BUTTON));
         }
         this.mBox.addChild(_loc4_);
         this.mBox.addChild(this.mClaimButton.getButtonMc());
         TextManager.setTextScaled(this.mTitle);
         TextManager.setTextScaled(_loc5_);
         if(this.mCollectibleGroup.getCollectibleGroupDefinition().icon != null)
         {
            _loc15_ = ShopTabDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().icon) as ShopTabDefinition;
            this.mBox.addChild(_loc15_.getIconOnItemShopDO());
         }
      }
      
      private function scaleImage() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = this.mBox.getChildByName("mark") as MovieClip;
         var _loc2_:Number = (_loc1_.height - 10) / this.mImage.height;
         var _loc3_:Number = (_loc1_.width - 10) / this.mImage.width;
         var _loc4_:Number = _loc2_ > _loc3_ ? _loc3_ : _loc2_;
         if(_loc4_ >= 1)
         {
            _loc4_ = 1;
         }
         this.mImage.scaleX = _loc4_;
         this.mImage.scaleY = _loc4_;
         this.mImage.x = _loc1_.x;
         this.mImage.y = _loc1_.y;
      }
      
      public function loadIcon() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.mImage == null)
         {
            if(this.mDef.isResourceLoaded())
            {
               _loc1_ = this.mBox.getChildByName("mark") as MovieClip;
               this.mImage = this.mDef.getDisplayObject("normal") as MovieClip;
               this.mImage.stop();
               _loc2_ = (_loc1_.height - 10) / this.mImage.height;
               _loc3_ = (_loc1_.width - 10) / this.mImage.width;
               _loc4_ = _loc2_ > _loc3_ ? _loc3_ : _loc2_;
               if(_loc4_ >= 1)
               {
                  _loc4_ = 1;
               }
               this.mImage.scaleX = _loc4_;
               this.mImage.scaleY = _loc4_;
               this.mImage.x = (this.mBox.width - this.mDef.baseWidth * _loc4_) / 2 - 5;
               this.mImage.y = (this.mBox.height + this.mImage.height) / 2;
               this.mBox.addChild(this.mImage);
               this.mImage.addEventListener(MouseEvent.MOUSE_OVER,this.showInfoBox);
               this.mImage.addEventListener(MouseEvent.MOUSE_OUT,this.closeInfoBox);
               switch(this.mCollectibleGroup.getState())
               {
                  case CollectibleGroupObject.STATE_INCOMPLETED:
                  case CollectibleGroupObject.STATE_LOCKED:
                     this.mImage.alpha = 0.5;
               }
            }
         }
      }
   }
}

