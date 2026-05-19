package com.dchoc.dollars.rewards
{
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoCommerce;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoDeco;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoHouse;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoWonder;
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class RewardItem extends RewardSingle
   {
      
      private var mRewardBox:Sprite;
      
      private var mItemDefinition:ItemDefinition;
      
      private var mInfo:InfoBox;
      
      public function RewardItem(param1:int, param2:String)
      {
         super(param1,param2);
         this.mItemDefinition = ItemDefinitionManager.getInstance().getDefinitionBySku(mSku) as ItemDefinition;
      }
      
      private function showInfoBox(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(this.mRewardBox.x,this.mRewardBox.y);
         _loc2_ = this.mRewardBox.localToGlobal(_loc2_);
         if(this.mInfo)
         {
            this.mInfo.show(this.mItemDefinition,_loc2_.x + this.mRewardBox.width - 15,_loc2_.y + this.mRewardBox.height / 2,this.mRewardBox.width - 20);
         }
      }
      
      override public function doApply() : void
      {
         StorageManager.getInstance().addItem(mSku,mAmount);
      }
      
      override public function draw() : Sprite
      {
         var _loc4_:ItemDefinition = null;
         var _loc5_:Sprite = null;
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"container_reward"))();
         this.mRewardBox = _loc1_.getChildByName("mission_reward") as Sprite;
         var _loc2_:TextField = _loc1_.getChildByName("text_reward_2") as TextField;
         _loc1_.removeChild(_loc2_);
         var _loc3_:Bitmap = new Bitmap(DCResourceManager.getInstance().get("blue_stars"));
         this.mRewardBox.addChild(_loc3_);
         if(PriorityLoader.getInstance().isLoaded(mSku))
         {
            _loc4_ = ItemDefinitionManager.getInstance().getDefinitionBySku(mSku) as ItemDefinition;
            _loc5_ = _loc4_.getIcon(this.mRewardBox).icon as Sprite;
            this.mRewardBox.addChild(_loc5_);
         }
         _loc2_ = _loc1_.getChildByName("text_reward") as TextField;
         if(mAmount > 1)
         {
            _loc2_.text = "x " + String(mAmount);
            TextManager.setTextScaled(_loc2_);
         }
         else
         {
            _loc1_.removeChild(_loc2_);
         }
         this.setupBox();
         return _loc1_;
      }
      
      private function closeInfoBox(param1:MouseEvent) : void
      {
         if(this.mInfo != null)
         {
            this.mInfo.close();
         }
      }
      
      private function setupBox() : void
      {
         this.mRewardBox.addEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
         this.mRewardBox.addEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
         if(this.mItemDefinition == null)
         {
            this.mItemDefinition = ItemDefinitionManager.getInstance().getDefinitionBySku(mSku) as ItemDefinition;
         }
         switch(this.mItemDefinition.type)
         {
            case ItemDefinition.TYPE_HOUSES_ID:
               this.mInfo = new ShopMenuInfoHouse(DollarsGame.smInstance.mPopupClip,this.mItemDefinition);
               break;
            case ItemDefinition.TYPE_COMMERCES_ID:
               this.mInfo = new ShopMenuInfoCommerce(DollarsGame.smInstance.mPopupClip,this.mItemDefinition);
               break;
            case ItemDefinition.TYPE_DECORATIONS_ID:
               this.mInfo = new ShopMenuInfoDeco(DollarsGame.smInstance.mPopupClip,this.mItemDefinition);
               break;
            case ItemDefinition.TYPE_WONDERS_ID:
               this.mInfo = new ShopMenuInfoWonder(DollarsGame.smInstance.mPopupClip,this.mItemDefinition);
         }
      }
      
      override protected function doGetRewardID() : String
      {
         return RewardManager.REWARD_EXP_ID;
      }
      
      override public function destroy() : void
      {
         this.mRewardBox.removeEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
         this.mRewardBox.removeEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
         this.mInfo.close();
         this.mInfo.destroy();
         this.mInfo = null;
         this.mRewardBox = null;
      }
   }
}

