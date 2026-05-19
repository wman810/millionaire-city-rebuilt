package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class ItemContentLocked extends ItemContent
   {
      
      public static const EVENT_UNLOCK_ITEM:String = "EventUnlockItem";
      
      public var mUnlockWithFBCredits:Boolean;
      
      protected var mSoldOutBox:MovieClip;
      
      public function ItemContentLocked(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      override public function start() : void
      {
         var _loc1_:MovieClip = mBox["unlock_FC"];
         if(_loc1_ != null)
         {
            mBox.removeChild(_loc1_);
         }
         mButton.start();
         mButton.disable();
      }
      
      override protected function getBox() : Sprite
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_SHOP,"shop_box_locked"))();
      }
      
      override public function setupIcon() : void
      {
         super.setupIcon();
         mImage.alpha = 0.5;
      }
      
      public function unlock() : void
      {
         dispatchEvent(new Event(EVENT_UNLOCK_ITEM));
         mDef.shopClickUnlockButton();
      }
      
      override protected function setupBox() : void
      {
         super.setupBox();
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mSoldOutBox = mBox["sold_out_box"];
         if(this.mSoldOutBox != null)
         {
            this.mSoldOutBox.visible = false;
         }
         var _loc2_:MovieClip = mBox["locked"];
         var _loc3_:TextField = _loc2_["Locked"];
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.replaceParameters(TextIDs.TID_POPUP_LEVEL_TEXT,new Array("" + mDef.level));
         TextManager.setTextScaled(_loc3_);
         this.mUnlockWithFBCredits = Config.FACEBOOK_CREDITS_AS_CURRENCY && mDef.getUnlockConditionID() == ItemDefinition.UNLOCK_CONDITION_LEVEL_ID && (mDef.getUnlockPrice(false) == 0 || _loc1_.DCCash < mDef.getUnlockPrice(false));
         mButton = new DynamicButton(mBox["fan"]);
         mButton.setLabel(TextManager.getText(TextIDs.TID_GEN_LOCKED));
         mButton.disable();
         if(!Tutorial.smTutorialEnd)
         {
            mButton.disable();
         }
      }
   }
}

