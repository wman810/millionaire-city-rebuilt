package com.dchoc.dollars.map
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleFound;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.PopupConfirmExpansion;
   import com.dchoc.dollars.GUI.PopupMessage;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.hud.Plot;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsBar;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.map.Layers.TopLayer;
   import com.dchoc.dollars.map.logicTiles.LogicTile;
   import com.dchoc.dollars.map.logicTiles.LogicTileSolid;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.GUI.messages.MessageManager;
   import com.dchoc.dollars.utils.animations.ItemSprite;
   import com.dchoc.dollars.utils.astar.Astar;
   import com.dchoc.dollars.utils.astar.INode;
   import com.dchoc.dollars.utils.astar.ISearchable;
   import com.dchoc.dollars.utils.astar.Path;
   import com.dchoc.dollars.utils.astar.SearchResults;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.math.Vector2D;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.ParticleAnimation;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.utils.particles.climate.ClimateManager;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.utils.screenshots.Screenshot;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.traffic.TrafficAgent;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManager;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.decorations.ItemDecoration;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import com.dchoc.framework.utils.AssetManager;
   import com.dchoc.framework.world.view.TopDownView;
   import com.dchoc.framework.world.view.View;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   
   public class Map extends Sprite implements ISearchable, FBCreditsPurchaseInterface
   {
      
      public static var smWidth:int;
      
      public static var smWidthHalf:int;
      
      public static var smHeight:int;
      
      public static var DEBUG:Array;
      
      public static var smHeightHalf:int;
      
      public static const EVENT_AUTO_SCROLL_ANIM_END:String = "EventAutoScrollAnimEnd";
      
      private static var DEBUG_GRID:uint = 0;
      
      private static var DEBUG_CURSOR:uint = 1;
      
      public static var DEBUG_ITEM:uint = 2;
      
      public static var DEBUG_ASTAR:uint = 3;
      
      private static var DEBUG_COUNT:uint = 4;
      
      private static const CARS_DEPTH_COUNT:int = 2;
      
      public static const BUILD_STEPS_COUNT:int = 5;
      
      public static const LOGIC_TILE_SOLID:int = 0;
      
      private static const LOGIC_TILE_CATALOG:Array = [LogicTileSolid];
      
      private const MIDDLE_TERRAIN_TILE:uint = 18;
      
      private var mCurrentTool:Tool;
      
      protected var mPersistence:XML;
      
      private var mRoadTilesData:Array;
      
      private var mZoomRefX:int;
      
      private var mZoomRefY:int;
      
      public var mItemObjectsLayerTop:ItemSprite;
      
      private var mPopupConfirmExpansion:PopupConfirmExpansion;
      
      private var mStartTile:TileData;
      
      private var mFinalSkin:String;
      
      private const FRAME_TILE:uint = 1;
      
      private var mViewPortX:int;
      
      private var mViewPortY:int;
      
      public var mItemObjectsLayerBottom:ItemSprite;
      
      private var mMapBottomExtraRows:uint;
      
      private var mMapTileRows:uint;
      
      private var mTerrainTilesDataPersistence:Array;
      
      private var mTerrainShape:Sprite;
      
      private var mDebugEnabled:Boolean = false;
      
      protected var mCursorIDBack:int;
      
      private var mTopLayer:TopLayer;
      
      private var mMapDataChanges:Array;
      
      private var mScrollBottomY:int;
      
      public var mItemObjectsLayerCars:Array;
      
      private const LAST_TERRAIN_TILE:uint = 39;
      
      private const GRASS_FRAME_TILE:uint = 13;
      
      private var mView:View;
      
      private var mMapTileRealRows:uint;
      
      private var mOriginX:Number;
      
      private var mOriginY:Number;
      
      private var mDebugLayers:Array;
      
      private var mTilesData:Array;
      
      private const FIRST_TERRAIN_TILE:uint = 14;
      
      private var mLastItemClicked:ItemObject;
      
      private var mExchangeTileIndex:int;
      
      private var mTileOffsets:Array;
      
      private var mSid:String = "";
      
      private var mRoadTilesDataPersistence:Array;
      
      private var mWorld:World;
      
      private var mControlDown:Boolean;
      
      private var mCurrentTime:int;
      
      private var mTerrainGrill2:Sprite;
      
      protected var mGainedDCCash:int;
      
      protected var mGainedDCCoins:int;
      
      protected var mGainedExp:int;
      
      private var mMapWidth:uint;
      
      private var mTerrainShapeRed:Sprite;
      
      private var mAutoScrollEnabled:Boolean;
      
      private var mTerrainGrid:Array;
      
      private var mBackground:Background;
      
      private var mAstarStartItem:ItemObject;
      
      private var mMapTopExtraRows:uint;
      
      public var mItemObjectsLayerDialog:ItemSprite;
      
      private var mPersistenceAttributesChanged:Boolean;
      
      private var mLastPath:Path;
      
      private var mMapTileCols:uint;
      
      private var mDestX:Number;
      
      private var mDestY:Number;
      
      private var mTerrainTilesData:Array;
      
      private var mMapHeight:uint;
      
      private const GRASS_TILE:uint = 1;
      
      private var mTerrainGrill:Sprite;
      
      private var mTileHeight:uint;
      
      private var roadTilesCount:int = 0;
      
      private var mTileWidth:uint;
      
      private var mPlotToBuy:int;
      
      private var mAstar:Astar;
      
      private const AUTO_SCROLL_TIMER:int = 500;
      
      private var mItemMouseOver:ItemObject;
      
      private var mGoalTile:TileData;
      
      private var mMapData:Array;
      
      public function Map(param1:World)
      {
         var _loc3_:ItemSprite = null;
         var _loc4_:uint = 0;
         this.mTileOffsets = [14,62,1];
         super();
         this.mWorld = param1;
         this.mBackground = new Background(this);
         addChild(this.mBackground);
         this.mItemObjectsLayerCars = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < CARS_DEPTH_COUNT)
         {
            _loc3_ = new ItemSprite();
            this.mItemObjectsLayerCars.push(_loc3_);
            addChild(_loc3_);
            _loc2_++;
         }
         this.mItemObjectsLayerBottom = new ItemSprite();
         addChild(this.mItemObjectsLayerBottom);
         this.mItemObjectsLayerTop = new ItemSprite();
         addChild(this.mItemObjectsLayerTop);
         this.mItemObjectsLayerDialog = new ItemSprite();
         addChild(this.mItemObjectsLayerDialog);
         if(Config.DEBUG_MODE)
         {
            this.mDebugLayers = new Array();
            _loc4_ = 0;
            while(_loc4_ < DEBUG_COUNT)
            {
               this.mDebugLayers[_loc4_] = new Shape();
               addChild(this.mDebugLayers[_loc4_]);
               this.mDebugLayers[_loc4_].visible = false;
               _loc4_++;
            }
         }
         this.mTileWidth = MapDefinition.getInstance().getTileWidth();
         this.mTileHeight = MapDefinition.getInstance().getTileHeight();
         this.mView = new TopDownView();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.mTerrainShape = new Sprite();
         this.mTerrainShape.graphics.lineStyle(2,65280);
         this.mTerrainShape.graphics.beginFill(65280,0.5);
         this.mTerrainShape.graphics.drawRect(0,0,this.mTileWidth,this.mTileHeight);
         this.mTerrainShape.graphics.endFill();
         this.mTerrainGrill = new AssetManager.Grill();
         this.mTerrainShape.addChild(this.mTerrainGrill);
         this.mTerrainGrill.x += this.mTileWidth / 2;
         this.mTerrainGrill.y += this.mTileHeight / 2;
         this.mTerrainShapeRed = new Sprite();
         this.mTerrainShapeRed.graphics.beginFill(16711680,0.5);
         this.mTerrainShapeRed.graphics.drawRect(0,0,this.mTileWidth,this.mTileHeight);
         this.mTerrainShapeRed.graphics.endFill();
         this.mTerrainGrill2 = new AssetManager.GrillBad();
         this.mTerrainShapeRed.addChild(this.mTerrainGrill2);
         this.mTerrainGrill2.x += this.mTileWidth / 2;
         this.mTerrainGrill2.y += this.mTileHeight / 2;
         this.mTerrainGrid = new Array();
         this.astarInit();
         Dollars.smStage.addEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
         mouseChildren = false;
         this.load();
      }
      
      public static function debugLoad() : void
      {
      }
      
      public static function debugDestroy() : void
      {
         if(Config.DEBUG_MODE)
         {
            DEBUG = null;
         }
      }
      
      private function onKey(param1:KeyboardEvent) : void
      {
         var _loc2_:PopupCollectibleFound = null;
         var _loc3_:CollectibleObject = null;
         var _loc4_:Screenshot = null;
         var _loc5_:NeighborObject = null;
         var _loc6_:Number = NaN;
         switch(param1.keyCode)
         {
            case Keyboard.CONTROL:
               this.mControlDown = false;
               break;
            case Keyboard.SPACE:
               if(Config.cheatsAreEnabled(Config.CHEAT_TIME_ID))
               {
                  DollarsGame.smInstance.mFriendsBar.visibleTimeButtons();
               }
               break;
            case Keyboard.F1:
               if(Config.cheatsAreEnabled(Config.CHEAT_EXP_ID))
               {
                  DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + int((DollarsGame.getProfile().maxExp - DollarsGame.getProfile().minExp) * 34 / 100);
               }
               break;
            case Keyboard.F2:
               break;
            case Keyboard.F3:
               this.launchHQSkinAnimation();
               break;
            case Keyboard.F4:
               if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
               {
                  _loc5_ = UpgradesManager.getInstance().getNeighborObject();
                  _loc6_ = _loc5_.getSuperUpgradeTimeToAllowRemaining();
                  trace("time = " + TextManager.convertTimeToString(_loc6_,false));
               }
               break;
            case Keyboard.F5:
               if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
               {
                  _loc5_ = UpgradesManager.getInstance().getNeighborObject();
                  _loc5_.resetSuperUpgradeTimeToAllowRemaining();
                  _loc6_ = _loc5_.getSuperUpgradeTimeToAllowRemaining();
               }
               break;
            case Keyboard.F7:
               if(Config.cheatsAreEnabled(Config.CHEAT_DCCOINS_ID))
               {
                  UserDataFacade.securityCoinsToAdd(10000);
               }
               if(Config.CHEAT_TRAFFIC_AGENT)
               {
                  TrafficAgent.SPAWN_STATUS = (TrafficAgent.SPAWN_STATUS + 1) % TrafficAgent.SPAWN_STATUS_COUNT;
               }
               break;
            case Keyboard.UP:
               _loc4_ = new Screenshot();
               _loc4_.takeScreenshot(this,-this.x,-this.y,Config.SCREEN_WIDTH,Config.SCREEN_HEIGHT);
               _loc4_.save("screenshot.bmp");
               break;
            case Keyboard.NUMPAD_0:
               if(DollarsGame.smFPSCounter != null)
               {
                  DollarsGame.smFPSCounter.setVisible(Debug.visible);
               }
         }
      }
      
      public function isValidTileIndex(param1:uint) : Boolean
      {
         return param1 < this.mMapTileRows * this.mMapTileCols;
      }
      
      public function launchHQSkinAnimation() : void
      {
         var _loc1_:MovieClip = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Contract_anim_ok_superupgrade"))();
         var _loc2_:ItemDecoration = this.mAstarStartItem.decorationsGetDecorationByType(ItemDecorationDefinition.TYPE_SKINS_ID);
         _loc1_.addEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         this.mAstarStartItem.displayObjectL1.addChild(_loc1_);
         _loc1_.x = this.mAstarStartItem.itemDefinition.baseWidth >> 1;
         _loc1_.y = this.mAstarStartItem.itemDefinition.baseHeight >> 1;
         if(_loc2_ != null)
         {
            _loc2_.currentSku = this.mFinalSkin;
         }
      }
      
      public function desactiveExpansion(param1:int) : void
      {
         this.switchExpansion(param1,false);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc4_:ItemSprite = null;
         var _loc5_:TileData = null;
         this.end();
         this.mWorld = null;
         TrafficAgentManager.getInstance().destroy();
         this.removeBuildGrid();
         if(this.mBackground != null && !param1)
         {
            if(contains(this.mBackground))
            {
               removeChild(this.mBackground);
            }
            this.mBackground.destroy();
            this.mBackground = null;
         }
         if(!Config.USE_OLD_ICON_SYSTEM)
         {
            if(this.mTopLayer != null)
            {
               if(contains(this.mTopLayer.getBitmap()))
               {
                  removeChild(this.mTopLayer.getBitmap());
               }
               this.mTopLayer.destroy();
               this.mTopLayer = null;
            }
         }
         if(this.mItemObjectsLayerCars != null)
         {
            _loc2_ = int(this.mItemObjectsLayerCars.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this.mItemObjectsLayerCars[_loc3_];
               removeChild(_loc4_);
               this.mItemObjectsLayerCars[_loc3_] = null;
               _loc3_++;
            }
            this.mItemObjectsLayerCars = null;
         }
         if(this.mItemObjectsLayerTop != null && contains(this.mItemObjectsLayerTop))
         {
            removeChild(this.mItemObjectsLayerTop);
            this.mItemObjectsLayerTop = null;
         }
         if(this.mItemObjectsLayerBottom != null && contains(this.mItemObjectsLayerBottom))
         {
            removeChild(this.mItemObjectsLayerBottom);
            this.mItemObjectsLayerBottom = null;
         }
         if(this.mItemObjectsLayerDialog != null && contains(this.mItemObjectsLayerDialog))
         {
            removeChild(this.mItemObjectsLayerDialog);
            this.mItemObjectsLayerDialog = null;
         }
         this.mPersistence = null;
         this.mItemMouseOver = null;
         if(this.mView != null)
         {
            this.mView = null;
         }
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool = null;
         }
         if(this.mMapData != null)
         {
            this.mMapData.splice(0,this.mMapData.length);
            this.mMapData = null;
         }
         if(this.mMapDataChanges != null)
         {
            this.mMapDataChanges.splice(0,this.mMapDataChanges.length);
            this.mMapDataChanges = null;
         }
         if(this.mTilesData != null)
         {
            _loc3_ = int(this.mTilesData.length - 1);
            while(_loc3_ > -1)
            {
               if(this.mTilesData[_loc3_] != null)
               {
                  _loc5_ = this.mTilesData[_loc3_];
                  _loc5_.destroy();
                  this.mTilesData[_loc3_] = null;
               }
               _loc3_--;
            }
            this.mTilesData.splice(0,this.mTilesData.length);
            this.mTilesData = null;
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         Dollars.smStage.removeEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
         if(this.mTerrainShape != null)
         {
            this.unattachTerrainShape();
            this.mTerrainShape.removeChild(this.mTerrainGrill);
            this.mTerrainShapeRed.removeChild(this.mTerrainGrill2);
            this.mTerrainShape = null;
            this.mTerrainGrill2 = null;
            this.mTerrainShapeRed = null;
            this.mTerrainGrill = null;
         }
         this.terrainDestroy();
         this.roadDestroy();
         if(Config.DEBUG_MODE)
         {
            _loc3_ = 0;
            while(_loc3_ < DEBUG_COUNT)
            {
               removeChild(this.mDebugLayers[_loc3_]);
               this.mDebugLayers[_loc3_] = null;
               _loc3_++;
            }
            this.mDebugLayers = null;
         }
         this.astarDestroy();
      }
      
      private function switchExpansion(param1:int, param2:Boolean) : void
      {
         var _loc3_:RulesFacade = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Shape = null;
         if(DollarsGame.getProfileUniverse().plots[param1] != Plot.TYPE_FULL)
         {
            _loc3_ = RulesFacade.getInstance();
            _loc4_ = _loc3_.expansionsGetPlotWidth(param1);
            _loc5_ = _loc3_.expansionsGetPlotHeight(param1);
            _loc6_ = this.mBackground.mExpansions[param1];
            if(_loc6_ != null)
            {
               _loc6_.graphics.clear();
               if(param2)
               {
                  _loc6_.graphics.lineStyle(2,65280);
                  _loc6_.graphics.beginFill(65280,0.3);
                  _loc6_.graphics.drawRoundRect(0,0,_loc4_,_loc5_,10,10);
               }
               else
               {
                  _loc6_.graphics.beginFill(0,0.3);
                  _loc6_.graphics.drawRect(0,0,_loc4_,_loc5_);
               }
               _loc6_.graphics.endFill();
            }
         }
      }
      
      private function checkCrossWalk() : void
      {
         var _loc5_:int = 0;
         var _loc1_:int = int(this.mTileOffsets[TileData.TILE_ROAD]);
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.mMapTileRows)
         {
            _loc3_ = 0;
            while(_loc3_ < this.mMapTileCols)
            {
               _loc4_ = _loc2_ * this.mMapTileCols + _loc3_;
               _loc5_ = this.mMapData[_loc4_] - _loc1_;
               if(_loc5_ == 16)
               {
                  if(this.mMapData[_loc4_ - 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ - 1,2);
                  }
                  if(this.mMapData[_loc4_ + 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ + 1,2);
                  }
                  if(this.mMapData[_loc4_ - this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ - this.mMapTileCols,3);
                  }
                  if(this.mMapData[_loc4_ + this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ + this.mMapTileCols,3);
                  }
               }
               else if(_loc5_ == 17)
               {
                  if(this.mMapData[_loc4_ - 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ - 1,2);
                  }
                  if(this.mMapData[_loc4_ - this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ - this.mMapTileCols,3);
                  }
                  if(this.mMapData[_loc4_ + this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ + this.mMapTileCols,3);
                  }
               }
               else if(_loc5_ == 19)
               {
                  if(this.mMapData[_loc4_ + 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ + 1,2);
                  }
                  if(this.mMapData[_loc4_ - 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ - 1,2);
                  }
                  if(this.mMapData[_loc4_ - this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ - this.mMapTileCols,3);
                  }
               }
               else if(_loc5_ == 20)
               {
                  if(this.mMapData[_loc4_ - 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ - 1,2);
                  }
                  if(this.mMapData[_loc4_ + 1] - _loc1_ == 10)
                  {
                     this.setMapData(_loc4_ + 1,2);
                  }
                  if(this.mMapData[_loc4_ + this.mMapTileCols] - _loc1_ == 9)
                  {
                     this.setMapData(_loc4_ + this.mMapTileCols,3);
                  }
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function removeTerrain(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param3)
         {
            _loc6_ = 0;
            while(_loc6_ < param2)
            {
               _loc4_ = param1 + _loc6_;
               this.setMapData(_loc4_,this.GRASS_TILE);
               this.mTilesData[_loc4_].isMyTerrain = false;
               _loc6_++;
            }
            param1 += this.mMapTileCols;
            _loc5_++;
         }
         this.mBackground.build();
      }
      
      public function getTileDataFromIndex(param1:int) : TileData
      {
         var _loc2_:TileData = null;
         if(this.isValidTileIndex(param1))
         {
            _loc2_ = this.mTilesData[param1];
         }
         return _loc2_;
      }
      
      public function setItemMouseOver(param1:ItemObject) : void
      {
         this.mItemMouseOver = param1;
      }
      
      public function isBuildableFromScreen(param1:Number, param2:Number, param3:ItemObject = null) : Boolean
      {
         var _loc4_:ItemDefinition = null;
         var _loc5_:Boolean = true;
         if(param3 != null)
         {
            _loc4_ = param3.itemDefinition;
            if(param3.getNoNeedPlot())
            {
               _loc5_ = false;
            }
         }
         var _loc6_:int = this.getScreenToTileIndex(param1,param2,true);
         return this.isBuildable(_loc6_,_loc4_,_loc5_);
      }
      
      private function astarShowPath(param1:SearchResults) : void
      {
         var _loc2_:Path = null;
         var _loc3_:int = 0;
         var _loc4_:TileData = null;
         if(Boolean(DEBUG[DEBUG_ASTAR]) && param1.getIsSuccess())
         {
            _loc2_ = param1.getPath();
            _loc3_ = 0;
            while(_loc3_ < _loc2_.getNodes().length)
            {
               _loc4_ = TileData(_loc2_.getNodes()[_loc3_]);
               _loc4_.showPath();
               _loc3_++;
            }
         }
         this.mLastPath = param1.getPath();
      }
      
      public function get mapRealRows() : uint
      {
         return this.mMapTileRealRows;
      }
      
      public function getTopY() : int
      {
         return this.mMapTopExtraRows * this.mTileHeight;
      }
      
      public function getTileXYToTileIndex(param1:int, param2:int, param3:Boolean = true) : int
      {
         if(param3 && (param1 < 0 || param2 < 0 || param1 >= this.mMapTileCols || param2 >= this.mMapTileRows))
         {
            return -1;
         }
         return param1 + param2 * this.mMapTileCols;
      }
      
      private function getNodeTransitionCostByType(param1:String, param2:String) : Number
      {
         if(param1 == param2 && param1 == "road")
         {
            return 1;
         }
         return 1000000;
      }
      
      public function roadTileDestroy(param1:int) : void
      {
         var _loc2_:TileData = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(this.isValidTileIndex(param1))
         {
            _loc2_ = this.mTilesData[param1];
            if(_loc2_.isRoad)
            {
               _loc2_.isRoad = false;
               _loc3_ = this.mRoadTilesData.indexOf(_loc2_);
               if(_loc3_ > -1)
               {
                  _loc6_ = this.mRoadTilesDataPersistence[_loc3_];
                  _loc7_ = _loc6_.indexOf(":");
                  _loc8_ = _loc6_.substring(0,_loc7_);
                  _loc9_ = _loc6_.substring(_loc7_ + 1,_loc6_.length);
                  UserDataFacade.getInstance().updateMap(this.mSid,"del",{
                     "type":"Road",
                     "x":_loc8_,
                     "y":_loc9_
                  },this.securityCreateObj("del","Road"));
                  this.mRoadTilesData.splice(_loc3_,1);
                  this.mRoadTilesDataPersistence.splice(_loc3_,1);
               }
               _loc4_ = int(this.GRASS_TILE);
               if(!this.isTileInAreaMine(param1,false))
               {
                  _loc4_ += Background.TILE_MAX;
               }
               this.setMapData(param1,_loc4_);
               _loc5_ = new Array();
               this.buildTerrain(param1,_loc5_,TileData.TILE_ROAD);
               this.checkCrossWalk();
               _loc2_.isMyTerrain = false;
               this.setMapData(param1,_loc4_);
               this.roadLoopNeighbours(param1,this.roadUnregisterItem);
               this.world.unregisterRoad(param1);
               this.mBackground.build();
            }
         }
      }
      
      private function roadLoad() : void
      {
         this.mRoadTilesData = new Array();
         this.mRoadTilesDataPersistence = new Array();
      }
      
      public function sortDisplayList() : void
      {
         this.mItemObjectsLayerBottom.sortDisplayList();
      }
      
      public function getTileRelativeXToTile(param1:int) : uint
      {
         return param1 + (this.mMapTileCols >> 1);
      }
      
      public function getWorldToTileY(param1:Number, param2:Boolean = false) : uint
      {
         var _loc3_:uint = param1 / this.mTileHeight;
         if(param2)
         {
            if(param1 % this.mTileHeight > this.mTileHeight >> 1)
            {
               _loc3_++;
            }
         }
         return _loc3_;
      }
      
      public function astarSetStartItem(param1:ItemObject) : void
      {
         this.mAstarStartItem = param1;
      }
      
      public function getWorldToTileX(param1:Number, param2:Boolean = false) : uint
      {
         var _loc3_:uint = param1 / this.mTileWidth;
         if(param2)
         {
            if(param1 % this.mTileWidth > this.mTileWidth >> 1)
            {
               _loc3_++;
            }
         }
         return _loc3_;
      }
      
      public function calculateScrollBottomY() : void
      {
         var _loc1_:int = Math.round(this.mMapTileRows * this.mTileHeight * scaleY);
         this.mScrollBottomY = DollarsGame.getScreenHeight() - _loc1_;
      }
      
      public function cameraStart() : void
      {
         var _loc1_:int = 0;
         if(Tutorial.smTutorialEnd)
         {
            this.x = this.cameraGetLookingAtHQX();
            this.y = this.cameraGetLookingAtHQY();
         }
         else
         {
            this.x = Dollars.smStage.stageWidth - this.mMapWidth >> 1;
            this.x += this.mTileWidth;
            _loc1_ = this.mapRealRows * this.mTileHeight;
            this.y = DollarsGame.getScreenHeight() - _loc1_ >> 1;
         }
      }
      
      public function unplaceItem(param1:ItemObject) : void
      {
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:TileData = null;
         var _loc2_:uint = this.getWorldToTileX(param1.worldX);
         var _loc3_:uint = this.getWorldToTileY(param1.worldY);
         var _loc4_:Boolean = param1.itemDefinition.requiresTerrainMine();
         var _loc5_:uint = 0;
         while(_loc5_ < param1.itemDefinition.baseCols)
         {
            _loc6_ = _loc2_ + _loc5_;
            _loc7_ = 0;
            while(_loc7_ < param1.itemDefinition.baseRows)
            {
               _loc8_ = uint(this.getTileXYToTileIndex(_loc6_,_loc3_ + _loc7_));
               _loc9_ = this.mTilesData[_loc8_] as TileData;
               _loc9_.baseItem = null;
               _loc9_.setHigh(false);
               if(_loc4_)
               {
                  this.setTileTerrain(_loc8_,false,false);
               }
               _loc7_++;
            }
            _loc5_++;
         }
         if(_loc4_)
         {
            this.mBackground.build();
         }
         this.removeFromDisplay(param1);
         this.mItemObjectsLayerBottom.sortDisplayList();
      }
      
      public function reportMouseOver() : void
      {
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool.reportMouseOver(null,true);
         }
      }
      
      private function astarDestroy() : void
      {
         this.mAstar.destroy();
         this.mAstar = null;
      }
      
      public function destroyItemTerrain(param1:ItemObject) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc2_:uint = this.getWorldToTileX(param1.worldX);
         var _loc3_:uint = this.getWorldToTileY(param1.worldY);
         var _loc4_:uint = 0;
         while(_loc4_ < param1.itemDefinition.baseCols)
         {
            _loc5_ = _loc2_ + _loc4_;
            _loc6_ = 0;
            while(_loc6_ < param1.itemDefinition.baseRows)
            {
               _loc7_ = uint(this.getTileXYToTileIndex(_loc5_,_loc3_ + _loc6_));
               this.destroyTile(_loc7_,false);
               _loc6_++;
            }
            _loc4_++;
         }
      }
      
      public function getScrollBottomY() : int
      {
         return this.mScrollBottomY - 60;
      }
      
      public function astarIsTileConnected(param1:INode) : Boolean
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:SearchResults = null;
         var _loc2_:Boolean = false;
         if(this.mAstarStartItem != null)
         {
            _loc3_ = this.mAstarStartItem.roadTiles;
            _loc4_ = int(_loc3_.length);
            _loc5_ = 0;
            while(_loc5_ < _loc4_ && !_loc2_)
            {
               _loc6_ = this.mAstar.search(_loc3_[_loc5_],[param1]);
               _loc2_ = _loc6_.getIsSuccess();
               _loc5_++;
            }
         }
         return _loc2_;
      }
      
      private function doAutoScroll(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:int = this.AUTO_SCROLL_TIMER * this.scaleX;
         if(this.mCurrentTime < _loc2_)
         {
            this.mCurrentTime += param1;
            _loc3_ = this.mDestX - this.mOriginX;
            _loc4_ = this.mDestY - this.mOriginY;
            _loc5_ = this.mCurrentTime * _loc3_ / _loc2_;
            _loc6_ = this.mCurrentTime * _loc4_ / _loc2_;
            this.x = this.mOriginX + _loc5_;
            this.y = this.mOriginY + _loc6_;
            if(this.mCurrentTime >= _loc2_)
            {
               this.x = this.mDestX;
               this.y = this.mDestY;
               this.mAutoScrollEnabled = false;
               if(this.mFinalSkin != null)
               {
                  this.launchHQSkinAnimation();
               }
            }
         }
      }
      
      public function getRows() : int
      {
         return this.mMapTileRows;
      }
      
      public function attachTerrainShape() : void
      {
         addChild(this.mTerrainShape);
         this.mTerrainShape.visible = false;
         addChild(this.mTerrainShapeRed);
         this.mTerrainShapeRed.visible = false;
      }
      
      public function onZoom(param1:Number = 0) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = Dollars.smStage.stageWidth;
         var _loc3_:int = Dollars.smStage.stageHeight;
         if(param1 != 0)
         {
            scaleX = Math.round((scaleX + param1) * 100) / 100;
            if(scaleX > 1)
            {
               scaleX = 1;
            }
            _loc6_ = this.mZoomRefX * scaleX;
            x = _loc6_ + (_loc2_ >> 1);
            scaleY = Math.round((scaleY + param1) * 100) / 100;
            if(scaleY > 1)
            {
               scaleY = 1;
            }
            _loc7_ = this.mZoomRefY * scaleY;
            y = _loc7_ + (_loc3_ >> 1);
         }
         this.calculateScrollBottomY();
         var _loc4_:int = int(this.getMapWidth(true));
         if(_loc2_ > _loc4_)
         {
            x = _loc2_ - _loc4_ >> 1;
         }
         else if(x < _loc2_ - _loc4_)
         {
            x = _loc2_ - _loc4_;
         }
         else if(x > 0)
         {
            x = 0;
         }
         _loc3_ = DollarsGame.getScreenHeight();
         var _loc5_:int = int(this.getMapHeight(true));
         if(_loc3_ > _loc5_)
         {
            y = Math.round((DollarsGame.getScreenHeight() - _loc5_) / 2);
         }
         else
         {
            if(y < _loc3_ - _loc5_)
            {
               y = _loc3_ - _loc5_;
            }
            else if(y > 0)
            {
               y = 0;
            }
            if(y < this.mScrollBottomY)
            {
               y = this.mScrollBottomY;
            }
         }
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
      }
      
      public function setToolItemMouseOver(param1:ItemObject) : void
      {
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool.setItemMouseOver(param1);
         }
      }
      
      public function start() : void
      {
         if(Config.DEBUG_MODE || Config.cheatsAreEnabled())
         {
            Dollars.smStage.addEventListener(KeyboardEvent.KEY_UP,this.onKey);
            Dollars.smStage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         }
      }
      
      private function setMutable(param1:Boolean) : void
      {
         this.mBackground.setMutable(param1);
      }
      
      public function getTileYToWorld(param1:uint) : Number
      {
         return param1 * this.mTileHeight;
      }
      
      private function isTileInArea(param1:int, param2:int, param3:Boolean = false, param4:Boolean = true) : Boolean
      {
         var _loc5_:Profile = null;
         var _loc6_:int = 0;
         if(!param3 || param3 && this.world.role != null && this.world.role.checksExpansionIsMine())
         {
            _loc5_ = DollarsGame.getProfile();
            _loc6_ = this.getAreaIndexFromTileIndex(param1);
            param4 = _loc5_.isExpansionAreaType(_loc6_,param2);
         }
         return param4;
      }
      
      public function setMapData(param1:int, param2:int) : void
      {
         this.mMapData[param1] = param2;
         this.mMapDataChanges.push(param1);
         this.mPersistenceAttributesChanged = true;
      }
      
      public function getTilesTerrain() : Array
      {
         return this.mTerrainTilesDataPersistence;
      }
      
      public function build(param1:int, param2:BitmapData) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:XML = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(param1 == 0)
         {
            this.setTileData();
         }
         else if(param1 == 1 && this.mPersistence != null)
         {
            for each(_loc6_ in this.mPersistence.Terrain)
            {
               _loc3_ = String(_loc6_.@chunk);
               _loc4_ = _loc3_.split(",");
               for each(_loc7_ in _loc4_)
               {
                  if(_loc7_ != "")
                  {
                     _loc5_ = _loc7_.split(":");
                     _loc8_ = parseInt(_loc5_[0]);
                     _loc9_ = parseInt(_loc5_[1]);
                     _loc8_ = int(this.getTileRelativeXToTile(_loc8_));
                     _loc9_ = int(this.getTileRelativeYToTile(_loc9_));
                     _loc10_ = this.getTileXYToTileIndex(_loc8_,_loc9_);
                     this.setTileTerrain(_loc10_,false);
                  }
               }
            }
         }
         else if(param1 == 2 && this.mPersistence != null)
         {
            for each(_loc6_ in this.mPersistence.Road)
            {
               _loc3_ = String(_loc6_.@chunk);
               _loc4_ = _loc3_.split(",");
               for each(_loc7_ in _loc4_)
               {
                  if(_loc7_ != "")
                  {
                     _loc5_ = _loc7_.split(":");
                     _loc8_ = parseInt(_loc5_[0]);
                     _loc9_ = parseInt(_loc5_[1]);
                     _loc8_ = int(this.getTileRelativeXToTile(_loc8_));
                     _loc9_ = int(this.getTileRelativeYToTile(_loc9_));
                     _loc10_ = this.getTileXYToTileIndex(_loc8_,_loc9_);
                     this.roadTileBuild(_loc10_,false);
                     ++this.roadTilesCount;
                  }
               }
            }
            this.checkCrossWalk();
         }
         else if(param1 == 3 && this.mPersistence != null)
         {
            _loc11_ = RulesFacade.getInstance().universeGetMapPersistence();
            for each(_loc6_ in _loc11_.LogicTiles)
            {
               _loc3_ = String(_loc6_.@chunk);
               _loc4_ = _loc3_.split(",");
               for each(_loc7_ in _loc4_)
               {
                  if(_loc7_ != "")
                  {
                     _loc5_ = _loc7_.split(":");
                     _loc12_ = parseInt(_loc5_[0]);
                     _loc8_ = parseInt(_loc5_[1]);
                     _loc9_ = parseInt(_loc5_[2]);
                     _loc8_ = int(this.getTileRelativeXToTile(_loc8_));
                     _loc9_ = int(this.getTileRelativeYToTile(_loc9_));
                     _loc10_ = this.getTileXYToTileIndex(_loc8_,_loc9_);
                     this.logicTileBuild(_loc10_,_loc12_,false);
                  }
               }
            }
         }
         else if(param1 == 4)
         {
            this.mBackground.setTileSet(param2);
            _loc13_ = 0;
            while(_loc13_ < 9)
            {
               this.mBackground.createBackgroundBuffers(_loc13_);
               _loc13_++;
            }
            this.mBackground.build();
            if(!Config.USE_OLD_ICON_SYSTEM)
            {
               this.createPngLayer();
            }
         }
      }
      
      public function getPlotIdToBuy() : int
      {
         return this.mPlotToBuy;
      }
      
      public function getTopLayer() : TopLayer
      {
         return this.mTopLayer;
      }
      
      public function getTileRelativeXToWorld(param1:int) : Number
      {
         return this.getTileXToWorld(this.getTileRelativeXToTile(param1));
      }
      
      public function notifyZoomEnd() : void
      {
         this.setMutable(false);
      }
      
      public function getHQItemObject() : ItemObject
      {
         return this.mAstarStartItem;
      }
      
      public function getTilePrice(param1:int) : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = 0;
         if(this.isValidTileIndex(param1))
         {
            _loc3_ = DollarsGame.getProfile().getTerrainPrice();
            _loc2_ = _loc3_;
         }
         return _loc2_;
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":FBCreditsPurchase.SKIP_ACTION_PRICE,
            "orderInfo":{
               "type":FBCreditsPurchase.TYPE_SKIP_ACTION,
               "sku":"terrain"
            }
         };
      }
      
      public function getNode(param1:int, param2:int) : INode
      {
         return this.getTileData(param1,param2);
      }
      
      public function setBuildGrid() : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:Shape = null;
         var _loc1_:int = 0;
         this.mTerrainGrid = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.mMapData.length)
         {
            if(Boolean(this.mTilesData[_loc3_].isMyTerrain && this.mTilesData[_loc3_].baseItem == null) && Boolean(!_loc2_) && this.isTileInAreaMine(_loc3_))
            {
               _loc4_ = new Shape();
               _loc4_.graphics.lineStyle(1,16777215);
               _loc4_.graphics.beginFill(16777215,0.25);
               _loc4_.graphics.drawRect(this.getTileXToWorld(this.getTileIndexToTileX(_loc3_)),this.getTileYToWorld(this.getTileIndexToTileY(_loc3_)),this.mTileWidth,this.mTileHeight);
               _loc4_.graphics.endFill();
               this.mTerrainGrid.push(_loc4_);
               this.mBackground.addChild(Shape(this.mTerrainGrid[_loc1_]));
               _loc1_++;
            }
            _loc3_++;
         }
      }
      
      private function getTypeFromCode(param1:int) : String
      {
         if(param1 >= 2 && param1 <= 12)
         {
            return "road";
         }
         if(param1 == 1)
         {
            return "grass";
         }
         return "else";
      }
      
      public function addIntoLayerDialog(param1:DisplayObject) : void
      {
         if(!this.mItemObjectsLayerDialog.contains(param1))
         {
            this.mItemObjectsLayerDialog.addChild(param1);
         }
      }
      
      public function removeFromDisplay(param1:ItemObject) : void
      {
         this.unregisterItemShadow(param1);
         if(this.mItemObjectsLayerBottom.contains(param1.displayObjectL0))
         {
            this.mItemObjectsLayerBottom.removeChild(param1.displayObjectL0);
         }
         if(this.mItemObjectsLayerTop.contains(param1.displayObjectL1))
         {
            this.mItemObjectsLayerTop.removeChild(param1.displayObjectL1);
         }
         param1.removeDisplayObjects();
      }
      
      public function getRulesPersistence() : XML
      {
         var _loc1_:XML = <Map/>;
         var _loc2_:XML = <LogicTiles/>;
         var _loc3_:XMLUtil = new XMLUtil(_loc2_,this.logicTileGetTiles());
         _loc3_.addToXML(_loc1_);
         return _loc1_;
      }
      
      private function buyPlot(param1:Event, param2:Boolean = false) : void
      {
         var _loc9_:Array = null;
         var _loc10_:* = 0;
         var _loc11_:int = 0;
         var _loc3_:RulesFacade = RulesFacade.getInstance();
         var _loc4_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc5_:Profile = DollarsGame.getProfile();
         var _loc6_:Array = _loc5_.plots;
         this.buyClose(param1);
         _loc6_[this.mPlotToBuy] = Plot.TYPE_FULL;
         _loc4_.world.areaBuy(this.mPlotToBuy);
         var _loc7_:int = _loc3_.expansionsGetPlotUnlockOrder(this.mPlotToBuy);
         if(_loc7_ + 1 < _loc3_.expansionsGetPlotUnlockOrderCount())
         {
            _loc9_ = _loc3_.expansionsGetPlotIndicesByUnlockOrder(_loc7_);
            _loc10_ = int(_loc9_.length - 1);
            while(_loc10_ > -1 && _loc6_[_loc9_[_loc10_]] == Plot.TYPE_FULL)
            {
               _loc10_--;
            }
            if(_loc10_ == -1 && _loc7_ < _loc3_.expansionsGetPlotsCount())
            {
               _loc9_ = _loc3_.expansionsGetPlotIndicesByUnlockOrder(_loc7_ + 1);
               _loc10_ = int(_loc9_.length - 1);
               while(_loc10_ > -1)
               {
                  _loc11_ = int(_loc9_[_loc10_]);
                  _loc6_[_loc11_] = Plot.TYPE_NORMAL;
                  this.mBackground.getForSalesSignUnlock(_loc11_);
                  _loc10_--;
               }
            }
         }
         _loc5_.plots = _loc6_;
         DollarsGame.getProfileUniverse().plots = _loc6_;
         this.buyExpansion(this.mPlotToBuy);
         var _loc8_:Object = UserDataFacade.securityCreateObj(this.mGainedExp,this.mGainedDCCoins,this.mGainedDCCash);
         UserDataFacade.getInstance().updatePlots("bought",{
            "index":this.mPlotToBuy,
            "boughtWithFB":param2
         },DollarsGame.getProfile().plotsGetPersistence());
         this.gainedReset();
         _loc5_.setUpdateEnabled(true);
         _loc5_.calculateCompanyValue();
         _loc5_.update();
      }
      
      public function logicTileBuild(param1:int, param2:int, param3:Boolean = true) : void
      {
         var _loc4_:TileData = null;
         var _loc5_:LogicTile = null;
         if(this.isValidTileIndex(param1))
         {
            _loc4_ = this.mTilesData[param1];
            _loc5_ = new LOGIC_TILE_CATALOG[param2](param2,_loc4_);
            _loc5_.build();
            _loc4_.setLogicTile(_loc5_);
            if(DollarsGame.getCurrentRole().isLogicTilesEditionAllowed())
            {
               this.setMapData(param1,TileData.TILE_LOGIC_START + param2);
               if(param3)
               {
                  this.mBackground.build();
               }
            }
         }
      }
      
      public function get view() : View
      {
         return this.mView;
      }
      
      public function unattachTerrainShape() : void
      {
         if(contains(this.mTerrainShape))
         {
            removeChild(this.mTerrainShape);
            this.mTerrainShape.visible = false;
         }
         if(contains(this.mTerrainShapeRed))
         {
            removeChild(this.mTerrainShapeRed);
            this.mTerrainShapeRed.visible = false;
         }
      }
      
      public function activeExpansion(param1:int) : void
      {
         this.switchExpansion(param1,true);
      }
      
      private function roadUnregisterItem(param1:ItemObject, param2:TileData) : void
      {
         param1.unregisterRoad(param2);
      }
      
      public function get currentTool() : Tool
      {
         return this.mCurrentTool;
      }
      
      public function cameraLookAt(param1:ItemObject) : void
      {
         this.mDestX = (-param1.worldX - param1.worldSizeX / 2) * this.scaleX + Dollars.smStage.stageWidth / 2;
         this.mDestY = (-param1.worldY - param1.worldSizeY / 2) * this.scaleY + Dollars.smStage.stageHeight / 3 + 25;
         this.x = this.mDestX;
         this.y = this.mDestY;
      }
      
      public function getRightX() : int
      {
         return this.mMapWidth;
      }
      
      public function placeItem(param1:ItemObject, param2:Boolean = true) : void
      {
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:int = 0;
         var _loc11_:TileData = null;
         var _loc12_:uint = 0;
         var _loc13_:int = 0;
         var _loc14_:TileData = null;
         var _loc15_:Boolean = false;
         var _loc3_:Boolean = false;
         if(this.mAstarStartItem == null && param1.itemDefinition.isHeadQuarters())
         {
            this.mAstarStartItem = param1;
            _loc3_ = true;
         }
         var _loc4_:uint = this.getWorldToTileX(param1.worldX);
         var _loc5_:uint = this.getWorldToTileY(param1.worldY);
         var _loc6_:Boolean = false;
         if(param1.getNoNeedPlot())
         {
            _loc8_ = 0;
            while(_loc8_ < param1.itemDefinition.baseCols)
            {
               _loc9_ = 0;
               while(_loc9_ < param1.itemDefinition.baseRows)
               {
                  _loc10_ = this.getTileXYToTileIndex(_loc4_ + _loc8_,_loc5_ + _loc9_);
                  _loc11_ = this.mTilesData[_loc10_] as TileData;
                  if(!_loc11_.isMyTerrain)
                  {
                     this.setTileTerrain(_loc10_,false,true,true);
                  }
                  _loc9_++;
               }
               _loc8_++;
            }
            this.mBackground.build();
         }
         var _loc7_:uint = 0;
         while(_loc7_ < param1.itemDefinition.baseCols)
         {
            _loc12_ = 0;
            while(_loc12_ < param1.itemDefinition.baseRows)
            {
               _loc13_ = this.getTileXYToTileIndex(_loc4_ + _loc7_,_loc5_ + _loc12_);
               _loc14_ = this.mTilesData[_loc13_] as TileData;
               _loc14_.baseItem = param1;
               if(_loc14_.isMyTerrain)
               {
                  _loc15_ = !param1.itemDefinition.requiresTerrainMine();
                  this.destroyTile(_loc13_,_loc15_);
                  if(!_loc15_)
                  {
                     this.mBackground.build();
                  }
               }
               _loc12_++;
            }
            _loc7_++;
         }
         this.addIntoDisplay(param1);
         this.mItemObjectsLayerBottom.sortDisplayList();
         if(param2)
         {
            this.removeBuildGrid();
            this.setBuildGrid();
         }
         if(param1.company.needsToRegisterRoad() && param1.itemDefinition.needsHQConnection())
         {
            param1.searchHQConnection();
         }
         if(_loc3_)
         {
            this.world.connectionToHQStart(World.CONNECTION_TO_HQ_TYPE_REGISTER_HQ);
         }
      }
      
      public function get mapDataChanges() : Array
      {
         return this.mMapDataChanges;
      }
      
      public function isBuildable(param1:int, param2:ItemDefinition = null, param3:Boolean = true) : Boolean
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:Boolean = false;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc4_:Boolean = this.isValidTileIndex(param1);
         var _loc5_:Boolean = param2.requiresTerrainMine() && param3;
         if((_loc5_) && this.world.role != null)
         {
            _loc5_ = this.world.role.requiresTerrainMine();
         }
         if(_loc4_ && _loc5_)
         {
            _loc4_ = Boolean(this.mTilesData[param1].isMyTerrain);
         }
         var _loc6_:Profile = DollarsGame.getProfile();
         if(_loc4_)
         {
            _loc4_ = this.isTileInAreaMine(param1);
         }
         if(_loc4_ && param2 != null)
         {
            _loc7_ = this.getTileIndexToTileX(param1);
            _loc8_ = this.getTileIndexToTileY(param1);
            _loc4_ = _loc7_ + param2.baseCols <= this.mMapTileCols && _loc8_ + param2.baseRows <= this.mMapTileRows;
            _loc9_ = false;
            _loc10_ = 0;
            while(_loc10_ < param2.baseCols && _loc4_)
            {
               _loc11_ = _loc7_ + _loc10_;
               _loc12_ = 0;
               while(_loc12_ < param2.baseRows && _loc4_)
               {
                  param1 = this.getTileXYToTileIndex(_loc11_,_loc8_ + _loc12_);
                  _loc4_ = this.isValidTileIndex(param1) && Boolean(this.mTilesData[param1].getIsBuildable());
                  if(_loc9_ && !_loc4_)
                  {
                     _loc4_ = (Boolean(this.mTilesData[param1].isRoad) || Boolean(this.mTilesData[param1].isSolid)) && this.mTilesData[param1].baseItem == null;
                  }
                  if(_loc4_ && _loc5_)
                  {
                     _loc4_ = Boolean(this.mTilesData[param1].isMyTerrain);
                  }
                  if(_loc4_)
                  {
                     _loc4_ = this.isTileInAreaMine(param1);
                  }
                  _loc12_++;
               }
               _loc10_++;
            }
         }
         return _loc4_;
      }
      
      public function removeBuildGrid() : void
      {
         var _loc1_:int = 0;
         if(this.mTerrainGrid != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mTerrainGrid.length)
            {
               if(this.mBackground != null)
               {
                  this.mBackground.removeChild(this.mTerrainGrid[_loc1_]);
               }
               this.mTerrainGrid[_loc1_] = null;
               _loc1_++;
            }
            this.mTerrainGrid = null;
         }
      }
      
      private function roadDestroy() : void
      {
         if(this.mRoadTilesData != null)
         {
            this.mRoadTilesData.splice(0,this.mRoadTilesData.length);
            this.mRoadTilesData = null;
         }
         if(this.mRoadTilesDataPersistence != null)
         {
            this.mRoadTilesDataPersistence.splice(0,this.mRoadTilesDataPersistence.length);
            this.mRoadTilesDataPersistence = null;
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.CONTROL:
               this.mControlDown = true;
         }
      }
      
      public function getRoadTilesCount() : int
      {
         return this.roadTilesCount;
      }
      
      private function cameraGetLookingAtHQY() : int
      {
         var _loc1_:Number = NaN;
         if(this.mAstarStartItem != null)
         {
            _loc1_ = (-this.mAstarStartItem.worldY - this.mAstarStartItem.worldSizeY / 2) * this.scaleY;
            return _loc1_ + Dollars.smStage.stageHeight / 3 + 25;
         }
         return 0;
      }
      
      private function removeTerrainCursor(param1:MouseEvent) : void
      {
      }
      
      public function get tilesData() : Array
      {
         return this.mTilesData;
      }
      
      private function cameraGetLookingAtHQX() : int
      {
         if(this.mAstarStartItem == null)
         {
            return 0;
         }
         var _loc1_:Number = (-this.mAstarStartItem.worldX - this.mAstarStartItem.worldSizeX / 2) * this.scaleX;
         return _loc1_ + Dollars.smStage.stageWidth / 2;
      }
      
      public function removeFromLayerDialog(param1:DisplayObject) : void
      {
         if(this.mItemObjectsLayerDialog.contains(param1))
         {
            this.mItemObjectsLayerDialog.removeChild(param1);
         }
      }
      
      public function destroyTileApplyEconomy(param1:int, param2:Boolean = true) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:MovieClip = null;
         var _loc3_:Profile = DollarsGame.getProfile();
         var _loc4_:Company = this.world.getCompanyMine();
         _loc3_.companyValue -= _loc3_.getTerrainPrice();
         var _loc5_:int = RulesFacade.getInstance().settingsGetDestroyTerrainProfit(_loc3_.getTerrainPrice());
         _loc4_.DCCoins += _loc5_;
         if(param2)
         {
            _loc6_ = this.getTileXToWorld(this.getTileIndexToTileX(param1));
            _loc7_ = this.getTileYToWorld(this.getTileIndexToTileY(param1));
            _loc8_ = new AssetManager.TerrainDestroyParticle();
            ParticlesManager.addParticle(new ParticleAnimation(_loc6_,_loc7_,_loc8_),false);
            ParticlesManager.addParticle(new PointsAnimation(_loc5_,PointsAnimation.TYPE_COINS,_loc6_,_loc7_),false);
            this.mTerrainShape.visible = false;
            this.setTerrainCursor(null);
         }
      }
      
      private function showBuyPlot(param1:int) : void
      {
         var _loc2_:Company = null;
         if(DollarsGame.getProfile().plots[param1] == Plot.TYPE_NORMAL)
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            this.mPlotToBuy = param1;
            this.mPopupConfirmExpansion = new PopupConfirmExpansion();
            this.mPopupConfirmExpansion.showPopup();
            this.mPopupConfirmExpansion.addEventListener(Popup.EVENT_ACCEPT,this.buyPlot);
            this.mPopupConfirmExpansion.addEventListener(PopupConfirmExpansion.EVENT_UNLOCK_EXPANSION_FBC,this.buyPlotFBC);
            this.mPopupConfirmExpansion.addEventListener(Popup.EVENT_CLOSE,this.buyClose);
         }
         else if(DollarsGame.getProfile().plots[param1] == Plot.TYPE_LOCKED)
         {
            DollarsGame.smInstance.mPopupMsgSmall.showPopupParams(TextManager.getText(TextIDs.TID_EXPANSION_LOCKED),PopupMessage.ICON_LOCK);
         }
      }
      
      public function end() : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool.end();
         }
         if(Config.DEBUG_MODE || Config.cheatsAreEnabled())
         {
            Dollars.smStage.removeEventListener(KeyboardEvent.KEY_UP,this.onKey);
            Dollars.smStage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         }
      }
      
      public function setPersistence(param1:XML) : void
      {
         this.mPersistence = param1;
         this.mSid = param1.@sid;
         var _loc2_:int = int(param1.@sid);
         if(DollarsGame.smMapSid <= _loc2_)
         {
            DollarsGame.smMapSid = _loc2_ + 1;
         }
      }
      
      public function buyExpansion(param1:int) : void
      {
         var _loc2_:Shape = this.mBackground.mExpansions[param1];
         _loc2_.graphics.clear();
         removeChild(_loc2_);
         this.mBackground.mExpansions[param1] = null;
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_BUY_EXPANSION);
      }
      
      public function addIntoDisplay(param1:ItemObject) : void
      {
         this.registerItemShadow(param1);
         this.mItemObjectsLayerBottom.addChild(param1.displayObjectL0);
         this.mItemObjectsLayerTop.addChild(param1.displayObjectL1);
         param1.displayObjectL0.depth = this.getWorldToTileIndex(param1.worldX + param1.worldSizeX,param1.worldY + (param1.worldSizeY - this.mTileHeight * scaleY),param1.worldZ,true,false);
      }
      
      public function getWorldXToScreen(param1:Number) : int
      {
         return Math.round(param1 * scaleX + x);
      }
      
      private function setTileTerrain(param1:int, param2:Boolean = true, param3:Boolean = true, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Company = null;
         var _loc10_:Profile = null;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(this.isValidTileIndex(param1))
         {
            _loc6_ = new Array();
            this.mTilesData[param1].isMyTerrain = true;
            this.buildTerrain(param1,_loc6_,TileData.TILE_TERRAIN);
            _loc6_ = null;
            if(param3)
            {
               this.mTerrainTilesData.push(param1);
               _loc7_ = this.getTileToTileRelativeX(this.getTileIndexToTileX(param1));
               _loc8_ = this.getTileToTileRelativeY(this.getTileIndexToTileY(param1));
               this.mTerrainTilesDataPersistence.push(_loc7_ + ":" + _loc8_);
            }
            if(param2)
            {
               if(!param5)
               {
                  _loc9_ = this.world.getCompanyMine();
                  _loc10_ = DollarsGame.getProfile();
                  _loc11_ = _loc10_.getTerrainPrice();
                  _loc12_ = this.getTileXToWorld(this.getTileIndexToTileX(param1));
                  _loc13_ = this.getTileYToWorld(this.getTileIndexToTileY(param1));
                  ParticlesManager.addParticle(new PointsAnimation(-_loc11_,PointsAnimation.TYPE_COINS,_loc12_,_loc13_),false);
                  _loc9_.DCCoins -= _loc11_;
                  _loc10_.companyValue += _loc10_.getTerrainPrice();
               }
               this.mBackground.build();
               UserDataFacade.getInstance().updateMap(this.mSid,"add",{
                  "type":"Terrain",
                  "x":_loc7_,
                  "y":_loc8_
               },this.securityCreateObj("add","Terrain",param5));
            }
         }
      }
      
      public function load() : void
      {
         this.terrainLoad();
         this.roadLoad();
      }
      
      public function disable() : void
      {
         if(mouseEnabled)
         {
            if(this.mCurrentTool != null)
            {
               this.mCursorIDBack = this.mCurrentTool.getDefaultCursorID();
               this.mCurrentTool.disable(true);
            }
            else
            {
               this.mCursorIDBack = Dollars.getCurrentCursor().mCurrentCursorID;
            }
            if(this.mItemMouseOver != null)
            {
               this.mItemMouseOver.undoMouseOver(true);
            }
            this.terrainDisable();
            mouseEnabled = false;
         }
      }
      
      public function getAreaIndexFromTileIndex(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = -1;
         if(this.isValidTileIndex(param1))
         {
            _loc3_ = int(this.getTileIndexToTileX(param1));
            _loc3_ /= MapDefinition.getInstance().getAreaTileCols();
            _loc4_ = this.getTileIndexToTileY(param1) - this.mMapTopExtraRows;
            _loc4_ = _loc4_ / MapDefinition.getInstance().getAreaTileRows();
            _loc5_ = _loc3_ + _loc4_ * MapDefinition.getInstance().getMapAreaCols();
            _loc2_ = RulesFacade.getInstance().expansionsGetMiniToPlot(_loc5_);
         }
         return _loc2_;
      }
      
      public function getMapHeight(param1:Boolean = false) : uint
      {
         var _loc2_:int = int(this.mMapHeight);
         if(param1)
         {
            _loc2_ = Math.round(_loc2_ * scaleY);
         }
         return _loc2_;
      }
      
      public function buildTerrain(param1:int, param2:Array, param3:int) : void
      {
         var _loc4_:int = int(this.mMapData[param1]);
         var _loc5_:int = this.getTileTerrainForm(param1,param3);
         var _loc6_:Profile = DollarsGame.getProfileUniverse();
         var _loc7_:int = this.getAreaIndexFromTileIndex(param1);
         if(!_loc6_.isExpansionAreaMine(_loc7_))
         {
            _loc5_ += Background.TILE_MAX;
         }
         if(_loc5_ != _loc4_ && param2.indexOf(param1) == -1)
         {
            this.setMapData(param1,_loc5_);
            param2.push(param1);
            this.checkAdjacentTiles(param1,param2,param3);
            if(Boolean(this.mTilesData[param1].isMyTerrain) && param3 == TileData.TILE_ROAD)
            {
               this.checkAdjacentTiles(param1,param2,TileData.TILE_TERRAIN);
            }
         }
      }
      
      public function getMarginHeight() : int
      {
         return Math.round(4 * this.mTileWidth * scaleX);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_SKIP_ACTION,MetricConstants.PRODUCT_PLOT,null,null,0,1);
            this.addTerrain(true);
         }
      }
      
      public function isTileInAreaForSale(param1:int, param2:Boolean = true) : Boolean
      {
         return this.isTileInArea(param1,Plot.TYPE_NORMAL,param2,false);
      }
      
      public function securityCreateObj(param1:String, param2:String, param3:Boolean = false) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:Profile = null;
         var _loc4_:Object = null;
         if(param2 == "Terrain")
         {
            _loc5_ = 0;
            _loc6_ = DollarsGame.getProfile();
            if(param1 == "add" && !param3)
            {
               _loc5_ = -_loc6_.getTerrainPrice();
            }
            else if(param1 == "del")
            {
               _loc5_ = RulesFacade.getInstance().settingsGetDestroyTerrainProfit(_loc6_.getTerrainPrice());
            }
            _loc4_ = UserDataFacade.securityCreateObj(0,_loc5_,0);
         }
         return _loc4_;
      }
      
      public function getTileData(param1:int, param2:int) : TileData
      {
         var _loc3_:int = this.getTileXYToTileIndex(param1,param2);
         return this.getTileDataFromIndex(_loc3_);
      }
      
      public function areaBuy(param1:int) : void
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc2_:RulesFacade = RulesFacade.getInstance();
         var _loc3_:MapDefinition = MapDefinition.getInstance();
         var _loc4_:int = _loc3_.getAreaTileCols();
         var _loc5_:int = _loc3_.getAreaTileRows();
         var _loc6_:int = _loc2_.expansionsGetPlotX(param1);
         var _loc7_:int = _loc2_.expansionsGetPlotY(param1);
         var _loc8_:int = _loc7_ * _loc5_ + this.mMapTopExtraRows;
         var _loc9_:int = _loc6_ * _loc4_;
         var _loc10_:int = 0;
         while(_loc10_ < _loc5_)
         {
            _loc11_ = _loc8_ + _loc10_;
            _loc12_ = 0;
            while(_loc12_ < _loc4_)
            {
               _loc13_ = this.getTileXYToTileIndex(_loc12_ + _loc9_,_loc11_);
               if(this.mMapData[_loc13_] > Background.TILE_MAX)
               {
                  this.setMapData(_loc13_,this.mMapData[_loc13_] - Background.TILE_MAX);
               }
               _loc12_++;
            }
            _loc10_++;
         }
         this.mBackground.areaBuy(param1);
      }
      
      private function roadLoopNeighbours(param1:int, param2:Function) : void
      {
         var _loc3_:TileData = this.mTilesData[param1];
         var _loc4_:int = param1 - 1;
         this.roadRegisterOnNeighbour(_loc4_,_loc3_,param2);
         _loc4_ = param1 - this.mMapTileCols;
         this.roadRegisterOnNeighbour(_loc4_,_loc3_,param2);
         _loc4_ = param1 + 1;
         this.roadRegisterOnNeighbour(_loc4_,_loc3_,param2);
         _loc4_ = param1 + this.mMapTileCols;
         this.roadRegisterOnNeighbour(_loc4_,_loc3_,param2);
      }
      
      public function gainedAccumExp(param1:int) : void
      {
         this.mGainedExp += param1;
      }
      
      private function checkAnimEnd(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
            DollarsGame.smInstance.mGameClip.mouseEnabled = true;
            this.mAstarStartItem.displayObjectL1.removeChild(_loc2_);
            _loc2_ = null;
            DollarsGame.smInstance.mPopupHelpShown = true;
            dispatchEvent(new Event(EVENT_AUTO_SCROLL_ANIM_END));
         }
      }
      
      private function terrainDestroy() : void
      {
         if(this.mTerrainTilesData != null)
         {
            this.mTerrainTilesData.splice(0,this.mTerrainTilesData.length);
            this.mTerrainTilesData = null;
         }
         if(this.mTerrainTilesDataPersistence != null)
         {
            this.mTerrainTilesDataPersistence.splice(0,this.mTerrainTilesDataPersistence.length);
            this.mTerrainTilesDataPersistence = null;
         }
      }
      
      public function getWorldToTileIndex(param1:Number, param2:Number, param3:Number, param4:Boolean = false, param5:Boolean = true) : int
      {
         return this.getTileXYToTileIndex(this.getWorldToTileX(param1,param4),this.getWorldToTileY(param2,param4),param5);
      }
      
      public function roadGetTiles() : Array
      {
         return this.mRoadTilesDataPersistence;
      }
      
      private function buyClose(param1:Event) : void
      {
         this.mPopupConfirmExpansion.removeEventListener(Popup.EVENT_ACCEPT,this.buyPlot);
         this.mPopupConfirmExpansion.removeEventListener(PopupConfirmExpansion.EVENT_UNLOCK_EXPANSION_FBC,this.buyPlotFBC);
         this.mPopupConfirmExpansion.removeEventListener(Popup.EVENT_CLOSE,this.buyClose);
         this.mPopupConfirmExpansion.destroy();
         this.mPopupConfirmExpansion = null;
      }
      
      private function roadRegisterOnNeighbour(param1:int, param2:TileData, param3:Function) : void
      {
         var _loc4_:ItemObject = null;
         if(this.isValidTileIndex(param1))
         {
            this.mTilesData[param1].setNeighbors(null);
            _loc4_ = this.mTilesData[param1].baseItem;
            if(_loc4_ != null)
            {
               param3(_loc4_,param2);
            }
         }
      }
      
      public function registerItemShadow(param1:ItemObject, param2:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         if(param2 == -1)
         {
            param2 = param1.getShadowRows();
         }
         var _loc3_:uint = this.getWorldToTileX(param1.worldX);
         var _loc4_:uint = this.getWorldToTileY(param1.worldY);
         var _loc6_:int = 0;
         while(_loc6_ < param1.itemDefinition.baseCols)
         {
            _loc7_ = 0;
            while(_loc7_ < param2)
            {
               _loc5_ = this.getTileXYToTileIndex(_loc3_ + _loc6_,_loc4_ - _loc7_ - 1);
               if(this.isValidTileIndex(_loc5_))
               {
                  (this.mTilesData[_loc5_] as TileData).addShadowItem(param1);
               }
               _loc7_++;
            }
            _loc6_++;
         }
      }
      
      public function getItemFromScreen(param1:Number, param2:Number) : ItemObject
      {
         var _loc3_:int = this.getScreenToTileIndex(param1,param2);
         var _loc4_:ItemObject = null;
         if(this.isValidTileIndex(_loc3_))
         {
            _loc4_ = (this.mTilesData[_loc3_] as TileData).baseItem;
         }
         return _loc4_;
      }
      
      public function get mapBottomExtraRows() : uint
      {
         return this.mMapBottomExtraRows;
      }
      
      public function get mapData() : Array
      {
         return this.mMapData;
      }
      
      private function onCloseConfirm(param1:Event) : void
      {
         this.removeConfirmEventListeners();
      }
      
      private function onExchange(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         this.addTerrain();
      }
      
      public function logicTileGetTiles() : Array
      {
         var _loc3_:TileData = null;
         var _loc4_:LogicTile = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Array = new Array();
         var _loc2_:* = int(this.mTilesData.length - 1);
         while(_loc2_ > -1)
         {
            _loc3_ = this.mTilesData[_loc2_] as TileData;
            _loc4_ = _loc3_.getLogicTile();
            if(_loc4_ != null)
            {
               _loc5_ = this.getTileToTileRelativeX(this.getTileIndexToTileX(_loc2_));
               _loc6_ = this.getTileToTileRelativeY(this.getTileIndexToTileY(_loc2_));
               _loc1_.push(_loc4_.getType() + ":" + _loc5_ + ":" + _loc6_);
            }
            _loc2_--;
         }
         return _loc1_;
      }
      
      public function gainedAccumDCCash(param1:int) : void
      {
         this.mGainedDCCash += param1;
      }
      
      public function logicTileDestroy(param1:int) : void
      {
         var _loc2_:TileData = null;
         var _loc3_:LogicTile = null;
         if(this.isValidTileIndex(param1))
         {
            _loc2_ = this.mTilesData[param1];
            _loc3_ = _loc2_.getLogicTile();
            if(_loc3_ != null)
            {
               _loc3_.unbuild();
               _loc2_.setLogicTile(null);
               if(DollarsGame.getCurrentRole().isLogicTilesEditionAllowed())
               {
                  this.setMapData(param1,TileData.TILE_GRASS - 1);
                  this.mBackground.build();
               }
            }
         }
      }
      
      private function buyPlotFBC(param1:Event) : void
      {
         this.buyPlot(param1,true);
      }
      
      private function astarClearPath() : void
      {
         var _loc1_:Path = null;
         var _loc2_:int = 0;
         var _loc3_:TileData = null;
         if(this.mStartTile != null)
         {
            this.mStartTile.unShowStartDot();
         }
         if(this.mLastPath != null)
         {
            _loc1_ = this.mLastPath;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.getNodes().length)
            {
               _loc3_ = TileData(_loc1_.getNodes()[_loc2_]);
               _loc3_.unShowPath();
               _loc2_++;
            }
            if(this.mGoalTile != null)
            {
               this.mGoalTile.unShowEndDot();
            }
         }
         this.mStartTile = null;
         this.mGoalTile = null;
         this.mLastPath = null;
      }
      
      private function checkAdjacentTiles(param1:int, param2:Array, param3:int) : void
      {
         var _loc4_:int = param1 + 1;
         if(this.TileIsInTheSameRow(param1,_loc4_,param3))
         {
            this.buildTerrain(_loc4_,param2,param3);
         }
         _loc4_ = param1 - 1;
         if(this.TileIsInTheSameRow(param1,_loc4_,param3))
         {
            this.buildTerrain(_loc4_,param2,param3);
         }
         _loc4_ = param1 - this.mMapTileCols;
         if(this.TileIsInTheMap(_loc4_,param3))
         {
            this.buildTerrain(_loc4_,param2,param3);
         }
         _loc4_ = param1 + this.mMapTileCols;
         if(this.TileIsInTheMap(_loc4_,param3))
         {
            this.buildTerrain(_loc4_,param2,param3);
         }
      }
      
      public function getMapWidth(param1:Boolean = false) : uint
      {
         var _loc2_:int = int(this.mMapWidth);
         if(param1)
         {
            _loc2_ = Math.round(_loc2_ * scaleX);
         }
         return int(_loc2_ + this.getMarginWidth());
      }
      
      public function gainedAccumDCCoins(param1:int) : void
      {
         this.mGainedDCCoins += param1;
      }
      
      public function notifyZoomBegin() : void
      {
         this.setMutable(true);
         this.mZoomRefX = x - (Dollars.smStage.stageWidth >> 1);
         this.mZoomRefY = y - (Dollars.smStage.stageHeight >> 1);
         this.mZoomRefX = Math.round(this.mZoomRefX / scaleX);
         this.mZoomRefY = Math.round(this.mZoomRefY / scaleY);
      }
      
      private function addTerrain(param1:Boolean = false) : void
      {
         var _loc2_:int = this.mExchangeTileIndex;
         this.setTileTerrain(_loc2_,true,true,false,param1);
         var _loc3_:MovieClip = new AssetManager.TerrainParticle();
         var _loc4_:Number = this.getTileXToWorld(this.getTileIndexToTileX(_loc2_)) + (this.mTileWidth >> 1);
         var _loc5_:Number = this.getTileYToWorld(this.getTileIndexToTileY(_loc2_)) + (this.mTileHeight >> 1);
         ParticlesManager.addParticle(new ParticleAnimation(_loc4_,_loc5_,_loc3_),false);
      }
      
      public function getTileRelativeYToWorld(param1:int) : Number
      {
         return this.getTileYToWorld(this.getTileRelativeYToTile(param1));
      }
      
      public function roadTileBuild(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:TileData = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(this.isValidTileIndex(param1))
         {
            _loc3_ = this.mTilesData[param1];
            if(_loc3_.isRoadAllowed())
            {
               if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == 4)
               {
                  _loc8_ = Tutorial.smAddRoadTiles.indexOf(param1);
                  if(_loc8_ > -1)
                  {
                     dispatchEvent(new Event(Tutorial.EVENT_SET_TERRAIN));
                  }
               }
               if(_loc3_.isMyTerrain)
               {
                  this.destroyTile(param1);
               }
               _loc3_.isRoad = true;
               _loc4_ = new Array();
               this.buildTerrain(param1,_loc4_,TileData.TILE_ROAD);
               if(param2)
               {
                  this.checkCrossWalk();
               }
               this.roadLoopNeighbours(param1,this.roadRegisterItem);
               _loc5_ = null;
               if(param2)
               {
                  this.mBackground.build();
                  this.world.registerRoad();
                  _loc5_ = this.securityCreateObj("add","Road");
               }
               this.mRoadTilesData.push(_loc3_);
               _loc6_ = this.getTileToTileRelativeX(this.getTileIndexToTileX(_loc3_.tileIndex));
               _loc7_ = this.getTileToTileRelativeY(this.getTileIndexToTileY(_loc3_.tileIndex));
               this.mRoadTilesDataPersistence.push(_loc6_ + ":" + _loc7_);
               UserDataFacade.getInstance().updateMap(this.mSid,"add",{
                  "type":"Road",
                  "x":_loc6_,
                  "y":_loc7_
               },_loc5_);
            }
         }
      }
      
      public function getNodeTransitionCost(param1:INode, param2:INode) : Number
      {
         return this.getNodeTransitionCostByType(param1.getNodeType(),param2.getNodeType());
      }
      
      public function getBottomY() : int
      {
         return (this.mMapTileRows - this.mMapBottomExtraRows - 3) * this.mTileHeight;
      }
      
      public function astarTileClicked(param1:int) : void
      {
         var _loc2_:TileData = null;
         var _loc3_:ItemObject = null;
         if(DEBUG[DEBUG_ASTAR])
         {
            if(this.isValidTileIndex(param1))
            {
               _loc2_ = this.mTilesData[param1];
               _loc3_ = _loc2_.baseItem;
               if(_loc2_.isRoad)
               {
                  if(this.mStartTile == null)
                  {
                     this.mStartTile = _loc2_;
                     this.mStartTile.showStartDot();
                  }
                  else if(this.mGoalTile == null)
                  {
                     this.mGoalTile = _loc2_;
                     this.mGoalTile.showEndDot();
                     this.astarSearch(this.mStartTile,this.mGoalTile);
                  }
                  else
                  {
                     this.astarClearPath();
                  }
               }
               else
               {
                  this.astarClearPath();
               }
               if(this.mLastItemClicked != null && _loc3_ != this.mLastItemClicked)
               {
                  this.mLastItemClicked.debugAStar(false);
                  this.mAstarStartItem.debugAStar(false);
               }
               this.mLastItemClicked = _loc3_;
               if(_loc3_ != null)
               {
                  this.astarSearchItem(_loc3_,true);
               }
            }
         }
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         if(this.mSid == "")
         {
            this.mSid = "" + DollarsGame.smMapSid;
            ++DollarsGame.smMapSid;
         }
         var _loc2_:String = this.mWorld.mSid;
         var _loc3_:XML = <Map sid={this.mSid} wsid={_loc2_}/>;
         var _loc4_:XML = <Terrain/>;
         var _loc5_:XMLUtil = new XMLUtil(_loc4_,this.getTilesTerrain());
         _loc5_.addToXML(_loc3_);
         _loc4_ = <Road/>;
         _loc5_ = new XMLUtil(_loc4_,this.roadGetTiles());
         _loc5_.addToXML(_loc3_);
         return _loc3_;
      }
      
      public function changeTool(param1:Tool, param2:String = null) : void
      {
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool.end();
         }
         this.mCurrentTool = param1;
         this.mCurrentTool.start(false,param2);
      }
      
      public function getCols() : int
      {
         return this.mMapTileCols;
      }
      
      public function getTileRelativeYToTile(param1:int) : uint
      {
         return param1 + (this.mMapTileRealRows >> 1) + this.mMapTopExtraRows;
      }
      
      public function unregisterItemShadow(param1:ItemObject, param2:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         if(param2 == -1)
         {
            param2 = param1.getShadowRows();
         }
         var _loc3_:uint = this.getWorldToTileX(param1.worldX);
         var _loc4_:uint = this.getWorldToTileY(param1.worldY);
         var _loc6_:int = 0;
         while(_loc6_ < param1.itemDefinition.baseCols)
         {
            _loc7_ = 0;
            while(_loc7_ < param2)
            {
               _loc5_ = this.getTileXYToTileIndex(_loc3_ + _loc6_,_loc4_ - _loc7_ - 1);
               if(this.isValidTileIndex(_loc5_))
               {
                  (this.mTilesData[_loc5_] as TileData).removeShadowItem(param1);
               }
               _loc7_++;
            }
            _loc6_++;
         }
      }
      
      private function TileIsInTheMap(param1:int, param2:int) : Boolean
      {
         return this.isValidTileIndex(param1) && this.mTilesData[param1].getGroundType() == param2;
      }
      
      public function onResize(param1:Event) : void
      {
         this.cameraStart();
         this.calculateScrollBottomY();
         MessageManager.getInstance().stageResize();
         if(!Config.USE_OLD_ICON_SYSTEM)
         {
            if(this.mTopLayer != null)
            {
               this.mTopLayer.setScreen(Dollars.smStage.stageWidth,Dollars.smStage.stageHeight);
            }
         }
      }
      
      public function get tileHeight() : uint
      {
         return this.mTileHeight;
      }
      
      public function astarSearchItem(param1:ItemObject, param2:Boolean = false) : SearchResults
      {
         var _loc3_:SearchResults = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:SearchResults = null;
         var _loc10_:int = 0;
         var _loc4_:Boolean = false;
         if(this.mAstarStartItem != null && this.mAstarStartItem.hasRoadInPerimeter())
         {
            if(param2)
            {
               this.mAstarStartItem.debugAStar(true);
            }
            if(param1.hasRoadInPerimeter())
            {
               if(param2)
               {
                  param1.debugAStar(true);
               }
               _loc5_ = param1.roadTiles;
               _loc6_ = int(_loc5_.length);
               _loc7_ = this.mAstarStartItem.roadTiles;
               _loc8_ = int(_loc7_.length);
               _loc9_ = null;
               _loc10_ = 0;
               while(_loc10_ < _loc6_ && !_loc4_)
               {
                  _loc3_ = _loc9_ = this.mAstar.search(_loc5_[_loc10_],_loc7_);
                  _loc4_ = _loc3_.getIsSuccess();
                  _loc10_++;
               }
               if(_loc4_ && param2)
               {
                  this.astarShowPath(_loc3_);
               }
            }
         }
         return _loc3_;
      }
      
      public function getTileToTileRelativeX(param1:uint) : int
      {
         return param1 - (this.mMapTileCols >> 1);
      }
      
      public function getTileToTileRelativeY(param1:uint) : int
      {
         return param1 - (this.mMapTileRealRows >> 1) - this.mMapTopExtraRows;
      }
      
      private function removeConfirmEventListeners() : void
      {
         var _loc1_:Popup = DollarsGame.smInstance.mPopupConfirm;
         _loc1_.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         _loc1_.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onCloseConfirm);
         _loc1_.removeEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
      }
      
      public function getMarginWidth() : int
      {
         return Math.round(4 * this.mTileWidth * scaleX);
      }
      
      public function launchAutoScroll(param1:String) : void
      {
         DollarsGame.smInstance.mPopupHelpShown = false;
         this.mFinalSkin = param1;
         DollarsGame.smInstance.mGameClip.mouseEnabled = false;
         this.mOriginX = this.x;
         this.mOriginY = this.y;
         this.mDestX = this.cameraGetLookingAtHQX();
         this.mDestY = this.cameraGetLookingAtHQY();
         this.mAutoScrollEnabled = true;
         this.mCurrentTime = 0;
      }
      
      public function getTileXToWorld(param1:uint) : Number
      {
         return param1 * this.mTileWidth;
      }
      
      public function getTileIndexToWorldX(param1:int) : int
      {
         var _loc2_:uint = this.getTileIndexToTileX(param1);
         return this.getTileXToWorld(_loc2_);
      }
      
      public function get world() : World
      {
         return this.mWorld;
      }
      
      public function getLeftX() : int
      {
         return 0;
      }
      
      public function sellTerrain(param1:ItemObject) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Profile = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = this.getScreenToTileIndex(param1.worldX,param1.worldY);
         if(param1.company.isMine())
         {
            _loc5_ = DollarsGame.getProfile();
            _loc6_ = param1.itemDefinition.baseRows * param1.itemDefinition.baseCols;
            _loc5_.companyValue += _loc6_ * _loc5_.getTerrainPrice();
         }
         var _loc4_:int = 0;
         while(_loc4_ < param1.itemDefinition.baseRows)
         {
            _loc7_ = 0;
            while(_loc7_ < param1.itemDefinition.baseCols)
            {
               _loc3_ = _loc2_ + _loc7_;
               if(param1.company.isMine())
               {
                  this.setTileTerrain(_loc3_,false);
               }
               else
               {
                  this.setMapData(_loc2_,this.GRASS_TILE);
                  this.mTilesData[_loc3_].isMyTerrain = false;
               }
               _loc7_++;
            }
            _loc2_ += this.mMapTileCols;
            _loc4_++;
         }
         this.mBackground.build();
      }
      
      public function getViewPortX() : int
      {
         return this.mViewPortX;
      }
      
      public function getViewPortY() : int
      {
         return this.mViewPortY;
      }
      
      public function getTileIndexToWorldY(param1:int) : int
      {
         var _loc2_:uint = this.getTileIndexToTileY(param1);
         return this.getTileYToWorld(_loc2_);
      }
      
      private function TileIsInTheSameRow(param1:int, param2:int, param3:int) : Boolean
      {
         return int(param1 / this.mMapTileCols) == int(param2 / this.mMapTileCols) && this.isValidTileIndex(param2) && this.mTilesData[param2].getGroundType() == param3;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.start();
      }
      
      public function enable() : void
      {
         if(!mouseEnabled)
         {
            if(this.mCurrentTool != null)
            {
               this.mCurrentTool.enable(true);
            }
            mouseEnabled = true;
            Dollars.getCurrentCursor().changeCursor(this.mCursorIDBack);
         }
      }
      
      public function get terrainTilesCount() : int
      {
         return this.mTerrainTilesDataPersistence.length;
      }
      
      public function setTerrainCursor(param1:MouseEvent) : void
      {
         var _loc3_:TileData = null;
         var _loc4_:int = 0;
         var _loc2_:int = this.getScreenToTileIndex(mouseX,mouseY);
         if(DollarsGame != null && this.isValidTileIndex(_loc2_))
         {
            if(this.isTileInAreaMine(_loc2_))
            {
               _loc3_ = this.mTilesData[_loc2_] as TileData;
               _loc4_ = Dollars.getCurrentCursor().mCurrentCursorID;
               if(_loc4_ == Cursor.CURSOR_TERRAIN)
               {
                  if(_loc3_.getIsBuildable() && !_loc3_.isMyTerrain)
                  {
                     this.mTerrainShape.visible = true;
                     this.mTerrainShape.x = this.getTileXToWorld(this.getTileIndexToTileX(_loc2_));
                     this.mTerrainShape.y = this.getTileYToWorld(this.getTileIndexToTileY(_loc2_));
                  }
                  else
                  {
                     this.mTerrainShape.visible = false;
                  }
                  if(_loc3_.isMyTerrain && _loc3_.baseItem == null || _loc3_.isRoad || _loc3_.isSolid)
                  {
                     this.mTerrainShapeRed.visible = true;
                     this.mTerrainShapeRed.x = this.getTileXToWorld(this.getTileIndexToTileX(_loc2_));
                     this.mTerrainShapeRed.y = this.getTileYToWorld(this.getTileIndexToTileY(_loc2_));
                  }
                  else
                  {
                     this.mTerrainShapeRed.visible = false;
                  }
               }
               else if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_SELECT && this.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
               {
                  if(_loc3_.isOnTerrain())
                  {
                     Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_BUILD);
                  }
               }
               else if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_BUILD)
               {
                  if(!_loc3_.isOnTerrain())
                  {
                     Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
                  }
               }
            }
            else
            {
               this.mTerrainShape.visible = false;
            }
         }
      }
      
      public function clickOnTerrain(param1:int) : void
      {
         var _loc3_:Profile = null;
         var _loc4_:int = 0;
         var _loc2_:Boolean = true;
         if(this.world.role.checksExpansionIsMine())
         {
            _loc3_ = DollarsGame.getProfileUniverse();
            _loc4_ = this.getAreaIndexFromTileIndex(param1);
            if(_loc3_.isExpansionAreaForSale(_loc4_))
            {
               this.showBuyPlot(_loc4_);
               _loc2_ = false;
            }
         }
         if(Boolean(_loc2_ && this.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON && this.mCurrentTool.isMapCursorEnabled() && Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_BUILD) && Boolean(this.mTilesData[param1].isMyTerrain) && this.mTilesData[param1].baseItem == null)
         {
            DollarsGame.smInstance.showBuyBox();
         }
      }
      
      private function gridUpdate() : void
      {
         var _loc10_:uint = 0;
         var _loc1_:Graphics = this.mDebugLayers[DEBUG_GRID].graphics;
         _loc1_.clear();
         _loc1_.lineStyle(0.3,16777215);
         _loc1_.moveTo(0,0);
         _loc1_.lineTo(0,0);
         _loc1_.lineTo(this.mMapWidth,0);
         _loc1_.lineTo(this.mMapWidth,this.mMapHeight);
         _loc1_.lineTo(0,this.mMapHeight);
         _loc1_.lineStyle(0.3,16711680);
         var _loc2_:uint = 0;
         while(_loc2_ < this.mMapTileCols)
         {
            _loc10_ = _loc2_ * this.mTileWidth;
            _loc1_.moveTo(_loc10_,0);
            _loc1_.lineTo(_loc10_,this.mMapHeight);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.mMapTileRows)
         {
            _loc10_ = _loc2_ * this.mTileHeight;
            _loc1_.moveTo(0,_loc10_);
            _loc1_.lineTo(this.mMapWidth,_loc10_);
            _loc2_++;
         }
         var _loc3_:int = (this.mMapTopExtraRows + (this.mMapTileRealRows >> 1)) * this.mTileHeight;
         _loc1_.lineStyle(0.3,65535);
         var _loc4_:int = this.mMapWidth >> 1;
         var _loc5_:int = _loc3_;
         _loc1_.moveTo(_loc4_,_loc5_ - 5);
         _loc1_.lineTo(_loc4_,_loc5_ + 5);
         _loc1_.moveTo(_loc4_ - 5,_loc5_);
         _loc1_.lineTo(_loc4_ + 5,_loc5_);
         _loc1_.lineStyle(0.3,65280);
         var _loc6_:int = MapDefinition.getInstance().getMapAreaCols() + 1;
         var _loc7_:int = MapDefinition.getInstance().getAreaTileRows();
         _loc2_ = 0;
         while(_loc2_ < _loc6_)
         {
            _loc10_ = (this.mMapTopExtraRows + _loc2_ * _loc7_) * this.mTileHeight;
            _loc1_.moveTo(0,_loc10_);
            _loc1_.lineTo(this.mMapWidth,_loc10_);
            _loc2_++;
         }
         var _loc8_:int = MapDefinition.getInstance().getMapAreaRows() + 1;
         var _loc9_:int = MapDefinition.getInstance().getAreaTileCols();
         _loc2_ = 0;
         while(_loc2_ < _loc8_)
         {
            _loc10_ = _loc2_ * _loc9_ * this.mTileWidth;
            _loc1_.moveTo(_loc10_,0);
            _loc1_.lineTo(_loc10_,this.mMapHeight);
            _loc2_++;
         }
      }
      
      public function createExpansions() : void
      {
         this.mBackground.createExpansions();
      }
      
      public function gainedReset() : void
      {
         this.mGainedDCCash = 0;
         this.mGainedDCCoins = 0;
         this.mGainedExp = 0;
      }
      
      public function get tileWidth() : uint
      {
         return this.mTileWidth;
      }
      
      private function terrainLoad() : void
      {
         this.mTerrainTilesData = new Array();
         this.mTerrainTilesDataPersistence = new Array();
      }
      
      public function get mapTileWidth() : uint
      {
         return this.mMapTileCols;
      }
      
      public function get mapTopExtraRows() : uint
      {
         return this.mMapTopExtraRows;
      }
      
      public function getTileIndexToTileX(param1:uint) : uint
      {
         return param1 % this.mMapTileCols;
      }
      
      private function roadRegisterItem(param1:ItemObject, param2:TileData) : void
      {
         param1.registerRoad(param2);
      }
      
      private function cursorUpdate() : void
      {
         var _loc1_:Graphics = this.mDebugLayers[DEBUG_CURSOR].graphics;
         _loc1_.clear();
         _loc1_.lineStyle(0.3,16777215);
         _loc1_.moveTo(mouseX - 5,mouseY);
         _loc1_.lineTo(mouseX + 5,mouseY);
         _loc1_.moveTo(mouseX,mouseY - 5);
         _loc1_.lineTo(mouseX,mouseY + 5);
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(Config.USE_CLIMATE)
         {
            ClimateManager.getInstance().logicUpdate(param1);
         }
         TrafficAgentManager.getInstance().logicUpdate(param1);
         if(Config.DEBUG_MODE)
         {
            this.cursorUpdate();
         }
         if(this.mCurrentTool != null)
         {
            this.mCurrentTool.logicUpdate(param1);
         }
         if(this.mPersistenceAttributesChanged)
         {
            this.mPersistenceAttributesChanged = false;
         }
         if(this.mAutoScrollEnabled)
         {
            this.doAutoScroll(param1);
         }
         if(!Config.USE_OLD_ICON_SYSTEM)
         {
            this.mTopLayer.logicUpdate(param1);
         }
      }
      
      public function destroyTile(param1:int, param2:Boolean = true) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc3_:TileData = this.mTilesData[param1];
         this.mTilesData[param1].isMyTerrain = false;
         if(param2)
         {
            _loc6_ = this.mTerrainTilesData.indexOf(param1);
            if(_loc6_ > -1)
            {
               _loc7_ = this.mTerrainTilesDataPersistence[_loc6_];
               _loc8_ = _loc7_.indexOf(":");
               _loc9_ = _loc7_.substring(0,_loc8_);
               _loc10_ = _loc7_.substring(_loc8_ + 1,_loc7_.length);
               this.mTerrainTilesData.splice(_loc6_,1);
               this.mTerrainTilesDataPersistence.splice(_loc6_,1);
            }
         }
         var _loc4_:int = int(this.GRASS_TILE);
         if(!this.isTileInAreaMine(param1,false))
         {
            _loc4_ += Background.TILE_MAX;
         }
         this.setMapData(param1,_loc4_);
         var _loc5_:Array = new Array();
         this.buildTerrain(param1,_loc5_,TileData.TILE_TERRAIN);
         this.setMapData(param1,_loc4_);
         if(param2)
         {
            if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
            {
               this.destroyTileApplyEconomy(param1);
               UserDataFacade.getInstance().updateMap(this.mSid,"del",{
                  "type":"Terrain",
                  "x":_loc9_,
                  "y":_loc10_
               },this.securityCreateObj("del","Terrain"));
            }
            else
            {
               _loc11_ = new Object();
               _loc11_.cmd = UserDataFacade.QUEUE_REQUEST_DEL_TERRAIN;
               _loc11_.sid = this.mSid;
               _loc11_.x = _loc9_;
               _loc11_.y = _loc10_;
               _loc11_.tileIndex = param1;
               UserDataFacade.getInstance().queueRequestAdd(_loc11_);
               Debug.trace("@@@@@@@@ queueRequestAdd " + _loc11_.cmd + " sid = " + _loc11_.sid + " x = " + _loc11_.x + " y = " + _loc11_.y);
            }
            this.mBackground.build();
         }
         _loc5_ = null;
      }
      
      public function getTileIndexToTileY(param1:uint) : uint
      {
         return param1 / this.mMapTileCols;
      }
      
      private function onFBCGoOn(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      public function createPngLayer() : void
      {
         if(this.mTopLayer == null)
         {
            this.mTopLayer = new TopLayer(this);
            addChild(this.mTopLayer.getBitmap());
            this.mTopLayer.getBitmap().x = this.mBackground.x;
            this.mTopLayer.getBitmap().y = this.mBackground.y;
            this.mTopLayer.createLayerBuffers(this.mBackground.width,this.mBackground.height);
         }
      }
      
      public function getTileTerrainForm(param1:int, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = param1 + 1;
         var _loc5_:int = int(this.mTileOffsets[param2]);
         var _loc6_:int = 15;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         if(this.TileIsInTheSameRow(param1,_loc3_,param2))
         {
            _loc8_ = true;
         }
         _loc3_ = param1 - 1;
         if(this.TileIsInTheSameRow(param1,_loc3_,param2))
         {
            _loc7_ = true;
         }
         _loc3_ = param1 - this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc10_ = true;
         }
         _loc3_ = param1 + this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc9_ = true;
         }
         _loc3_ = param1 - 1 - this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc11_ = true;
         }
         _loc3_ = param1 + 1 - this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc12_ = true;
         }
         _loc3_ = param1 - 1 + this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc13_ = true;
         }
         _loc3_ = param1 + 1 + this.mMapTileCols;
         if(this.TileIsInTheMap(_loc3_,param2))
         {
            _loc14_ = true;
         }
         if(_loc8_)
         {
            _loc6_ = 12;
            if(_loc7_)
            {
               _loc6_ = 10;
               if(_loc10_)
               {
                  _loc6_ = 19;
                  if(_loc9_)
                  {
                     _loc6_ = 16;
                     if(_loc11_)
                     {
                        _loc6_ = 41;
                        if(_loc12_)
                        {
                           _loc6_ = 28;
                           if(_loc14_)
                           {
                              _loc6_ = 29;
                              if(_loc13_)
                              {
                                 _loc6_ = 4;
                              }
                           }
                           else if(_loc13_)
                           {
                              _loc6_ = 32;
                           }
                        }
                        else if(_loc14_)
                        {
                           _loc6_ = 45;
                           if(_loc13_)
                           {
                              _loc6_ = 30;
                           }
                        }
                        else if(_loc13_)
                        {
                           _loc6_ = 26;
                        }
                     }
                     else if(_loc12_)
                     {
                        _loc6_ = 44;
                        if(_loc14_)
                        {
                           _loc6_ = 25;
                           if(_loc13_)
                           {
                              _loc6_ = 31;
                           }
                        }
                        else if(_loc13_)
                        {
                           _loc6_ = 46;
                        }
                     }
                     else if(_loc14_)
                     {
                        _loc6_ = 43;
                        if(_loc13_)
                        {
                           _loc6_ = 27;
                        }
                     }
                     else if(_loc13_)
                     {
                        _loc6_ = 42;
                     }
                  }
                  else if(_loc11_)
                  {
                     _loc6_ = 35;
                     if(_loc12_)
                     {
                        _loc6_ = 7;
                     }
                  }
                  else if(_loc12_)
                  {
                     _loc6_ = 39;
                  }
               }
               else if(_loc9_)
               {
                  _loc6_ = 20;
                  if(_loc13_)
                  {
                     _loc6_ = 40;
                     if(_loc14_)
                     {
                        _loc6_ = 1;
                     }
                  }
                  else if(_loc14_)
                  {
                     _loc6_ = 36;
                  }
               }
            }
            else if(_loc10_)
            {
               _loc6_ = 23;
               if(_loc9_)
               {
                  _loc6_ = 18;
                  if(_loc12_)
                  {
                     _loc6_ = 34;
                     if(_loc14_)
                     {
                        _loc6_ = 3;
                     }
                  }
                  else if(_loc14_)
                  {
                     _loc6_ = 38;
                  }
               }
               else if(_loc12_)
               {
                  _loc6_ = 6;
               }
            }
            else if(_loc9_)
            {
               _loc6_ = 21;
               if(_loc14_)
               {
                  _loc6_ = 0;
               }
            }
         }
         else if(_loc7_)
         {
            _loc6_ = 11;
            if(_loc10_)
            {
               _loc6_ = 24;
               if(_loc9_)
               {
                  _loc6_ = 17;
                  if(_loc11_)
                  {
                     _loc6_ = 33;
                     if(_loc13_)
                     {
                        _loc6_ = 5;
                     }
                  }
                  else if(_loc13_)
                  {
                     _loc6_ = 37;
                  }
               }
               else if(_loc11_)
               {
                  _loc6_ = 8;
               }
            }
            else if(_loc9_)
            {
               _loc6_ = 22;
               if(_loc13_)
               {
                  _loc6_ = 2;
               }
            }
         }
         else if(_loc10_)
         {
            _loc6_ = 14;
            if(_loc9_)
            {
               _loc6_ = 9;
            }
         }
         else if(_loc9_)
         {
            _loc6_ = 13;
         }
         return _loc6_ + _loc5_;
      }
      
      public function getTileIndexToWorldCenterPos(param1:int) : Vector2D
      {
         var _loc2_:uint = this.getTileIndexToTileX(param1);
         var _loc3_:uint = this.getTileIndexToTileY(param1);
         return new Vector2D(this.getTileXToWorld(_loc2_) + (this.tileWidth >> 1),this.getTileYToWorld(_loc3_) + (this.tileHeight >> 1));
      }
      
      public function getToolItemMouseOver() : ItemObject
      {
         var _loc1_:ItemObject = null;
         if(this.mCurrentTool != null)
         {
            _loc1_ = this.mCurrentTool.getItemMouseOver();
         }
         return _loc1_;
      }
      
      public function isTileInAreaMine(param1:int, param2:Boolean = true) : Boolean
      {
         return this.isTileInArea(param1,Plot.TYPE_FULL,param2,true);
      }
      
      public function buyTerrain(param1:MouseEvent = null) : void
      {
         var _loc3_:Company = null;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:int = this.getScreenToTileIndex(mouseX,mouseY);
         if(this.isValidTileIndex(_loc2_))
         {
            if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_TERRAIN)
            {
               if(Boolean(!this.mTilesData[_loc2_].isMyTerrain) && Boolean(this.mTilesData[_loc2_].getIsBuildable()) && this.isTileInAreaMine(_loc2_))
               {
                  _loc3_ = this.world.getCompanyMine();
                  if(_loc3_.DCCoins < DollarsGame.getProfile().getTerrainPrice())
                  {
                     DollarsGame.smInstance.mPopupConfirm.startAskForHelpFBCredits(DollarsGame.getProfile().getTerrainPrice());
                     DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
                     DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
                     DollarsGame.smInstance.mPopupConfirm.addEventListener(Popup.EVENT_CLOSE,this.onCloseConfirm);
                     this.mTerrainShape.visible = false;
                     this.mExchangeTileIndex = _loc2_;
                  }
                  else if(!Tutorial.smTutorialEnd)
                  {
                     if(Tutorial.smTutorialStep == 2)
                     {
                        _loc4_ = Tutorial.smAddTerrainTiles.indexOf(_loc2_);
                        if(_loc4_ > -1)
                        {
                           this.setTileTerrain(_loc2_);
                           dispatchEvent(new Event(Tutorial.EVENT_SET_TERRAIN));
                        }
                     }
                  }
                  else
                  {
                     this.setTileTerrain(_loc2_);
                     _loc5_ = new AssetManager.TerrainParticle();
                     _loc6_ = this.getTileXToWorld(this.getTileIndexToTileX(_loc2_)) + (this.mTileWidth >> 1);
                     _loc7_ = this.getTileYToWorld(this.getTileIndexToTileY(_loc2_)) + (this.mTileHeight >> 1);
                     ParticlesManager.addParticle(new ParticleAnimation(_loc6_,_loc7_,_loc5_),false);
                  }
               }
               if(Tutorial.smTutorialEnd)
               {
                  this.setTerrainCursor(null);
               }
            }
            else
            {
               this.clickOnTerrain(_loc2_);
            }
         }
      }
      
      public function getScreenToTileIndex(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         var _loc4_:Number = this.mView.getScreenToWorldX(param1,param2);
         var _loc5_:Number = this.mView.getScreenToWorldY(param1,param2);
         return this.getWorldToTileIndex(_loc4_,_loc5_,0,param3);
      }
      
      public function getRoadTilesData() : Array
      {
         return this.mRoadTilesData;
      }
      
      private function astarInit() : void
      {
         this.mAstar = new Astar(this);
      }
      
      public function debugGetTileInfo(param1:int) : String
      {
         return "";
      }
      
      public function getWorldYToScreen(param1:Number) : int
      {
         return Math.round(param1 * scaleY + y);
      }
      
      public function get mapTileHeight() : uint
      {
         return this.mMapTileRows;
      }
      
      public function terrainDisable() : void
      {
         this.mTerrainShape.visible = false;
         this.mTerrainShapeRed.visible = false;
      }
      
      public function astarSearch(param1:INode, param2:INode) : SearchResults
      {
         var _loc3_:Date = new Date();
         var _loc4_:SearchResults = this.mAstar.search(param1,[param2]);
         this.astarShowPath(_loc4_);
         return _loc4_;
      }
      
      private function setTileData() : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TileData = null;
         var _loc10_:int = 0;
         this.mMapTileCols = MapDefinition.getInstance().getMapTileCols();
         this.mMapTileRows = MapDefinition.getInstance().getMapTileRows();
         this.mMapTileRealRows = this.mMapTileRows;
         this.mMapWidth = this.mMapTileCols * this.mTileWidth;
         this.mMapHeight = this.mMapTileRows * this.mTileHeight;
         smWidth = this.mMapWidth;
         smHeight = this.mMapHeight;
         smWidthHalf = smWidth / 2;
         smHeightHalf = smHeight / 2;
         this.mMapTopExtraRows = 2;
         var _loc1_:int = DollarsGame.getScreenHeight() - this.mMapHeight >> 1;
         if(_loc1_ > 0)
         {
            this.mMapTopExtraRows = _loc1_ / this.mTileHeight;
            if(_loc1_ % this.mTileHeight != 0)
            {
               ++this.mMapTopExtraRows;
            }
         }
         this.mMapTopExtraRows = 0;
         this.mMapTileRows += this.mMapTopExtraRows;
         var _loc2_:int = FriendsBar.getHeight();
         this.mMapBottomExtraRows = 0;
         this.mMapHeight = this.mMapTileRows * this.mTileHeight;
         this.mMapData = new Array();
         this.mMapDataChanges = new Array();
         this.mTilesData = new Array();
         var _loc3_:Profile = DollarsGame.getProfileUniverse();
         var _loc4_:int = this.mMapTileCols * this.mMapTileRows;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = this.GRASS_TILE;
            _loc7_ = int(this.getTileIndexToTileX(_loc5_));
            _loc8_ = int(this.getTileIndexToTileY(_loc5_));
            if(_loc8_ < this.mMapTopExtraRows || _loc8_ >= this.mMapTopExtraRows + this.mMapTileRealRows)
            {
               _loc6_ = this.GRASS_FRAME_TILE;
            }
            else
            {
               _loc10_ = this.getAreaIndexFromTileIndex(_loc5_);
               if(!_loc3_.isExpansionAreaMine(_loc10_))
               {
                  _loc6_ = Background.TILE_MAX + this.GRASS_TILE;
               }
            }
            this.mMapData.push(_loc6_);
            if(_loc8_ >= this.mMapTopExtraRows + this.mMapTileRealRows)
            {
               this.mMapDataChanges.push(_loc5_);
            }
            _loc9_ = new TileData(_loc7_,_loc8_,true);
            this.mTilesData.push(_loc9_);
            this.mTilesData[_loc5_].isMyTerrain = _loc6_ >= this.FIRST_TERRAIN_TILE && _loc6_ <= this.LAST_TERRAIN_TILE;
            _loc5_++;
         }
         this.mView.setParameters(this.mTileWidth,this.mTileHeight,this.mMapTileCols,this.mMapTileRows);
         if(Config.DEBUG_MODE)
         {
            this.gridUpdate();
         }
         this.onZoom();
      }
   }
}

