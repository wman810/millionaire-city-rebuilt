package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupValue;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.items.decorations.ItemDecoration;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinitionManager;
   import com.dchoc.framework.states.StateMachine;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StateOnHeadQuarter extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_HEADQUARTER_ID;
      
      private var mPopupValue:PopupValue;
      
      public function StateOnHeadQuarter(param1:StateMachine)
      {
         super(param1);
         this.viewStart();
      }
      
      private function viewStart() : void
      {
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:ItemDecoration = null;
         var _loc3_:int = 0;
         if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_SELECT)
         {
            _loc2_ = mItemObject.decorationsGetDecorationByType(ItemDecoration.TYPE_SKIN_ID);
            _loc3_ = ItemDecorationDefinitionManager.getInstance().getDefinitionId(_loc2_.currentSku,ItemDecoration.TYPE_SKIN_ID);
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HQ_01,_loc3_);
         }
      }
      
      private function onClosePopupValue(param1:Event) : void
      {
         this.mPopupValue.removeEventListener(Popup.EVENT_CLOSE,this.onClosePopupValue);
         this.mPopupValue.destroy();
         this.mPopupValue = null;
      }
      
      private function viewUpdate() : void
      {
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(Dollars.getCurrentCursor().isCursorInCollection(Cursor.CURSOR_HQ_01))
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         }
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return mItemObject.company.isMine();
      }
      
      override protected function doUndoSelection() : void
      {
      }
      
      private function viewEnd() : void
      {
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      override public function doClick() : void
      {
         if(Tutorial.smTutorialEnd)
         {
            mItemObject.undoMouseOver(true);
            this.mPopupValue = new PopupValue();
            this.mPopupValue.showpopup();
            this.mPopupValue.addEventListener(Popup.EVENT_CLOSE,this.onClosePopupValue);
         }
      }
      
      override protected function doDoSelection() : void
      {
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         if(param1)
         {
            mItemObject.init();
         }
      }
      
      protected function onButtonUpgrade(param1:MouseEvent = null) : void
      {
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         var _loc1_:Boolean = Boolean(super.doIsMouseOverEnabled()) && !UserDataFacade.getInstance().isNPC(DollarsGame.getCurrentUniverse().owner);
         return _loc1_ && Tutorial.smTutorialEnd;
      }
      
      override public function exit() : void
      {
         super.exit();
         if(mUIIsSelected)
         {
            mItemObject.company.world.role.toolsBar.unattachItem(mItemObject);
         }
         this.viewEnd();
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_EDITOR;
      }
   }
}

