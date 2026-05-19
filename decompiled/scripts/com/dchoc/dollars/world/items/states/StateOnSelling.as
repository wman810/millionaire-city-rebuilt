package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.notifications.NotificationSellingEnd;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class StateOnSelling extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_SELLING_ID;
      
      private var mForSaleSpr:Sprite;
      
      private var mSellTime:int;
      
      private var mTime:int;
      
      private var mPrice:int;
      
      private var mProgressFillBar:DCFillBar;
      
      private var mProgressBar:Sprite;
      
      public function StateOnSelling(param1:StateMachine, param2:int = 0, param3:int = 0)
      {
         super(param1);
         this.mSellTime = param2;
         this.mPrice = param3;
         this.load();
      }
      
      public function onCancel(param1:MouseEvent) : void
      {
         mItemObject.changeState(new StateOnRent(mItemObject));
         mItemObject.doMouseOver();
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         if(this.mTime > 0)
         {
            this.mTime -= param1;
            this.mProgressFillBar.setValueWithoutBarAnimation(this.mSellTime - this.mTime);
            if(this.mTime <= 0)
            {
               this.mTime = 0;
               undoMouseOver();
               this.viewEnd();
               setNotification(new NotificationSellingEnd(mItemObject,this.mPrice,itemObject.company.world.getCompanyRival()));
            }
         }
      }
      
      override protected function doUndoSelection() : void
      {
         if(mUIIsSelected)
         {
            setNotification(null,false);
            mUIIsSelected = false;
         }
      }
      
      private function viewEnd() : void
      {
         if(this.mProgressBar != null && mItemObject.displayObjectL1.contains(this.mProgressBar))
         {
            mItemObject.displayObjectL1.removeChild(this.mProgressBar);
         }
         if(this.mForSaleSpr != null)
         {
            mItemObject.displayObjectL1.removeChild(this.mForSaleSpr);
            this.mForSaleSpr = null;
         }
      }
      
      public function get price() : int
      {
         return this.mPrice;
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return mItemObject.company.isMine() && this.mTime > 0;
      }
      
      public function get time() : int
      {
         return this.mTime;
      }
      
      override public function isAffectedByType(param1:int) : Boolean
      {
         return false;
      }
      
      private function viewStart() : void
      {
         var _loc2_:TextField = null;
         this.mProgressFillBar.setMaxValue(this.mSellTime);
         this.mProgressFillBar.setMinValue(0);
         this.mProgressBar.x = mItemObject.getBarX();
         this.mProgressBar.y = mItemObject.getBarY();
         mItemObject.displayObjectL1.addChild(this.mProgressBar);
         mUIIsSelected = false;
         var _loc1_:ItemDefinition = mItemObject.itemDefinition;
         this.mForSaleSpr = new AssetManager.PopupForSale();
         this.mForSaleSpr.x = _loc1_.baseCols / 2 * MapDefinition.getInstance().getTileWidth();
         this.mForSaleSpr.y = _loc1_.baseHeight;
         _loc2_ = this.mForSaleSpr.getChildByName("prize") as TextField;
         _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(mItemObject.getSellPrice(),TextManager.TRUNCATE_THOUSAND,6);
         mItemObject.displayObjectL1.addChild(this.mForSaleSpr);
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.mTime = this.mSellTime;
         }
         else
         {
            mItemObject.changeAnim(ItemObject.STATE_NORMAL);
         }
         mItemObject.influenceResetCommercesAffectedByItem();
         this.viewStart();
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return false;
      }
      
      override public function exit() : void
      {
         super.exit();
         this.viewEnd();
         if(mUIIsSelected)
         {
            mItemObject.company.world.role.toolsBar.unattachItem(mItemObject);
         }
      }
      
      override public function setPersistence(param1:XML) : void
      {
         this.mTime = param1.@time;
         this.mSellTime = param1.@sellTime;
         this.mPrice = param1.@price;
      }
      
      private function load() : void
      {
         this.mProgressBar = new AssetManager.SellBarOnHouse();
         this.mProgressFillBar = new DCFillBar(this.mProgressBar.getChildByName("FillBar") as MovieClip,0,0);
      }
      
      override public function getPersistence() : XML
      {
         var _loc1_:XML = super.getPersistence();
         _loc1_.@time = this.mTime;
         _loc1_.@sellTime = this.mSellTime;
         _loc1_.@price = this.mPrice;
         return _loc1_;
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      override public function destroy() : void
      {
         this.mProgressFillBar = null;
         this.mProgressBar = null;
         super.destroy();
      }
      
      override public function suspend() : void
      {
         mItemObject.resume();
      }
      
      override protected function doDoSelection() : void
      {
         if(!mUIIsSelected)
         {
            mUIIsSelected = true;
         }
      }
      
      public function get sellTime() : int
      {
         return this.mSellTime;
      }
   }
}

