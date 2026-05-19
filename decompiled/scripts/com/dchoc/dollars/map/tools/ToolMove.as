package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmMove;
   import com.dchoc.dollars.GUI.PopupPayMove;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.media.SoundManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ToolMove extends Tool
   {
      
      private static const STATE_WAITING_FOR_ITEM:int = 0;
      
      private static const STATE_MOVING_WITH_ITEM:int = 1;
      
      private var mUsingFreeMove:Boolean;
      
      private var mState:int;
      
      private var mItemToMove:ItemObject;
      
      public function ToolMove(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
         this.mUsingFreeMove = false;
      }
      
      override protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
         switch(this.mState)
         {
            case STATE_WAITING_FOR_ITEM:
               if(param2 != null && (mWhose == WHOSE_ANY || param2.company.whose == mWhose) && param2.isMoveable())
               {
                  this.mItemToMove = param2;
                  this.changeState(STATE_MOVING_WITH_ITEM);
               }
               break;
            case STATE_MOVING_WITH_ITEM:
               if(this.isAtTheSamePosition(mItemAttachedToCursor.worldX,mItemAttachedToCursor.worldY))
               {
                  this.changeState(STATE_WAITING_FOR_ITEM);
                  break;
               }
               if(itemAttachedProcessNotAbleToPlace())
               {
                  if(this.itemAttachedCheckPrize())
                  {
                     this.doMove();
                  }
               }
         }
      }
      
      private function isAtTheSamePosition(param1:int, param2:int) : Boolean
      {
         return param1 == this.mItemToMove.worldX && param2 == this.mItemToMove.worldY;
      }
      
      public function cancelMovement() : void
      {
         if(this.mItemToMove != null)
         {
            this.changeState(STATE_WAITING_FOR_ITEM);
         }
      }
      
      private function changeState(param1:int) : void
      {
         switch(this.mState)
         {
            case STATE_MOVING_WITH_ITEM:
               unattachItemToCursor();
               this.mItemToMove.endMoving();
               if(this.mItemToMove.itemDefinition.requiresMapGrid())
               {
                  mMap.removeBuildGrid();
               }
               this.mItemToMove = null;
               DollarsGame.getProfile().servicesSetLock(Profile.SERVICES_MOVE_SKU,false);
               Dollars.getCurrentCursor().setApplyOffset(false);
         }
         this.mState = param1;
         switch(this.mState)
         {
            case STATE_MOVING_WITH_ITEM:
               mItemAttachedToCursor.company = getCompany(mWhose);
               setItemDefinition(this.mItemToMove.itemDefinition);
               this.mItemToMove.startMoving();
               attachItemToCursor();
               if(this.mItemToMove.itemDefinition.requiresMapGrid())
               {
                  mMap.setBuildGrid();
               }
               DollarsGame.getProfile().servicesSetLock(Profile.SERVICES_MOVE_SKU,true);
               Dollars.getCurrentCursor().setApplyOffset(true);
         }
      }
      
      override protected function getPlaceItemCash() : int
      {
         return mItemAttachedToCursor.itemDefinition.getMoveCash();
      }
      
      override protected function usesItemAttachedToCursor() : Boolean
      {
         return true;
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_MOVE;
      }
      
      override protected function getPlaceItemCoins() : int
      {
         var _loc1_:ItemDefinition = mItemAttachedToCursor.itemDefinition;
         return _loc1_.getMoveCoins() + RulesFacade.getInstantBuildPrice(_loc1_.getConstructionTime(),_loc1_.getMoveFactor());
      }
      
      protected function itemAttachedCheckPrize() : Boolean
      {
         var _loc2_:PopupConfirmMove = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Company = null;
         var _loc6_:PopupPayMove = null;
         var _loc1_:Boolean = false;
         if(this.mUsingFreeMove)
         {
            _loc2_ = new PopupConfirmMove();
            _loc2_.addEventListener(Popup.EVENT_ACCEPT,this.onAcceptMove);
            _loc2_.addEventListener(Popup.EVENT_CLOSE,this.onCancelMove);
            _loc2_.show();
         }
         else if(DollarsGame.getProfile().servicesIsAvailable(Profile.SERVICES_MOVE_SKU))
         {
            _loc1_ = true;
         }
         else
         {
            _loc3_ = this.getPlaceItemCoins();
            _loc4_ = this.getPlaceItemCash();
            _loc5_ = getCompany(mWhose);
            _loc6_ = new PopupPayMove();
            _loc6_.addEventListener(Popup.EVENT_ACCEPT,this.onAcceptMove);
            _loc6_.addEventListener(Popup.EVENT_CLOSE,this.onCancelMove);
            _loc6_.addEventListener(PopupPayMove.EVENT_RENT,this.onRentCrane);
            if(_loc3_ > 0)
            {
               _loc6_.showPopupParams(_loc3_,false);
            }
            else
            {
               _loc6_.showPopupParams(_loc4_,true);
            }
         }
         return _loc1_;
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         this.mUsingFreeMove = param2 != null;
         super.start(param1);
         this.changeState(STATE_WAITING_FOR_ITEM);
      }
      
      public function removeListenerMovement(param1:Event) : void
      {
         var _loc2_:Popup = param1.target as Popup;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.onAcceptMove);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onCancelMove);
         if(!this.mUsingFreeMove)
         {
            _loc2_.removeEventListener(PopupPayMove.EVENT_RENT,this.onRentCrane);
         }
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_MOVE);
         _loc2_.destroy();
         _loc2_ = null;
      }
      
      private function onCancelMove(param1:Event) : void
      {
         this.cancelMovement();
         this.removeListenerMovement(param1);
      }
      
      override protected function usesAuthorizationFilters() : Boolean
      {
         return true;
      }
      
      override protected function isItemAttachedToCursorEnabled() : Boolean
      {
         return Boolean(super.isItemAttachedToCursorEnabled()) && this.mState == STATE_MOVING_WITH_ITEM;
      }
      
      private function onRentCrane(param1:Event) : void
      {
         DollarsGame.getProfile().servicesContract(Profile.SERVICES_MOVE_SKU);
         this.doMove();
         this.removeListenerMovement(param1);
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         if(this.mState == STATE_WAITING_FOR_ITEM && param1.company.whose == mWhose)
         {
            return Boolean(super.isMouseOverEnabled(param1)) && !param1.itemDefinition.isHeadQuarters();
         }
         return false;
      }
      
      override protected function isItemAttachedAbleToBePlaced(param1:int, param2:int) : Boolean
      {
         return Boolean(super.isItemAttachedAbleToBePlaced(param1,param2)) || this.isAtTheSamePosition(param1,param2);
      }
      
      private function onAcceptMove(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Company = null;
         if(!this.mUsingFreeMove)
         {
            _loc2_ = this.getPlaceItemCoins();
            _loc3_ = this.getPlaceItemCash();
            _loc4_ = _loc2_;
            _loc5_ = int(PointsAnimation.TYPE_COINS);
            _loc6_ = getCompany(mWhose);
            if(_loc3_ > 0)
            {
               _loc6_.delayedPaymentSetGold(_loc3_,MetricConstants.LABEL_ECONOMY_MOVE_ITEM,MetricConstants.PRODUCT_ITEM,mItemAttachedToCursor.itemDefinition.itemName,true,_loc6_.world.map.getWorldXToScreen(mItemAttachedToCursor.worldX),_loc6_.world.map.getWorldYToScreen(mItemAttachedToCursor.worldY));
            }
            else if(_loc2_ > 0)
            {
               _loc6_.delayedPaymentSetCoins(_loc2_,MetricConstants.LABEL_ECONOMY_MOVE_ITEM,"",mItemAttachedToCursor.itemDefinition.itemName,true,_loc6_.world.map.getWorldXToScreen(mItemAttachedToCursor.worldX),_loc6_.world.map.getWorldYToScreen(mItemAttachedToCursor.worldY));
            }
         }
         this.doMove();
         this.removeListenerMovement(param1);
      }
      
      private function doMove() : void
      {
         this.mItemToMove.move(mItemAttachedToCursor.worldX,mItemAttachedToCursor.worldY,this.mUsingFreeMove);
         this.mItemToMove.registerEvent(MissionsEventIDs.MISSION_EVENT_MOVE_HOUSE);
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().playSound(ModelConfig.SOUND_BUILD,1,0,0);
         }
         this.changeState(STATE_WAITING_FOR_ITEM);
         if(this.mUsingFreeMove)
         {
            StorageManager.getInstance().removeItem("move");
            if(StorageManager.getInstance().getItem("move") == null)
            {
               DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
            }
         }
      }
      
      override public function end() : void
      {
         super.end();
         this.cancelMovement();
      }
      
      override public function itemMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return this.isMouseOverEnabled(param1);
      }
   }
}

