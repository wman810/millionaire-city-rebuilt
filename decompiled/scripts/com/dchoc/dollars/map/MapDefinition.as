package com.dchoc.dollars.map
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   
   public class MapDefinition
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:MapDefinition;
      
      private var mTileHeight:int;
      
      private var mTileWidth:int;
      
      private var mMapTileCols:int;
      
      private var mMapAreaCount:int;
      
      private var mMapAreaRows:int;
      
      private var mExpansionsSide:int;
      
      private var mAreaTileRows:int;
      
      private var mMapAreaCols:int;
      
      private var mMapTileRows:int;
      
      private var mAreaTileCols:int;
      
      public function MapDefinition()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: MapDefinition Error: Instantiation failed: Use MapDefinition.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : MapDefinition
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new MapDefinition();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function getExpansionsSide() : int
      {
         return this.mExpansionsSide;
      }
      
      public function getAreaWidth() : int
      {
         return this.mTileWidth * this.mAreaTileCols;
      }
      
      public function getMapTileCols() : int
      {
         return this.mMapTileCols;
      }
      
      public function getAreaTileRows() : int
      {
         return this.mAreaTileRows;
      }
      
      public function getMapAreaRows() : int
      {
         return this.mMapAreaRows;
      }
      
      public function getTileWidth() : int
      {
         return this.mTileWidth;
      }
      
      public function getAreaHeight() : int
      {
         return this.mTileHeight * this.mAreaTileRows;
      }
      
      public function setPersistence(param1:XML) : void
      {
         this.mTileWidth = param1.Definition.@tileWidth;
         this.mTileHeight = param1.Definition.@tileHeight;
         this.mAreaTileCols = param1.Definition.@areaTileCols;
         this.mAreaTileRows = param1.Definition.@areaTileRows;
         this.mMapAreaCols = int(param1.Definition.@miniExpansionsSide);
         this.mMapAreaRows = this.mMapAreaCols;
         this.mExpansionsSide = int(param1.Definition.@expansionsSide);
         this.build();
      }
      
      public function getAreaTileCols() : int
      {
         return this.mAreaTileCols;
      }
      
      public function getTileHeight() : int
      {
         return this.mTileHeight;
      }
      
      private function load() : void
      {
      }
      
      private function build() : void
      {
         this.mMapAreaCount = this.mMapAreaCols * this.mMapAreaRows;
         this.mMapTileCols = this.mMapAreaCols * this.mAreaTileCols;
         this.mMapTileRows = this.mMapAreaRows * this.mAreaTileRows;
      }
      
      public function getAreaCentral() : int
      {
         var _loc1_:Array = RulesFacade.getInstance().expansionsGetPlotIndicesByUnlockOrder(0);
         return _loc1_[0];
      }
      
      public function getMapTileRows() : int
      {
         return this.mMapTileRows;
      }
      
      public function getMapAreaCols() : int
      {
         return this.mMapAreaCols;
      }
      
      public function destroy() : void
      {
      }
      
      public function getMapAreaCount() : int
      {
         return this.mMapAreaCount;
      }
   }
}

