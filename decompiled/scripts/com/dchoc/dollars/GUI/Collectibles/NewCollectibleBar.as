package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleDefinitionManager;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class NewCollectibleBar extends Sprite
   {
      
      private const mMaxTimer:int = 2000;
      
      private var mBar:Sprite;
      
      private var mTimer:int;
      
      private var mCollectibleTextInfo:TextField;
      
      private const mElapsed:int = 1000;
      
      private var mSetIntervalId:int;
      
      private var mRewardTextInfo:TextField;
      
      private var mCollectibleImage:Sprite;
      
      private var mRewardImage:Sprite;
      
      public function NewCollectibleBar(param1:String)
      {
         var _loc2_:Sprite = null;
         var _loc3_:String = null;
         var _loc4_:Sprite = null;
         super();
         this.mBar = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"button_gifts"))();
         addChild(this.mBar);
         _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,param1))();
         this.mCollectibleImage = this.mBar.getChildByName("giftimage") as Sprite;
         _loc2_.x = this.mCollectibleImage.x;
         _loc2_.y = this.mCollectibleImage.y;
         this.mBar.removeChild(this.mCollectibleImage);
         this.mBar.addChild(_loc2_);
         this.mRewardImage = this.mBar.getChildByName("rewardimage") as Sprite;
         _loc3_ = CollectibleManager.getInstance().getGroupBySku(param1).getCollectibleGroupDefinition().rewardSku;
         _loc4_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,_loc3_))();
         _loc4_.x = this.mRewardImage.x;
         _loc4_.y = this.mRewardImage.y;
         this.mBar.removeChild(this.mRewardImage);
         this.mBar.addChild(_loc4_);
         var _loc5_:CollectibleDefinition = CollectibleDefinitionManager.getInstance().getDefinitionBySku(param1) as CollectibleDefinition;
         var _loc6_:CollectibleRewardDefinition = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(_loc3_) as CollectibleRewardDefinition;
         this.mCollectibleTextInfo = this.mBar.getChildByName("gift_itemtxt") as TextField;
         TextManager.reformatTextField(this.mCollectibleTextInfo);
         this.mCollectibleTextInfo.text = TextManager.getText(TextIDs[_loc5_.textID]);
         TextManager.setTextScaled(this.mCollectibleTextInfo);
         this.mRewardTextInfo = this.mBar.getChildByName("gift_collectiontxt") as TextField;
         TextManager.reformatTextField(this.mRewardTextInfo);
         this.mRewardTextInfo.text = TextManager.getText(TextIDs[_loc6_.textID]);
         TextManager.setTextScaled(this.mRewardTextInfo);
      }
      
      public function start() : void
      {
         this.visible = true;
      }
      
      public function showCollectibleBar() : void
      {
         this.start();
         this.mTimer = this.mMaxTimer;
         this.mSetIntervalId = setInterval(this.collectibleBarTimer,1000);
      }
      
      private function collectibleBarTimer() : void
      {
         if(this.mTimer > 0)
         {
            this.mTimer = Math.max(0,this.mTimer - this.mElapsed);
            if(this.mTimer <= 0)
            {
               clearInterval(this.mSetIntervalId);
               this.hideCollectibleBar();
            }
         }
      }
      
      private function hideCollectibleBar() : void
      {
         this.end();
         DollarsGame.getCurrentRole().toolsBar.decreaseCollectibleCounter();
      }
      
      public function end() : void
      {
         this.mCollectibleImage = null;
         this.mRewardImage = null;
         this.mCollectibleTextInfo = null;
         this.mRewardTextInfo = null;
         removeChild(this.mBar);
      }
   }
}

