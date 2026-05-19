package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.GUI.ItemService;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.PopupMessage;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   
   public class Tool
   {
      
      protected static const WHOSE_ANY:int = -1;
      
      private var mWorking:Boolean;
      
      private var mAreaEndTileX:int;
      
      private var mAreaEndTileY:int;
      
      private var mEnabled:Boolean;
      
      private const AREA_COLOR:int = 65280;
      
      private var mAreaTilesHeight:int;
      
      protected var mWhose:int;
      
      private const AREA_ALPHA_SPEED:Number = 0.01;
      
      private var mEnabledLocked:Boolean;
      
      protected const ITEM_OFFSET:int = 0;
      
      private const AREA_MAX_ALPHA:Number = 0.4;
      
      private var mTransformForbiddenFilters:Array;
      
      private var mAreaStartTileY:int;
      
      private var mAreaStartTileX:int;
      
      protected var mId:int;
      
      private var mAreaTilesWidth:int;
      
      protected var mRole:Role;
      
      private var mTransformAllowedFilters:Array;
      
      protected var mMap:Map;
      
      private var mAreaDO:Sprite;
      
      protected var mItemAttachedToCursor:ItemObject;
      
      protected var mNextTool:Tool;
      
      private var mOriginalFilters:Array;
      
      private const AREA_MIN_ALPHA:Number = 0.1;
      
      private var mAreaAlphaSpeed:Number;
      
      private var mMouseMoveTileCheck:int;
      
      protected var mItemMouseOver:ItemObject;
      
      protected var mAreaItemsAffected:Array;
      
      protected var mTileIndex:int;
      
      private var mAreaAlpha:Number;
      
      protected var mCursorDO:Shape;
      
      public function Tool(param1:Role, param2:Tool = null)
      {
         super();
         this.mRole = param1;
         this.mNextTool = param2;
         this.mWhose == WHOSE_ANY;
      }
      
      protected function cursorIsEnabled() : Boolean
      {
         return false;
      }
      
      public function getEnabled() : Boolean
      {
         return this.mEnabled;
      }
      
      private function areaEnd() : void
      {
         var _loc1_:ItemObject = null;
         if(this.mAreaItemsAffected != null)
         {
            for each(_loc1_ in this.mAreaItemsAffected)
            {
               _loc1_.setDisplayObjectOutlineVisible(false,0);
               _loc1_.undoMouseOver(true);
            }
            this.mAreaItemsAffected.splice(0,this.mAreaItemsAffected.length);
         }
         if(this.mAreaDO != null && this.mMap.contains(this.mAreaDO))
         {
            this.mMap.removeChild(this.mAreaDO);
         }
      }
      
      public function getId() : int
      {
         return this.mId;
      }
      
      public function setItemMouseOver(param1:ItemObject) : void
      {
         this.mItemMouseOver = param1;
      }
      
      protected function setNexTool(param1:Boolean = false) : void
      {
         if(this.mNextTool != null)
         {
            this.mMap.changeTool(this.mNextTool);
            if(param1)
            {
               this.mNextTool.setItemMouseOver(this.mItemMouseOver);
            }
         }
      }
      
      public function reportMouseDown(param1:MouseEvent) : void
      {
      }
      
      public function itemMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return param1 != null && param1.isClickPriority();
      }
      
      public function getDefaultCursorID() : int
      {
         return -1;
      }
      
      public function setId(param1:int) : void
      {
         this.mId = param1;
      }
      
      private function onContract(param1:Event) : void
      {
         this.onClosePopup(null);
         var _loc2_:int = this.getToolButtonId();
         if(_loc2_ > -1)
         {
            DollarsGame.getCurrentRole().toolsBar.showMultifunctionBar(_loc2_);
         }
      }
      
      protected function unattachItemToCursor() : void
      {
         if(this.mItemAttachedToCursor.itemDefinition.isHeadQuarters())
         {
            this.mItemAttachedToCursor.changeAnim(ItemObject.STATE_HQ_NORMAL);
         }
         else if(this.mItemAttachedToCursor.itemDefinition.type == ItemDefinition.TYPE_DECORATIONS_ID)
         {
            this.mItemAttachedToCursor.changeAnim(ItemObject.STATE_NORMAL);
         }
         else
         {
            this.mItemAttachedToCursor.changeAnim(ItemObject.STATE_BUILDING);
         }
         this.mItemAttachedToCursor.setInfluenceAreaVisibility(false,true);
         this.mItemAttachedToCursor.setBase(ItemObject.BASE_NOT_VISIBLE,this.mOriginalFilters);
         if(this.mMap.contains(this.mItemAttachedToCursor.displayObjectL0))
         {
            this.mMap.removeChild(this.mItemAttachedToCursor.displayObjectL0);
         }
         if(this.mMap.contains(this.mItemAttachedToCursor.displayObjectL1))
         {
            this.mMap.removeChild(this.mItemAttachedToCursor.displayObjectL1);
         }
         var _loc1_:Array = this.mItemAttachedToCursor.influenceItemsAffectedByInfluence;
         if(_loc1_ != null)
         {
            _loc1_.splice(0,_loc1_.length);
         }
      }
      
      private function areaLogicUpdate(param1:int) : void
      {
         this.mAreaAlpha += this.mAreaAlphaSpeed;
         if(this.mAreaAlpha >= this.AREA_MAX_ALPHA)
         {
            this.mAreaAlpha = this.AREA_MAX_ALPHA;
            this.mAreaAlphaSpeed *= -1;
         }
         else if(this.mAreaAlpha <= this.AREA_MIN_ALPHA)
         {
            this.mAreaAlpha = this.AREA_MIN_ALPHA;
            this.mAreaAlphaSpeed *= -1;
         }
         this.areaDraw();
      }
      
      protected function getToolButtonId() : int
      {
         return -1;
      }
      
      protected function usesAuthorizationFilters() : Boolean
      {
         return false;
      }
      
      public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return !this.areaIsEnabled() && param1 != null && param1.isMouseOverEnabled();
      }
      
      private function areaLoad() : void
      {
         this.mAreaItemsAffected = new Array();
      }
      
      public function areaSetSize(param1:int, param2:int) : void
      {
         this.mAreaTilesWidth = param1;
         this.mAreaTilesHeight = param2;
         this.mAreaStartTileX = -(this.mAreaTilesWidth >> 1);
         if(this.mAreaTilesWidth % 2 != 0)
         {
            --this.mAreaStartTileX;
         }
         this.mAreaEndTileX = -this.mAreaStartTileX;
         this.mAreaStartTileY = -(this.mAreaTilesHeight >> 1);
         if(this.mAreaTilesHeight % 2 != 0)
         {
            --this.mAreaStartTileY;
         }
         this.mAreaEndTileY = -this.mAreaStartTileY;
         this.areaDraw();
      }
      
      protected function cursorIsVisible(param1:int) : Boolean
      {
         return false;
      }
      
      protected function doReportMouseOver(param1:MouseEvent, param2:ItemObject) : void
      {
         if(this.mRole.isMouseTerrainAllowed())
         {
            this.doReportMouseOverTerrain(param1);
         }
      }
      
      public function reportMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         if(this.mWorking)
         {
            this.reportMouseOver(param1);
            if(this.cursorIsEnabled())
            {
               this.cursorMove(param1);
            }
         }
         if(this.areaIsEnabled())
         {
            this.areaMove(param1);
         }
         else if(this.isItemAttachedToCursorEnabled())
         {
            _loc2_ = this.getXFromMouse();
            _loc3_ = this.getYFromMouse();
            _loc4_ = this.mMap.view.getScreenToWorldX(_loc2_,_loc3_,true);
            _loc5_ = this.mMap.view.getScreenToWorldY(_loc2_,_loc3_,true);
            _loc2_ = _loc4_ - this.ITEM_OFFSET;
            _loc3_ = _loc5_;
            this.mItemAttachedToCursor.setWorldPosition(this.mMap.view.getScreenToWorldX(_loc2_,_loc3_,true),this.mMap.view.getScreenToWorldY(_loc2_,_loc3_,true));
            _loc6_ = this.mMap.getWorldToTileIndex(_loc2_,_loc3_,0);
            if(this.mMouseMoveTileCheck != _loc6_)
            {
               this.mMouseMoveTileCheck = _loc6_;
               if(this.isItemAttachedAbleToBePlaced(_loc2_,_loc3_))
               {
                  this.mItemAttachedToCursor.setBase(ItemObject.BASE_BUILDABLE,this.mTransformAllowedFilters);
               }
               else
               {
                  this.mItemAttachedToCursor.setBase(ItemObject.BASE_NOT_BUILDABLE,this.mTransformForbiddenFilters);
               }
               if(this.mMap.isTileInAreaMine(_loc6_))
               {
                  if(!this.mItemAttachedToCursor.isVisible())
                  {
                     this.mItemAttachedToCursor.setVisible(true);
                  }
                  if(this.mItemAttachedToCursor.hasInfluenceArea())
                  {
                     this.mItemAttachedToCursor.setInfluenceAreaVisibility(true,true);
                  }
               }
               else if(this.mItemAttachedToCursor.isVisible())
               {
                  this.mItemAttachedToCursor.setVisible(false);
               }
            }
         }
      }
      
      public function reportMouseOver(param1:MouseEvent, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc4_:TileData = null;
         var _loc5_:ItemObject = null;
         if(!this.mEnabled && (param1 != null || param2))
         {
            this.enable();
         }
         if(this.mEnabled)
         {
            _loc3_ = this.mMap.getWorldToTileIndex(this.mMap.mouseX,this.mMap.mouseY,0);
            if(_loc3_ != this.mTileIndex)
            {
               _loc4_ = this.mMap.getTileDataFromIndex(this.mTileIndex);
               if(_loc4_ != null)
               {
                  _loc4_.undoMouseOver();
               }
            }
            this.mTileIndex = _loc3_;
            _loc4_ = this.mMap.getTileDataFromIndex(this.mTileIndex);
            if(_loc4_ != null)
            {
               _loc4_.doMouseOver();
            }
         }
         if(!this.areaIsEnabled())
         {
            _loc5_ = null;
            if(this.mEnabled)
            {
               _loc5_ = this.mMap.getItemFromScreen(this.mMap.mouseX,this.mMap.mouseY);
            }
            if(_loc5_ != null && _loc5_.isClickPriority())
            {
               this.reportMouseOverAnItem(param1,_loc5_);
            }
            else if(!this.reportMouseOverAnItem(param1,_loc5_))
            {
               this.doReportMouseOver(param1,_loc5_);
            }
         }
      }
      
      protected function getCompany(param1:int) : Company
      {
         return DollarsGame.getCurrentWorld().getCompany(param1);
      }
      
      public function reportMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:ItemObject = null;
         if(this.mEnabled)
         {
            if(this.areaIsEnabled())
            {
               this.areaClick(param1);
            }
            else
            {
               _loc2_ = this.mMap.getItemFromScreen(this.mMap.mouseX,this.mMap.mouseY);
               if(_loc2_ != null && _loc2_.isClickPriority())
               {
                  _loc2_.doClick();
               }
               else
               {
                  this.doReportMouseUp(param1,_loc2_);
               }
            }
         }
      }
      
      public function setWhose(param1:int) : void
      {
         this.mWhose = param1;
         if(this.mItemAttachedToCursor != null)
         {
            this.mItemAttachedToCursor.company = this.getCompany(this.mWhose);
         }
      }
      
      public function unattachItem(param1:ItemObject) : void
      {
      }
      
      protected function cursorMove(param1:MouseEvent) : void
      {
         var _loc2_:int = int(this.mMap.getWorldToTileX(this.mMap.mouseX));
         var _loc3_:int = int(this.mMap.getWorldToTileY(this.mMap.mouseY));
         var _loc4_:Boolean = this.cursorIsApplicable();
         if(_loc4_)
         {
            this.cursorStart();
         }
         else
         {
            this.cursorEnd();
         }
         this.cursorDraw(_loc4_);
         this.mCursorDO.x = this.mMap.getTileXToWorld(_loc2_);
         this.mCursorDO.y = this.mMap.getTileYToWorld(_loc3_);
      }
      
      protected function getPlaceItemCash() : int
      {
         return -1;
      }
      
      public function isMapCursorEnabled() : Boolean
      {
         return true;
      }
      
      protected function cursorLoad() : void
      {
         this.mCursorDO = new Shape();
         this.cursorDraw(true);
      }
      
      public function start(param1:Boolean = false, param2:String = null) : void
      {
         this.mWorking = true;
         this.mEnabledLocked = false;
         this.mEnabled = true;
         this.mMouseMoveTileCheck = -1;
         if(param1)
         {
            this.mMap.addEventListener(MouseEvent.MOUSE_DOWN,this.reportMouseDown);
            this.mMap.addEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMove);
            this.mMap.addEventListener(MouseEvent.MOUSE_OUT,this.reportMouseOut);
         }
         if(this.mItemMouseOver != null)
         {
            this.mItemMouseOver.undoMouseOver(true);
         }
         this.mItemMouseOver = null;
         this.mTileIndex = -1;
         if(this.cursorIsEnabled())
         {
            this.cursorStart();
         }
         if(this.areaIsEnabled())
         {
            this.areaStart();
         }
         this.reportMouseMove(null);
      }
      
      protected function getPlaceItemCoins() : int
      {
         return -1;
      }
      
      private function areaDraw() : void
      {
         if(this.mAreaDO == null)
         {
            this.mAreaDO = new Sprite();
         }
         var _loc1_:int = this.mMap.tileWidth * this.mAreaTilesWidth;
         var _loc2_:int = this.mMap.tileHeight * this.mAreaTilesHeight;
         FiltersManager.drawRectangleWithBorder(this.mAreaDO.graphics,-(_loc1_ >> 1),-(_loc2_ >> 1),_loc1_,_loc2_,this.AREA_COLOR,this.mAreaAlpha);
      }
      
      protected function isItemAttachedAbleToBePlaced(param1:int, param2:int) : Boolean
      {
         return this.mMap.isBuildableFromScreen(param1,param2,this.mItemAttachedToCursor);
      }
      
      protected function itemAttachedProcessNotAbleToPlace(param1:Boolean = false) : Boolean
      {
         var _loc3_:ItemDefinition = null;
         var _loc2_:Boolean = false;
         if(this.isItemAttachedAbleToBePlaced(this.mItemAttachedToCursor.worldX,this.mItemAttachedToCursor.worldY))
         {
            _loc2_ = true;
         }
         else
         {
            _loc3_ = this.mItemAttachedToCursor.itemDefinition;
            if(_loc3_.requiresTerrainMine())
            {
               DollarsGame.smInstance.mPopupMsgSmall.showPopupParams(TextManager.replaceParameters(TextIDs.TID_PLACE_IN_TERRAIN,new Array(_loc3_.baseCols + "x" + _loc3_.baseRows)),PopupMessage.ICON_TERRAIN);
            }
            else
            {
               DollarsGame.smInstance.mPopupMsgSmall.showPopupParams(TextManager.getText(TextIDs.TID_CANT_BUILD_DECORATION));
            }
         }
         return _loc2_;
      }
      
      protected function getXFromMouse() : int
      {
         var _loc1_:int = this.mMap.mouseX;
         if(this.mItemAttachedToCursor != null)
         {
            _loc1_ -= this.mItemAttachedToCursor.worldSizeX >> 1;
         }
         return _loc1_;
      }
      
      protected function setEnabled(param1:Boolean) : void
      {
         if(!this.mEnabledLocked)
         {
            this.mEnabled = param1;
         }
      }
      
      protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
      }
      
      protected function areaIsItemsAffectedEnabled() : Boolean
      {
         return this.areaIsEnabled();
      }
      
      protected function reportMouseOverAnItem(param1:MouseEvent, param2:ItemObject) : Boolean
      {
         var _loc3_:Boolean = false;
         if(param2 != this.mItemMouseOver || param1 == null)
         {
            if(this.mItemMouseOver != null)
            {
               this.mItemMouseOver.undoMouseOver();
            }
            if(param2 != null && !this.isMouseOverEnabled(param2) && !this.itemMouseOverEnabled(param2))
            {
               param2 = null;
            }
            if(param2 != null)
            {
               param2.doMouseOver();
            }
            this.mItemMouseOver = param2;
            _loc3_ = true;
         }
         return _loc3_;
      }
      
      protected function areaDoClick(param1:ItemObject) : Boolean
      {
         return true;
      }
      
      public function enable(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.mEnabledLocked = false;
         }
         this.setEnabled(true);
         this.reportMouseOver(null);
         if(this.cursorIsEnabled())
         {
            this.cursorStart();
         }
      }
      
      public function getItemMouseOver() : ItemObject
      {
         return this.mItemMouseOver;
      }
      
      protected function areaGetServiceSku() : String
      {
         return null;
      }
      
      protected function usesItemAttachedToCursor() : Boolean
      {
         return false;
      }
      
      protected function areaGetServiceContractsPopup() : Popup
      {
         return null;
      }
      
      protected function getYFromMouse() : int
      {
         var _loc1_:int = this.mMap.mouseY;
         if(this.mItemAttachedToCursor != null)
         {
            _loc1_ -= this.mItemAttachedToCursor.worldSizeY >> 1;
         }
         return _loc1_;
      }
      
      public function setMap(param1:Map) : void
      {
         this.mMap = param1;
      }
      
      protected function doReportMouseOverTerrain(param1:MouseEvent) : void
      {
      }
      
      protected function areaApplyService(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:ItemObject = null;
         if(this.mAreaItemsAffected.length > 0)
         {
            _loc2_ = false;
            for each(_loc3_ in this.mAreaItemsAffected)
            {
               _loc2_ = this.areaDoClick(_loc3_) || _loc2_;
            }
            if(!_loc2_)
            {
               this.areaDoNoItemsOk();
            }
         }
         this.areaMove(param1);
      }
      
      protected function cursorEnd() : void
      {
         if(this.mMap.contains(this.mCursorDO))
         {
            this.mMap.removeChild(this.mCursorDO);
         }
      }
      
      public function areaIsEnabled() : Boolean
      {
         return false;
      }
      
      protected function cursorStart() : void
      {
         if(!this.mMap.contains(this.mCursorDO))
         {
            this.mMap.addChild(this.mCursorDO);
            this.reportMouseMove(null);
         }
      }
      
      private function areaDestroy() : void
      {
         if(this.mAreaDO != null)
         {
            this.areaEnd();
            this.mAreaDO = null;
         }
         if(this.mAreaItemsAffected != null)
         {
            this.mAreaItemsAffected.splice(0,this.mAreaItemsAffected.length);
            this.mAreaItemsAffected = null;
         }
      }
      
      protected function getPlaceItemFBCredits() : int
      {
         return -1;
      }
      
      protected function cursorDraw(param1:Boolean) : void
      {
         var _loc2_:Graphics = this.mCursorDO.graphics;
         _loc2_.clear();
         if(param1)
         {
            _loc2_.lineStyle(2,65280);
            _loc2_.beginFill(65280,0.5);
            _loc2_.drawRect(0,0,MapDefinition.getInstance().getTileWidth(),MapDefinition.getInstance().getTileHeight());
            _loc2_.endFill();
         }
         else
         {
            _loc2_.lineStyle(2,16711680);
            _loc2_.beginFill(16711680,0.5);
            _loc2_.drawRect(0,0,MapDefinition.getInstance().getTileWidth(),MapDefinition.getInstance().getTileHeight());
            _loc2_.endFill();
         }
      }
      
      public function reportMouseOut(param1:MouseEvent) : void
      {
         if(this.mEnabled)
         {
            this.disable();
         }
      }
      
      protected function areaDoNoItemsOk() : void
      {
      }
      
      protected function onAskForMoneyClose(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onAskForMoneyClose);
         this.mRole.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
      }
      
      public function setItemDefinition(param1:ItemDefinition, param2:Boolean = false, param3:Object = null, param4:Boolean = false) : void
      {
         var _loc5_:Company = null;
         if(this.mItemAttachedToCursor.itemDefinition != null && this.mItemAttachedToCursor.itemDefinition != param1)
         {
            _loc5_ = this.mItemAttachedToCursor.company;
            this.mItemAttachedToCursor.destroy(false,false);
            this.mItemAttachedToCursor = null;
            this.mItemAttachedToCursor = new ItemObject();
            this.mItemAttachedToCursor.company = _loc5_;
         }
         this.mItemAttachedToCursor.itemDefinition = param1;
         this.mItemAttachedToCursor.setUseAsGift(param2);
         this.mItemAttachedToCursor.setExtraCmdToServer(param3);
      }
      
      protected function attachItemToCursor() : void
      {
         this.mItemAttachedToCursor.changeAnim(ItemObject.STATE_NORMAL,true);
         this.mItemAttachedToCursor.setInfluenceIconEnabled(true);
         this.reportMouseMove(null);
         this.mItemAttachedToCursor.setInfluenceAreaVisibility(true,true);
         this.mMap.addChild(this.mItemAttachedToCursor.displayObjectL0);
         this.mMap.addChild(this.mItemAttachedToCursor.displayObjectL1);
      }
      
      protected function doCursorIsApplicable(param1:TileData) : Boolean
      {
         return false;
      }
      
      protected function cursorDestroy() : void
      {
         this.cursorEnd();
         this.mCursorDO = null;
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.areaIsEnabled())
         {
            this.areaLogicUpdate(param1);
         }
      }
      
      private function areaStart() : void
      {
         if(this.mAreaDO == null)
         {
            this.areaDraw();
         }
         this.mAreaAlpha = this.AREA_MIN_ALPHA;
         this.mAreaAlphaSpeed = this.AREA_ALPHA_SPEED;
         if(!this.mMap.contains(this.mAreaDO))
         {
            this.mMap.addChild(this.mAreaDO);
         }
      }
      
      public function canBuildTerrain() : Boolean
      {
         if(this.mNextTool != null)
         {
            return this.mNextTool.canBuildTerrain();
         }
         return true;
      }
      
      public function end() : void
      {
         this.mWorking = false;
         this.mEnabled = false;
         this.mMap.removeEventListener(MouseEvent.MOUSE_DOWN,this.reportMouseDown);
         this.mMap.removeEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMove);
         this.mMap.removeEventListener(MouseEvent.MOUSE_OUT,this.reportMouseOut);
         if(this.mItemMouseOver != null)
         {
            this.mItemMouseOver.undoMouseOver(true);
         }
         if(this.cursorIsEnabled())
         {
            this.cursorEnd();
         }
         if(this.areaIsEnabled())
         {
            this.areaEnd();
         }
      }
      
      protected function cursorIsApplicable() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:TileData = null;
         var _loc1_:Boolean = this.cursorIsEnabled();
         if(_loc1_)
         {
            _loc1_ = false;
            _loc2_ = int(this.mMap.getWorldToTileX(this.mMap.mouseX));
            _loc3_ = int(this.mMap.getWorldToTileY(this.mMap.mouseY));
            _loc4_ = this.mMap.getTileData(_loc2_,_loc3_);
            if(_loc4_ != null)
            {
               if(this.mMap.isTileInAreaMine(_loc4_.tileIndex))
               {
                  _loc1_ = this.doCursorIsApplicable(_loc4_);
               }
               if(_loc4_.isHigh())
               {
                  _loc1_ = true;
               }
            }
         }
         return _loc1_;
      }
      
      private function onClosePopup(param1:Event) : void
      {
         var _loc2_:Popup = this.areaGetServiceContractsPopup();
         if(_loc2_ != null)
         {
            _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onClosePopup);
            _loc2_.removeEventListener(ItemService.EVENT_CONTRACT,this.onContract);
         }
         else if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("############# ERROR in Tool.onClosePopup(): popup is null for service " + this.areaGetServiceSku());
         }
      }
      
      protected function areaIsItemAffected(param1:ItemObject) : Boolean
      {
         return param1.company == this.getCompany(this.mWhose);
      }
      
      public function load() : void
      {
         var _loc1_:BitmapFilter = null;
         if(this.cursorIsEnabled())
         {
            this.cursorLoad();
         }
         if(this.areaIsEnabled())
         {
            this.areaLoad();
         }
         if(this.usesItemAttachedToCursor())
         {
            this.mItemAttachedToCursor = new ItemObject();
         }
         if(this.usesAuthorizationFilters())
         {
            this.mTransformForbiddenFilters = new Array();
            _loc1_ = this.getBitmapFilter(16711680);
            this.mTransformForbiddenFilters.push(_loc1_);
            this.mTransformAllowedFilters = new Array();
            _loc1_ = this.getBitmapFilter(65280);
            this.mTransformAllowedFilters.push(_loc1_);
            this.mOriginalFilters = this.mItemAttachedToCursor.displayObjectL0.filters;
         }
      }
      
      public function disable(param1:Boolean = false) : void
      {
         var _loc2_:TileData = this.mMap.getTileDataFromIndex(this.mTileIndex);
         if(_loc2_ != null)
         {
            _loc2_.undoMouseOver();
         }
         this.setEnabled(false);
         this.reportMouseOver(null);
         if(param1)
         {
            this.mEnabledLocked = true;
         }
         if(this.cursorIsEnabled())
         {
            this.cursorEnd();
         }
      }
      
      public function serviceEnd() : void
      {
         if(this.areaIsEnabled())
         {
            this.mRole.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         }
      }
      
      protected function isItemAttachedToCursorEnabled() : Boolean
      {
         return this.usesItemAttachedToCursor();
      }
      
      public function destroy() : void
      {
         if(this.cursorIsEnabled())
         {
            this.cursorDestroy();
         }
         if(this.areaIsEnabled())
         {
            this.areaDestroy();
         }
         if(this.mItemAttachedToCursor != null)
         {
            this.mItemAttachedToCursor.destroy(false);
            this.mItemAttachedToCursor = null;
         }
         if(this.mTransformForbiddenFilters != null)
         {
            this.mTransformForbiddenFilters = null;
         }
         if(this.mTransformAllowedFilters != null)
         {
            this.mTransformAllowedFilters = null;
         }
      }
      
      private function areaClick(param1:MouseEvent) : void
      {
         var _loc2_:Popup = null;
         this.areaMove(param1);
         if(!DollarsGame.getProfile().servicesIsAvailable(this.areaGetServiceSku()))
         {
            DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
            _loc2_ = this.areaGetServiceContractsPopup();
            _loc2_.showPopup();
            _loc2_.addEventListener(Popup.EVENT_CLOSE,this.onClosePopup);
            _loc2_.addEventListener(ItemService.EVENT_CONTRACT,this.onContract);
         }
         else
         {
            this.areaApplyService(param1);
         }
      }
      
      private function getBitmapFilter(param1:Number) : BitmapFilter
      {
         var _loc2_:Number = 0.5;
         var _loc3_:Number = 32;
         var _loc4_:Number = 32;
         var _loc5_:Number = 2;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Number = BitmapFilterQuality.HIGH;
         return new GlowFilter(param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc8_,_loc6_,_loc7_);
      }
      
      private function areaMove(param1:MouseEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:ItemObject = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TileData = null;
         var _loc10_:ItemObject = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:int = int(this.mMap.getWorldToTileX(this.mMap.mouseX));
         var _loc3_:int = int(this.mMap.getWorldToTileY(this.mMap.mouseY));
         this.mAreaDO.x = this.mMap.getTileXToWorld(_loc2_);
         this.mAreaDO.y = this.mMap.getTileYToWorld(_loc3_);
         if(this.areaIsItemsAffectedEnabled())
         {
            _loc4_ = new Array();
            _loc5_ = this.mAreaStartTileY;
            while(_loc5_ < this.mAreaEndTileY)
            {
               _loc7_ = this.mAreaStartTileX;
               while(_loc7_ < this.mAreaEndTileX)
               {
                  _loc8_ = this.mMap.getTileXYToTileIndex(_loc2_ + _loc7_,_loc3_ + _loc5_);
                  _loc9_ = this.mMap.getTileDataFromIndex(_loc8_);
                  if(_loc9_ != null)
                  {
                     _loc10_ = _loc9_.baseItem;
                     if(_loc10_ != null && this.areaIsItemAffected(_loc10_))
                     {
                        _loc11_ = this.mAreaItemsAffected.indexOf(_loc10_);
                        if(_loc11_ > -1)
                        {
                           this.mAreaItemsAffected.splice(_loc11_,1);
                        }
                        _loc12_ = _loc4_.indexOf(_loc10_);
                        if(_loc12_ == -1)
                        {
                           if(_loc10_.itemDefinition.isACommerce())
                           {
                              _loc4_.splice(0,0,_loc10_);
                           }
                           else
                           {
                              _loc4_.push(_loc10_);
                           }
                           _loc10_.setDisplayObjectOutlineVisible(true,ItemObject.INFLUENCE_COLOR);
                        }
                     }
                  }
                  _loc7_++;
               }
               _loc5_++;
            }
            for each(_loc6_ in this.mAreaItemsAffected)
            {
               _loc6_.setDisplayObjectOutlineVisible(false,0);
            }
            this.mAreaItemsAffected = _loc4_;
            _loc4_ = null;
         }
      }
   }
}

