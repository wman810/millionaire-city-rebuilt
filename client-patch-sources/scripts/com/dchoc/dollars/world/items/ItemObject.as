package com.dchoc.dollars.world.items
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmDestroy;
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.server.Server;
   import com.dchoc.dollars.utils.animations.BitmapAnimation;
   import com.dchoc.dollars.utils.animations.BitmapDataFactory;
   import com.dchoc.dollars.utils.animations.ItemSprite;
   import com.dchoc.dollars.utils.animations.SpriteObject;
   import com.dchoc.dollars.utils.astar.INode;
   import com.dchoc.dollars.utils.astar.SearchResults;
   import com.dchoc.dollars.utils.crypto.EncryptionUtils;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.utils.poll.PollEvent;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.contracts.ContractDefinitionManager;
   import com.dchoc.dollars.world.items.decorations.ItemDecoration;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinition;
   import com.dchoc.dollars.world.items.gui.InfluenceIcon;
   import com.dchoc.dollars.world.items.states.StateItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.states.FSMState;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.AssetManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class ItemObject extends StateMachine
   {
      
      private static const STOP_ANIMATIONS_IN_LOW_QUALITY:Boolean = false;
      
      private static var smID:int = 0;
      
      public static const STATE_BUILDING:int = 0;
      
      public static const STATE_NORMAL:int = 1;
      
      public static const STATE_HQ_NORMAL:int = 4;
      
      public static const STATE_NORMAL_CLUB:int = 5;
      
      public static const STATE_COUNT:int = 6;
      
      private static var EFFECTS_VISIBLE_PER_STATE:Array = [false,true,true,true,true,true];
      
      public static const BASE_NOT_VISIBLE:int = -1;
      
      public static const BASE_BUILDABLE:int = 0;
      
      public static const BASE_NOT_BUILDABLE:int = 1;
      
      public static const BASE_COUNT:int = 2;
      
      private static const INFLUENCE_ALPHA:Number = 0.2;
      
      private static const TWEEN_IN_LENGHT:Number = 0.15;
      
      private static const TWEEN_OUT_LENGHT:Number = 0.05;
      
      private static const TWEEN_MIN_SCALE:Number = 0;
      
      private static const TWEEN_MIN_ALPHA:Number = 0;
      
      private static const BUILD_SHORT_FORMAT_DELIMETER:String = ":";
      
      public static const VIEW_CONNECTED_TO_ROAD_ID:int = 0;
      
      private static const VIEW_COUNT:int = 1;
      
      public static const GLOW_LOOP_COLOR:uint = 542463249;
      
      public static const GLOW_COLOR:uint = 16777011;
      
      public static const INFLUENCE_COLOR:uint = 65520;
      
      private static const GLOW_LOOP_TWEEN_LENGTH:Number = 0.75;
      
      public static const ICON_RENT:int = 0;
      
      public static const ICON_RENT_COLLECT:int = 1;
      
      public static const ICON_CONTRACT:int = 2;
      
      public static const ICON_CONTRACT_COLLECT:int = 3;
      
      private var mIsOutlined:Boolean = false;
      
      private var mBarPosX:Number;
      
      private var mBarPosY:Number;
      
      private var mLoading:MovieClip;
      
      private var mViewColorTransformBack:ColorTransform;
      
      private var mInitialized:Boolean;
      
      private var mContractSku:String;
      
      private var mDisplayObjectInfluenceIcon:InfluenceIcon;
      
      public var mID:int;
      
      private var mTweenColorLoop:GTween;
      
      private var mDecorationsDictionary:Dictionary;
      
      private var mDisplayObjectInfluenceArea:Shape;
      
      private var mIsConnected:Boolean;
      
      private var mDef:ItemDefinition;
      
      private var mResourcesLoaded:Boolean;
      
      private var mStateId:int;
      
      private var mRoadTiles:Array;
      
      private var mTileRelativeX:int;
      
      private var mTileRelativeY:int;
      
      private var mIcon:MovieClip;
      
      private var mContract:ContractDefinition;
      
      private var mInfluenceItemsAffectedByInfluence:Array;
      
      private var mDisplayObjectNotConnectedToHQ:Sprite;
      
      private var mSearchToHQ:SearchResults;
      
      private var mStateBeforeDemolition:StateItemObject;
      
      private var mBuildingResources:Boolean;
      
      private var mBase:Shape;
      
      private var mLoader:DCResourceManager;
      
      private const MAGIC_PRIME_ENCRYPTION_NUMBER:Number = Dollars.getMagicEncryptionNumber();
      
      private var mUseAsGift:Boolean;
      
      private var mCrewIcon:MovieClip;
      
      private var mColorTransform:ColorTransform;
      
      private var mMoving:Boolean;
      
      public var mSid:String = "";
      
      private var mDecorations:Array;
      
      private var mAbTestGroup:int;
      
      private var mVisible:Boolean;
      
      private var mInfluenceValue:int;
      
      private var mCompany:Company;
      
      private var mEffectsDOs:Array;
      
      private var mExtraCmdToServer:Object;
      
      private var mViewDOs:Array;
      
      private var mPeopleLayer:MovieClip;
      
      private var mCrew:Array;
      
      private var mSku:String;
      
      private var mMouseOverTimer:int;
      
      private var mDisplayObjectL0:ItemSprite;
      
      private var mDisplayObjectL1:ItemSprite;
      
      private var mInfluenceItemsAffectedByCommerce:Array;
      
      private var mInfluenceItems:Array;
      
      private var mMap:Map;
      
      private var mSimulate:Boolean = false;
      
      private var mDecorationsPersistence:Array;
      
      private var mNoNeedPlot:Boolean;
      
      private var mWorldX:Number;
      
      private var mWorldY:Number;
      
      private var mWorldZ:Number;
      
      private var mStatePersistence:XML;
      
      public var mDistanceFromMapCenter:int;
      
      private var mDisplayObjectMc:SpriteObject;
      
      private var mPersistence:XML;
      
      private var mTween:GTween;
      
      public function ItemObject(param1:Company = null)
      {
         super(null);
         this.mLoader = DCResourceManager.getInstance();
         this.mResourcesLoaded = false;
         this.mBuildingResources = false;
         this.mCompany = param1;
         if(this.mCompany != null && this.mCompany.world != null)
         {
            this.mMap = this.mCompany.world.map;
         }
         this.mStatePersistence = null;
         this.mDisplayObjectL0 = new ItemSprite();
         this.mDisplayObjectL1 = new ItemSprite();
         this.mID = smID;
         ++smID;
         this.influenceLoad();
         this.mRoadTiles = new Array();
         this.mSearchToHQ = null;
         this.decorationsLoad();
         this.mVisible = true;
         this.mInitialized = false;
         this.mMoving = false;
         this.setInfluenceValue(0);
         this.mColorTransform = this.mDisplayObjectL0.transform.colorTransform;
      }
      
      public function unregisterRoadNeighbour() : void
      {
         this.roadLoopNeighbours(this.unregisterRoad);
      }
      
      public function set tileRelativeX(param1:int) : void
      {
         this.mTileRelativeX = param1;
      }
      
      public function get worldSizeX() : Number
      {
         return this.mDef.baseWidth * this.mMap.scaleX;
      }
      
      public function get worldSizeY() : Number
      {
         return this.mDef.baseHeight * this.mMap.scaleY;
      }
      
      public function get worldSizeZ() : Number
      {
         return 0;
      }
      
      public function changeAnimFrame(param1:int, param2:Boolean = false, param3:Function = null) : void
      {
         var _loc4_:MovieClip = null;
         if(this.mDisplayObjectMc != null)
         {
            _loc4_ = this.mDisplayObjectMc.getCurrentAnim() as MovieClip;
            if(param2)
            {
               _loc4_.gotoAndPlay(param1);
               if(param3 != null)
               {
                  _loc4_.addEventListener(Event.ENTER_FRAME,param3);
               }
            }
            else
            {
               _loc4_.gotoAndStop(param1);
               if(param3 != null)
               {
                  _loc4_.removeEventListener(Event.ENTER_FRAME,param3);
               }
            }
         }
      }
      
      public function get tileRelativeX() : int
      {
         return this.mTileRelativeX;
      }
      
      public function getIncomeValue(param1:Boolean = false, param2:ItemObject = null) : uint
      {
         var _loc6_:ItemObject = null;
         var _loc7_:int = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         if(this.mDef.hasCommerceBehaviour())
         {
            if(param1)
            {
               this.influenceGetItemsAffectedByCommerce();
               for each(_loc6_ in this.mInfluenceItemsAffectedByCommerce)
               {
                  _loc4_ += _loc6_.getPopulation();
               }
            }
            else if(param2 != null)
            {
               _loc4_ = uint(param2.getPopulation());
            }
            _loc3_ = this.getIncomeCoins() * _loc4_;
         }
         else
         {
            _loc3_ = uint(this.getIncomeCoins());
         }
         var _loc5_:StateItemObject = this.getCurrentState();
         if(_loc5_ != null && _loc5_.upgradeGetEnabled())
         {
            _loc7_ = UpgradesManager.getInstance().getExtraPercentage(this.mSid);
            _loc3_ += _loc7_ * _loc3_ / 100;
         }
         _loc3_ += _loc3_ * this.influenceValue / 100;
         if(this.mDef.getIncomeLevelFactor() > 0 && _loc3_ > 0)
         {
            _loc3_ += this.mDef.getIncomeLevelFactor() * _loc4_;
         }
         return _loc3_;
      }
      
      public function decorationsGetPersistence() : XML
      {
         var _loc2_:ItemDecoration = null;
         var _loc1_:XML = null;
         if(this.mDecorations != null && this.mDecorations.length > 0)
         {
            _loc1_ = <Decorations/>;
            for each(_loc2_ in this.mDecorations)
            {
               _loc1_.appendChild(_loc2_.getPersistence());
            }
         }
         return _loc1_;
      }
      
      public function searchHQContainsNode(param1:INode) : Boolean
      {
         return this.mSearchToHQ.getPath().containsNode(param1);
      }
      
      public function disableContract(param1:Boolean = true) : void
      {
         var _loc2_:Profile = null;
         var _loc3_:int = 0;
         if(this.mContract != null)
         {
            _loc2_ = DollarsGame.getProfile();
            _loc3_ = this.mContract.getCostCoins();
            if(!param1)
            {
               _loc3_ += 1;
            }
            _loc2_.companyValue -= _loc3_;
            this.mContract = null;
            if(!param1)
            {
               _loc2_.companyValue += 1;
            }
            this.peopleLayerSetVisible(false);
         }
         this.mContractSku = null;
      }
      
      private function isInExpansionMine() : Boolean
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc1_:Boolean = true;
         var _loc2_:uint = this.mMap.getWorldToTileX(this.worldX);
         var _loc3_:uint = this.mMap.getWorldToTileY(this.worldY);
         var _loc4_:int = this.mDef.baseCols + _loc2_;
         var _loc5_:int = this.mDef.baseRows + _loc3_;
         var _loc6_:int = int(_loc2_);
         while(_loc1_ && _loc6_ < _loc4_)
         {
            _loc7_ = int(_loc3_);
            while(_loc1_ && _loc7_ < _loc5_)
            {
               _loc8_ = this.mMap.getTileXYToTileIndex(_loc6_,_loc7_);
               _loc1_ = this.mMap.isTileInAreaMine(_loc8_);
               _loc7_++;
            }
            _loc6_++;
         }
         return _loc1_;
      }
      
      public function get incomeTime() : uint
      {
         var _loc1_:int = this.mDef.getIncomeTime();
         if(this.mContract != null)
         {
            _loc1_ = this.mContract.getIncomeTime();
         }
         return _loc1_;
      }
      
      public function set tileRelativeY(param1:int) : void
      {
         this.mTileRelativeY = param1;
      }
      
      public function attachInfluence() : void
      {
         this.influenceLoopNeighbours(this.attachInfluenceTile);
      }
      
      private function influenceLoopNeighbours(param1:Function) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:TileData = null;
         if(this.mMap != null)
         {
            _loc2_ = this.mMap.getWorldToTileX(this.worldX);
            _loc3_ = this.mMap.getWorldToTileY(this.worldY);
            _loc4_ = uint(this.mDef.getInfluenceRatio());
            _loc5_ = this.mDef.baseCols + _loc4_;
            _loc6_ = this.mDef.baseRows + _loc4_;
            _loc7_ = -_loc4_;
            while(_loc7_ < _loc5_)
            {
               _loc8_ = -_loc4_;
               while(_loc8_ < _loc6_)
               {
                  _loc9_ = this.mMap.getTileXYToTileIndex(_loc2_ + _loc7_,_loc3_ + _loc8_);
                  _loc10_ = this.mMap.getTileDataFromIndex(_loc9_);
                  if(_loc10_ != null)
                  {
                     param1(_loc10_);
                  }
                  _loc8_++;
               }
               _loc7_++;
            }
         }
      }
      
      public function influenceResetCommercesAffectedByItem() : void
      {
         var _loc1_:ItemObject = null;
         for each(_loc1_ in this.mInfluenceItems)
         {
            _loc1_.influenceResetItemsAffectedByCommerce(true);
         }
      }
      
      public function endColorBase() : void
      {
         if(this.mBase != null && this.mDisplayObjectL0.contains(this.mBase))
         {
            this.mDisplayObjectL0.removeChild(this.mBase);
            this.mBase = null;
         }
      }
      
      public function set sku(param1:String) : void
      {
         this.mSku = param1;
      }
      
      public function get roadTiles() : Array
      {
         return this.mRoadTiles;
      }
      
      public function unregisterItemInfluence(param1:ItemObject) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1 != this)
         {
            _loc2_ = true;
            if(this.mDef.hasCommerceBehaviour())
            {
               _loc2_ = param1.mDef.isAffectedByInfluence();
            }
            if(_loc2_)
            {
               _loc3_ = this.mInfluenceItems.indexOf(param1);
               if(_loc3_ > -1)
               {
                  this.mInfluenceItems.splice(_loc3_,1);
                  if(this.mDef.isAffectedByType(param1.mDef.type))
                  {
                     _loc4_ = param1.itemDefinition.getInfluenceValue();
                     _loc4_ = _loc4_ + this.mCompany.attributesGetValue(Company.ATTRIBUTES_KEY_INFLUENCE,param1.itemDefinition);
                     if(_loc4_ != 0)
                     {
                        this.setInfluenceValue(this.getOwnInfluenceValue() - _loc4_);
                        this.influenceIconDraw();
                        this.checkInfluenceEvent();
                     }
                  }
               }
               if(this.mCompany.isCommerceEventsEnabled() && this.mDef.hasCommerceBehaviour() && this.mInfluenceItemsAffectedByCommerce != null && this.mInfluenceItemsAffectedByCommerce.length > 0)
               {
                  _loc3_ = this.mInfluenceItemsAffectedByCommerce.indexOf(param1);
                  if(_loc3_ > -1)
                  {
                     this.mInfluenceItemsAffectedByCommerce.splice(_loc3_,1);
                     if(this.mInfluenceItemsAffectedByCommerce.length == 0)
                     {
                        this.getCurrentState().resetMode();
                     }
                  }
               }
            }
         }
      }
      
      public function getUseAsGift() : Boolean
      {
         return this.mUseAsGift;
      }
      
      public function isClickPriority() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:StateItemObject = this.getCurrentState();
         if(_loc2_ != null && _loc2_.isClickPriority())
         {
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      public function setBase(param1:int, param2:Array = null) : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2 != null)
         {
            _loc4_ = this.mDef.isHeadQuarters() ? this.mDisplayObjectL1 : this.mDisplayObjectL0;
            _loc4_.filters = param2;
         }
         if(this.mBase != null && _loc4_.contains(this.mBase))
         {
            _loc4_.removeChild(this.mBase);
            this.mBase = null;
         }
         var _loc3_:uint = param1 == BASE_BUILDABLE ? 65280 : 16711680;
         if(param1 != BASE_NOT_VISIBLE)
         {
            this.mBase = new Shape();
            this.mBase.graphics.lineStyle(2,_loc3_);
            this.mBase.graphics.beginFill(_loc3_,0.3);
            this.mBase.graphics.drawRect(0,0,this.mDef.baseWidth,this.mDef.baseHeight);
            this.mBase.graphics.endFill();
            _loc5_ = this.mDef.baseWidth / this.mDef.baseCols;
            _loc6_ = this.mDef.baseHeight / this.mDef.baseRows;
            this.mBase.graphics.lineStyle(1,_loc3_);
            _loc7_ = 0;
            while(_loc7_ < this.mDef.baseCols - 1)
            {
               this.mBase.graphics.moveTo((_loc7_ + 1) * _loc5_,0);
               this.mBase.graphics.lineTo((_loc7_ + 1) * _loc5_,this.mDef.baseHeight);
               _loc7_++;
            }
            _loc7_ = 0;
            while(_loc7_ < this.mDef.baseRows - 1)
            {
               this.mBase.graphics.moveTo(0,(_loc7_ + 1) * _loc6_);
               this.mBase.graphics.lineTo(this.mDef.baseWidth,(_loc7_ + 1) * _loc6_);
               _loc7_++;
            }
            _loc4_.addChild(this.mBase);
         }
      }
      
      public function decorationsSetItemDefinition(param1:ItemDefinition) : void
      {
         var _loc4_:ItemDecoration = null;
         var _loc5_:ItemDecoration = null;
         var _loc6_:XML = null;
         if(this.mDecorations != null)
         {
            for each(_loc4_ in this.mDecorations)
            {
               _loc4_.destroy();
            }
            this.mDecorations.length = 0;
         }
         var _loc2_:Array = param1.decorations;
         var _loc3_:int = 0;
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = _loc4_.clone();
            this.decorationsAddDecoration(_loc5_);
            _loc6_ = this.mDecorationsPersistence[_loc3_];
            _loc5_.setPersistence(_loc6_);
            if(this.mDecorationsPersistence[_loc3_] != null)
            {
               this.mDecorationsPersistence[_loc3_] = null;
            }
            _loc3_++;
         }
      }
      
      public function getCrewHired() : Array
      {
         return this.mCrew[ItemDefinition.CREW_INVITED];
      }
      
      public function needsToBeTrackedForRent() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.getCurrentState() != null)
         {
            _loc1_ = this.getCurrentState().needsToBeTrackedForRent();
         }
         return _loc1_;
      }
      
      public function attachRole(param1:Role) : void
      {
         var _loc2_:StateItemObject = this.getCurrentState();
         if(_loc2_ != null && this.mCompany.world.role != null)
         {
            this.mStatePersistence = _loc2_.getPersistence();
         }
         var _loc3_:Boolean = _loc2_ == null;
         var _loc4_:StateItemObject = param1.getStateItemObject(this);
         if(this.mStatePersistence != null)
         {
            _loc4_.setPersistence(this.mStatePersistence);
            _loc3_ = false;
         }
         this.changeState(_loc4_,_loc3_);
      }
      
      public function getIncomeTimeLeft() : int
      {
         var _loc1_:int = 0;
         if(this.getCurrentState() != null)
         {
            _loc1_ = this.getCurrentState().getIncomeTimeLeft();
         }
         return _loc1_;
      }
      
      public function getSellPrice(param1:Boolean = true) : uint
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:int = 0;
         var _loc2_:uint = this.mMap.getWorldToTileX(this.worldX);
         var _loc3_:uint = this.mMap.getWorldToTileY(this.worldY);
         var _loc4_:Number = 0;
         if(param1)
         {
            _loc7_ = 0;
            while(_loc7_ < this.mDef.baseCols)
            {
               _loc8_ = 0;
               while(_loc8_ < this.mDef.baseRows)
               {
                  _loc9_ = this.mMap.getTileXYToTileIndex(_loc2_ + _loc7_,_loc3_ + _loc8_);
                  _loc4_ += this.mMap.getTilePrice(_loc9_);
                  _loc8_++;
               }
               _loc7_++;
            }
         }
         var _loc5_:uint;
         var _loc6_:int = int(_loc5_ = uint(_loc4_ + this.value));
         return RulesFacade.getInstance().settingsGetSellPrice(_loc6_);
      }
      
      public function getItemType() : uint
      {
         return this.mDef.type;
      }
      
      public function endLoopGlow() : void
      {
         if(this.mTweenColorLoop != null)
         {
            this.mTweenColorLoop.repeatCount = 1;
            this.mTweenColorLoop.end();
            this.mTweenColorLoop = null;
         }
         this.endGlow();
      }
      
      public function influenceGetItemsAffectedByCommerce() : Array
      {
         var _loc1_:ItemObject = null;
         if(this.mInfluenceItemsAffectedByCommerce == null)
         {
            this.mInfluenceItemsAffectedByCommerce = new Array();
         }
         else
         {
            this.influenceResetItemsAffectedByCommerce();
         }
         if(this.mDef.hasCommerceBehaviour())
         {
            for each(_loc1_ in this.mInfluenceItems)
            {
               if(_loc1_.isAffectedByType(this.mCompany,this.mDef.type))
               {
                  this.mInfluenceItemsAffectedByCommerce.push(_loc1_);
               }
            }
         }
         return this.mInfluenceItemsAffectedByCommerce;
      }
      
      public function get incomeXP() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:int = this.getIncomeXP();
         var _loc2_:StateItemObject = this.getCurrentState();
         if(_loc2_ != null && _loc2_.upgradeGetEnabled())
         {
            _loc3_ = UpgradesManager.getInstance().getExtraPercentage(this.mSid);
            _loc1_ += _loc3_ * _loc1_ / 100;
         }
         return _loc1_;
      }
      
      public function getPersistenceShortFormat(param1:Boolean = false) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = this.mSid + BUILD_SHORT_FORMAT_DELIMETER;
         var _loc3_:int = this.mSku.indexOf("_");
         if(Config.DEBUG_ASSERTS && _loc3_ == -1)
         {
            _loc2_ = "";
            Debug.trace("############# ERROR in ItemObject.getPersistenceShortFormat(): wrong sku " + this.mSku + " for item with sid " + this.mSid + ".");
         }
         else
         {
            _loc4_ = this.mSku.substring(_loc3_ + 1);
            this.mTileRelativeX = this.mMap.getTileToTileRelativeX(this.mMap.getWorldToTileX(this.mWorldX));
            this.mTileRelativeY = this.mMap.getTileToTileRelativeY(this.mMap.getWorldToTileY(this.mWorldY));
            _loc2_ += _loc4_ + BUILD_SHORT_FORMAT_DELIMETER + this.mTileRelativeX + BUILD_SHORT_FORMAT_DELIMETER + this.mTileRelativeY;
         }
         return _loc2_;
      }
      
      private function toString() : String
      {
         var _loc1_:String = "";
         _loc1_ += " mID = " + this.mID;
         return _loc1_ + (" InfluenceValue = " + this.influenceValue);
      }
      
      public function build() : void
      {
         this.setWorldPosition(this.mMap.getTileRelativeXToWorld(this.mTileRelativeX),this.mMap.getTileRelativeYToWorld(this.mTileRelativeY),0);
         this.init();
      }
      
      public function searchHQConnection(param1:Boolean = false) : void
      {
         var _loc2_:Boolean = this.isHQConnected();
         this.mSearchToHQ = this.mMap.astarSearchItem(this);
         this.applyHQConnection();
         if(param1 && !_loc2_ && this.isHQConnected() && this.company.isRival())
         {
            PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_BUILD_ROAD);
         }
      }
      
      public function registerRoad(param1:TileData) : void
      {
         this.mRoadTiles.push(param1);
      }
      
      public function isOnScreen() : Boolean
      {
         return true;
      }
      
      public function setPersistenceShortFormat(param1:String) : Boolean
      {
         var _loc2_:Array = param1.split(BUILD_SHORT_FORMAT_DELIMETER);
         var _loc3_:String = "decorations_" + _loc2_[1];
         var _loc4_:XML = <Item sid={_loc2_[0]} sku={_loc3_} x={_loc2_[2]} y={_loc2_[3]}/>;
         var _loc5_:XML = <State id="5"/>;
         _loc4_.appendChild(_loc5_);
         return this.setPersistence(_loc4_);
      }
      
      public function unattachInfluence() : void
      {
         this.influenceLoopNeighbours(this.unattachInfluenceTile);
      }
      
      private function viewGetParent(param1:int) : DisplayObjectContainer
      {
         var _loc2_:DisplayObjectContainer = this.displayObjectL0;
         if(param1 == VIEW_CONNECTED_TO_ROAD_ID)
         {
            _loc2_ = this.displayObjectL1;
         }
         return _loc2_;
      }
      
      public function get company() : Company
      {
         return this.mCompany;
      }
      
      public function setBehaviorTutorial(param1:int = -1) : void
      {
         this.getCurrentState().setBehaviorTutorial(param1);
      }
      
      public function debugTraceInfo() : void
      {
         trace(this.toString());
      }
      
      private function setInfluenceValue(param1:int) : void
      {
         this.mInfluenceValue = param1;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            this.mInfluenceValue = EncryptionUtils.encrypt(0,this.mInfluenceValue,Number(this.sid),this.MAGIC_PRIME_ENCRYPTION_NUMBER);
         }
      }
      
      public function get eventOnTime() : uint
      {
         return this.itemDefinition.getEventOnTime();
      }
      
      public function getAnim(param1:int) : MovieClip
      {
         if(this.mDisplayObjectMc != null)
         {
            return this.mDisplayObjectMc.getCurrentAnim() as MovieClip;
         }
         return null;
      }
      
      public function getContract(param1:Boolean = true) : ContractDefinition
      {
         var _loc2_:ContractDefinition = this.mContract;
         if(_loc2_ == null)
         {
            _loc2_ = ContractDefinitionManager.getInstance().getDefinitionBySku(this.mContractSku) as ContractDefinition;
         }
         return _loc2_;
      }
      
      private function effectsSetVisible(param1:Boolean, param2:Boolean = true) : void
      {
         var _loc3_:MovieClip = null;
         if(this.mEffectsDOs != null)
         {
            for each(_loc3_ in this.mEffectsDOs)
            {
               _loc3_.visible = param1;
               if(param1 && param2)
               {
                  Dollars.playChilds(_loc3_);
               }
               else
               {
                  Dollars.stopChild(_loc3_);
               }
            }
         }
         this.peopleLayerSetVisible(param1);
      }
      
      public function viewSetColorAreaMine() : void
      {
         this.mDisplayObjectL0.transform.colorTransform = this.mViewColorTransformBack;
      }
      
      public function undoMouseOver(param1:Boolean = false) : void
      {
         this.mMouseOverTimer = -1;
         if(!param1)
         {
            param1 = this.isOutlineInMouseOverEnabled();
         }
         if(param1)
         {
            if(DollarsGame.getItemOutlineEnabled())
            {
               this.setDisplayObjectOutlineVisible(false,0);
            }
            else
            {
               DollarsGame.setItemOutlinePending(this);
            }
         }
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.undoMouseOver();
         }
         if(this.hasInfluenceArea())
         {
            this.setInfluenceAreaVisibility(false);
         }
         this.getCurrentState().undoMouseOver();
      }
      
      public function isHQConnected() : Boolean
      {
         var _loc1_:Boolean = true;
         if(DollarsGame.getCurrentRole().needsToCheckHQConnection())
         {
            _loc1_ = this.mSearchToHQ != null && this.mSearchToHQ.getIsSuccess();
         }
         return _loc1_;
      }
      
      public function hasResourcesLoaded() : Boolean
      {
         return this.mResourcesLoaded;
      }
      
      private function isUIAllowed() : Boolean
      {
         var _loc1_:Boolean = true;
         if(DollarsGame.getCurrentRole().checksExpansionIsMine())
         {
            _loc1_ = this.isInExpansionMine();
         }
         return _loc1_;
      }
      
      public function getIncomeCoins() : int
      {
         var _loc1_:int = this.mDef.getIncomeValue();
         if(this.mContract != null)
         {
            _loc1_ += this.mContract.getIncomeCoins();
         }
         return _loc1_;
      }
      
      private function setInfluenceAreaAffectedVisibility(param1:Boolean, param2:ItemDefinition, param3:Boolean = false) : void
      {
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.setInfluenceAreaAffectedVisibility(param1,param2,param3);
         }
         if(this.mDisplayObjectInfluenceArea != null)
         {
            this.mDisplayObjectInfluenceArea.visible = param1;
         }
         else
         {
            this.setDisplayObjectOutlineVisible(param1,ItemObject.INFLUENCE_COLOR);
         }
      }
      
      public function setUseAsGift(param1:Boolean) : void
      {
         this.mUseAsGift = param1;
      }
      
      public function toggleAnimation(param1:Boolean) : void
      {
         if(param1)
         {
            Dollars.stopChild(this.mDisplayObjectL0);
            this.effectsSetVisible(EFFECTS_VISIBLE_PER_STATE[this.stateId],false);
            if(this.mIcon != null)
            {
               this.mIcon.stop();
            }
         }
         else
         {
            if(this.mDef.isAnimated)
            {
               Dollars.playChilds(this.mDisplayObjectL0);
            }
            if(this.mLoading != null)
            {
               this.mLoading.play();
            }
            this.effectsSetVisible(EFFECTS_VISIBLE_PER_STATE[this.stateId]);
            if(this.mIcon != null)
            {
               this.mIcon.play();
            }
         }
         if(this.getCurrentState() != null)
         {
            if(Dollars.smStage.quality.toUpperCase() == StageQuality.HIGH.toUpperCase())
            {
               this.getCurrentState().changeAnimationQuality(!param1);
            }
         }
      }
      
      public function decorationsSetDecorations(param1:ItemObject) : void
      {
         var _loc3_:ItemDecoration = null;
         var _loc4_:ItemDecoration = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.mDecorations.length)
         {
            _loc3_ = param1.mDecorations[_loc2_] as ItemDecoration;
            _loc4_ = this.mDecorations[_loc2_] as ItemDecoration;
            _loc4_.cloneValues(_loc3_,false,true);
            _loc2_++;
         }
      }
      
      public function hasInfluenceArea() : Boolean
      {
         return Boolean(this.mInfluenceItemsAffectedByInfluence) && this.mDef.getInfluenceRatio() > 0;
      }
      
      public function changeAnimationQuality(param1:Boolean) : void
      {
         this.getCurrentState().changeAnimationQuality(param1);
         if(STOP_ANIMATIONS_IN_LOW_QUALITY)
         {
            this.toggleAnimation(!param1);
         }
      }
      
      public function viewSetColorAreaNotMine() : void
      {
         this.mViewColorTransformBack = this.mDisplayObjectL0.transform.colorTransform;
         this.mDisplayObjectL0.transform.colorTransform = FiltersManager.setInk(this.mViewColorTransformBack,0,0.3);
      }
      
      public function getConstructionTime() : Number
      {
         var _loc1_:Number = NaN;
         if(this.mCompany.isMine())
         {
            _loc1_ = this.mDef.getConstructionTime();
         }
         else
         {
            _loc1_ = 60 * 1000;
         }
         return _loc1_;
      }
      
      public function getConstructionCrewSku() : String
      {
         return this.mDef.constructionCrewSku;
      }
      
      public function setScaleIcon(param1:Number, param2:Number) : void
      {
         if(this.mIcon != null)
         {
            this.mIcon.scaleX = param1;
            this.mIcon.scaleY = param2;
         }
      }
      
      override public function changeState(param1:FSMState, param2:Boolean = true) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:XML = null;
         var _loc9_:int = 0;
         var _loc10_:XML = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:int = -1;
         var _loc4_:StateItemObject = this.getCurrentState();
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.getID();
         }
         UserDataFacade.smSecurityIgnore = true;
         super.changeState(param1,param2);
         UserDataFacade.smSecurityIgnore = false;
         if(this.mDef.needsHQConnection() && !this.isHQConnected() && this.mCompany.isMine())
         {
            suspend();
         }
         if(param2)
         {
            mCurrentState.doEnterFirstTime();
         }
         var _loc5_:XML = this.getPersistence(true);
         if(_loc3_ == -1)
         {
            _loc6_ = null;
            _loc7_ = {
               "item":Server.XMLToObject(_loc5_),
               "dec":this.mDef.getFormatId()
            };
            if(this.mDef.offerDef != null && !this.mUseAsGift)
            {
               _loc7_ = {
                  "item":Server.XMLToObject(_loc5_),
                  "dec":this.mDef.getFormatId(),
                  "offer":this.mDef.offerDef.sku
               };
            }
            if(this.mExtraCmdToServer != null)
            {
               _loc7_[this.mExtraCmdToServer.key] = this.mExtraCmdToServer.value;
               this.mExtraCmdToServer = null;
            }
            UserDataFacade.getInstance().updateItem(this.mSid,"new_item",_loc7_,_loc5_,_loc6_);
            if(Config.DEBUG_SERVER)
            {
               _loc8_ = XMLUtil.XMLListToXML(_loc5_.State);
               _loc9_ = this.getCurrentState().getID();
               Debug.trace("item (" + this.mSid + ":" + this.mSku + ") NEW ITEM CREATED, state: " + StateItemObject.getStateName(_loc9_));
            }
         }
         else
         {
            _loc10_ = XMLUtil.XMLListToXML(_loc5_.State);
            _loc11_ = this.getCurrentState().getID();
            if(_loc11_ != StateItemObject.STATE_ON_DEMOLITION_ID)
            {
               _loc12_ = int(_loc10_.@mode);
               _loc13_ = int(_loc10_.@time);
               UserDataFacade.getInstance().updateItem(this.mSid,"new_state",{
                  "state":_loc11_,
                  "mode":_loc12_,
                  "time":_loc13_
               },_loc5_);
               if(Config.DEBUG_SERVER)
               {
                  Debug.trace("item (" + this.mSid + ":" + this.mSku + ") changeState from " + StateItemObject.getStateName(_loc3_) + " to " + StateItemObject.getStateName(_loc11_));
               }
            }
         }
      }
      
      public function hasCurrentAnimFinished() : Boolean
      {
         if(this.mDisplayObjectMc != null)
         {
            return this.mDisplayObjectMc.hasCurrentAnimFinished();
         }
         return false;
      }
      
      private function effectsDestroy() : void
      {
         var _loc1_:MovieClip = null;
         if(this.mEffectsDOs != null)
         {
            for each(_loc1_ in this.mEffectsDOs)
            {
               if(this.mDisplayObjectL0.contains(_loc1_))
               {
                  this.mDisplayObjectL0.removeChild(_loc1_);
               }
               if(this.mDisplayObjectL1.contains(_loc1_))
               {
                  this.mDisplayObjectL1.removeChild(_loc1_);
               }
            }
            this.mEffectsDOs = null;
         }
         if(this.mPeopleLayer != null)
         {
            if(this.mDisplayObjectL0.contains(this.mPeopleLayer))
            {
               this.mDisplayObjectL0.removeChild(this.mPeopleLayer);
            }
            this.mPeopleLayer = null;
         }
      }
      
      public function get itemDefinition() : ItemDefinition
      {
         return this.mDef;
      }
      
      public function isDestroyable() : Boolean
      {
         var _loc1_:Boolean = this.isUIAllowed();
         if(_loc1_)
         {
            _loc1_ = this.getCurrentState().isDestroyable();
         }
         return _loc1_;
      }
      
      public function startColorBase(param1:uint) : void
      {
         if(this.mBase == null)
         {
            this.mBase = new Shape();
            this.mBase.graphics.beginFill(param1,0.3);
            this.mBase.graphics.lineStyle(2,param1);
            this.mBase.graphics.drawRect(-2,-2,this.mDef.baseWidth + 4,this.mDef.baseHeight + 4);
            this.mBase.graphics.endFill();
            this.mDisplayObjectL0.addChildAt(this.mBase,0);
         }
      }
      
      public function applyUpgrade() : void
      {
         var _loc1_:StateItemObject = this.getCurrentState();
         if(_loc1_ != null && _loc1_.upgradeGetEnabled())
         {
            _loc1_.upgradeDestroy();
            _loc1_.upgradeLoad();
            _loc1_.upgradeSetEnabled(true);
         }
      }
      
      private function decorationsDestroy() : void
      {
         var _loc1_:ItemDecoration = null;
         for each(_loc1_ in this.mDecorations)
         {
            _loc1_.destroy();
         }
         this.mDecorations = null;
         this.mDecorationsDictionary = null;
         this.mDecorationsPersistence = null;
      }
      
      public function accelerateIncomeTime(param1:int) : void
      {
         var _loc2_:StateItemObject = this.getCurrentState();
         if(_loc2_ != null && _loc2_ is StateOnRent)
         {
            (_loc2_ as StateOnRent).accelerateIncomeTime(param1);
         }
      }
      
      public function get sid() : String
      {
         return this.mSid;
      }
      
      public function buildUpdate(param1:int) : Boolean
      {
         if(!this.mResourcesLoaded && (this.mDef.isResourceLoaded() || this.isHeadQuarters()))
         {
            this.mBuildingResources = true;
            this.buildResources();
            if(this.mStateId == STATE_BUILDING || this.mStateId == StateItemObject.STATE_ON_HIRE_CREW)
            {
               this.changeAnim(STATE_BUILDING);
            }
            else
            {
               this.changeAnim(STATE_NORMAL);
            }
            if(mCurrentState != null)
            {
               mCurrentState.resume();
            }
            this.mBuildingResources = false;
         }
         return this.mResourcesLoaded;
      }
      
      public function startLoopGlow(param1:uint) : void
      {
         if(this.mTweenColorLoop != null)
         {
            this.mTweenColorLoop.repeatCount = 1;
            this.mTweenColorLoop.end();
            this.mTweenColorLoop = null;
         }
         this.mTweenColorLoop = new GTween(this.mDisplayObjectL0,ItemObject.GLOW_LOOP_TWEEN_LENGTH,{"tint":param1},{
            "ease":Linear.easeNone,
            "repeatCount":0,
            "reflect":true
         });
      }
      
      public function refresh() : void
      {
         this.applyHQConnection();
         this.influenceIconDraw();
         this.checkInfluenceEvent();
      }
      
      public function setPersistence(param1:XML) : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:Role = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         this.mPersistence = param1;
         this.mSid = param1.@sid;
         var _loc2_:int = int(param1.@sid);
         if(DollarsGame.smItemSid <= _loc2_)
         {
            DollarsGame.smItemSid = _loc2_ + 1;
         }
         this.sku = this.mPersistence.@sku;
         this.abTestGroup = this.mPersistence.@abTestGroup;
         this.tileRelativeX = this.mPersistence.@x;
         this.tileRelativeY = this.mPersistence.@y;
         this.decorationsSetPersistence(this.mPersistence);
         this.mIsConnected = int(this.mPersistence.@isSuspended) == 0;
         for each(_loc3_ in this.mPersistence.State)
         {
            if(this.mStatePersistence == null)
            {
               this.mStatePersistence = _loc3_;
            }
         }
         for each(_loc4_ in this.mPersistence.Crew)
         {
            _loc6_ = _loc4_.@ids.split(",");
            if(this.mCrew == null)
            {
               this.mCrew = new Array();
               this.mCrew[ItemDefinition.CREW_INVITED] = new Array();
               this.mCrew[ItemDefinition.CREW_PAID] = new Array();
            }
            for each(_loc7_ in _loc6_)
            {
               if(_loc7_ != "")
               {
                  this.mCrew[ItemDefinition.CREW_INVITED].push(_loc7_);
               }
            }
            _loc6_ = _loc4_.@bought.split(",");
            for each(_loc7_ in _loc6_)
            {
               if(_loc7_ != "")
               {
                  this.mCrew[ItemDefinition.CREW_PAID].push(int(_loc7_));
               }
            }
         }
         this.stateId = this.mStatePersistence.@id;
         _loc5_ = DollarsGame.getCurrentRole();
         return _loc5_.isItemStateAllowed(this.stateId);
      }
      
      public function doMouseOver() : void
      {
         this.mMap.setItemMouseOver(this);
         if(this.mMouseOverTimer <= 0)
         {
            this.mMouseOverTimer = 200;
         }
      }
      
      public function setContractSku(param1:String) : void
      {
         this.mContractSku = param1;
      }
      
      public function isContractSignReady() : Boolean
      {
         return !mIsSuspended && this.getCurrentState().isContractSignReady();
      }
      
      public function removeAnimEnterFrameListener(param1:Function) : void
      {
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.getCurrentAnim().removeEventListener(Event.ENTER_FRAME,param1);
         }
      }
      
      public function canBeAccelerated() : Boolean
      {
         var _loc1_:StateItemObject = this.getCurrentState();
         if(_loc1_ != null && _loc1_ is StateOnRent)
         {
            return (_loc1_ as StateOnRent).canBeAccelerated() && this.mDef.type == ItemDefinition.TYPE_HOUSES_ID && !this.mDef.isHeadQuarters();
         }
         return false;
      }
      
      public function demolish(param1:int = 0) : void
      {
         var _loc2_:PopupConfirmDestroy = null;
         var _loc3_:int = 0;
         this.mStateBeforeDemolition = this.getCurrentState();
         DollarsGame.setItemOutlineEnabled(false);
         if(this.mCompany.world.role.demolitionConfirmationRequired())
         {
            _loc2_ = new PopupConfirmDestroy();
            _loc2_.addEventListener(Popup.EVENT_ACCEPT,this.onAccept);
            _loc2_.addEventListener(Popup.EVENT_CLOSE,this.onPopupClose);
            _loc3_ = RulesFacade.getInstance().settingsGetDestroyItemProfit(this);
            if(_loc3_ > 0)
            {
               _loc2_.showPopUp(param1,TextManager.getText(TextIDs.TID_DESTROY_MSG),_loc3_);
            }
            else
            {
               _loc2_.showPopUp(param1,TextManager.getText(TextIDs.TID_DESTROY_BUILDING_NOREWARD),_loc3_);
            }
         }
         else
         {
            this.onAccept();
         }
      }
      
      public function set company(param1:Company) : void
      {
         this.mCompany = param1;
         this.mMap = this.mCompany.world.map;
      }
      
      public function setPersistenceFromFormat(param1:Object, param2:int) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc5_:XML = null;
         if(param2 == ItemDefinition.BUILD_FORMAT_SHORT_ID)
         {
            _loc4_ = param1 as String;
            _loc3_ = this.setPersistenceShortFormat(_loc4_);
         }
         else
         {
            _loc5_ = param1 as XML;
            _loc3_ = this.setPersistence(_loc5_);
         }
         return _loc3_;
      }
      
      public function getOfferType() : String
      {
         if(this.mDef.offerDef != null)
         {
            return this.mDef.offerDef.offerType;
         }
         return OfferManager.TYPE_NONE;
      }
      
      private function influenceGetItemsAffectedTile(param1:TileData) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         if(param1.isBaseAffectedByInfluence())
         {
            _loc2_ = true;
            if(this.mInfluenceItemsAffectedByInfluence == null)
            {
               this.mInfluenceItemsAffectedByInfluence = new Array();
            }
            if(_loc2_)
            {
               _loc3_ = this.mInfluenceItemsAffectedByInfluence.indexOf(param1.baseItem);
               if(_loc3_ == -1)
               {
                  this.mInfluenceItemsAffectedByInfluence.push(param1.baseItem);
               }
            }
         }
      }
      
      public function doConstruction() : void
      {
         var _loc1_:int = 0;
         var _loc2_:uint = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         if(!this.mUseAsGift)
         {
            _loc1_ = 0;
            _loc2_ = PointsAnimation.TYPE_COINS;
            _loc3_ = DollarsGame.smInstance.mBuyBox.getSelectedTab();
            _loc4_ = "";
            if(_loc3_ == "featured")
            {
               _loc4_ = MetricConstants.LABEL_ECONOMY_BUY_ITEM_SPECIALS;
            }
            else if(_loc3_ == "new_items")
            {
               _loc4_ = MetricConstants.LABEL_ECONOMY_BUY_ITEM_WEEK;
            }
            _loc5_ = new Array([MetricConstants.PRODUCT_HOUSE,MetricConstants.PRODUCT_COMMERCE,MetricConstants.PRODUCT_DECORATION,MetricConstants.PRODUCT_WONDER],[MetricConstants.PRODUCT_HOUSE,MetricConstants.PRODUCT_COMMERCE,MetricConstants.PRODUCT_DECORATION,MetricConstants.PRODUCT_WONDER]);
            if(Config.FACEBOOK_CREDITS_AS_CURRENCY && (this.itemDefinition.getConstructionFBCredits() > 0 && (this.itemDefinition.getConstructionCash() == 0 || this.mCompany.DCCash < this.itemDefinition.getConstructionCash())))
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_ITEM,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionFBCredits());
               if(_loc4_ != "")
               {
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,_loc4_,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionFBCredits());
               }
            }
            else if(Config.FACEBOOK_CREDITS_AS_CURRENCY && (this.itemDefinition.getConstructionFBCnoCash() > 0 && this.mCompany.DCCoins < this.itemDefinition.getConstructionCoins()))
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_ITEM,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionFBCnoCash());
               if(_loc4_ != "")
               {
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,_loc4_,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionFBCnoCash());
               }
            }
            else
            {
               if(this.itemDefinition.getConstructionCash() > 0)
               {
                  _loc1_ = this.itemDefinition.getConstructionCash();
                  this.mCompany.DCCash -= _loc1_;
                  this.getCurrentState().gainedAccumDCCash(-_loc1_);
                  _loc2_ = PointsAnimation.TYPE_GOLD;
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_ITEM,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionCash());
                  if(_loc4_ != "")
                  {
                     MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,_loc4_,_loc5_[0][this.itemDefinition.type],this.itemDefinition.itemName,null,0,this.itemDefinition.getConstructionCash());
                  }
               }
               else
               {
                  _loc1_ = this.itemDefinition.getConstructionCoins();
                  this.mCompany.DCCoins -= _loc1_;
                  this.getCurrentState().gainedAccumDCCoins(-_loc1_);
                  MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_ITEM,_loc5_[1][this.itemDefinition.type],this.itemDefinition.itemName,null,this.itemDefinition.getConstructionCoins(),0);
                  if(_loc4_ != "")
                  {
                     MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,_loc4_,_loc5_[1][this.itemDefinition.type],this.itemDefinition.itemName,null,this.itemDefinition.getConstructionCoins(),0);
                  }
                  if(this.itemDefinition.sku == "houses_004_001")
                  {
                     MyMetrics.sendMetricNG(MetricConstants.EVENT_TUTORIAL_MISSION_TOOLBAR,MetricConstants.LABEL_TUTORIAL_MISSION_TOOLBAR_STORY_3,_loc5_[1][this.itemDefinition.type],this.itemDefinition.itemName,null,this.itemDefinition.getConstructionCoins(),0);
                  }
               }
               if(this.mCompany.showsCoinsParticles() && _loc1_ > 0)
               {
                  ParticlesManager.addParticle(new PointsAnimation(-_loc1_,_loc2_,this.displayObjectL0.x,this.displayObjectL0.y));
               }
            }
         }
         this.init();
      }
      
      public function isOutlineInMouseOverEnabled() : Boolean
      {
         return this.isMouseOverEnabled() && this.getCurrentState().isOutlineInMouseOverEnabled();
      }
      
      public function get worldX() : Number
      {
         return this.mWorldX;
      }
      
      public function get worldZ() : Number
      {
         return this.mWorldZ;
      }
      
      public function endMoving() : void
      {
         if(this.mMoving)
         {
            this.mMoving = false;
            if(this.hasInfluenceArea())
            {
               this.attachInfluence();
            }
            this.mMap.placeItem(this,false);
            if(!this.mDef.needsHQConnection())
            {
               resume();
            }
         }
      }
      
      public function influenceResetItemsAffectedByCommerce(param1:Boolean = false) : void
      {
         var _loc2_:StateItemObject = null;
         if(this.mInfluenceItemsAffectedByCommerce != null)
         {
            this.mInfluenceItemsAffectedByCommerce.splice(0,this.mInfluenceItemsAffectedByCommerce.length);
         }
         if(param1)
         {
            this.influenceGetItemsAffectedByCommerce();
            if(this.mInfluenceItemsAffectedByCommerce.length == 0)
            {
               _loc2_ = this.getCurrentState();
               if(_loc2_ != null)
               {
                  _loc2_.resetMode();
               }
            }
         }
      }
      
      private function attachInfluenceTile(param1:TileData) : void
      {
         param1.addItemInfluence(this);
      }
      
      public function getCurrentState() : StateItemObject
      {
         return StateItemObject(mCurrentState);
      }
      
      public function getShadowRows() : int
      {
         var _loc2_:ItemDecoration = null;
         var _loc1_:int = this.mDef.shadowRows;
         if(this.mDef.isHeadQuarters())
         {
            _loc2_ = this.decorationsGetDecorationByType(ItemDecorationDefinition.TYPE_SKINS_ID);
            _loc1_ = _loc2_.getShadowRows();
         }
         return _loc1_;
      }
      
      public function init() : void
      {
         this.registerRoadNeighbour();
         if(!this.mInitialized)
         {
            if(this.mDef.needsToRegisterNumberOfConstructions())
            {
               this.mCompany.registerOccurrencesAddItem(this);
            }
            if(this.hasInfluenceArea())
            {
               this.attachInfluence();
            }
            this.mInitialized = true;
         }
      }
      
      public function get influenceItemsAffectedByCommerce() : Array
      {
         return this.mInfluenceItemsAffectedByCommerce;
      }
      
      public function setInfluenceAreaVisibility(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc3_:ItemObject = null;
         this.mSimulate = param2;
         if(this.hasInfluenceArea() && this.mResourcesLoaded)
         {
            if(this.mDisplayObjectInfluenceArea != null)
            {
               if(this.mSimulate)
               {
                  if(this.mInfluenceItemsAffectedByInfluence != null)
                  {
                     for each(_loc3_ in this.mInfluenceItemsAffectedByInfluence)
                     {
                        _loc3_.setInfluenceAreaAffectedVisibility(false,this.itemDefinition,this.mSimulate);
                     }
                     this.mInfluenceItemsAffectedByInfluence.length = 0;
                  }
               }
               this.mDisplayObjectInfluenceArea.visible = true;
               this.influenceAreaDraw();
               if(param1)
               {
                  if(!this.mSimulate)
                  {
                     this.mDisplayObjectInfluenceArea.scaleX = ItemObject.TWEEN_MIN_SCALE;
                     this.mDisplayObjectInfluenceArea.scaleY = ItemObject.TWEEN_MIN_SCALE;
                     this.mDisplayObjectInfluenceArea.alpha = ItemObject.TWEEN_MIN_ALPHA;
                     if(this.mTween != null)
                     {
                        this.mTween.end();
                     }
                     this.mTween = new GTween(this.mDisplayObjectInfluenceArea,ItemObject.TWEEN_IN_LENGHT,{
                        "scaleX":1,
                        "scaleY":1,
                        "alpha":1
                     },{
                        "ease":Linear.easeNone,
                        "onComplete":this.enableItemsAffected
                     });
                  }
                  else
                  {
                     if(this.mTween != null)
                     {
                        this.mTween.end();
                     }
                     this.mDisplayObjectInfluenceArea.scaleX = 1;
                     this.mDisplayObjectInfluenceArea.scaleY = 1;
                     this.mDisplayObjectInfluenceArea.alpha = 1;
                     this.setItemsAffected(true);
                  }
               }
               else
               {
                  if(this.mTween != null)
                  {
                     this.mTween.end();
                  }
                  this.mTween = new GTween(this.mDisplayObjectInfluenceArea,ItemObject.TWEEN_OUT_LENGHT,{
                     "scaleX":ItemObject.TWEEN_MIN_SCALE,
                     "scaleY":ItemObject.TWEEN_MIN_SCALE,
                     "alpha":ItemObject.TWEEN_MIN_ALPHA
                  },{
                     "ease":Linear.easeNone,
                     "onComplete":this.disabledItemsAffected
                  });
               }
            }
            else
            {
               this.setDisplayObjectOutlineVisible(param1,ItemObject.INFLUENCE_COLOR);
            }
         }
      }
      
      public function undoSelection() : void
      {
         this.getCurrentState().undoSelection();
         this.undoMouseOver();
      }
      
      public function set stateId(param1:int) : void
      {
         this.mStateId = param1;
      }
      
      private function setItemsAffected(param1:Boolean) : void
      {
         var _loc3_:ItemObject = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         this.influenceGetItemsAffected();
         var _loc2_:int = 0;
         for each(_loc3_ in this.mInfluenceItemsAffectedByInfluence)
         {
            _loc4_ = this.mMap.getWorldToTileIndex(_loc3_.worldX,_loc3_.worldY,_loc3_.worldZ);
            _loc5_ = this.mMap.isTileInAreaMine(_loc4_);
            if(this.mDef.hasCommerceBehaviour())
            {
               _loc5_ = _loc3_.isAffectedByType(this.mCompany,this.mDef.type);
               if(_loc5_)
               {
                  _loc2_ += _loc3_.getPopulation();
               }
            }
            if(_loc5_)
            {
               _loc3_.setInfluenceAreaAffectedVisibility(param1,this.itemDefinition,this.mSimulate);
            }
         }
         if(this.mDef.hasCommerceBehaviour() && this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.update(_loc2_);
         }
      }
      
      public function getBarY() : Number
      {
         return this.mBarPosY;
      }
      
      public function get sku() : String
      {
         return this.mSku;
      }
      
      public function setDisplayObjectOutlineVisible(param1:Boolean, param2:uint) : void
      {
         if(this.mDisplayObjectL0 != null)
         {
            if(param1)
            {
               this.startColorBase(param2);
               this.startGlow(param2);
            }
            else
            {
               this.endColorBase();
               this.endGlow();
            }
            this.mIsOutlined = param1;
         }
      }
      
      public function get worldY() : Number
      {
         return this.mWorldY;
      }
      
      public function isSelectable() : Boolean
      {
         return this.getCurrentState().isSelectable();
      }
      
      public function getAnimFrame() : int
      {
         var _loc1_:MovieClip = null;
         if(this.mDisplayObjectMc != null)
         {
            _loc1_ = this.mDisplayObjectMc.getCurrentAnim() as MovieClip;
            return _loc1_.currentFrame;
         }
         return -1;
      }
      
      public function isMouseOver() : Boolean
      {
         return this.getCurrentState() != null && this.getCurrentState().isMouseOver();
      }
      
      public function getBarX() : Number
      {
         return this.mBarPosX;
      }
      
      public function destroyAnim(param1:int) : void
      {
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.destroyIndex(param1);
         }
      }
      
      private function decorationsAddDecoration(param1:ItemDecoration) : void
      {
         param1.itemObject = this;
         this.mDecorationsDictionary[param1.type] = param1;
         this.mDecorations.push(param1);
      }
      
      public function doUIEventWaitingFor() : void
      {
         this.getCurrentState().doUIEventWaitingFor();
      }
      
      public function startGlow(param1:uint) : void
      {
         if(this.mTweenColorLoop != null && !this.mTweenColorLoop.paused)
         {
            this.mTweenColorLoop.paused = true;
         }
         if(!this.mIsOutlined)
         {
            this.mDisplayObjectL0.transform.colorTransform = FiltersManager.setInk(this.mDisplayObjectL0.transform.colorTransform,param1,0.2);
         }
      }
      
      private function viewConnectedToRoadCheckEnd(param1:Event) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:MovieClip = this.mViewDOs[VIEW_CONNECTED_TO_ROAD_ID];
         if(_loc3_ != null)
         {
            if(_loc3_.currentFrame == _loc3_.totalFrames || param1 == null)
            {
               this.viewUnattach(VIEW_CONNECTED_TO_ROAD_ID);
               if(param1 != null)
               {
                  _loc2_ = true;
               }
            }
         }
         return _loc2_;
      }
      
      public function applyHQConnection() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(this.mCompany.isAffectedByHQConnection())
         {
            _loc1_ = this.isHQConnected();
            if(this.mDisplayObjectNotConnectedToHQ.visible && _loc1_ && DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD && (Tutorial.smTutorialStep >= Tutorial.TUTORIAL_STEP_BUILD_HOUSE_ID || Tutorial.smTutorialEnd))
            {
               this.viewAttach(VIEW_CONNECTED_TO_ROAD_ID);
            }
            this.mDisplayObjectNotConnectedToHQ.visible = !_loc1_;
            if(this.mMap != null)
            {
               this.mDisplayObjectNotConnectedToHQ.x = this.mWorldX + (this.mDef.baseWidth >> 1);
               this.mDisplayObjectNotConnectedToHQ.y = this.mWorldY + (this.mDef.baseHeight >> 1);
               this.mMap.addIntoLayerDialog(this.mDisplayObjectNotConnectedToHQ);
            }
            if(_loc1_)
            {
               _loc2_ = true;
               if(!this.mIsConnected)
               {
                  this.mIsConnected = true;
                  if(DollarsGame.smInstance.mState == DollarsGame.STATE_BUILD_WORLD)
                  {
                     _loc3_ = new Object();
                     _loc3_.cmd = UserDataFacade.QUEUE_REQUEST_SET_ITEM_CONNECTION;
                     _loc3_.item = this;
                     UserDataFacade.getInstance().queueRequestAdd(_loc3_);
                     _loc2_ = false;
                     Debug.trace("@@@@@@@@ queueRequestAdd " + _loc3_.cmd + " sid = " + this.mSid + " x = " + _loc3_.x + " y = " + _loc3_.y);
                  }
               }
               if(_loc2_)
               {
                  resume();
               }
            }
            else
            {
               suspend();
               this.mIsConnected = false;
            }
         }
         else
         {
            this.mDisplayObjectNotConnectedToHQ.visible = false;
            this.mMap.removeFromLayerDialog(this.mDisplayObjectNotConnectedToHQ);
         }
      }
      
      public function getStateID() : int
      {
         var _loc1_:int = StateItemObject.STATE_NONE;
         var _loc2_:StateItemObject = this.getCurrentState();
         if(_loc2_ != null)
         {
            _loc1_ = _loc2_.getID();
         }
         return _loc1_;
      }
      
      private function disabledItemsAffected(param1:GTween) : void
      {
         this.setItemsAffected(false);
      }
      
      public function isMouseOverEnabled() : Boolean
      {
         return this.getCurrentState().isMouseOverEnabled();
      }
      
      private function viewLoad() : void
      {
         if(this.mViewDOs == null)
         {
            this.mViewDOs = new Array(VIEW_COUNT);
         }
      }
      
      public function registerRoadNeighbour() : void
      {
         this.roadLoopNeighbours(this.registerRoad);
      }
      
      public function doSelection() : void
      {
         this.getCurrentState().doSelection();
         if(Config.DEBUG_MODE)
         {
            this.debugTraceInfo();
         }
      }
      
      public function getPopulation() : int
      {
         var _loc2_:Array = null;
         var _loc3_:ItemObject = null;
         var _loc1_:int = 0;
         if(this.mDef.hasCommerceBehaviour())
         {
            _loc2_ = this.influenceGetItemsAffectedByCommerce();
            for each(_loc3_ in _loc2_)
            {
               _loc1_ += _loc3_.getPopulation();
            }
         }
         else if(this.mContract != null)
         {
            return this.mDef.getTenants();
         }
         return _loc1_;
      }
      
      public function registerItemInfluence(param1:ItemObject) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 != this)
         {
            _loc2_ = true;
            if(this.mDef.hasCommerceBehaviour())
            {
               _loc2_ = param1.mDef.isAffectedByInfluence();
            }
            if(_loc2_)
            {
               _loc3_ = this.mInfluenceItems.indexOf(param1);
               if(_loc3_ == -1)
               {
                  this.mInfluenceItems.push(param1);
                  if(this.mDef.isAffectedByType(param1.mDef.type))
                  {
                     _loc4_ = param1.itemDefinition.getInfluenceValue();
                     if(_loc4_ != 0)
                     {
                        _loc5_ = int(this.getSellPrice(false));
                        this.setInfluenceValue(this.getOwnInfluenceValue() + _loc4_);
                        _loc6_ = int(this.getSellPrice(false));
                        _loc7_ = _loc6_ - _loc5_;
                        DollarsGame.getProfile().companyValue = DollarsGame.getProfile().companyValue + _loc7_;
                        this.influenceIconDraw();
                        this.checkInfluenceEvent();
                     }
                  }
               }
            }
         }
      }
      
      public function gotoAndStopIcon(param1:Object) : void
      {
         if(this.mIcon != null)
         {
            this.mIcon.stop();
         }
      }
      
      public function setExtraCmdToServer(param1:Object) : void
      {
         this.mExtraCmdToServer = param1;
      }
      
      private function influenceDestroy() : void
      {
         this.mInfluenceItems = null;
         this.mInfluenceItemsAffectedByInfluence = null;
         this.mInfluenceItemsAffectedByCommerce = null;
      }
      
      public function getCurrentAnimIndex() : int
      {
         if(this.mDisplayObjectMc != null)
         {
            return this.mDisplayObjectMc.getCurrentAnimIndex();
         }
         return 0;
      }
      
      public function roadLoopNeighbours(param1:Function) : void
      {
         var _loc8_:int = 0;
         var _loc9_:TileData = null;
         var _loc2_:uint = this.mMap.getWorldToTileX(this.worldX);
         var _loc3_:uint = this.mMap.getWorldToTileY(this.worldY);
         var _loc4_:int = 1;
         var _loc5_:int = this.mDef.baseCols + _loc4_;
         var _loc6_:int = this.mDef.baseRows + _loc4_;
         var _loc7_:int = -_loc4_;
         while(_loc7_ < _loc5_)
         {
            _loc8_ = -_loc4_;
            while(_loc8_ < _loc6_)
            {
               if(!((_loc8_ == -_loc4_ || _loc8_ == _loc6_ - 1) && (_loc7_ == -_loc4_ || _loc7_ == _loc5_ - 1)))
               {
                  _loc9_ = this.mMap.getTileData(_loc2_ + _loc7_,_loc3_ + _loc8_);
                  if(_loc9_ != null && _loc9_.isRoad)
                  {
                     param1(_loc9_);
                  }
               }
               _loc8_++;
            }
            _loc7_++;
         }
      }
      
      public function afterMoving() : void
      {
         this.getCurrentState().afterMoving();
      }
      
      public function hasRoadInPerimeter() : Boolean
      {
         return this.mRoadTiles.length > 0;
      }
      
      public function startMoving() : void
      {
         if(!this.mMoving)
         {
            this.mMoving = true;
            suspend();
            if(this.hasInfluenceArea())
            {
               this.unattachInfluence();
            }
            this.mMap.unplaceItem(this);
         }
      }
      
      private function decorationsLoad() : void
      {
         this.mDecorationsDictionary = new Dictionary(true);
         this.mDecorations = new Array();
         this.mDecorationsPersistence = new Array();
      }
      
      public function viewAttach(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc3_:DisplayObjectContainer = this.viewGetParent(param1);
         switch(param1)
         {
            case VIEW_CONNECTED_TO_ROAD_ID:
               _loc2_ = new (this.mLoader.getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Start_Income"))();
               _loc2_.mouseChildren = false;
               _loc3_.addChild(_loc2_);
               _loc2_.x = this.mDef.baseWidth >> 1;
               _loc2_.y = this.mDef.baseHeight >> 1;
               _loc2_.addEventListener(Event.ENTER_FRAME,this.viewConnectedToRoadCheckEnd);
               this.mViewDOs[param1] = _loc2_;
               _loc4_ = this.mViewDOs[param1] as MovieClip;
               _loc5_ = 0;
               while(_loc5_ < _loc4_.numChildren)
               {
                  if(_loc4_.getChildAt(_loc5_) is TextField)
                  {
                     TextManager.reformatTextField(TextField(_loc4_.getChildAt(_loc5_)));
                     TextField(_loc4_.getChildAt(_loc5_)).text = TextManager.getText(TextIDs.TID_HOUSE_CONNECTED);
                     TextManager.setTextScaled(TextField(_loc4_.getChildAt(_loc5_)),false);
                  }
                  _loc5_++;
               }
         }
      }
      
      private function peopleLayerSetVisible(param1:Boolean) : void
      {
         if(this.mPeopleLayer != null)
         {
            if(param1 && this.mContract != null)
            {
               this.mPeopleLayer.visible = true;
            }
            else
            {
               this.mPeopleLayer.visible = false;
            }
         }
      }
      
      private function buildResources() : void
      {
         var _loc1_:Array = null;
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:Sprite = null;
         var _loc5_:Class = null;
         var _loc6_:String = null;
         var _loc7_:Sprite = null;
         var _loc8_:Bitmap = null;
         var _loc9_:Sprite = null;
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.destroy();
         }
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.destroy();
         }
         this.mDisplayObjectInfluenceIcon = this.mDef.getInfluenceIcon();
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.setItemObject(this);
         }
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.x = this.itemDefinition.baseWidth >> 1;
            this.mDisplayObjectInfluenceIcon.y = this.itemDefinition.baseHeight;
            this.mDisplayObjectL1.addChild(this.mDisplayObjectInfluenceIcon);
         }
         this.influenceDraw();
         if(this.mDef.needsToLoadSWF())
         {
            _loc1_ = new Array();
            _loc2_ = 0;
            while(_loc2_ < STATE_COUNT)
            {
               _loc1_.push(null);
               _loc2_++;
            }
            this.mBarPosX = 0;
            this.mBarPosY = 0;
            if(this.mDef.type != ItemDefinition.TYPE_DECORATIONS_ID)
            {
               if(this.mDef.hasBarPosition())
               {
                  _loc4_ = this.mDef.getDisplayObject("BarPosition");
                  this.mBarPosX = _loc4_.getChildAt(0).x;
                  this.mBarPosY = _loc4_.getChildAt(0).y + this.mDef.baseHeight;
                  if(this.mStateId == STATE_BUILDING || this.mStateId == StateItemObject.STATE_ON_HIRE_CREW)
                  {
                     _loc5_ = DCResourceManager.getInstance().getSWFClass(this.mDef.getSkuToLoad(),"building");
                     if(_loc5_ != null)
                     {
                        _loc1_[STATE_BUILDING] = new _loc5_();
                        _loc1_[STATE_BUILDING].y = this.mDef.baseHeight;
                     }
                     else
                     {
                        _loc6_ = "T" + this.mDef.baseRows + "x" + this.mDef.baseCols;
                        if(this.mDef.isAClub())
                        {
                           _loc6_ += "_club";
                           this.mCrewIcon = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,"friends_accepted"))();
                           this.updateCrew();
                           _loc1_[STATE_BUILDING] = this.mDef.getBuildObject("normal");
                           _loc1_[STATE_BUILDING].y = this.mDef.baseHeight;
                           if(this.mCrewIcon != null)
                           {
                              _loc1_[STATE_BUILDING].addChild(this.mCrewIcon);
                              this.mCrewIcon.x = this.mDef.baseWidth / 2;
                              this.mCrewIcon.y = -this.mDef.baseHeight;
                           }
                        }
                        else
                        {
                           _loc5_ = DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUILDING_STATE_SWF,_loc6_);
                           if(_loc5_ != null)
                           {
                              _loc7_ = new Sprite();
                              _loc8_ = new Bitmap(new _loc5_(1,1));
                              _loc8_.y = this.mDef.baseHeight - _loc8_.height;
                              _loc7_.addChild(_loc8_);
                              _loc1_[STATE_BUILDING] = _loc7_;
                           }
                        }
                     }
                  }
               }
               else
               {
                  _loc1_[STATE_NORMAL] = new (this.mLoader.getSWFClass(this.mDef.getSkuToLoad(),"Asset"))();
                  _loc1_[STATE_HQ_NORMAL] = new (this.mLoader.getSWFClass(this.mDef.getSkuToLoad(),"Asset"))();
               }
            }
            if(this.mDef.hasBarPosition())
            {
               if(Config.USE_BITMAP_DATA_ANIMATIONS)
               {
                  _loc1_[STATE_NORMAL] = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainer(this.mDef.getSkuToLoad(),"normal"));
                  _loc1_[STATE_NORMAL].gotoAndPlay(1);
                  _loc1_[STATE_NORMAL].y = this.mDef.baseHeight;
               }
               else
               {
                  _loc1_[STATE_NORMAL] = this.mDef.getBuildObject("normal");
                  if(this.mDef.isAClub())
                  {
                     _loc1_[STATE_HQ_NORMAL] = this.mDef.getBuildObject("normal_2");
                  }
               }
            }
            _loc1_[STATE_NORMAL].play();
            if(this.mDef.type != ItemDefinition.TYPE_DECORATIONS_ID)
            {
               if(!this.mDef.isAnimated || Dollars.smStage.quality.toUpperCase() == StageQuality.LOW.toUpperCase())
               {
                  _loc1_[STATE_NORMAL].stop();
               }
            }
            _loc2_ = 1;
            while(_loc2_ < STATE_COUNT)
            {
               if(_loc1_[_loc2_] != null)
               {
                  if(!(_loc1_[_loc2_] is Bitmap))
                  {
                     _loc9_ = _loc1_[_loc2_];
                     _loc9_.y = this.mDef.baseHeight;
                     _loc9_.mouseChildren = false;
                     _loc9_.mouseEnabled = false;
                  }
               }
               _loc2_++;
            }
            _loc3_ = 0;
            if(_loc1_[_loc3_] == null)
            {
               _loc3_ = STATE_NORMAL;
            }
            this.mDisplayObjectMc = new SpriteObject(this.mDisplayObjectL0,_loc1_,_loc3_);
            this.effectsDraw();
         }
         if(this.mLoading != null)
         {
            this.mDisplayObjectL0.removeChild(this.mLoading);
            this.mLoading = null;
         }
         this.decorationsDraw(this.mDisplayObjectL0);
         this.toggleAnimation(false);
         this.mResourcesLoaded = true;
      }
      
      public function gotoAndPlayIcon(param1:Object) : void
      {
         if(this.mIcon != null)
         {
            this.mIcon.play();
         }
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc6_:XML = null;
         if(this.mSid == "")
         {
            this.mSid = "" + DollarsGame.smItemSid;
            ++DollarsGame.smItemSid;
         }
         var _loc2_:String = this.mCompany.mSid;
         this.mTileRelativeX = this.mMap.getTileToTileRelativeX(this.mMap.getWorldToTileX(this.mWorldX));
         this.mTileRelativeY = this.mMap.getTileToTileRelativeY(this.mMap.getWorldToTileY(this.mWorldY));
         var _loc3_:String = isSuspended ? "1" : "0";
         var _loc4_:XML = <Item sid={this.mSid} csid={_loc2_} sku={this.sku} type={this.mDef.type} x={this.mTileRelativeX} y={this.mTileRelativeY} isSuspended={_loc3_}/>;
         var _loc5_:XML = this.decorationsGetPersistence();
         if(_loc5_ != null)
         {
            _loc4_.appendChild(_loc5_);
         }
         if(mCurrentState != null)
         {
            this.mStatePersistence = this.getCurrentState().getPersistence();
            _loc4_.appendChild(this.mStatePersistence);
         }
         if(this.mCrew != null)
         {
            _loc6_ = <Crew ids={this.mCrew[ItemDefinition.CREW_INVITED].toString()} bought={this.mCrew[ItemDefinition.CREW_PAID].toString()}/>;
            _loc4_.appendChild(_loc6_);
         }
         this.mPersistence = _loc4_;
         return this.mPersistence;
      }
      
      public function getCompanyValue() : int
      {
         var _loc1_:int = this.mDef.getCompanyValue();
         if(this.mContractSku != null)
         {
            _loc1_ += this.getContract().getCostCoins();
         }
         return _loc1_;
      }
      
      public function endGlow() : void
      {
         if(this.mTweenColorLoop != null && this.mTweenColorLoop.paused)
         {
            this.mTweenColorLoop.paused = false;
         }
         this.mDisplayObjectL0.transform.colorTransform = this.mColorTransform;
      }
      
      private function effectsDraw() : void
      {
         var _loc1_:Class = null;
         var _loc6_:* = undefined;
         if(this.mEffectsDOs != null)
         {
            this.effectsDestroy();
         }
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:Array = ["",ItemDefinition.EFFECT_NAME_LAYOUT];
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc3_ = 0;
            do
            {
               _loc2_ = false;
               _loc1_ = null;
               _loc1_ = ItemDefinition.getItemDesignClass(this.itemDefinition.getSkuToLoad(),ItemDefinition.EFFECTS_NAME_PREFIX + _loc3_ + _loc4_[_loc5_]);
               _loc2_ ||= _loc1_ != null;
               if(_loc1_ != null)
               {
                  if(this.mEffectsDOs == null)
                  {
                     this.mEffectsDOs = new Array();
                  }
                  _loc6_ = new _loc1_();
                  _loc6_.y = this.mDef.baseHeight;
                  this.mEffectsDOs.push(_loc6_);
                  if(_loc5_ == 0)
                  {
                     this.mDisplayObjectL0.addChild(_loc6_);
                  }
                  else
                  {
                     this.mDisplayObjectL1.addChild(_loc6_);
                  }
               }
               _loc3_++;
            }
            while(_loc2_);
            _loc5_++;
         }
         _loc1_ = this.mLoader.getSWFClass(this.mDef.getSkuToLoad(),ItemDefinition.EFFECTS_NAME_PREFIX + 0 + ItemDefinition.EFFECT_NAME_PEOPLE_LAYOUT);
         if(_loc1_ != null)
         {
            this.mPeopleLayer = new _loc1_();
            this.mPeopleLayer.y = this.mDef.baseHeight;
            this.mDisplayObjectL0.addChild(this.mPeopleLayer);
         }
      }
      
      public function get value() : uint
      {
         return this.itemDefinition.getCompanyValue();
      }
      
      public function influenceIconDraw(param1:int = 0) : void
      {
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.draw();
         }
      }
      
      public function isBuilt() : Boolean
      {
         var _loc2_:StateItemObject = null;
         var _loc1_:Boolean = false;
         if(this.mStateBeforeDemolition != null)
         {
            _loc1_ = this.mStateBeforeDemolition.isBuilt();
         }
         else
         {
            _loc2_ = this.getCurrentState();
            _loc1_ = _loc2_ != null && _loc2_.isBuilt();
         }
         return _loc1_;
      }
      
      public function getNoNeedPlot() : Boolean
      {
         return this.mNoNeedPlot;
      }
      
      public function setNoNeedPlot(param1:Boolean) : void
      {
         this.mNoNeedPlot = param1;
      }
      
      private function influenceLoad() : void
      {
         this.mInfluenceItems = new Array();
         this.mInfluenceItemsAffectedByInfluence = new Array();
      }
      
      public function getContractSku() : String
      {
         return this.mContractSku;
      }
      
      public function get influenceItemsAffectedByInfluence() : Array
      {
         return this.mInfluenceItemsAffectedByInfluence;
      }
      
      public function decorationsSetPersistence(param1:XML) : void
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.mPersistence.Decorations.Decoration)
         {
            this.mDecorationsPersistence.push(_loc2_);
         }
      }
      
      public function get influenceValue() : int
      {
         var _loc1_:int = this.mInfluenceValue;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            _loc1_ = EncryptionUtils.decrypt(0,_loc1_,Number(this.sid),this.MAGIC_PRIME_ENCRYPTION_NUMBER);
         }
         if(this.mCompany != null && this.mDef.isAffectedByWonderInfluence())
         {
            _loc1_ += this.mCompany.attributesGetValue(Company.ATTRIBUTES_KEY_INFLUENCE,this.mDef);
         }
         return _loc1_;
      }
      
      private function createInfluenceArea() : void
      {
         var _loc1_:uint = uint(this.mDef.getInfluenceRatio());
         if(this.mDisplayObjectInfluenceArea != null && this.mDisplayObjectL1.contains(this.mDisplayObjectInfluenceArea))
         {
            this.mDisplayObjectL1.removeChild(this.mDisplayObjectInfluenceArea);
         }
         this.mDisplayObjectInfluenceArea = null;
         if(_loc1_ > 0)
         {
            this.mDisplayObjectInfluenceArea = new Shape();
            this.mDisplayObjectL1.addChild(this.mDisplayObjectInfluenceArea);
            this.mDisplayObjectInfluenceArea.visible = false;
         }
      }
      
      public function unregisterRoad(param1:TileData) : void
      {
         var _loc2_:int = this.mRoadTiles.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.mRoadTiles.splice(_loc2_,1);
         }
      }
      
      public function get stateId() : int
      {
         return this.mStateId;
      }
      
      private function influenceAreaDraw(param1:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Graphics = null;
         var _loc2_:uint = uint(this.mDef.getInfluenceRatio());
         var _loc3_:uint = uint(MapDefinition.getInstance().getTileWidth());
         var _loc4_:uint = uint(MapDefinition.getInstance().getTileHeight());
         var _loc5_:uint = 65520;
         if(param1)
         {
            this.createInfluenceArea();
         }
         if(_loc2_ > 0)
         {
            _loc6_ = -_loc2_ * _loc3_;
            _loc7_ = -_loc2_ * _loc4_;
            _loc8_ = (this.mDef.baseCols + 2 * _loc2_) * _loc3_;
            _loc9_ = (this.mDef.baseRows + 2 * _loc2_) * _loc4_;
            _loc10_ = this.mDisplayObjectInfluenceArea.graphics;
            FiltersManager.drawRectangleWithBorder(_loc10_,_loc6_,_loc7_,_loc8_,_loc9_,_loc5_,ItemObject.INFLUENCE_ALPHA);
         }
      }
      
      public function getStateBeforeDemolition() : StateItemObject
      {
         return this.mStateBeforeDemolition;
      }
      
      private function isAffectedByType(param1:Company, param2:int) : Boolean
      {
         var _loc4_:StateItemObject = null;
         var _loc3_:Boolean = !mIsSuspended && this.mDef.isAffectedByInfluence();
         if(_loc3_)
         {
            _loc4_ = this.getCurrentState();
            _loc3_ = _loc4_ != null && _loc4_.isAffectedByType(param2);
         }
         return _loc3_;
      }
      
      public function isHeadQuarters() : Boolean
      {
         return this.mDef.isHeadQuarters();
      }
      
      public function set itemDefinition(param1:ItemDefinition) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         this.mSku = param1.sku;
         this.mDef = param1;
         this.decorationsSetItemDefinition(this.mDef);
         this.viewLoad();
         if(this.mDef.type != ItemDefinition.TYPE_DECORATIONS_ID)
         {
            if(this.mDisplayObjectNotConnectedToHQ == null)
            {
               this.mDisplayObjectNotConnectedToHQ = new AssetManager.ItemNoRoadIcon();
            }
         }
         var _loc2_:int = CrewMechanicsManager.getInstance().getCrewCount(this.mDef.constructionCrewSku);
         if(_loc2_ > 0 && this.mCrew == null)
         {
            this.mCrew = new Array();
            this.mCrew[ItemDefinition.CREW_INVITED] = new Array();
            this.mCrew[ItemDefinition.CREW_PAID] = new Array();
         }
         if(this.mDef.isResourceLoaded() || this.isHeadQuarters())
         {
            this.buildResources();
         }
         else if(this.mLoading == null)
         {
            this.mLoading = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"lightgrey_loading_alone"))();
            _loc3_ = this.mDef.baseWidth / this.mDef.baseCols;
            _loc4_ = this.mDef.baseHeight / this.mLoading.height;
            _loc5_ = this.mDef.baseWidth / this.mLoading.width;
            _loc6_ = _loc4_ > _loc5_ ? _loc5_ : _loc4_;
            if(_loc6_ >= 0.5)
            {
               _loc6_ = 0.5;
            }
            this.mLoading.scaleX = _loc6_;
            this.mLoading.scaleY = _loc6_;
            this.mLoading.x = (this.mDef.baseWidth - this.mLoading.width) / 2;
            this.mLoading.y = (this.mDef.baseHeight - this.mLoading.height) / 2;
            this.mDisplayObjectL0.addChild(this.mLoading);
         }
      }
      
      private function viewDestroy() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < VIEW_COUNT)
         {
            this.viewUnattach(_loc1_);
            _loc1_++;
         }
         this.mViewDOs.splice(0,this.mViewDOs.length);
         this.mViewDOs = null;
         this.mViewColorTransformBack = null;
      }
      
      public function removeDisplayObjects() : void
      {
         if(this.mDisplayObjectNotConnectedToHQ != null)
         {
            this.mMap.removeFromLayerDialog(this.mDisplayObjectNotConnectedToHQ);
         }
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mMap.removeFromLayerDialog(this.mDisplayObjectInfluenceIcon);
         }
         if(this.mIcon != null)
         {
            this.mMap.removeFromLayerDialog(this.mIcon);
         }
      }
      
      public function destroyIcon(param1:Function = null) : void
      {
         if(this.mIcon != null)
         {
            this.mMap.removeFromLayerDialog(this.mIcon);
            if(param1 != null && this.mIcon.hasEventListener(Event.ENTER_FRAME))
            {
               this.mIcon.removeEventListener(Event.ENTER_FRAME,param1);
            }
            this.mIcon = null;
         }
      }
      
      public function setWorldPosition(param1:Number, param2:Number, param3:Number = 0) : void
      {
         this.mWorldX = param1;
         this.mWorldY = param2;
         this.mWorldZ = param3;
         var _loc4_:int = param1 - Map.smWidthHalf;
         var _loc5_:int = param2 - Map.smHeightHalf;
         this.mDistanceFromMapCenter = _loc4_ * _loc4_ + _loc5_ * _loc5_;
         this.mDisplayObjectL0.x = param1;
         this.mDisplayObjectL0.y = param2;
         this.mDisplayObjectL1.x = param1;
         this.mDisplayObjectL1.y = param2;
      }
      
      public function getCrewBought() : Array
      {
         return this.mCrew[ItemDefinition.CREW_PAID];
      }
      
      public function canBeSold() : Boolean
      {
         return this.getCurrentState().canBeSold();
      }
      
      private function enableItemsAffected(param1:GTween) : void
      {
         this.setItemsAffected(true);
      }
      
      public function setVisibilityIcon(param1:Boolean) : void
      {
         if(this.mIcon != null)
         {
            this.mIcon.visible = param1;
         }
      }
      
      public function setVisible(param1:Boolean) : void
      {
         this.mVisible = param1;
         this.mDisplayObjectL0.visible = this.mVisible;
         this.mDisplayObjectL1.visible = this.mVisible;
      }
      
      public function influenceGetItemsAffected() : void
      {
         if(this.mInfluenceItemsAffectedByInfluence != null)
         {
            this.mInfluenceItemsAffectedByInfluence.length = 0;
         }
         this.influenceLoopNeighbours(this.influenceGetItemsAffectedTile);
      }
      
      public function decorationsGetDecorationByType(param1:int) : ItemDecoration
      {
         return this.mDecorations[param1];
      }
      
      public function enableContract() : void
      {
         if(this.mContractSku != null)
         {
            this.mContract = this.getContract(true);
            this.peopleLayerSetVisible(true);
         }
      }
      
      public function registerEvent(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         PollManager.getInstance().registerEvent(param1,this.mDef.nameType);
         if(this.mDef.hasSubtype())
         {
            while(_loc2_ < this.mDef.getSubtype().length)
            {
               _loc3_ = this.mDef.nameType + "_" + this.mDef.getSubtype()[_loc2_];
               PollManager.getInstance().registerEvent(param1,this.mDef.nameType + "_" + this.mDef.getSubtype()[_loc2_]);
               _loc2_++;
            }
         }
         PollManager.getInstance().registerEvent(param1,this.mDef.sku);
      }
      
      public function doClick(param1:Boolean = false) : void
      {
         if(param1 || this.isMouseOverEnabled() && this.mMouseOverTimer < 0)
         {
            this.getCurrentState().doClick();
         }
      }
      
      public function decorationsDraw(param1:DisplayObjectContainer) : void
      {
         var _loc2_:ItemDecoration = null;
         for each(_loc2_ in this.mDecorations)
         {
            _loc2_.draw(param1);
         }
      }
      
      public function get displayObjectL1() : ItemSprite
      {
         return this.mDisplayObjectL1;
      }
      
      override public function logicUpdate(param1:int) : void
      {
         super.logicUpdate(param1);
         this.buildUpdate(param1);
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.update();
         }
         if(this.mIcon != null && this.mIcon is BitmapAnimation)
         {
            (this.mIcon as BitmapAnimation).update();
         }
         if(this.mMouseOverTimer > 0)
         {
            this.mMouseOverTimer -= param1;
            if(this.mMouseOverTimer <= 0)
            {
               this.mMouseOverTimer = -1;
               this.mouseOverShow();
            }
         }
         if(this.mDisplayObjectInfluenceIcon != null && this.mCompany.attributesHaveChanged(Company.ATTRIBUTES_KEY_INFLUENCE,this.itemDefinition))
         {
            this.checkInfluenceEvent();
            this.mDisplayObjectInfluenceIcon.update();
         }
      }
      
      public function get displayObjectL0() : ItemSprite
      {
         return this.mDisplayObjectL0;
      }
      
      public function checkInfluenceEvent() : void
      {
         var _loc1_:PollEvent = null;
         if(this.mCompany.isMine())
         {
            _loc1_ = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_CHECK_BONUS + this.mDef.sku);
            if(_loc1_ != null && _loc1_.needsToBeChecked())
            {
               _loc1_.checkCondition(this.influenceValue,this.mSid);
            }
            _loc1_ = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_CHECK_BONUS + this.mDef.subsku);
            if(_loc1_ != null && _loc1_.needsToBeChecked())
            {
               _loc1_.checkCondition(this.influenceValue,this.mSid);
            }
         }
      }
      
      public function mouseOverShow(param1:Boolean = false) : void
      {
         var _loc2_:Boolean = true;
         var _loc3_:Boolean = DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER;
         if(_loc2_)
         {
            if(this.isOutlineInMouseOverEnabled())
            {
               this.setDisplayObjectOutlineVisible(true,ItemObject.GLOW_COLOR);
            }
            if(this.mDisplayObjectInfluenceIcon != null)
            {
               this.mDisplayObjectInfluenceIcon.doMouseOver();
            }
            this.setInfluenceAreaVisibility(true);
            this.getCurrentState().doMouseOver(param1);
         }
      }
      
      public function setDisplayObjectWaitingForUI(param1:Boolean) : void
      {
         if(param1)
         {
            DollarsGame.setItemOutlinePending(null);
         }
         this.setDisplayObjectOutlineVisible(param1,ItemObject.GLOW_COLOR);
      }
      
      public function updateCrew() : void
      {
         var _loc1_:TextField = this.mCrewIcon["caption"];
         var _loc2_:int = CrewMechanicsManager.getInstance().getCrewCount(this.getConstructionCrewSku());
         var _loc3_:int = this.mCrew[ItemDefinition.CREW_PAID].length + this.mCrew[ItemDefinition.CREW_INVITED].length;
         _loc1_.text = _loc3_ + "/" + _loc2_;
      }
      
      private function onAccept(param1:Event = null) : void
      {
         this.getCurrentState().demolish();
         this.onPopupClose(param1);
         if(Config.USE_SOUNDS && this.itemDefinition.type != ItemDefinition.TYPE_DECORATIONS_ID)
         {
            SoundManager.getInstance().playSound(ModelConfig.SOUND_DESTROY,1,0,0);
         }
      }
      
      public function getIncomeXP() : int
      {
         var _loc1_:int = this.mDef.getIncomeXP();
         if(this.mContract != null)
         {
            _loc1_ += this.mContract.getIncomeXP();
         }
         return _loc1_;
      }
      
      public function move(param1:int, param2:int, param3:Boolean) : void
      {
         this.unregisterRoadNeighbour();
         this.mCompany.move(this,param1,param2);
         this.init();
         this.afterMoving();
         this.endMoving();
         this.mCompany.delayedPaymentPay();
         var _loc4_:int = this.mMap.getTileToTileRelativeX(this.mMap.getWorldToTileX(this.mWorldX));
         var _loc5_:int = this.mMap.getTileToTileRelativeY(this.mMap.getWorldToTileY(this.mWorldY));
         Debug.trace("############# ItemObject: add MOVE ITEM server call in ItemObject.move() method sid = " + this.mSid + " newX = " + _loc4_ + " newY = " + _loc5_ + " coins = " + DollarsGame.getProfile().DCCoins + " dec = " + this.mDef.getFormatId());
         var _loc6_:Object = {
            "x":_loc4_,
            "y":_loc5_,
            "dec":this.mDef.getFormatId()
         };
         if(param3)
         {
            _loc6_.freeMove = "true";
         }
         UserDataFacade.getInstance().updateItem(this.mSid,"move",_loc6_);
      }
      
      private function influenceDraw() : void
      {
         this.influenceIconDraw();
         this.createInfluenceArea();
      }
      
      public function setInfluenceIconEnabled(param1:Boolean) : void
      {
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.setEnabled(param1);
         }
      }
      
      private function unattachInfluenceTile(param1:TileData) : void
      {
         param1.removeItemInfluence(this);
      }
      
      public function getCrew() : Array
      {
         return this.mCrew;
      }
      
      public function set abTestGroup(param1:int) : void
      {
         this.mAbTestGroup = param1;
      }
      
      public function changeAnim(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:MovieClip = null;
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.changeAnim(param1);
            this.effectsSetVisible(Boolean(EFFECTS_VISIBLE_PER_STATE[param1]) || param2 || this.mMoving);
            if(this.mDef != null && !this.mDef.isAnimated)
            {
               _loc3_ = this.mDisplayObjectMc.getCurrentAnim() as MovieClip;
               if(_loc3_ != null)
               {
                  _loc3_.stop();
               }
            }
         }
      }
      
      public function viewUnattach(param1:int) : void
      {
         var _loc2_:MovieClip = this.mViewDOs[param1];
         var _loc3_:DisplayObjectContainer = this.viewGetParent(param1);
         if(_loc2_ != null)
         {
            if(param1 == VIEW_CONNECTED_TO_ROAD_ID)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.viewConnectedToRoadCheckEnd);
            }
            if(_loc3_.contains(_loc2_))
            {
               _loc3_.removeChild(_loc2_);
            }
            this.mViewDOs[param1] = null;
         }
      }
      
      public function isVisible() : Boolean
      {
         return this.mVisible;
      }
      
      private function onPopupClose(param1:Event) : void
      {
         var _loc2_:Popup = param1.target as Popup;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.onAccept);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onPopupClose);
         _loc2_.destroy();
         _loc2_ = null;
         this.undoMouseOver(true);
      }
      
      public function get abTestGroup() : int
      {
         return this.mAbTestGroup;
      }
      
      public function debugAStar(param1:Boolean) : void
      {
         var _loc2_:TileData = null;
         for each(_loc2_ in this.mRoadTiles)
         {
            if(param1)
            {
               _loc2_.showStartDot();
            }
            else
            {
               _loc2_.unShowStartDot();
            }
         }
      }
      
      public function isItemOnScreen() : Boolean
      {
         var _loc1_:int = Dollars.smStage.stageWidth;
         var _loc2_:int = Dollars.smStage.stageHeight;
         var _loc3_:int = this.mMap.getWorldXToScreen(this.worldX);
         var _loc4_:int = this.mMap.getWorldYToScreen(this.worldY) + this.worldSizeY;
         if(_loc3_ + this.worldSizeX > 0 && _loc3_ < _loc1_ && _loc4_ > 0 && _loc4_ - this.displayObjectL0.getHeight() < _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function signContract(param1:ContractDefinition) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.mCompany.DCCoins >= param1.getCostCoins())
         {
            this.getCurrentState().signContract(param1);
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function isIncomeReady() : Boolean
      {
         return !mIsSuspended && this.getCurrentState().isIncomeReady();
      }
      
      public function getOwnInfluenceValue() : int
      {
         var _loc1_:int = this.mInfluenceValue;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            _loc1_ = EncryptionUtils.decrypt(0,_loc1_,Number(this.sid),this.MAGIC_PRIME_ENCRYPTION_NUMBER);
         }
         return _loc1_;
      }
      
      public function getCurrentAnim() : MovieClip
      {
         var _loc1_:MovieClip = null;
         if(this.mDisplayObjectMc != null)
         {
            _loc1_ = this.mDisplayObjectMc.getCurrentAnim() as MovieClip;
         }
         return _loc1_;
      }
      
      public function isMoveable() : Boolean
      {
         var _loc1_:Boolean = this.isUIAllowed();
         if(_loc1_)
         {
            _loc1_ = this.getCurrentState().isMoveable();
         }
         return _loc1_;
      }
      
      public function destroy(param1:Boolean = false, param2:Boolean = true) : void
      {
         if(param2)
         {
            if(param1)
            {
               UserDataFacade.getInstance().updateItem(this.mSid,"destroy",{"dec":this.mDef.getFormatId()});
            }
            else
            {
               this.mMap.unplaceItem(this);
            }
         }
         this.removeDisplayObjects();
         var _loc3_:StateItemObject = this.getCurrentState();
         if(_loc3_ != null)
         {
            _loc3_.destroy();
         }
         if(this.hasInfluenceArea())
         {
            this.unattachInfluence();
         }
         this.mStatePersistence = null;
         if(this.mLoading != null)
         {
            this.mDisplayObjectL0.removeChild(this.mLoading);
            this.mLoading = null;
         }
         if(this.mDisplayObjectInfluenceIcon != null)
         {
            this.mDisplayObjectInfluenceIcon.destroy();
         }
         this.effectsDestroy();
         this.viewDestroy();
         this.mDisplayObjectL0 = null;
         this.mDisplayObjectL1 = null;
         if(this.mDisplayObjectMc != null)
         {
            this.mDisplayObjectMc.destroy();
            this.mDisplayObjectMc = null;
         }
         this.influenceDestroy();
         this.mRoadTiles = null;
         this.mSearchToHQ = null;
         this.decorationsDestroy();
         this.mContract = null;
         this.mContractSku = null;
         this.mDisplayObjectNotConnectedToHQ = null;
      }
      
      public function setIcon(param1:int, param2:Function = null) : Boolean
      {
         var _loc3_:String = Config.getRoot() + ModelConfig.HOUSES_RENT_SWF;
         if(this.mDef.isACommerce())
         {
            if(!this.mResourcesLoaded)
            {
               return false;
            }
            _loc3_ = Config.getRoot() + ModelConfig.CONTRACT_SWF;
         }
         if(Config.USE_BITMAP_DATA_ANIMATIONS)
         {
            _loc3_ = "icons";
         }
         this.destroyIcon(param2);
         var _loc4_:String = "_rent";
         if(this.mDef.isACommerce())
         {
            _loc4_ = "_commerce";
         }
         switch(param1)
         {
            case ItemObject.ICON_RENT:
               if(Config.USE_BITMAP_DATA_ANIMATIONS)
               {
                  if(this.mDef.isACommerce())
                  {
                     this.mIcon = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainerCombined(_loc3_,"Event" + _loc4_,this.mDef.getCommerceIcon(),"icon"));
                     break;
                  }
                  this.mIcon = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainer(_loc3_,"Event" + _loc4_));
                  break;
               }
               this.mIcon = new (this.mLoader.getSWFClass(_loc3_,"Event" + _loc4_))();
               break;
            case ItemObject.ICON_RENT_COLLECT:
               if(Config.USE_BITMAP_DATA_ANIMATIONS)
               {
                  this.mIcon = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainer(_loc3_,"Event" + _loc4_ + "_ok"));
                  break;
               }
               this.mIcon = new (this.mLoader.getSWFClass(_loc3_,"Event" + _loc4_ + "_ok"))();
               break;
            case ItemObject.ICON_CONTRACT:
               if(Config.USE_BITMAP_DATA_ANIMATIONS)
               {
                  this.mIcon = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainer(_loc3_,"Event_contract"));
                  break;
               }
               this.mIcon = new (this.mLoader.getSWFClass(_loc3_,"Event_contract"))();
               break;
            case ItemObject.ICON_CONTRACT_COLLECT:
               if(Config.USE_BITMAP_DATA_ANIMATIONS)
               {
                  this.mIcon = new BitmapAnimation(BitmapDataFactory.getInstance().getAnimationContainer(_loc3_,"Event_contract_ok"));
                  break;
               }
               this.mIcon = new (this.mLoader.getSWFClass(_loc3_,"Event_contract_ok"))();
         }
         this.mIcon.gotoAndPlay(1);
         this.mIcon.x = this.mWorldX + (this.mDef.baseWidth >> 1);
         this.mIcon.y = this.mWorldY + (this.mDef.baseHeight >> 1);
         if(param2 != null)
         {
            this.mIcon.addEventListener(Event.ENTER_FRAME,param2);
         }
         this.mMap.addIntoLayerDialog(this.mIcon);
         return true;
      }
      
      public function get tileRelativeY() : int
      {
         return this.mTileRelativeY;
      }
   }
}

