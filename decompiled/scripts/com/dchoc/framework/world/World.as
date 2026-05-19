package com.dchoc.framework.world
{
   import com.dchoc.framework.world.view.IsometricView;
   import com.dchoc.framework.world.view.View;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   
   public class World extends MovieClip implements IWorldInterface
   {
      
      public var mLayerTiles:Sprite;
      
      public var mTileWidthScreen:Number = 64;
      
      public var mTiles:Array;
      
      private var mListenerObjectDestroyed:Function;
      
      public var mElementObjects:Array = new Array();
      
      private var mToolTileClass:Class;
      
      private const HILL_RADIUS:int = 4;
      
      public const STATE_SCROLL:int = 2;
      
      public const STATE_OBJECT_DESTROY:int = 5;
      
      private var mEngineStateTimestamp:Number;
      
      private var mEngineTime:Number = 0;
      
      public var mTileSizeY:Number = 1;
      
      public var mTileSizeX:Number = 1;
      
      private var mSelectedObject:WorldElementObject;
      
      public const STATE_TILE_RAISE:int = 6;
      
      public var mLayerObjects:WorldDisplayContainerSorted;
      
      public const STATE_SELECT:int = 1;
      
      public const STATE_TILE_LOWER:int = 7;
      
      public const STATE_MOVE_OBJECT:int = 3;
      
      private var mMouseDownY:Number;
      
      protected var mView:View;
      
      private var mListenerObjectMoved:Function;
      
      private var mSelectedElement:WorldElement;
      
      private var mMouseDownX:Number;
      
      private var mGridLayer:Shape;
      
      private var mEngineState:int = 0;
      
      public var mTileHeightScreen:Number = 32;
      
      public const STATE_START:int = 0;
      
      private var mSelectedTile:WorldElementTile;
      
      public const STATE_TILE_EDITING:int = 4;
      
      public function World(param1:Number, param2:Number)
      {
         super();
         this.mTileWidthScreen = param1;
         this.mTileHeightScreen = param2;
         this.initView();
         this.initDisplayContainers();
      }
      
      public function getWorldToScreenX(param1:Number, param2:Number, param3:Number) : int
      {
         return this.mView.getWorldToScreenX(param1,param2,param3);
      }
      
      private function reportMouseWheel(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         trace("Event wheel:" + param1.delta);
         if(param1.delta > 0 && width < 3200)
         {
            _loc2_ = 1 + param1.delta / 20;
            width *= _loc2_;
            height *= _loc2_;
         }
         if(param1.delta < 0 && width > 50)
         {
            _loc2_ = 1 / (1 - param1.delta / 20);
            width *= _loc2_;
            height *= _loc2_;
         }
      }
      
      public function getGroundHeight(param1:Number, param2:Number) : Number
      {
         var _loc3_:WorldElement = null;
         if(this.isTilePositionInBoundaries(param1,param2))
         {
            _loc3_ = this.mTiles[param2][param1];
            return _loc3_.mWorldZ;
         }
         return 0;
      }
      
      public function setLevelData(param1:ByteArray) : void
      {
         var _loc3_:String = null;
         var _loc4_:Class = null;
         var _loc5_:WorldElement = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         this.initDisplayContainers();
         var _loc2_:int = param1.readInt();
         this.mTiles = new Array();
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_)
         {
            _loc9_ = param1.readInt();
            this.mTiles[_loc6_] = new Array();
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc3_ = param1.readUTF();
               _loc4_ = getDefinitionByName(_loc3_) as Class;
               _loc5_ = new _loc4_(this);
               _loc5_.restoreFromByteArray(param1);
               this.mTiles[_loc6_][_loc10_] = _loc5_;
               this.mLayerTiles.addChild(_loc5_);
               _loc10_++;
            }
            _loc6_++;
         }
         var _loc7_:int = param1.readInt();
         this.mElementObjects = new Array();
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = param1.readUTF();
            _loc4_ = getDefinitionByName(_loc3_) as Class;
            _loc5_ = new _loc4_(this);
            _loc5_.restoreFromByteArray(param1);
            this.mElementObjects[_loc8_] = _loc5_;
            this.mLayerObjects.addChild(_loc5_);
            _loc8_++;
         }
      }
      
      public function getWorldToRealScreenY(param1:Number, param2:Number, param3:Number) : int
      {
         return y + this.getWorldToScreenY(param1,param2,param3);
      }
      
      private function reportMouseDown(param1:MouseEvent) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SELECT:
               if(this.mSelectedElement == this.mSelectedTile)
               {
                  this.mMouseDownX = this.mouseX;
                  this.mMouseDownY = this.mouseY;
                  this.changeEngineState(this.STATE_SCROLL);
               }
               break;
            case this.STATE_SCROLL:
               break;
            case this.STATE_TILE_EDITING:
               if(Boolean(this.mSelectedTile) && Boolean(this.mToolTileClass))
               {
                  this.mSelectedTile.replaceWith(new this.mToolTileClass(this));
               }
               break;
            case this.STATE_MOVE_OBJECT:
            case this.STATE_OBJECT_DESTROY:
         }
      }
      
      public function setSelectedElement(param1:WorldElement) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SELECT:
            case this.STATE_TILE_EDITING:
            case this.STATE_OBJECT_DESTROY:
            case this.STATE_TILE_RAISE:
            case this.STATE_TILE_LOWER:
               this.mSelectedElement = param1;
         }
      }
      
      private function updateScrolling() : void
      {
         this.scrollGameCanvas((this.mouseX - this.mMouseDownX) * scaleX,(this.mouseY - this.mMouseDownY) * scaleY);
         this.mMouseDownX = this.mouseX;
         this.mMouseDownY = this.mouseY;
      }
      
      public function isTilePositionInBoundaries(param1:Number, param2:Number) : Boolean
      {
         return param1 >= 0 && param2 >= 0 && param2 < this.mTiles.length && param1 < this.mTiles[param2].length;
      }
      
      public function lowerSelectedTileMountain() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:WorldElement = null;
         var _loc1_:Number = -this.HILL_RADIUS;
         while(_loc1_ <= this.HILL_RADIUS)
         {
            _loc2_ = -this.HILL_RADIUS;
            while(_loc2_ <= this.HILL_RADIUS)
            {
               _loc3_ = (this.HILL_RADIUS * this.HILL_RADIUS * 2 - _loc2_ * _loc2_ - _loc1_ * _loc1_) * 0.125 / (this.HILL_RADIUS * this.HILL_RADIUS * 2);
               if(this.isTilePositionInBoundaries(this.mSelectedTile.mWorldX + _loc2_,this.mSelectedTile.mWorldY + _loc1_))
               {
                  _loc4_ = this.mTiles[this.mSelectedTile.mWorldY + _loc1_][this.mSelectedTile.mWorldX + _loc2_];
                  _loc4_.setWorldPosition(_loc4_.mWorldX,_loc4_.mWorldY,_loc4_.mWorldZ - _loc3_);
               }
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function addObject(param1:Class) : WorldElementObject
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:WorldElementObject = new param1(this);
         this.mSelectedObject = _loc2_;
         if(this.mSelectedObject)
         {
            this.mElementObjects[this.mElementObjects.length] = this.mSelectedObject;
            this.mLayerObjects.addChild(this.mSelectedObject);
            _loc3_ = this.getScreenToWorldX(mouseX,mouseY);
            _loc4_ = this.getScreenToWorldY(mouseX,mouseY);
            _loc5_ = this.getGroundHeight(_loc3_,_loc4_);
            this.mSelectedObject.setWorldPosition(_loc3_,_loc4_,_loc5_);
            this.mSelectedObject.updatePhysics(1);
         }
         return _loc2_;
      }
      
      private function reportMouseMove(param1:MouseEvent) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SCROLL:
               this.updateScrolling();
               break;
            case this.STATE_SELECT:
               break;
            case this.STATE_TILE_EDITING:
               if(Boolean(param1.buttonDown) && Boolean(this.mSelectedTile) && Boolean(this.mToolTileClass))
               {
                  this.mSelectedTile.replaceWith(new this.mToolTileClass(this));
               }
               break;
            case this.STATE_MOVE_OBJECT:
         }
      }
      
      private function initDisplayContainers() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren)
         {
            this.removeChildAt(_loc1_);
            _loc1_++;
         }
         this.mLayerObjects = new WorldDisplayContainerSorted();
         this.mLayerObjects.cacheAsBitmap = true;
         this.mLayerTiles = new Sprite();
         this.mLayerTiles.cacheAsBitmap = true;
         this.mGridLayer = new Shape();
         addChild(this.mLayerTiles);
         addChild(this.mLayerObjects);
         addChild(this.mGridLayer);
      }
      
      private function reportMouseClick(param1:MouseEvent) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_TILE_LOWER:
               this.lowerSelectedTileMountain();
               break;
            case this.STATE_TILE_RAISE:
               this.raiseSelectedTileMountain();
               break;
            case this.STATE_SELECT:
            case this.STATE_SCROLL:
            case this.STATE_TILE_EDITING:
            case this.STATE_MOVE_OBJECT:
               break;
            case this.STATE_OBJECT_DESTROY:
               if(this.mSelectedObject == this.mSelectedElement)
               {
                  this.destroyObject(this.mSelectedObject);
               }
         }
      }
      
      private function reportMouseUp(param1:MouseEvent) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SELECT:
               break;
            case this.STATE_SCROLL:
               this.changeEngineState(this.STATE_SELECT);
               break;
            case this.STATE_TILE_EDITING:
               break;
            case this.STATE_MOVE_OBJECT:
               if(this.mListenerObjectMoved != null && Boolean(this.mSelectedObject))
               {
                  this.mListenerObjectMoved(this.mSelectedObject);
               }
               this.changeEngineState(this.STATE_SELECT);
         }
      }
      
      public function initLevel(param1:int, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:WorldElementTile = null;
         this.mTiles = new Array();
         this.mElementObjects = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < param2)
         {
            this.mTiles[_loc3_] = new Array();
            _loc4_ = 0;
            while(_loc4_ < param1)
            {
               _loc5_ = new WorldElementTileGrass(this);
               _loc5_.setWorldPosition(_loc4_,_loc3_,0);
               this.mTiles[_loc3_][_loc4_] = _loc5_;
               this.mLayerTiles.addChild(_loc5_);
               _loc4_++;
            }
            _loc3_++;
         }
      }
      
      public function setSelectedTile(param1:WorldElementTile) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SELECT:
            case this.STATE_TILE_EDITING:
            case this.STATE_TILE_RAISE:
            case this.STATE_TILE_LOWER:
               this.mSelectedTile = param1;
         }
      }
      
      public function addListenerObjectDestroyed(param1:Function) : void
      {
         this.mListenerObjectDestroyed = param1;
      }
      
      public function moveObject() : void
      {
         if(this.mEngineState == this.STATE_SELECT)
         {
            this.changeEngineState(this.STATE_MOVE_OBJECT);
         }
      }
      
      public function selectToolTile(param1:Class) : void
      {
         this.mToolTileClass = param1;
         this.changeEngineState(this.STATE_TILE_EDITING);
      }
      
      private function scrollGameCanvas(param1:Number, param2:Number) : void
      {
         this.x += param1;
         this.y += param2;
      }
      
      public function selectToolRaise() : void
      {
         this.changeEngineState(this.STATE_TILE_RAISE);
      }
      
      public function raiseSelectedTileMountain() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:WorldElement = null;
         var _loc1_:Number = -this.HILL_RADIUS;
         while(_loc1_ <= this.HILL_RADIUS)
         {
            _loc2_ = -this.HILL_RADIUS;
            while(_loc2_ <= this.HILL_RADIUS)
            {
               _loc3_ = (this.HILL_RADIUS * this.HILL_RADIUS * 2 - _loc2_ * _loc2_ - _loc1_ * _loc1_) * 0.125 / (this.HILL_RADIUS * this.HILL_RADIUS * 2);
               if(this.isTilePositionInBoundaries(this.mSelectedTile.mWorldX + _loc2_,this.mSelectedTile.mWorldY + _loc1_))
               {
                  _loc4_ = this.mTiles[this.mSelectedTile.mWorldY + _loc1_][this.mSelectedTile.mWorldX + _loc2_];
                  _loc4_.setWorldPosition(_loc4_.mWorldX,_loc4_.mWorldY,_loc4_.mWorldZ + _loc3_);
               }
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function get view() : View
      {
         return this.mView;
      }
      
      public function changeEngineState(param1:int) : void
      {
         this.mEngineState = param1;
         this.mEngineStateTimestamp = this.mEngineTime;
      }
      
      public function lowerSelectedTile() : void
      {
         this.mSelectedTile.setWorldPosition(this.mSelectedTile.mWorldX,this.mSelectedTile.mWorldY,this.mSelectedTile.mWorldZ - 0.125);
      }
      
      private function updateGrid() : void
      {
         var _loc1_:Graphics = this.mGridLayer.graphics;
         _loc1_.clear();
         if(this.mSelectedElement)
         {
            if(this.mSelectedObject == this.mSelectedElement && this.mSelectedObject.getCollisionObject() != null)
            {
               this.mSelectedElement.drawOnGC(_loc1_,16711680);
            }
            else
            {
               this.mSelectedElement.drawOnGC(_loc1_,65280);
            }
         }
      }
      
      public function getLevelData() : ByteArray
      {
         var _loc2_:WorldElement = null;
         var _loc5_:int = 0;
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeInt(this.mTiles.length);
         var _loc3_:int = 0;
         while(_loc3_ < this.mTiles.length)
         {
            _loc1_.writeInt(this.mTiles[_loc3_].length);
            _loc5_ = 0;
            while(_loc5_ < this.mTiles[_loc3_].length)
            {
               _loc2_ = this.mTiles[_loc3_][_loc5_];
               _loc1_.writeUTF(getQualifiedClassName(_loc2_));
               _loc2_.storeToByteArray(_loc1_);
               _loc5_++;
            }
            _loc3_++;
         }
         _loc1_.writeInt(this.mElementObjects.length);
         var _loc4_:int = 0;
         while(_loc4_ < this.mElementObjects.length)
         {
            _loc2_ = this.mElementObjects[_loc4_];
            _loc1_.writeUTF(getQualifiedClassName(_loc2_));
            _loc2_.storeToByteArray(_loc1_);
            _loc4_++;
         }
         return _loc1_;
      }
      
      public function selectToolDestroy() : void
      {
         this.changeEngineState(this.STATE_OBJECT_DESTROY);
      }
      
      public function setSelectedObject(param1:WorldElementObject) : void
      {
         switch(this.mEngineState)
         {
            case this.STATE_SELECT:
            case this.STATE_OBJECT_DESTROY:
               this.mSelectedObject = param1;
         }
      }
      
      public function selectToolLower() : void
      {
         this.changeEngineState(this.STATE_TILE_LOWER);
      }
      
      public function getWorldToRealScreenFromObjectX(param1:WorldElement) : int
      {
         return x + this.getWorldToScreenX(param1.mWorldX,param1.mWorldY,param1.mWorldZ);
      }
      
      public function logicUpdate(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this.updateGrid();
         this.mLayerObjects.sortChildren();
         switch(this.mEngineState)
         {
            case this.STATE_START:
               stage.addEventListener(MouseEvent.CLICK,this.reportMouseClick);
               stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.reportMouseWheel);
               stage.addEventListener(MouseEvent.MOUSE_UP,this.reportMouseUp);
               addEventListener(MouseEvent.MOUSE_DOWN,this.reportMouseDown);
               stage.addEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMove);
               this.changeEngineState(this.STATE_SELECT);
               break;
            case this.STATE_SELECT:
            case this.STATE_SCROLL:
               break;
            case this.STATE_MOVE_OBJECT:
               if(this.mSelectedObject)
               {
                  _loc3_ = this.getScreenToWorldX(mouseX,mouseY);
                  _loc2_ = this.getScreenToWorldY(mouseX,mouseY);
                  _loc4_ = this.getGroundHeight(_loc3_,_loc2_);
                  this.mSelectedObject.setWorldPosition(_loc3_,_loc2_,_loc4_);
                  this.mSelectedObject.updatePhysics(param1);
               }
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.mElementObjects.length)
         {
            this.mElementObjects[_loc5_].logicUpdate(param1);
            _loc5_++;
         }
      }
      
      public function getWorldToRealScreenFromObjectY(param1:WorldElement) : int
      {
         return y + this.getWorldToScreenY(param1.mWorldX,param1.mWorldY,param1.mWorldZ);
      }
      
      protected function initView() : void
      {
         this.mView = new IsometricView();
         this.mView.setParameters(this.mTileWidthScreen,this.mTileHeightScreen,this.mTileSizeX,this.mTileSizeY);
      }
      
      public function getDisplayObjectContainer() : DisplayObjectContainer
      {
         return this.mLayerObjects;
      }
      
      public function selectToolSelect() : void
      {
         this.changeEngineState(this.STATE_SELECT);
      }
      
      public function setLevelDataTiles(param1:ByteArray) : void
      {
         var _loc3_:String = null;
         var _loc4_:Class = null;
         var _loc5_:WorldElement = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         this.initDisplayContainers();
         var _loc2_:int = param1.readInt();
         this.mTiles = new Array();
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_)
         {
            _loc7_ = param1.readInt();
            this.mTiles[_loc6_] = new Array();
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc3_ = param1.readUTF();
               _loc4_ = getDefinitionByName(_loc3_) as Class;
               _loc5_ = new _loc4_(this);
               _loc5_.restoreFromByteArray(param1);
               this.mTiles[_loc6_][_loc8_] = _loc5_;
               this.mLayerTiles.addChild(_loc5_);
               _loc8_++;
            }
            _loc6_++;
         }
      }
      
      public function getScreenToWorldX(param1:Number, param2:Number) : int
      {
         return this.mView.getScreenToWorldX(param1,param2);
      }
      
      public function getScreenToWorldY(param1:Number, param2:Number) : int
      {
         return this.mView.getScreenToWorldY(param1,param2);
      }
      
      public function destroyObject(param1:WorldElementObject) : void
      {
         var _loc2_:int = 0;
         if(this.mLayerObjects.contains(param1))
         {
            this.mLayerObjects.removeChild(this.mSelectedObject);
            _loc2_ = this.mElementObjects.indexOf(this.mSelectedObject);
            this.mElementObjects[_loc2_] = null;
            this.mSelectedObject = null;
            this.mElementObjects.splice(_loc2_,1);
            trace("Object destroyed");
            if(this.mListenerObjectDestroyed != null && Boolean(param1))
            {
               this.mListenerObjectDestroyed(param1);
            }
            param1 = null;
         }
      }
      
      public function raiseSelectedTile() : void
      {
         this.mSelectedTile.setWorldPosition(this.mSelectedTile.mWorldX,this.mSelectedTile.mWorldY,this.mSelectedTile.mWorldZ + 0.125);
      }
      
      public function getWorldToRealScreenX(param1:Number, param2:Number, param3:Number) : int
      {
         return x + this.getWorldToScreenX(param1,param2,param3);
      }
      
      public function getWorldToScreenY(param1:Number, param2:Number, param3:Number) : int
      {
         return this.mView.getWorldToScreenY(param1,param2,param3);
      }
      
      public function addListenerObjectMoved(param1:Function) : void
      {
         this.mListenerObjectMoved = param1;
      }
   }
}

