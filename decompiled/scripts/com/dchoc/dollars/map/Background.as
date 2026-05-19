package com.dchoc.dollars.map
{
   import com.dchoc.dollars.GUI.PopupConfirmExpansion;
   import com.dchoc.dollars.GUI.hud.Plot;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.animations.ItemSprite;
   import com.dchoc.dollars.utils.particles.climate.ClimateManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class Background extends MovieClip
   {
      
      public static const TILE_MAX:int = 0;
      
      public static const TERRAIN_SKU:String = "Terrain";
      
      public static const BACKGROUND_COLOR:int = 16777215;
      
      public static const FENCE_SKU:String = "Fence";
      
      private var mXTiles:int;
      
      private var mFencesIsBuilt:Boolean;
      
      private const DIVISIONS:int = 3;
      
      private var mScreenBmds:Array;
      
      private var mScreenBms:Array;
      
      private var mForSales:Array;
      
      private var mTileSetBmd:BitmapData;
      
      private var mYTiles:int;
      
      private var mFencesDO:Dictionary;
      
      public var mExpansions:Array;
      
      private var mMap:Map;
      
      private var mFencesIndices:Array;
      
      private var mBackground:Sprite;
      
      public function Background(param1:Map)
      {
         super();
         this.mMap = param1;
         this.load();
      }
      
      public function createBackgroundBuffers(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:BitmapData = null;
         var _loc6_:Bitmap = null;
         this.mXTiles = this.mMap.mapTileWidth / this.DIVISIONS;
         if(this.mMap.mapTileWidth % this.DIVISIONS > 0)
         {
            ++this.mXTiles;
         }
         var _loc2_:int = int(this.mMap.mapTileHeight);
         this.mYTiles = _loc2_ / this.DIVISIONS;
         if(_loc2_ % this.DIVISIONS > 0)
         {
            ++this.mYTiles;
         }
         _loc3_ = this.mYTiles * this.mMap.tileHeight;
         _loc4_ = this.mXTiles * this.mMap.tileWidth;
         if(param1 == 0)
         {
            addChild(this.mBackground);
            if(Config.USE_CLIMATE)
            {
               ClimateManager.getInstance().init(this.mBackground.width - this.mMap.tileWidth * 2,this.mBackground.height - this.mMap.tileHeight * 5,this.mMap,ClimateManager.TYPE_SNOW);
               this.mMap.addChild(ClimateManager.getInstance());
            }
         }
         switch(param1)
         {
            case 0:
               this.mScreenBmds = new Array();
               this.mScreenBms = new Array();
         }
         _loc5_ = new BitmapData(_loc4_,_loc3_,true,0);
         this.mScreenBmds.push(_loc5_);
         _loc6_ = new Bitmap(_loc5_);
         _loc6_.x = _loc4_ * (param1 % this.DIVISIONS);
         _loc6_.y = _loc3_ * int(param1 / this.DIVISIONS);
         this.mScreenBms.push(_loc6_);
         if(!contains(_loc6_))
         {
            addChild(_loc6_);
         }
      }
      
      private function fencesUnbuild() : void
      {
         var _loc1_:String = null;
         if(this.mFencesIsBuilt)
         {
            for each(_loc1_ in this.mFencesIndices)
            {
               this.fencesRemoveFence(_loc1_);
            }
            this.mFencesIsBuilt = false;
         }
      }
      
      private function fencesAddFence(param1:String) : void
      {
         var _loc2_:ItemSprite = this.mFencesDO[param1] as ItemSprite;
         this.mMap.mItemObjectsLayerBottom.addChild(_loc2_);
      }
      
      private function fencesRemoveFence(param1:String) : void
      {
         var _loc2_:ItemSprite = this.mFencesDO[param1] as ItemSprite;
         if(_loc2_ != null && this.mMap.mItemObjectsLayerBottom.contains(_loc2_))
         {
            this.mMap.mItemObjectsLayerBottom.removeChild(_loc2_);
            _loc2_.destroy();
         }
      }
      
      public function end() : void
      {
      }
      
      public function start() : void
      {
      }
      
      public function getForSalesSignUnlock(param1:int) : void
      {
         var _loc2_:ItemSprite = this.mForSales[param1];
         Sprite(_loc2_.getChildAt(0)).getChildByName("locked").visible = false;
      }
      
      private function fencesLoad() : void
      {
         var _loc1_:RulesFacade = null;
         if(this.mFencesDO == null)
         {
            _loc1_ = RulesFacade.getInstance();
            this.mFencesDO = new Dictionary(true);
            this.mFencesIndices = new Array();
            this.mFencesIsBuilt = false;
         }
      }
      
      public function setTileSet(param1:BitmapData) : void
      {
         this.mTileSetBmd = param1;
      }
      
      public function setMutable(param1:Boolean) : void
      {
         this.mBackground.cacheAsBitmap = !param1;
      }
      
      private function fencesBuild() : void
      {
         var _loc1_:Profile = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:RulesFacade = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Boolean = false;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:Array = null;
         var _loc16_:ItemSprite = null;
         var _loc17_:Sprite = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         if(!this.mFencesIsBuilt)
         {
            _loc1_ = DollarsGame.getProfileUniverse();
            _loc2_ = MapDefinition.getInstance().getExpansionsSide();
            _loc3_ = MapDefinition.getInstance().getAreaCentral();
            _loc4_ = _loc3_ / _loc2_;
            _loc5_ = RulesFacade.getInstance();
            _loc6_ = _loc5_.expansionsGetConsecutivePlotsWithSameUnlockOrder();
            _loc7_ = _loc5_.expansionsGetPlotsCount();
            _loc8_ = _loc5_.expansionsGetConsecutivePlotsWithSameUnlockOrderCount();
            _loc9_ = _loc7_ + _loc8_;
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc12_ = "fence_";
               if(_loc10_ < _loc7_)
               {
                  _loc11_ = !_loc1_.isExpansionAreaMine(_loc10_);
                  _loc14_ = _loc10_ + "";
                  _loc13_ = _loc10_;
               }
               else
               {
                  _loc14_ = _loc6_[_loc10_ - _loc7_];
                  _loc15_ = _loc14_.split("_");
                  _loc13_ = parseInt(_loc15_[0]);
                  _loc11_ = !_loc1_.isExpansionAreaMine(_loc13_) || !_loc1_.isExpansionAreaMine(parseInt(_loc15_[1]));
               }
               _loc12_ += _loc14_;
               if(_loc11_)
               {
                  _loc16_ = new ItemSprite();
                  _loc17_ = new (DCResourceManager.getInstance().getSWFClass(FENCE_SKU,_loc12_))();
                  _loc16_.addChild(_loc17_);
                  _loc18_ = _loc5_.expansionsGetPlotHeight(_loc13_);
                  _loc19_ = _loc5_.expansionsGetPlotX(_loc13_);
                  _loc20_ = _loc5_.expansionsGetPlotY(_loc13_);
                  _loc21_ = _loc13_ / _loc2_;
                  if(_loc21_ <= _loc4_)
                  {
                     _loc20_ += _loc18_;
                  }
                  _loc16_.depth = this.mMap.getWorldToTileIndex(_loc19_,_loc20_,0,true,false);
                  this.mFencesDO[_loc14_] = _loc16_;
                  this.fencesAddFence(_loc14_);
                  this.mFencesIndices.push(_loc14_);
               }
               _loc10_++;
            }
            this.mMap.mItemObjectsLayerBottom.sortDisplayList();
            this.mFencesIsBuilt = true;
         }
      }
      
      public function load() : void
      {
         if(this.mBackground == null)
         {
            this.mBackground = new (DCResourceManager.getInstance().getSWFClass(TERRAIN_SKU,"background"))();
            this.mBackground.cacheAsBitmap = true;
         }
         this.fencesLoad();
      }
      
      public function build() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:MapDefinition = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Rectangle = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:* = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:Rectangle = null;
         var _loc25_:Point = null;
         if(this.mScreenBmds != null)
         {
            _loc1_ = this.mMap.mapData;
            _loc2_ = this.mMap.mapDataChanges;
            _loc3_ = MapDefinition.getInstance();
            _loc4_ = this.mMap.mapTileWidth / this.DIVISIONS;
            _loc5_ = this.mMap.mapRealRows / this.DIVISIONS;
            _loc6_ = _loc5_ * this.mMap.tileHeight;
            _loc7_ = _loc4_ * this.mMap.tileWidth;
            _loc8_ = 0;
            _loc9_ = 0;
            for each(_loc11_ in _loc2_)
            {
               _loc12_ = _loc11_ % (this.mXTiles * this.DIVISIONS);
               _loc13_ = _loc11_ / (this.mXTiles * this.DIVISIONS);
               _loc14_ = _loc12_ / this.mXTiles;
               _loc15_ = _loc13_ / this.mYTiles;
               _loc16_ = _loc12_ % this.mXTiles;
               _loc17_ = _loc13_ % this.mYTiles;
               _loc18_ = int(_loc1_[_loc11_]);
               if(_loc18_ > 0)
               {
                  _loc18_--;
                  _loc19_ = _loc16_ * this.mMap.tileWidth;
                  _loc20_ = _loc17_ * this.mMap.tileHeight;
                  _loc21_ = _loc15_ * this.DIVISIONS + _loc14_;
                  _loc22_ = _loc18_ % 16 * this.mMap.tileWidth;
                  _loc23_ = int(_loc18_ / 16) * this.mMap.tileHeight;
                  _loc24_ = new Rectangle(_loc22_,_loc23_,this.mMap.tileWidth,this.mMap.tileHeight);
                  _loc25_ = new Point(_loc19_,_loc20_);
                  this.mScreenBmds[_loc21_].copyPixels(this.mTileSetBmd,_loc24_,_loc25_);
                  if(_loc18_ == 0)
                  {
                     _loc10_ = new Rectangle(_loc19_,_loc20_,this.mMap.tileWidth,this.mMap.tileHeight);
                     this.mScreenBmds[_loc21_].fillRect(_loc10_,0);
                  }
               }
            }
            _loc2_.splice(0,_loc2_.length);
            this.fencesBuild();
         }
      }
      
      public function createExpansions() : void
      {
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Shape = null;
         var _loc10_:ItemSprite = null;
         var _loc11_:Sprite = null;
         var _loc12_:Profile = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:MapDefinition = MapDefinition.getInstance();
         this.mExpansions = new Array();
         this.mForSales = new Array();
         var _loc3_:int = _loc2_.getExpansionsSide();
         var _loc4_:int = _loc2_.getAreaCentral();
         _loc5_ = _loc4_ % _loc3_;
         var _loc6_:int = _loc4_ / _loc3_;
         var _loc7_:int = _loc1_.expansionsGetPlotsCount();
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc9_ = new Shape();
            _loc10_ = new ItemSprite();
            _loc11_ = new (DCResourceManager.getInstance().getSWFClass(PopupConfirmExpansion.SKU,"popup_for_sale_expansion"))();
            _loc10_.addChild(_loc11_);
            this.mForSales.push(_loc10_);
            TextManager.reformatTextField(TextField(_loc11_.getChildByName("prize")));
            TextField(_loc11_.getChildByName("prize")).text = TextManager.getText(TextIDs.TID_CLICK_TO_BUY);
            TextManager.reformatTextField(TextField(_loc11_.getChildByName("TopText")));
            TextField(_loc11_.getChildByName("TopText")).text = TextManager.getText(TextIDs.TID_PANEL_EXPANSION_FOR_SALE);
            _loc9_.graphics.beginFill(0,0.3);
            _loc9_.graphics.drawRect(0,0,_loc1_.expansionsGetPlotWidth(_loc8_),_loc1_.expansionsGetPlotHeight(_loc8_));
            _loc9_.graphics.endFill();
            _loc9_.x = _loc1_.expansionsGetPlotX(_loc8_);
            _loc9_.y = _loc1_.expansionsGetPlotY(_loc8_);
            this.mExpansions.push(_loc9_);
            _loc12_ = DollarsGame.getProfileUniverse();
            if(_loc12_.plots[_loc8_] != Plot.TYPE_FULL)
            {
               this.mMap.addChildAt(_loc9_,1);
               _loc13_ = _loc1_.expansionsGetPlotWidth(_loc8_);
               _loc14_ = _loc9_.height;
               _loc10_.x = (_loc13_ >> 1) + _loc9_.x;
               _loc10_.y = (_loc14_ >> 1) + _loc9_.y;
               _loc15_ = _loc8_ % _loc3_;
               if(_loc15_ < _loc5_)
               {
                  _loc10_.x += _loc13_ >> 2;
               }
               else if(_loc15_ > _loc5_)
               {
                  _loc10_.x -= _loc13_ >> 2;
               }
               _loc16_ = _loc8_ / _loc3_;
               if(_loc16_ < _loc6_)
               {
                  _loc10_.y += _loc14_ >> 2;
               }
               else if(_loc16_ > _loc6_)
               {
                  _loc10_.y -= _loc14_ >> 2;
               }
               this.mMap.mItemObjectsLayerBottom.addChild(_loc10_);
               _loc17_ = this.mMap.getWorldToTileIndex(_loc10_.x + _loc10_.width / 4,_loc10_.y,0);
               _loc10_.depth = _loc17_;
               if(_loc12_.plots[_loc8_] == Plot.TYPE_NORMAL)
               {
                  _loc11_.getChildByName("locked").visible = false;
               }
            }
            _loc8_++;
         }
         this.mMap.mItemObjectsLayerBottom.sortDisplayList();
      }
      
      public function areaBuy(param1:int) : void
      {
         var _loc2_:ItemSprite = this.mForSales[param1];
         this.mMap.mItemObjectsLayerBottom.removeChild(_loc2_);
         this.mForSales[param1] = null;
         var _loc3_:String = param1 + "";
         this.fencesRemoveFence(_loc3_);
         var _loc4_:Profile = DollarsGame.getProfile();
         var _loc5_:RulesFacade = RulesFacade.getInstance();
         var _loc6_:int = MapDefinition.getInstance().getExpansionsSide();
         var _loc7_:int = param1 % _loc6_;
         var _loc8_:int = param1 / _loc6_;
         var _loc9_:int = param1 - 1;
         if(_loc5_.expansionsAreConsecutivePlotsWithSameUnlockOrder(_loc9_,param1))
         {
            if(_loc4_.isExpansionAreaMine(_loc9_))
            {
               this.fencesRemoveFence(_loc5_.expansionsGetKeyFromConsecutivePlots(_loc9_,param1));
            }
         }
         var _loc10_:int = param1 + 1;
         if(_loc5_.expansionsAreConsecutivePlotsWithSameUnlockOrder(param1,_loc10_))
         {
            if(_loc4_.isExpansionAreaMine(_loc10_))
            {
               this.fencesRemoveFence(_loc5_.expansionsGetKeyFromConsecutivePlots(param1,_loc10_));
            }
         }
         var _loc11_:int = param1 - _loc6_;
         if(_loc5_.expansionsAreConsecutivePlotsWithSameUnlockOrder(_loc11_,param1))
         {
            if(_loc4_.isExpansionAreaMine(_loc11_))
            {
               this.fencesRemoveFence(_loc5_.expansionsGetKeyFromConsecutivePlots(_loc11_,param1));
            }
         }
         var _loc12_:int = param1 + _loc6_;
         if(_loc5_.expansionsAreConsecutivePlotsWithSameUnlockOrder(param1,_loc12_))
         {
            if(_loc4_.isExpansionAreaMine(_loc12_))
            {
               this.fencesRemoveFence(_loc5_.expansionsGetKeyFromConsecutivePlots(param1,_loc12_));
            }
         }
         this.build();
      }
      
      public function destroy() : void
      {
         var _loc1_:* = 0;
         var _loc2_:Bitmap = null;
         var _loc3_:BitmapData = null;
         this.end();
         if(this.mScreenBms != null)
         {
            _loc1_ = int(this.mScreenBms.length - 1);
            while(_loc1_ > -1)
            {
               _loc2_ = this.mScreenBms[_loc1_] as Bitmap;
               if(contains(_loc2_))
               {
                  removeChild(_loc2_);
               }
               _loc3_ = this.mScreenBmds[_loc1_];
               _loc3_.dispose();
               this.mScreenBmds[_loc1_] = null;
               this.mScreenBms[_loc1_] = null;
               _loc1_--;
            }
            this.mScreenBms = null;
            this.mScreenBmds = null;
         }
         if(this.mBackground != null)
         {
            if(contains(this.mBackground))
            {
               removeChild(this.mBackground);
            }
            this.mBackground = null;
         }
         if(this.mTileSetBmd != null)
         {
            this.mTileSetBmd = null;
         }
         this.fencesDestroy();
      }
      
      private function fencesDestroy() : void
      {
         if(this.mFencesDO != null)
         {
            this.fencesUnbuild();
            this.mFencesIndices = null;
            this.mFencesDO = null;
         }
      }
   }
}

