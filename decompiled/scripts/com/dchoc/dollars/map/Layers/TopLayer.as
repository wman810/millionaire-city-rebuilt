package com.dchoc.dollars.map.Layers
{
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.animations.DCBitmapSprite;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.StageQuality;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class TopLayer
   {
      
      public static var PNG_CONTRACT:String = ModelConfig.CONTRACT_PNG_SKU;
      
      public static var PNG_RENT:String = ModelConfig.RENT_PNG_SKU;
      
      public static const MASK:String = "_MASK";
      
      public static const TILE_WIDTH:int = 75;
      
      public static const TILE_HEIGHT:int = 75;
      
      public static const NUM_FRAMES:int = 6;
      
      private static const DIVISIONS:int = 5;
      
      private static const NUM_BUFFER:int = DIVISIONS * DIVISIONS;
      
      private var mFrame:int;
      
      private var mScreenWidth:int;
      
      private var mScreenBms:Bitmap;
      
      private var mItemsToDraw:Vector.<DCBitmapSprite>;
      
      private var mAnimation:Vector.<Object>;
      
      private var mItemsToDrawCount:int;
      
      private var mSectorPos:Point;
      
      private var mTotalItems:Vector.<DCBitmapSprite>;
      
      private var mMap:Map;
      
      private var mXInArea:int;
      
      private var mScreenHeight:int;
      
      private var mSectorHeight:Vector.<int>;
      
      private var mItemsPerSector:Vector.<Vector.<DCBitmapSprite>>;
      
      private var mItemsToRemove:Vector.<Vector.<DCBitmapSprite>>;
      
      private var mSectorWidth:Vector.<int>;
      
      private var mYTiles:int;
      
      private var mXTiles:int;
      
      private var mItemsToRemoveCount:int;
      
      private var mFrameTime:int;
      
      private var mRect:Rectangle;
      
      private var mScreenBmds:BitmapData;
      
      public var mPngCatalog:Dictionary;
      
      private var mYInArea:int;
      
      public function TopLayer(param1:Map)
      {
         super();
         this.mMap = param1;
         this.mScreenBms = new Bitmap();
         this.changeQuality(Dollars.getQuality() == StageQuality.HIGH);
         this.mSectorPos = new Point();
         this.mAnimation = new Vector.<Object>(NUM_FRAMES,true);
         this.mAnimation[0] = {
            "time":150,
            "frame":0
         };
         this.mAnimation[1] = {
            "time":130,
            "frame":1
         };
         this.mAnimation[2] = {
            "time":130,
            "frame":2
         };
         this.mAnimation[3] = {
            "time":150,
            "frame":3
         };
         this.mAnimation[4] = {
            "time":130,
            "frame":2
         };
         this.mAnimation[5] = {
            "time":130,
            "frame":1
         };
         this.mScreenWidth = Dollars.smStage.stageWidth;
         this.mScreenHeight = Dollars.smStage.stageHeight;
         this.mPngCatalog = new Dictionary();
      }
      
      public function getResource(param1:String) : BitmapData
      {
         var _loc3_:BitmapData = null;
         var _loc2_:BitmapData = this.mPngCatalog[param1];
         if(_loc2_ == null)
         {
            _loc2_ = DCResourceManager.getInstance().get(param1);
            _loc3_ = new BitmapData(_loc2_.width,_loc2_.height);
            _loc3_.draw(_loc2_,null,null,BlendMode.ALPHA);
            this.mPngCatalog[param1] = _loc2_;
            this.mPngCatalog[param1 + MASK] = _loc3_;
         }
         return _loc2_;
      }
      
      public function destroy() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(this.mScreenBms != null)
         {
            if(this.mScreenBmds != null)
            {
               this.mScreenBmds.dispose();
            }
            this.mScreenBmds = null;
            this.mScreenBms = null;
         }
         if(this.mPngCatalog != null)
         {
            if(this.mPngCatalog[PNG_CONTRACT + MASK] != null)
            {
               this.mPngCatalog[PNG_CONTRACT + MASK].dispose();
               this.mPngCatalog[PNG_CONTRACT + MASK] = null;
            }
            if(this.mPngCatalog[PNG_RENT + MASK] != null)
            {
               this.mPngCatalog[PNG_RENT + MASK].dispose();
               this.mPngCatalog[PNG_RENT + MASK] = null;
            }
            _loc1_ = ItemDefinitionManager.getInstance().getDefinitions(ItemDefinition.TYPE_COMMERCES_ID);
            _loc2_ = int(_loc1_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_ = _loc1_[_loc4_].getCommerceIcon() + MASK;
               if(this.mPngCatalog[_loc3_] != null)
               {
                  this.mPngCatalog[_loc3_].dispose();
                  this.mPngCatalog[_loc3_] = null;
               }
               _loc4_++;
            }
            this.mPngCatalog = null;
         }
      }
      
      public function eraseItemInLayer() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DCBitmapSprite = null;
         var _loc5_:int = 0;
         if(this.mScreenBmds != null)
         {
            this.mScreenBmds.lock();
            _loc2_ = 0;
            while(_loc2_ < NUM_BUFFER)
            {
               _loc1_ = int(this.mItemsToRemove[_loc2_].length);
               _loc3_ = 0;
               while(_loc3_ < _loc1_)
               {
                  _loc4_ = this.mItemsToRemove[_loc2_][_loc3_];
                  _loc4_.remove(this.mScreenBmds);
                  this.mItemsPerSector[_loc2_].splice(this.mItemsPerSector[_loc2_].indexOf(_loc4_),1);
                  --this.mItemsToDrawCount;
                  _loc5_ = this.mTotalItems.indexOf(_loc4_);
                  if(_loc5_ > -1)
                  {
                     this.mTotalItems.splice(_loc5_,1);
                  }
                  _loc3_++;
               }
               this.mItemsToRemove[_loc2_].splice(0,this.mItemsToRemove[_loc2_].length);
               this.mItemsToRemoveCount = 0;
               _loc2_++;
            }
            this.mScreenBmds.unlock();
         }
      }
      
      public function getBitmap() : DisplayObject
      {
         return this.mScreenBms;
      }
      
      public function drawItemInLayer() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.mScreenBmds != null)
         {
            _loc3_ = int(this.mTotalItems.length);
            this.mScreenBmds.lock();
            _loc1_ = 0;
            while(_loc1_ < _loc3_)
            {
               this.mTotalItems[_loc1_].remove(this.mScreenBmds);
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _loc3_)
            {
               this.mTotalItems[_loc1_].draw(this.mScreenBmds);
               this.mTotalItems[_loc1_].hasToDraw = false;
               _loc1_++;
            }
            this.mScreenBmds.unlock();
         }
      }
      
      public function changeQuality(param1:Boolean) : void
      {
         if(this.mScreenBms != null)
         {
            this.mScreenBms.smoothing = param1;
         }
      }
      
      public function addItemInLayer(param1:DCBitmapSprite, param2:ItemObject) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:int = param2.itemDefinition.baseCols;
         var _loc4_:int = param2.itemDefinition.baseRows;
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc6_:int = param2.displayObjectL0.depth;
         var _loc9_:int = 0;
         while(_loc9_ < _loc4_)
         {
            _loc6_ = param2.displayObjectL0.depth - _loc9_ * this.mMap.mapTileWidth;
            _loc10_ = 0;
            while(_loc10_ < _loc3_)
            {
               _loc6_ -= _loc10_;
               _loc8_ = 0;
               _loc11_ = this.getBufferIndex(_loc6_);
               if(_loc5_.length > 0)
               {
                  for each(_loc7_ in _loc5_)
                  {
                     if(_loc7_ == _loc11_)
                     {
                        _loc8_++;
                     }
                  }
               }
               if(_loc8_ == 0)
               {
                  _loc5_.push(_loc11_);
                  this.mItemsPerSector[_loc11_].push(param1);
                  ++this.mItemsToDrawCount;
               }
               _loc10_++;
            }
            _loc9_++;
         }
         this.mTotalItems.push(param1);
      }
      
      private function getBufferIndex(param1:int) : int
      {
         var _loc2_:int = param1 % this.mMap.mapTileWidth;
         var _loc3_:int = param1 / this.mMap.mapTileHeight / this.mXTiles;
         _loc2_ /= this.mXTiles;
         if(_loc2_ >= DIVISIONS)
         {
            _loc2_ = DIVISIONS - 1;
         }
         if(_loc3_ >= DIVISIONS)
         {
            _loc3_ = DIVISIONS - 1;
         }
         return _loc3_ * DIVISIONS + _loc2_;
      }
      
      public function createLayerBuffers(param1:int, param2:int) : void
      {
         this.mXTiles = this.mMap.mapTileWidth / DIVISIONS;
         this.mYTiles = this.mMap.mapTileHeight / DIVISIONS;
         this.mItemsPerSector = new Vector.<Vector.<DCBitmapSprite>>(NUM_BUFFER,true);
         this.mItemsToRemove = new Vector.<Vector.<DCBitmapSprite>>(NUM_BUFFER,true);
         this.mTotalItems = new Vector.<DCBitmapSprite>();
         this.mSectorWidth = new Vector.<int>(NUM_BUFFER,true);
         this.mSectorHeight = new Vector.<int>(NUM_BUFFER,true);
         this.mScreenBmds = new BitmapData(param1,param2,true,0);
         this.mScreenBms.bitmapData = this.mScreenBmds;
         this.mScreenBms.smoothing = Dollars.smStage.quality.toUpperCase() == StageQuality.HIGH.toUpperCase();
         this.mRect = new Rectangle(0,0,param1,param2);
         var _loc3_:int = 0;
         while(_loc3_ < NUM_BUFFER)
         {
            this.mItemsPerSector[_loc3_] = new Vector.<DCBitmapSprite>();
            this.mItemsToRemove[_loc3_] = new Vector.<DCBitmapSprite>();
            this.mSectorWidth[_loc3_] = this.mXTiles;
            if(_loc3_ % DIVISIONS == DIVISIONS - 1)
            {
               this.mSectorWidth[_loc3_] = this.mMap.mapTileWidth - this.mXTiles * (DIVISIONS - 1);
            }
            this.mSectorWidth[_loc3_] *= this.mMap.tileWidth;
            this.mSectorHeight[_loc3_] = this.mYTiles;
            if(int(_loc3_ / DIVISIONS) == DIVISIONS - 1)
            {
               this.mSectorHeight[_loc3_] = this.mMap.mapTileHeight - this.mYTiles * (DIVISIONS - 1);
            }
            this.mSectorHeight[_loc3_] *= this.mMap.tileHeight;
            _loc3_++;
         }
      }
      
      public function updateSectors() : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:DCBitmapSprite = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc1_:Vector.<int> = new Vector.<int>();
         this.mSectorPos.x = 0;
         this.mSectorPos.y = 0;
         this.mSectorPos = this.mScreenBms.localToGlobal(this.mSectorPos);
         var _loc2_:Number = this.mSectorPos.x;
         var _loc3_:Number = this.mSectorPos.y;
         var _loc4_:Number = this.mSectorPos.x;
         var _loc5_:Number = this.mSectorPos.y;
         var _loc6_:Number = this.mMap.scaleX;
         var _loc9_:int = 0;
         while(_loc9_ < NUM_BUFFER)
         {
            _loc7_ = this.mSectorWidth[_loc9_] * _loc6_;
            _loc8_ = this.mSectorHeight[_loc9_] * _loc6_;
            if(_loc2_ + _loc7_ >= 0 && _loc2_ <= this.mScreenWidth && _loc3_ + _loc8_ >= 0 && _loc3_ <= this.mScreenHeight)
            {
               _loc1_.push(_loc9_);
            }
            _loc2_ += _loc7_;
            if(_loc9_ % DIVISIONS == DIVISIONS - 1)
            {
               _loc2_ = _loc4_;
               _loc3_ += _loc8_;
            }
            _loc9_++;
         }
         var _loc10_:int = int(_loc1_.length);
         var _loc12_:Number = TILE_WIDTH * _loc6_;
         var _loc13_:Number = TILE_HEIGHT * _loc6_;
         var _loc14_:Number = this.mMap.x;
         var _loc15_:Number = this.mMap.y;
         _loc9_ = 0;
         while(_loc9_ < _loc10_)
         {
            for each(_loc11_ in this.mItemsPerSector[_loc1_[_loc9_]])
            {
               _loc16_ = _loc11_.x * _loc6_ + _loc14_;
               _loc17_ = _loc11_.y * _loc6_ + _loc15_;
               _loc11_.hasToDraw = _loc16_ + _loc12_ > 0 && _loc16_ < this.mScreenWidth && _loc17_ + _loc13_ > 0 && _loc17_ < this.mScreenHeight;
            }
            _loc9_++;
         }
      }
      
      public function logicUpdate(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.mItemsToRemoveCount > 0)
         {
            this.eraseItemInLayer();
         }
         if(this.mItemsToDrawCount > 0)
         {
            this.mFrameTime -= param1;
            if(this.mFrameTime <= 0)
            {
               this.updateSectors();
               this.mFrame = (this.mFrame + 1) % NUM_FRAMES;
               this.mFrameTime = this.mAnimation[this.mFrame].time;
               _loc2_ = int(this.mTotalItems.length);
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  this.mTotalItems[_loc3_].setCurrentFrame(this.mAnimation[this.mFrame].frame);
                  _loc3_++;
               }
               this.drawItemInLayer();
            }
         }
      }
      
      public function setScreen(param1:Number, param2:Number) : void
      {
         this.mScreenWidth = param1;
         this.mScreenHeight = param2;
      }
      
      public function removeItemInLayer(param1:DCBitmapSprite, param2:ItemObject) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:int = param2.itemDefinition.baseCols;
         var _loc4_:int = param2.itemDefinition.baseRows;
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc6_:int = param2.displayObjectL0.depth;
         param1.visible = true;
         param1.hasToDraw = true;
         var _loc9_:int = 0;
         while(_loc9_ < _loc4_)
         {
            _loc6_ = param2.displayObjectL0.depth - _loc9_ * this.mMap.mapTileWidth;
            _loc10_ = 0;
            while(_loc10_ < _loc3_)
            {
               _loc6_ -= _loc10_;
               _loc8_ = 0;
               if(_loc5_.length > 0)
               {
                  for each(_loc7_ in _loc5_)
                  {
                     if(_loc7_ == this.getBufferIndex(_loc6_))
                     {
                        _loc8_++;
                     }
                  }
               }
               if(_loc8_ == 0)
               {
                  _loc5_.push(this.getBufferIndex(_loc6_));
                  this.mItemsToRemove[this.getBufferIndex(_loc6_)].push(param1);
                  ++this.mItemsToRemoveCount;
               }
               _loc10_++;
            }
            _loc9_++;
         }
      }
   }
}

