package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ToolBuild extends Tool implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_PLACE_GIFT_ITEM:String = "eventplacegiftitem";
      
      private var mFromStorage:Boolean;
      
      private var mCompanyWhose:int;
      
      private var mBuildWithFBCreditsOffer:Boolean;
      
      private var mObjectToPlaceX:int;
      
      private var mObjectToPlaceY:int;
      
      public function ToolBuild(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
      }
      
      private function removeConfirmEventListeners() : void
      {
         if(this.mBuildWithFBCreditsOffer)
         {
            DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onBuyWithFBCreditsOffer);
         }
         else
         {
            DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.startBuildingItem);
         }
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,onAskForMoneyClose);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.startBuildingItem();
         }
         this.mBuildWithFBCreditsOffer = false;
      }
      
      public function onBuyWithFBCreditsOffer(param1:Event) : void
      {
         this.mBuildWithFBCreditsOffer = true;
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      override public function reportMouseUp(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:ItemDefinition = null;
         var _loc8_:int = 0;
         var _loc9_:Company = null;
         var _loc10_:Boolean = false;
         var _loc2_:Number = mItemAttachedToCursor.worldX;
         var _loc3_:Number = mItemAttachedToCursor.worldY;
         var _loc4_:int = _loc2_;
         var _loc5_:int = _loc3_;
         if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION)
         {
            _loc6_ = mMap.getScreenToTileIndex(_loc4_,_loc5_);
            if(_loc6_ != Tutorial.smAddDecorationTile)
            {
               return;
            }
         }
         if(itemAttachedProcessNotAbleToPlace(this.mFromStorage))
         {
            this.mObjectToPlaceX = mItemAttachedToCursor.worldX;
            this.mObjectToPlaceY = mItemAttachedToCursor.worldY;
            if(this.mFromStorage)
            {
               this.startBuildingItem();
            }
            else
            {
               _loc7_ = mItemAttachedToCursor.itemDefinition;
               _loc8_ = mRole.getCompanyWhoseBuilding(_loc7_.type);
               _loc9_ = getCompany(_loc8_);
               if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc7_.getConstructionFBCredits() > 0 && (_loc7_.getConstructionCash() == 0 || _loc9_.DCCash < _loc7_.getConstructionCash()))
               {
                  _loc10_ = Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN;
                  FBCreditsPurchase.getInstance().startPurchaseProcess(this);
                  mItemAttachedToCursor.setWorldPosition(this.mObjectToPlaceX,this.mObjectToPlaceY,0);
                  if(_loc10_)
                  {
                     mMap.cameraLookAt(mItemAttachedToCursor);
                  }
               }
               else if(this.itemAttachedCheckPrice())
               {
                  this.startBuildingItem();
               }
            }
         }
      }
      
      public function buyWithCredits() : Object
      {
         var _loc1_:int = mItemAttachedToCursor.itemDefinition.getConstructionFBCredits();
         var _loc2_:String = FBCreditsPurchase.TYPE_BUY_ITEM;
         if(this.mBuildWithFBCreditsOffer)
         {
            _loc1_ = mItemAttachedToCursor.itemDefinition.getConstructionFBCnoCash();
            _loc2_ = FBCreditsPurchase.TYPE_BUY_ITEM_OFFER;
         }
         return {
            "price":_loc1_,
            "orderInfo":{
               "type":_loc2_,
               "sku":mItemAttachedToCursor.itemDefinition.sku
            }
         };
      }
      
      override protected function usesItemAttachedToCursor() : Boolean
      {
         return true;
      }
      
      override protected function getPlaceItemCash() : int
      {
         return mItemAttachedToCursor.itemDefinition.getConstructionCash();
      }
      
      protected function itemAttachedCheckPrice() : Boolean
      {
         var _loc1_:Boolean = true;
         var _loc2_:Company = getCompany(mWhose);
         var _loc3_:int = this.getPlaceItemCoins();
         var _loc4_:int = this.getPlaceItemCash();
         if(_loc2_.DCCash < _loc4_)
         {
            DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,_loc4_);
            _loc1_ = false;
         }
         else if(_loc2_.DCCoins < _loc3_)
         {
            this.mBuildWithFBCreditsOffer = DollarsGame.smInstance.mPopupConfirm.startFBCreditsOffer(_loc3_,mItemAttachedToCursor.itemDefinition.getConstructionFBCnoCash());
            if(this.mBuildWithFBCreditsOffer)
            {
               DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_USE_FB_CREDITS,this.onBuyWithFBCreditsOffer);
            }
            else
            {
               DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.startBuildingItem);
            }
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,onAskForMoneyClose);
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      override public function isMapCursorEnabled() : Boolean
      {
         return false;
      }
      
      override public function setMap(param1:Map) : void
      {
         super.setMap(param1);
         setWhose(mWhose);
      }
      
      override public function end() : void
      {
         unattachItemToCursor();
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_SELECT;
      }
      
      override protected function getPlaceItemCoins() : int
      {
         return mItemAttachedToCursor.itemDefinition.getConstructionCoins();
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return false;
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         attachItemToCursor();
         this.mFromStorage = param2 != null;
         this.mBuildWithFBCreditsOffer = false;
      }
      
      private function startBuildingItem(param1:Event = null) : void
      {
         var _loc12_:int = 0;
         this.removeConfirmEventListeners();
         var _loc2_:ItemObject = mItemAttachedToCursor;
         var _loc3_:int = mRole.getCompanyWhoseBuilding(_loc2_.itemDefinition.type);
         var _loc4_:Company = getCompany(_loc3_);
         var _loc5_:ItemDefinition = mItemAttachedToCursor.itemDefinition;
         _loc5_.place();
         unattachItemToCursor();
         mItemAttachedToCursor.setWorldPosition(this.mObjectToPlaceX,this.mObjectToPlaceY,0);
         var _loc6_:int = mMap.getWorldToTileIndex(mItemAttachedToCursor.worldX,mItemAttachedToCursor.worldY,0);
         mItemAttachedToCursor = new ItemObject(_loc4_);
         if(this.mFromStorage)
         {
            setItemDefinition(_loc5_,true,UserDataFacade.getInstance().cmdCreateNewItemFromStorage());
         }
         else
         {
            setItemDefinition(_loc5_);
         }
         mItemAttachedToCursor.company = _loc4_;
         attachItemToCursor();
         _loc4_.addItem(_loc2_);
         _loc2_.setInfluenceIconEnabled(false);
         _loc2_.registerEvent(MissionsEventIDs.MISSION_EVENT_BUILD_ITEM);
         if(!Tutorial.smTutorialEnd)
         {
            if(Tutorial.smTutorialStep == 1 && _loc2_.itemDefinition.isHeadQuarters())
            {
               Tutorial.activeOkButton();
               Tutorial.removeHQTerrains();
               mMap.launchHQSkinAnimation();
            }
            else if(Tutorial.smTutorialStep == 3)
            {
               Tutorial.removeToolbarArrow(mMap);
               Tutorial.activeOkButton();
            }
            else if(Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_BUILD_DECORATION)
            {
               _loc12_ = mMap.getScreenToTileIndex(this.mObjectToPlaceX,this.mObjectToPlaceY);
               if(_loc12_ == Tutorial.smAddDecorationTile)
               {
                  mMap.dispatchEvent(new Event(Tutorial.EVENT_SET_TERRAIN));
               }
            }
         }
         if(this.mFromStorage)
         {
            StorageManager.getInstance().removeItem(_loc2_.itemDefinition.sku);
         }
         var _loc7_:Boolean = _loc5_.requiresMapGrid();
         var _loc8_:Boolean = _loc5_.requiresTerrainMine();
         var _loc9_:Boolean = _loc2_.getUseAsGift() && !this.mFromStorage;
         var _loc10_:Boolean = this.mFromStorage && StorageManager.getInstance().getItem(_loc2_.itemDefinition.sku) == null;
         var _loc11_:Boolean = Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc5_.getConstructionFBCredits() > 0 && !this.mFromStorage;
         if(_loc7_ || !_loc7_ && _loc8_ || _loc9_ || _loc10_ || _loc11_)
         {
            setNexTool(true);
            mMap.removeBuildGrid();
            mRole.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
            if(_loc9_)
            {
               DollarsGame.getCurrentWorld().map.dispatchEvent(new Event(EVENT_PLACE_GIFT_ITEM));
            }
            else if(this.mFromStorage)
            {
               DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
            }
         }
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().playSound(ModelConfig.SOUND_BUILD,1,0,0);
         }
         if(!this.mFromStorage && _loc5_.offerDef != null && _loc5_.offerDef.offerType == OfferManager.TYPE_BUNDLE)
         {
            StorageManager.getInstance().addItem(_loc5_.sku,_loc5_.offerDef.amount);
         }
      }
      
      override protected function usesAuthorizationFilters() : Boolean
      {
         return true;
      }
      
      override protected function getPlaceItemFBCredits() : int
      {
         return mItemAttachedToCursor.itemDefinition.getConstructionFBCredits();
      }
   }
}

