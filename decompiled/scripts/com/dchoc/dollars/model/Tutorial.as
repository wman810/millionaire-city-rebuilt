package com.dchoc.dollars.model
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.Collectibles.PopupPendingCollectiblesList;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupInvestAccept;
   import com.dchoc.dollars.GUI.PopupInviteNeighbors;
   import com.dchoc.dollars.GUI.TabButton;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.hud.HudOwner;
   import com.dchoc.dollars.collectibles.CollectiblePendingManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.flow.RonaldsCity;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.metrics.BAMetrics;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.companies.CompanyMine;
   import com.dchoc.dollars.world.companies.CompanyRival;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class Tutorial
   {
      
      private static var mPopupInviteNeighbors:PopupInviteNeighbors;
      
      private static var smTutorialArrows:Array;
      
      public static var smManagersMsgShown:Boolean;
      
      private static var smRoads:Array;
      
      public static var smToolBarArrowOffsetX:int;
      
      public static var smAddRoadTiles:Array;
      
      private static var smItemBuildByTheUser:ItemObject;
      
      private static var smMap:Map;
      
      private static var smTerrainsCleared:int;
      
      public static var smTutorialStep:int;
      
      public static var smAddDecorationTile:int;
      
      public static var smRoadMsgShown:Boolean;
      
      public static var smAddTerrainTiles:Array;
      
      private static var smTerrains:Array;
      
      public static var smTutorialEnd:Boolean;
      
      public static var smToolbarArrowPosX:int;
      
      private static var mPopupInvestAccept:PopupInvestAccept;
      
      private static var smDecorationTile:Sprite;
      
      public static const TUTORIAL_STEP_WELCOME_ID:int = 0;
      
      public static const TUTORIAL_STEP_BUILD_HOUSE_ID:int = 3;
      
      public static const TUTORIAL_STEP_BUILD_ROAD:int = 4;
      
      public static const TUTORIAL_STEP_INSTANT_BUILD_ID:int = 5;
      
      public static const TUTORIAL_STEP_SIGN_CONTRACT_ID:int = 6;
      
      public static const TUTORIAL_STEP_BUILD_DECORATION:int = 7;
      
      public static const TUTORIAL_STEP_COLLECT_RENT_ID:int = 8;
      
      public static const TUTORIAL_STEP_BUY_HOUSE_ID:int = 8;
      
      public static const TUTORIAL_STEP_COUNT:int = 9;
      
      public static const EVENT_SET_TERRAIN:String = "EventSetTerrain";
      
      public static const EVENT_HOUSE_PLACE:String = "EventHousePlace";
      
      public static const TUTORIAL_BUILD_HOUSE_TIME:int = 5000;
      
      public function Tutorial()
      {
         super();
      }
      
      private static function destroyPopupInviteNeighbors(param1:Event) : void
      {
         mPopupInviteNeighbors.removeEventListener(Popup.EVENT_CLOSE,destroyPopupInviteNeighbors);
         mPopupInviteNeighbors.destroy();
         mPopupInviteNeighbors = null;
         onStep12(param1);
      }
      
      public static function showPopupInvest() : void
      {
         var _loc1_:FriendObject = FriendsManager.getFriendPlayerByID(InvestManager.getInstance().getInversorUserId());
         mPopupInvestAccept = new PopupInvestAccept(false);
         mPopupInvestAccept.showPopupParams(_loc1_);
         mPopupInvestAccept.addEventListener(Popup.EVENT_CLOSE,destroyPopupInvest);
      }
      
      private static function clearRoad(param1:Event) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc2_:int = smMap.getScreenToTileIndex(smMap.mouseX,smMap.mouseY);
         if(smTerrainsCleared == 0)
         {
            _loc4_ = smAddRoadTiles.indexOf(_loc2_);
            _loc3_ = smRoads[_loc4_] as Sprite;
         }
         else
         {
            _loc3_ = smRoads[0] as Sprite;
         }
         smMap.removeChild(_loc3_);
         smRoads.splice(smRoads.indexOf(_loc3_),1);
         ++smTerrainsCleared;
         if(smTerrainsCleared == 2)
         {
            activeOkButton();
            smMap.removeEventListener(EVENT_SET_TERRAIN,clearRoad);
            DollarsGame.getCurrentWorld().role.toolsBar.disableButton(ToolsBar.ROAD_BUTTON);
            if(smTutorialArrows != null)
            {
               _loc5_ = smTutorialArrows[0];
               smMap.removeChild(_loc5_);
               smTutorialArrows[0] = null;
               smTutorialArrows = null;
            }
         }
      }
      
      public static function addToolbarArrow(param1:Point) : void
      {
         smTutorialArrows = new Array();
         var _loc2_:MovieClip = new AssetManager.TutorialArrow();
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         DollarsGame.getCurrentWorld().role.toolsBar.getDisplayObject().addChild(_loc2_);
         smTutorialArrows.push(_loc2_);
         smToolbarArrowPosX = param1.x;
         smToolBarArrowOffsetX = 20;
         DollarsGame.getCurrentWorld().role.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
      }
      
      public static function destroy() : void
      {
         smAddTerrainTiles = null;
         smAddRoadTiles = null;
         smTerrains = null;
         smRoads = null;
      }
      
      private static function setHQTerrains(param1:Event) : void
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:ItemDefinition = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:MovieClip = null;
         var _loc2_:URLLoader = param1.target as URLLoader;
         var _loc3_:XML = new XML(_loc2_.data);
         _loc2_.removeEventListener(Event.COMPLETE,setHQTerrains);
         smTerrains = new Array();
         smTutorialArrows = new Array();
         for each(_loc4_ in _loc3_.position)
         {
            _loc7_ = int(_loc4_.@tileX);
            _loc8_ = int(_loc4_.@tileY);
            _loc7_ = int(smMap.getTileRelativeXToTile(_loc7_));
            _loc8_ = int(smMap.getTileRelativeYToTile(_loc8_));
            _loc9_ = smMap.getTileXYToTileIndex(_loc7_,_loc8_);
            smTerrains.push(_loc9_);
            _loc10_ = new AssetManager.TutorialArrow();
            _loc10_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(_loc9_)) + 2 * smMap.tileWidth;
            _loc10_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(_loc9_));
            smTutorialArrows.push(_loc10_);
            smMap.addChild(_loc10_);
         }
         smAddTerrainTiles = new Array();
         smAddRoadTiles = new Array();
         for each(_loc5_ in _loc3_.addTerrainPosition)
         {
            _loc7_ = int(_loc5_.@tileX);
            _loc8_ = int(_loc5_.@tileY);
            _loc7_ = int(smMap.getTileRelativeXToTile(_loc7_));
            _loc8_ = int(smMap.getTileRelativeYToTile(_loc8_));
            _loc9_ = smMap.getTileXYToTileIndex(_loc7_,_loc8_);
            smAddTerrainTiles.push(_loc9_);
         }
         for each(_loc5_ in _loc3_.addRoadPosition)
         {
            _loc7_ = int(_loc5_.@tileX);
            _loc8_ = int(_loc5_.@tileY);
            _loc7_ = int(smMap.getTileRelativeXToTile(_loc7_));
            _loc8_ = int(smMap.getTileRelativeYToTile(_loc8_));
            _loc9_ = smMap.getTileXYToTileIndex(_loc7_,_loc8_);
            smAddRoadTiles.push(_loc9_);
         }
         _loc7_ = int(_loc3_.addDecorationPosition[0].@tileX);
         _loc8_ = int(_loc3_.addDecorationPosition[0].@tileY);
         _loc7_ = int(smMap.getTileRelativeXToTile(_loc7_));
         _loc8_ = int(smMap.getTileRelativeYToTile(_loc8_));
         _loc9_ = smMap.getTileXYToTileIndex(_loc7_,_loc8_);
         smAddDecorationTile = _loc9_;
         _loc6_ = ItemDefinitionManager.getInstance().getDefinitionBySku(ItemDefinition.SKU_HEADQUARTERS) as ItemDefinition;
         DollarsGame.getCurrentWorld().role.toolsBar.setToolBuild(_loc6_);
         smMap.setBuildGrid();
         smMap.enable();
      }
      
      public static function showPopupInviteNeighbors() : void
      {
         mPopupInviteNeighbors = new PopupInviteNeighbors();
         mPopupInviteNeighbors.showPopup();
         mPopupInviteNeighbors.addEventListener(Popup.EVENT_CLOSE,destroyPopupInviteNeighbors);
      }
      
      public static function removeHQTerrains() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         while(_loc1_ < smTerrains.length)
         {
            smMap.removeTerrain(smTerrains[_loc1_],4,2);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < smTutorialArrows.length)
         {
            _loc2_ = smTutorialArrows[_loc1_];
            smMap.removeChild(_loc2_);
            smTutorialArrows[_loc1_] = null;
            _loc1_++;
         }
         smTutorialArrows = null;
         smMap.removeBuildGrid();
         smTerrains = null;
      }
      
      public static function removeArrowFromDecorations(param1:TabButton) : void
      {
         var _loc2_:MovieClip = param1.parent.getChildByName("arrow") as MovieClip;
         if(_loc2_ != null && param1.parent.contains(_loc2_))
         {
            param1.parent.removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      public static function addTerrains() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         if(smTerrains == null)
         {
            smTerrains = new Array(2);
            smTutorialArrows = new Array();
            _loc1_ = new AssetManager.TutorialArrow();
            _loc1_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddTerrainTiles[0])) + smMap.tileWidth / 2;
            _loc1_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddTerrainTiles[0]));
            smMap.addChild(_loc1_);
            smTutorialArrows.push(_loc1_);
            while(_loc2_ < 2)
            {
               _loc3_ = new Sprite();
               _loc3_.graphics.lineStyle(2,65280);
               _loc3_.graphics.beginFill(65280,0.25);
               _loc3_.graphics.drawRect(0,0,MapDefinition.getInstance().getTileWidth(),MapDefinition.getInstance().getTileHeight());
               _loc3_.graphics.endFill();
               _loc3_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddTerrainTiles[_loc2_]));
               _loc3_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddTerrainTiles[_loc2_]));
               smMap.addChild(_loc3_);
               smTerrains[_loc2_] = _loc3_;
               smMap.addEventListener(EVENT_SET_TERRAIN,clearTerrain);
               _loc2_++;
            }
         }
      }
      
      private static function loadLocations() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,setHQTerrains);
         _loc1_.load(new URLRequest(Config.getRoot() + Config.DIR_DATA + "rules/TutorialHQPositions.xml"));
      }
      
      private static function clearTerrain(param1:Event) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc2_:int = smMap.getScreenToTileIndex(smMap.mouseX,smMap.mouseY);
         if(smTerrainsCleared == 0)
         {
            _loc4_ = smAddTerrainTiles.indexOf(_loc2_);
            _loc3_ = smTerrains[_loc4_] as Sprite;
         }
         else
         {
            _loc3_ = smTerrains[0] as Sprite;
         }
         smMap.removeChild(_loc3_);
         smTerrains.splice(smTerrains.indexOf(_loc3_),1);
         ++smTerrainsCleared;
         if(smTerrainsCleared == 2)
         {
            activeOkButton();
            smMap.removeEventListener(EVENT_SET_TERRAIN,clearTerrain);
            DollarsGame.getCurrentWorld().role.toolsBar.disableButton(ToolsBar.BUY_TERRAIN_BUTTON);
            if(smTutorialArrows != null)
            {
               _loc5_ = smTutorialArrows[0];
               smMap.removeChild(_loc5_);
               smTutorialArrows[0] = null;
               smTutorialArrows = null;
            }
         }
      }
      
      private static function onStep12(param1:Event) : void
      {
         var _loc2_:int = InvestManager.getInstance().getInversorUserId();
         if(InvestManager.getInstance().isAnInversorValid(_loc2_))
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{"type":UserDataFacade.INVEST_TYPE_GET_INVERSION});
         }
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
            {
               if(CollectiblePendingManager.getInstance().getPendingCollectibles().length > 0)
               {
                  PopupCollectibleManager.getInstance().smPopupCollectiblePendingList = new PopupPendingCollectiblesList();
               }
            }
         }
         DollarsGame.getProfile().firstMission = true;
         DollarsGame.getProfile().firstMissionToDo();
         DollarsGame.getCurrentRole().toolsBar.addMissionArrow();
         DollarsGame.getCurrentRole().toolsBar.startBlink();
      }
      
      public static function addDecoration() : void
      {
         var _loc1_:MovieClip = null;
         smTutorialArrows = new Array();
         _loc1_ = new AssetManager.TutorialArrow();
         _loc1_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddDecorationTile)) + smMap.tileWidth / 2;
         _loc1_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddDecorationTile));
         smMap.addChild(_loc1_);
         smTutorialArrows.push(_loc1_);
         smDecorationTile = new Sprite();
         smDecorationTile.graphics.lineStyle(2,65280);
         smDecorationTile.graphics.beginFill(65280,0.25);
         smDecorationTile.graphics.drawRect(0,0,MapDefinition.getInstance().getTileWidth(),MapDefinition.getInstance().getTileHeight());
         smDecorationTile.graphics.endFill();
         smDecorationTile.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddDecorationTile));
         smDecorationTile.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddDecorationTile));
         smMap.addChild(smDecorationTile);
         smMap.addEventListener(EVENT_SET_TERRAIN,clearDecoration);
      }
      
      public static function addRoads() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         if(smRoads == null)
         {
            smRoads = new Array(2);
            smTutorialArrows = new Array();
            _loc1_ = new AssetManager.TutorialArrow();
            _loc1_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddRoadTiles[0])) + smMap.tileWidth;
            _loc1_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddRoadTiles[0]));
            smMap.addChild(_loc1_);
            smTutorialArrows.push(_loc1_);
            smTerrainsCleared = 0;
            while(_loc2_ < 2)
            {
               _loc3_ = new Sprite();
               _loc3_.graphics.lineStyle(2,65280);
               _loc3_.graphics.beginFill(65280,0.25);
               _loc3_.graphics.drawRect(0,0,MapDefinition.getInstance().getTileWidth(),MapDefinition.getInstance().getTileHeight());
               _loc3_.graphics.endFill();
               _loc3_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddRoadTiles[_loc2_]));
               _loc3_.y = smMap.getTileYToWorld(smMap.getTileIndexToTileY(smAddRoadTiles[_loc2_]));
               smMap.addChild(_loc3_);
               smRoads[_loc2_] = _loc3_;
               smMap.addEventListener(EVENT_SET_TERRAIN,clearRoad);
               _loc2_++;
            }
         }
      }
      
      public static function createBuildHouseArrow() : void
      {
         var _loc1_:MovieClip = null;
         smTutorialArrows = new Array();
         _loc1_ = new AssetManager.TutorialArrow();
         _loc1_.x = smMap.getTileXToWorld(smMap.getTileIndexToTileX(smAddTerrainTiles[0])) + 2;
         _loc1_.y = smMap.getTileXToWorld(smMap.getTileIndexToTileY(smAddTerrainTiles[0]));
         smMap.addChild(_loc1_);
         smTutorialArrows.push(_loc1_);
      }
      
      public static function addArrowToDecorations(param1:TabButton) : void
      {
         var _loc2_:MovieClip = new AssetManager.TutorialArrow();
         _loc2_.name = "arrow";
         param1.parent.addChild(_loc2_);
         _loc2_.mouseEnabled = false;
         _loc2_.x = 125;
         _loc2_.y = -160;
      }
      
      private static function onStep10(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep10);
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         _loc2_.mRain.start(_loc2_.mRainClip);
         _loc2_.mPopupTutorial.showPopUp(TextIDs.TID_POPUP_LEVEL_TITLE,TextIDs.TID_TUTORIAL_END,smTutorialStep);
         _loc2_.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep11);
         _loc2_.mPopupTutorial.changeButtonText(TextIDs.TID_BUTTON_DONE);
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_COLLECT_RENT);
         _loc2_.mRain2.start(_loc2_.mRainClip2);
      }
      
      private static function onStep11(param1:Event) : void
      {
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         _loc2_.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep11);
         showPopupInviteNeighbors();
         smTutorialEnd = true;
         DollarsGame.getProfile().tutorialCompleted();
         DollarsGame.getCurrentWorld().role.toolsBar.enableButtons();
         smMap.enable();
         MissionObjectManager.getInstance().notifyChange();
         _loc2_.mRain.stop();
         _loc2_.mRain2.stop();
         _loc2_.mRainClip.addChild(_loc2_.mRain);
         _loc2_.mRainClip2.addChild(_loc2_.mRain2);
         DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         DollarsGame.getFriendsBar().setEnabled(true);
         DollarsGame.smInstance.mFriendsBar.getBackground().mouseChildren = true;
         _loc2_.mPopupTutorial.destroy();
         _loc2_.mPopupTutorial = null;
         _loc2_.mFriendsBar.getBackground().mouseChildren = true;
         DCResourceManager.getInstance().unload(RonaldsCity.SKU);
         HudOwner(DollarsGame.getCurrentRole().hud).enableButtons();
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().stopSound(ModelConfig.SOUND_TUTORIAL);
            SoundManager.getInstance().playSound(ModelConfig.SOUND_MAIN,1,0,-1);
         }
         DollarsGame.getProfile().rankingPos = FriendsManager.getSortedNeightbors().indexOf(FriendsManager.getNeighborByID(UserDataFacade.getInstance().mUserId));
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_CONGRATS);
         if(Config.BA_ENABLED)
         {
            BAMetrics.getInstance().registerEvent("newUsers","TutorialComplete");
         }
      }
      
      public static function onStep2(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep2);
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_PLACE_HQ);
         showStep3();
      }
      
      private static function onStep4(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep4);
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_5,TextIDs.TID_TUTORIAL_5,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep5);
         DollarsGame.smInstance.mPopupTutorial.disable();
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_BUILD_HOUSE);
         var _loc2_:World = DollarsGame.getCurrentWorld();
         _loc2_.role.toolsBar.enableButton(ToolsBar.ROAD_BUTTON);
         _loc2_.registerRoad();
         addToolbarArrow(DollarsGame.getCurrentWorld().role.toolsBar.getRoadButtonPoint());
         smMap.disable();
      }
      
      private static function onStep7(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep7);
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_8,TextIDs.TID_TUTORIAL_8,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep8);
         DollarsGame.smInstance.mPopupTutorial.disable();
         DollarsGame.getCurrentWorld().role.toolsBar.enableButton(ToolsBar.BUILD_BUTTON);
         addToolbarArrow(DollarsGame.getCurrentWorld().role.toolsBar.getShopButtonPoint());
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_SIGN_CONTRACT);
      }
      
      private static function onStep3(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep3);
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_4,TextIDs.TID_TUTORIAL_4,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep4);
         DollarsGame.smInstance.mPopupTutorial.disable();
         DollarsGame.getCurrentWorld().role.toolsBar.enableButton(ToolsBar.BUILD_BUTTON);
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_BUY_PLOTS);
         addToolbarArrow(DollarsGame.getCurrentWorld().role.toolsBar.getShopButtonPoint());
         smMap.disable();
      }
      
      public static function incomeHouseArrow() : void
      {
         smMap.enable();
         smTutorialArrows = new Array();
         var _loc1_:MovieClip = new AssetManager.TutorialArrow();
         smItemBuildByTheUser.displayObjectL1.addChild(_loc1_);
         smTutorialArrows.push(_loc1_);
         _loc1_.x = smItemBuildByTheUser.worldSizeX / 2;
      }
      
      private static function onStep5(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep5);
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_6,TextIDs.TID_TUTORIAL_6,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep6);
         DollarsGame.smInstance.mPopupTutorial.disable();
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_PLACE_ROAD);
         var _loc2_:CompanyMine = DollarsGame.getCurrentWorld().getCompanyMine() as CompanyMine;
         smItemBuildByTheUser = _loc2_.getLastItem();
         smItemBuildByTheUser.setBehaviorTutorial(smTutorialStep);
         smMap.enable();
         incomeHouseArrow();
      }
      
      private static function onStep6(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep6);
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         _loc2_.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_7,TextIDs.TID_TUTORIAL_7,smTutorialStep);
         _loc2_.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep7);
         _loc2_.mPopupTutorial.disable();
         smItemBuildByTheUser.setBehaviorTutorial(smTutorialStep);
         incomeHouseArrow();
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_INSTANT_BUILD);
      }
      
      public static function activeOkButton() : void
      {
         DollarsGame.smInstance.mPopupTutorial.enable();
         DollarsGame.getCurrentWorld().role.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         DollarsGame.smInstance.mPopupTutorial.playAnim();
         smMap.disable();
      }
      
      private static function clearDecoration(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         smMap.removeChild(smDecorationTile);
         activeOkButton();
         smMap.removeEventListener(EVENT_SET_TERRAIN,clearDecoration);
         if(smTutorialArrows != null)
         {
            _loc2_ = smTutorialArrows[0];
            smMap.removeChild(_loc2_);
            smTutorialArrows[0] = null;
            smTutorialArrows = null;
         }
      }
      
      public static function onStep1(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep1);
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_COMPANY_START);
         showStep2();
      }
      
      public static function welcomeTutorial() : void
      {
         var _loc1_:String = TextManager.getText(TextIDs.TID_RONALD_NAME);
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_FEMALE)
         {
            _loc1_ = TextManager.getText(TextIDs.TID_CINDY_NAME);
         }
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_1,TextManager.replaceParameters(TextIDs.TID_TUTORIAL_1,new Array(_loc1_)),smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep1);
         smMap.disable();
         var _loc2_:CompanyRival = DollarsGame.getCurrentWorld().getCompanyRival() as CompanyRival;
         var _loc3_:ItemObject = _loc2_.getItem(0);
         _loc3_.setBehaviorTutorial(smTutorialStep);
         DollarsGame.smInstance.mFriendsBar.getBackground().mouseChildren = false;
      }
      
      public static function showStep2() : void
      {
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_2,TextIDs.TID_TUTORIAL_2,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.disable();
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep2);
         loadLocations();
      }
      
      public static function removeHouseArrow(param1:ItemObject) : void
      {
         if(smTutorialArrows != null)
         {
            param1.displayObjectL1.removeChild(smTutorialArrows[0] as MovieClip);
            smTutorialArrows[0] = null;
            smTutorialArrows = null;
         }
      }
      
      private static function destroyPopupInvest(param1:Event) : void
      {
         mPopupInvestAccept.removeEventListener(Popup.EVENT_CLOSE,destroyPopupInvest);
         mPopupInvestAccept.destroy();
         mPopupInvestAccept = null;
      }
      
      private static function onStep8(param1:Event) : void
      {
         ++smTutorialStep;
         DollarsGame.smInstance.mPopupTutorial.removeEventListener(Popup.EVENT_ACCEPT,onStep8);
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_9,TextIDs.TID_TUTORIAL_9,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep10);
         DollarsGame.smInstance.mPopupTutorial.disable();
         DollarsGame.smInstance.mPopupTutorial.changeButtonText(TextIDs.TID_BUTTON_DONE);
         smItemBuildByTheUser.setBehaviorTutorial(smTutorialStep);
         incomeHouseArrow();
         MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_BUY_DECORATION);
      }
      
      private static function showStep3() : void
      {
         DollarsGame.smInstance.mPopupTutorial.showPopUp(TextIDs.TID_TUTORIAL_TITLE_3,TextIDs.TID_TUTORIAL_3,smTutorialStep);
         DollarsGame.smInstance.mPopupTutorial.addEventListener(Popup.EVENT_ACCEPT,onStep3);
         DollarsGame.smInstance.mPopupTutorial.disable();
         DollarsGame.getCurrentWorld().role.toolsBar.enableButton(ToolsBar.BUY_TERRAIN_BUTTON);
         addToolbarArrow(DollarsGame.getCurrentWorld().role.toolsBar.getTerrainButtonPoint());
      }
      
      public static function removeToolbarArrow(param1:DisplayObjectContainer) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         if(smTutorialArrows != null)
         {
            _loc3_ = 0;
            while(_loc3_ < smTutorialArrows.length)
            {
               _loc2_ = smTutorialArrows[0];
               if(param1.contains(_loc2_))
               {
                  param1.removeChild(_loc2_);
                  smTutorialArrows[_loc3_] = null;
               }
               _loc3_++;
            }
            smTutorialArrows = null;
         }
         smToolBarArrowOffsetX = 0;
      }
      
      public static function disableButtons() : void
      {
         DollarsGame.getCurrentWorld().role.toolsBar.disableButtons();
         smMap = DollarsGame.getCurrentWorld().map;
         smMap.disable();
         DollarsGame.getFriendsBar().setEnabled(false);
      }
   }
}

