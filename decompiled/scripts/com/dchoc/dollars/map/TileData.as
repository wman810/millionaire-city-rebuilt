package com.dchoc.dollars.map
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.logicTiles.LogicTile;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.astar.INode;
   import com.dchoc.dollars.world.items.ItemObject;
   
   public class TileData implements INode
   {
      
      public static const TILE_TERRAIN:int = 0;
      
      public static const TILE_ROAD:int = 1;
      
      public static const TILE_GRASS:int = 2;
      
      public static const TILE_LOGIC_START:int = 3;
      
      private var mIsBuildable:Boolean;
      
      private var mInfluenceItems:Array;
      
      private var mHeuristic:Number;
      
      private var mRow:int;
      
      private var mIsMyTerrain:Boolean;
      
      private var mIsHigh:Boolean = false;
      
      private var mIsRoad:Boolean;
      
      private var mBaseItemObject:ItemObject;
      
      private var mLogicTile:LogicTile;
      
      private var mCol:int;
      
      private var mNeighbors:Array;
      
      private var mTileIndex:int;
      
      private var mIsSolid:Boolean;
      
      private var mShadowItemObject:Array;
      
      public function TileData(param1:int, param2:int, param3:Boolean)
      {
         super();
         this.mCol = param1;
         this.mRow = param2;
         this.mTileIndex = DollarsGame.getCurrentWorld().map.getTileXYToTileIndex(param1,param2);
         this.start();
         this.mIsBuildable = param3;
      }
      
      public function addItemInfluence(param1:ItemObject) : void
      {
         if(this.mInfluenceItems == null)
         {
            this.mInfluenceItems = new Array();
         }
         this.mInfluenceItems.push(param1);
         if(this.isBaseAffectedByInfluence())
         {
            this.mBaseItemObject.registerItemInfluence(param1);
            param1.registerItemInfluence(this.mBaseItemObject);
         }
      }
      
      public function get baseItem() : ItemObject
      {
         return this.mBaseItemObject;
      }
      
      public function setNeighbors(param1:Array) : void
      {
         this.mNeighbors = param1;
      }
      
      public function set baseItem(param1:ItemObject) : void
      {
         var _loc2_:ItemObject = null;
         if(this.isBaseAffectedByInfluence())
         {
            for each(_loc2_ in this.mInfluenceItems)
            {
               this.mBaseItemObject.unregisterItemInfluence(_loc2_);
               _loc2_.unregisterItemInfluence(this.mBaseItemObject);
            }
         }
         this.mBaseItemObject = param1;
         if(this.isBaseAffectedByInfluence())
         {
            for each(_loc2_ in this.mInfluenceItems)
            {
               this.mBaseItemObject.registerItemInfluence(_loc2_);
               _loc2_.registerItemInfluence(this.mBaseItemObject);
            }
         }
      }
      
      public function getNeighbors() : Array
      {
         return this.mNeighbors;
      }
      
      public function removeItemInfluence(param1:ItemObject) : void
      {
         var _loc2_:int = 0;
         if(this.mInfluenceItems != null)
         {
            _loc2_ = this.mInfluenceItems.indexOf(param1);
            if(_loc2_ > -1)
            {
               this.mInfluenceItems.splice(_loc2_,1);
            }
         }
         if(this.isBaseAffectedByInfluence())
         {
            this.mBaseItemObject.unregisterItemInfluence(param1);
            param1.unregisterItemInfluence(this.mBaseItemObject);
         }
      }
      
      public function getIsBuildable() : Boolean
      {
         return this.mIsBuildable && this.mBaseItemObject == null && !this.mIsRoad && !this.mIsSolid;
      }
      
      public function canBeStepped() : Boolean
      {
         return this.isRoad;
      }
      
      public function undoMouseOver() : void
      {
         var _loc1_:ItemObject = null;
         if(this.needsToCheckShadow())
         {
            for each(_loc1_ in this.mShadowItemObject)
            {
               _loc1_.displayObjectL0.alpha = 1;
               _loc1_.displayObjectL1.alpha = 1;
            }
         }
      }
      
      public function getHeuristic() : Number
      {
         return this.mHeuristic;
      }
      
      public function setRow(param1:int) : void
      {
         this.mRow = param1;
      }
      
      public function get isSolid() : Boolean
      {
         return this.mIsSolid;
      }
      
      public function setHigh(param1:Boolean) : void
      {
         this.mIsHigh = param1;
      }
      
      public function getRow() : int
      {
         return this.mRow;
      }
      
      public function isBaseAffectedByInfluence() : Boolean
      {
         return this.mBaseItemObject != null && this.mBaseItemObject.itemDefinition.isAffectedByInfluence();
      }
      
      public function isPassable() : Boolean
      {
         return this.mIsRoad && DollarsGame.getCurrentWorld().map.mapData[this.mTileIndex] != 66;
      }
      
      private function needsToCheckShadow() : Boolean
      {
         return Tutorial.smTutorialEnd && this.mShadowItemObject != null && DollarsGame.getCurrentWorld().map.isTileInAreaMine(this.mTileIndex);
      }
      
      public function set isSolid(param1:Boolean) : void
      {
         this.mIsSolid = param1;
      }
      
      public function isBusy() : Boolean
      {
         return this.mBaseItemObject != null || this.mIsRoad || this.mIsSolid;
      }
      
      public function isRoadable() : Boolean
      {
         if(!this.mIsRoad)
         {
            if(this.mBaseItemObject == null)
            {
               return true;
            }
            if(this.mIsHigh)
            {
               return true;
            }
         }
         return false;
      }
      
      public function set isMyTerrain(param1:Boolean) : void
      {
         this.mIsMyTerrain = param1;
      }
      
      public function setHeuristic(param1:Number) : void
      {
         this.mHeuristic = param1;
      }
      
      public function showPath() : void
      {
      }
      
      public function getCol() : int
      {
         return this.mCol;
      }
      
      public function getNodeId() : int
      {
         return this.mTileIndex;
      }
      
      public function isOnTerrain() : Boolean
      {
         return this.mIsMyTerrain && this.mBaseItemObject == null && !this.mIsRoad && !this.mIsSolid;
      }
      
      public function setCol(param1:int) : void
      {
         this.mCol = param1;
      }
      
      public function doMouseOver() : void
      {
         var _loc1_:ItemObject = null;
         if(this.needsToCheckShadow())
         {
            for each(_loc1_ in this.mShadowItemObject)
            {
               _loc1_.displayObjectL0.alpha = 0.3;
               _loc1_.displayObjectL1.alpha = 0.3;
            }
         }
      }
      
      public function getNodeType() : String
      {
         if(this.mIsRoad)
         {
            return "road";
         }
         if(this.isBusy())
         {
            return "busy";
         }
         return "grass";
      }
      
      public function addShadowItem(param1:ItemObject) : void
      {
         if(this.mShadowItemObject == null)
         {
            this.mShadowItemObject = new Array();
         }
         this.mShadowItemObject.push(param1);
      }
      
      public function get tileIndex() : int
      {
         return this.mTileIndex;
      }
      
      public function unShowStartDot() : void
      {
      }
      
      public function isRoadAllowed() : Boolean
      {
         if(this.mIsHigh && !this.mIsRoad)
         {
            return true;
         }
         return !this.isBusy() && this.getIsBuildable();
      }
      
      public function get isMyTerrain() : Boolean
      {
         return this.mIsMyTerrain;
      }
      
      public function start() : void
      {
      }
      
      public function set isRoad(param1:Boolean) : void
      {
         this.mIsRoad = param1;
      }
      
      public function getGroundType() : int
      {
         var _loc1_:int = TILE_GRASS;
         if(this.mBaseItemObject == null)
         {
            if(this.mIsRoad)
            {
               _loc1_ = TILE_ROAD;
            }
            if(this.mIsMyTerrain)
            {
               _loc1_ = TILE_TERRAIN;
            }
         }
         else if(this.mIsHigh)
         {
            if(this.mIsRoad)
            {
               _loc1_ = TILE_ROAD;
            }
            if(this.mIsMyTerrain)
            {
               _loc1_ = TILE_TERRAIN;
            }
         }
         return _loc1_;
      }
      
      public function setLogicTile(param1:LogicTile) : void
      {
         this.mLogicTile = param1;
      }
      
      public function isHigh() : Boolean
      {
         return this.mIsHigh;
      }
      
      public function showEndDot() : void
      {
      }
      
      public function get isRoad() : Boolean
      {
         return this.mIsRoad;
      }
      
      public function getLogicTile() : LogicTile
      {
         return this.mLogicTile;
      }
      
      public function removeShadowItem(param1:ItemObject) : void
      {
         var _loc2_:int = 0;
         if(this.mShadowItemObject != null)
         {
            _loc2_ = this.mShadowItemObject.indexOf(param1);
            if(_loc2_ > -1)
            {
               this.mShadowItemObject.splice(_loc2_,1);
            }
         }
      }
      
      public function showStartDot() : void
      {
      }
      
      public function destroy() : void
      {
         var _loc1_:* = 0;
         if(this.mShadowItemObject != null)
         {
            _loc1_ = int(this.mShadowItemObject.length - 1);
            while(_loc1_ > -1)
            {
               this.mShadowItemObject[_loc1_] = null;
               _loc1_--;
            }
            this.mShadowItemObject = null;
         }
         if(this.mInfluenceItems != null)
         {
            _loc1_ = int(this.mInfluenceItems.length - 1);
            while(_loc1_ > -1)
            {
               this.mInfluenceItems[_loc1_] = null;
               _loc1_--;
            }
            this.mInfluenceItems = null;
         }
      }
      
      public function unShowPath() : void
      {
      }
      
      public function setIsBuildable(param1:Boolean) : void
      {
         this.mIsBuildable = param1;
      }
      
      public function unShowEndDot() : void
      {
      }
   }
}

