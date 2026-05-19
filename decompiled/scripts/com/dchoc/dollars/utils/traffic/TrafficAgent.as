package com.dchoc.dollars.utils.traffic
{
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.utils.math.DChocMath;
   import com.dchoc.dollars.utils.math.Vector2D;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.CapsStyle;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.JointStyle;
   import flash.display.LineScaleMode;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class TrafficAgent extends MovieClip
   {
      
      private static var mCurrentIndex:int = 0;
      
      public static const STATE_NONE:int = 0;
      
      public static const STATE_MOVEMENT_START:int = 1;
      
      public static const STATE_MOVEMENT_RUNNING:int = 2;
      
      public static const STATE_MOVEMENT_TURNING:int = 3;
      
      public static const STATE_MOVEMENT_END:int = 4;
      
      public static const STATE_END:int = 5;
      
      public static const STATE_NEAR_CROSSING:int = 6;
      
      public static const STATE_WAITING:int = 7;
      
      public static const DIRECTION_NONE:int = -1;
      
      public static const DIRECTION_RIGHT:int = 0;
      
      public static const DIRECTION_UP:int = 1;
      
      public static const DIRECTION_LEFT:int = 2;
      
      public static const DIRECTION_DOWN:int = 3;
      
      private static const DIRECTION_COUNT:int = 4;
      
      public static const DIRECTION_COL_OFFSET:Array = [1,0,-1,0];
      
      public static const DIRECTION_ROW_OFFSET:Array = [0,-1,0,1];
      
      public static const DIRECTION_VECT_UNIT:Array = [new Vector2D(1,0),new Vector2D(0,-1),new Vector2D(-1,0),new Vector2D(0,1)];
      
      public static const BB_VECT_DIR:Array = [new Vector2D(1,1),new Vector2D(1,-1),new Vector2D(-1,1),new Vector2D(1,1)];
      
      private static const MAX_SPEED:Number = 90 / 1000;
      
      private static const MIN_SPEED:Number = 0;
      
      private static const MOVEMENT_EXPIRE_TIME_MS:int = 5 * 60000;
      
      private static const MOVEMENT_ALPHA_TIME_MS:int = 1000;
      
      private static const MOVEMENT_ALPHA_INCREASE:int = 0;
      
      private static const MOVEMENT_ALPHA_DECREASE:int = 1;
      
      private static const MOVEMENT_CIRCLE_OUTER_RADIUS:int = 22;
      
      private static const MOVEMENT_CIRCLE_INNER_RADIUS:int = 12;
      
      public static var SPAWN_DIRECTION:int = 0;
      
      public static var SPAWN_STATUS:int = 0;
      
      public static const SPAWN_DIRECTION_COUNT:int = 2;
      
      public static const SPAWN_STATUS_COUNT:int = 2;
      
      private static const VIEW_DO_POINT_CHECK:int = 0;
      
      private static const VIEW_DO_AREA_TILE:int = 1;
      
      private static const VIEW_DO_AREA_CAR_BOUND:int = 2;
      
      private static const VIEW_DO_POINT_TURN_CENTER:int = 3;
      
      private static const VIEW_DO_BOUNDING_BOX:int = 4;
      
      private static const VIEW_DO_COUNT:int = 5;
      
      private static const VIEW_DO_TYPE_POINT:int = 0;
      
      private static const VIEW_DO_TYPE_DRAW_RECT:int = 1;
      
      private static const VIEW_DO_TYPE_COUNT:int = 2;
      
      private static const VIEW_DO_TYPE:Array = [VIEW_DO_TYPE_POINT,VIEW_DO_TYPE_DRAW_RECT,VIEW_DO_TYPE_DRAW_RECT,VIEW_DO_TYPE_POINT,VIEW_DO_BOUNDING_BOX];
      
      private static const VIEW_DO_COLOR:Array = [14538496,16711680,16711680,65280,1044480];
      
      public static const TRAFFIC_RIGHT:int = 0;
      
      public static const TRAFFIC_AHEAD:int = 1;
      
      private static const STOP_TIMER:Number = 4000;
      
      private var curPos:Vector2D = new Vector2D();
      
      private var mEnabled:Boolean = false;
      
      private var mPrevPos:Vector2D = new Vector2D();
      
      private var currentPos:Vector2D = new Vector2D();
      
      private var mMovementRealCurrentDirection:Vector2D;
      
      private var mState:int;
      
      private var mMovementNextDirectionId:int;
      
      private var mWanderHeadingLength:int;
      
      private var mMovementCrossingPoint:Vector2D;
      
      private var mViewWidth:int;
      
      private var mMovementCurrentRotation:Number;
      
      private var bb:Vector2D = new Vector2D();
      
      private var waiting:Boolean = false;
      
      private var mTrafficTimer:Number;
      
      private var mDepth:int;
      
      public var mIndex:int;
      
      private var mMovementCurrentDirection:Vector2D;
      
      private var mVelocity:Number;
      
      private var mMovementAngleSpeedSign:int;
      
      private var mMovementDistanceToCrossing:Number;
      
      private var mViewHeight:int;
      
      public const COLLISION_DISTANCE:int = 60;
      
      private var mStoppedTimer:Number = 0;
      
      private var offset:Vector2D = new Vector2D();
      
      private var mMaxTrafficTimer:Number = 2000;
      
      private var mIndexColText:TextField;
      
      private var oldPos:Vector2D = new Vector2D();
      
      public var mMaxSpeed:Number;
      
      private var mMovementAlphaType:int;
      
      private var mViewCurrentAnimation:MovieClip;
      
      private var mCollisionPointLocal:Vector2D;
      
      private var mBoundingBox:Sprite;
      
      private var mAccelerationIncreaseModifier:Number = 0.0001;
      
      private var frontPoint:Vector2D = new Vector2D();
      
      private var mMovementPrevTileIndex:int;
      
      private var mViewHeading:Sprite;
      
      private var axisPos:Vector2D = new Vector2D();
      
      private var mMovementTurnCenterPos:Vector2D;
      
      private var mViewHeadingLine:Sprite;
      
      private var mCollisionPointWorld:Vector2D;
      
      private var mViewAngleOffByFrame:Number;
      
      private var mMovementCurrentDirectionId:int;
      
      private var mBoundingRadius:Number;
      
      private var mFrontCollisionPointLocal:Vector2D;
      
      private var mIndexText:TextField;
      
      private var mMovementCurrentAngle:Number;
      
      private var mTrafficAgentDefinition:TrafficAgentDefinition;
      
      private var mMovementTrafficRules:Boolean;
      
      private var mFrontCollisionPointWorld:Vector2D;
      
      private var mViewDOs:Array;
      
      private var mViewAsset:MovieClip;
      
      private var mMovementSpeed:Number;
      
      private var mMovementPreviousDirection:Vector2D;
      
      private var off:Vector2D = new Vector2D();
      
      private var mViewBody:Sprite;
      
      private var mAccelerationModifier:Number;
      
      private var mCollisionAgentList:Array;
      
      private var mMovementExpireTimer:int;
      
      private var mAcceleration:Number;
      
      private var mTrafficList:Array = new Array();
      
      private var vel:Vector2D = new Vector2D();
      
      private var mMovementPreviousDirectionId:int;
      
      public var mMovementCurrentTileIndex:int;
      
      private var mMap:Map;
      
      private var offAxis:Vector2D = new Vector2D();
      
      private var mFrontCollisionPointSprite:Sprite;
      
      private var mMovementAlphaTimer:int;
      
      private var mTag:Boolean;
      
      public var mCollisionPointSprite:Sprite;
      
      private var mViewFramesCount:int;
      
      private var mPaused:Boolean = false;
      
      public function TrafficAgent(param1:Map)
      {
         super();
         this.mMap = param1;
         this.mEnabled = false;
      }
      
      public static function decreaseAcceleration() : void
      {
      }
      
      public static function increaseAcceleration() : void
      {
      }
      
      public function addCollisionAgent(param1:TrafficAgent) : void
      {
         if(this.mCollisionAgentList)
         {
            this.mCollisionAgentList.push(param1);
         }
         else
         {
            this.mCollisionAgentList = new Array();
         }
      }
      
      public function getWidth() : int
      {
         return this.mViewWidth;
      }
      
      public function viewContainsPoint(param1:int, param2:int) : Boolean
      {
         return param1 >= x - this.mViewWidth / 2 && param1 <= x + this.mViewWidth / 2 && param2 >= y - this.mViewHeight / 2 && param2 <= y + this.mViewHeight / 2;
      }
      
      private function movementAdvanceTile() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = int(this.mMap.getTileIndexToTileX(this.mMovementCurrentTileIndex));
         var _loc2_:int = int(this.mMap.getTileIndexToTileY(this.mMovementCurrentTileIndex));
         _loc1_ += this.mMovementCurrentDirection.x;
         _loc2_ += this.mMovementCurrentDirection.y;
         this.mMovementCurrentTileIndex = this.mMap.getTileXYToTileIndex(_loc1_,_loc2_);
         var _loc3_:TileData = this.mMap.getTileData(_loc1_,_loc2_);
         if(_loc3_ != null && _loc3_.isPassable())
         {
            _loc4_ = this.wanderChooseDirection(this.mMovementCurrentTileIndex);
            this.movementSetTurnCenterPos(this.mMovementCurrentTileIndex,this.mMovementCurrentDirectionId,_loc4_);
         }
         else
         {
            this.stateChangeState(STATE_MOVEMENT_END);
         }
      }
      
      private function drawFrontCollisionPoint() : void
      {
         if(this.mFrontCollisionPointLocal)
         {
            if(this.mFrontCollisionPointSprite)
            {
               if(contains(this.mFrontCollisionPointSprite))
               {
                  removeChild(this.mFrontCollisionPointSprite);
               }
            }
            this.mFrontCollisionPointSprite = new Sprite();
            addChild(this.mFrontCollisionPointSprite);
            this.mFrontCollisionPointSprite.graphics.beginFill(61680);
            this.mFrontCollisionPointSprite.graphics.drawCircle(this.mFrontCollisionPointLocal.x,this.mFrontCollisionPointLocal.y,2);
            this.mFrontCollisionPointSprite.graphics.endFill();
            if(this.mBoundingBox)
            {
               if(contains(this.mBoundingBox))
               {
                  removeChild(this.mBoundingBox);
                  this.mBoundingBox = null;
               }
            }
            this.mBoundingBox = new Sprite();
            this.mFrontCollisionPointSprite.addChild(this.mBoundingBox);
            this.off.set(this.mMovementCurrentDirection.x * this.COLLISION_DISTANCE,this.mMovementCurrentDirection.y * this.COLLISION_DISTANCE);
            if(Math.abs(this.mMovementCurrentDirection.y) == 1)
            {
               this.bb.set(BB_VECT_DIR[this.mMovementCurrentDirectionId]).times(new Vector2D(this.mViewHeight,0));
            }
            else
            {
               this.bb.set(BB_VECT_DIR[this.mMovementCurrentDirectionId]).times(new Vector2D(0,this.mViewHeight));
            }
            this.off.plus(this.bb);
         }
      }
      
      public function getCollisionAgentList() : Array
      {
         return this.mCollisionAgentList;
      }
      
      private function checkEndOfRoad() : Boolean
      {
         var _loc1_:int = int(this.mMap.getTileIndexToTileX(this.mMovementCurrentTileIndex));
         var _loc2_:int = int(this.mMap.getTileIndexToTileY(this.mMovementCurrentTileIndex));
         var _loc3_:TileData = this.mMap.getTileData(_loc1_,_loc2_);
         if(_loc3_ != null && _loc3_.isPassable())
         {
            return false;
         }
         return true;
      }
      
      public function addTrafficAtCrossing(param1:TrafficAgent) : void
      {
         this.mTrafficList.push(param1);
      }
      
      public function unTag() : void
      {
         this.mTag = false;
      }
      
      private function cleanColText() : void
      {
         if(this.mIndexColText)
         {
            if(contains(this.mIndexColText))
            {
               removeChild(this.mIndexColText);
            }
         }
      }
      
      private function advanceTile() : void
      {
         var _loc1_:int = int(this.mMap.getTileIndexToTileX(this.mMovementCurrentTileIndex));
         var _loc2_:int = int(this.mMap.getTileIndexToTileY(this.mMovementCurrentTileIndex));
         _loc1_ += this.mMovementCurrentDirection.x;
         _loc2_ += this.mMovementCurrentDirection.y;
         this.mMovementCurrentTileIndex = this.mMap.getTileXYToTileIndex(_loc1_,_loc2_);
      }
      
      private function stateStart() : void
      {
         this.mState = STATE_NONE;
         this.stateChangeState(STATE_END);
      }
      
      public function getVelocity() : Number
      {
         return this.mVelocity;
      }
      
      public function getPreviousDirectionId() : int
      {
         return this.mMovementPreviousDirectionId;
      }
      
      public function movementGetCurrentDirection() : Vector2D
      {
         var _loc1_:Vector2D = null;
         if(this.mMovementNextDirectionId == -1)
         {
            return this.mMovementCurrentDirection;
         }
         return new Vector2D(this.mMovementCurrentDirection).plus(DIRECTION_VECT_UNIT[this.mMovementNextDirectionId]).normalize();
      }
      
      public function start(param1:Boolean = false) : void
      {
         this.mEnabled = true;
         this.mPaused = param1;
         this.mDepth = 0;
         this.mMap.mItemObjectsLayerCars[0].addChild(this);
         this.stateStart();
         this.movementStart();
      }
      
      public function getCollisionPoint() : Vector2D
      {
         return this.mCollisionPointWorld;
      }
      
      public function setup(param1:TrafficAgentDefinition) : void
      {
         this.mTrafficAgentDefinition = param1;
         this.mVelocity = 0;
         this.mMaxSpeed = this.mTrafficAgentDefinition.speed / 1000;
         this.mAccelerationModifier = 0.0001;
         this.mAcceleration = this.mAccelerationModifier;
         this.mIndex = mCurrentIndex++;
         this.mViewWidth = this.mTrafficAgentDefinition.width;
         this.mViewHeight = this.mTrafficAgentDefinition.heigh;
         this.mBoundingRadius = this.mViewWidth / 2;
         this.load();
      }
      
      private function checkCarStopped(param1:Number) : void
      {
         this.curPos.set(x,y);
         if(this.curPos.isEqualTo(this.mPrevPos))
         {
            this.mStoppedTimer += param1;
            if(this.mStoppedTimer >= STOP_TIMER)
            {
               this.stateChangeState(STATE_MOVEMENT_END);
            }
         }
         else
         {
            this.mStoppedTimer = 0;
         }
      }
      
      private function enforceNonPenetrationConstant(param1:Vector2D) : Vector2D
      {
         var _loc5_:TrafficAgent = null;
         var _loc6_:TrafficAgent = null;
         var _loc7_:Vector2D = null;
         var _loc8_:Vector2D = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc2_:Vector2D = param1;
         var _loc3_:Array = TrafficAgentManager.getInstance().getTrafficAgentList();
         var _loc4_:int = int(_loc3_.length);
         if(_loc4_ > 0)
         {
            for each(_loc5_ in _loc3_)
            {
               _loc6_ = _loc5_;
               if(_loc6_.mIndex != this.mIndex)
               {
                  _loc7_ = new Vector2D(_loc6_.x,_loc6_.y);
                  _loc8_ = new Vector2D(_loc7_).minus(new Vector2D(param1));
                  trace("Tile index current car " + this.mIndex + ": " + this.mMovementCurrentTileIndex);
                  trace("Tile index observed car " + _loc6_.mIndex + ": " + _loc6_.mMovementCurrentTileIndex);
                  _loc9_ = _loc8_.magnitude;
                  _loc10_ = this.mBoundingRadius + _loc6_.getBRadius() - _loc9_;
                  if(_loc10_ >= 0)
                  {
                     _loc2_ = new Vector2D(new Vector2D(param1.x,param1.y).plus(new Vector2D(_loc8_).times(1 / _loc9_).times(_loc10_)));
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function setCollisionPoint(param1:Vector2D) : void
      {
         this.mCollisionPointWorld = param1;
      }
      
      private function stateEnd() : void
      {
         this.stateChangeState(STATE_END);
      }
      
      private function wanderDestroy() : void
      {
      }
      
      private function drawText() : void
      {
         if(!this.mIndexText)
         {
            this.mIndexText = new TextField();
         }
         if(contains(this.mIndexText))
         {
            removeChild(this.mIndexText);
         }
         this.mIndexText.textColor = 16711680;
         this.mIndexText.text = this.mIndex.toString();
         addChild(this.mIndexText);
      }
      
      public function removeCollisionAgent(param1:TrafficAgent) : void
      {
         if(this.mCollisionAgentList)
         {
            if(this.mCollisionAgentList.indexOf(param1) > -1)
            {
               this.mCollisionAgentList.splice(this.mCollisionAgentList.indexOf(param1),1);
            }
         }
      }
      
      private function advanceTurnCenterPoint() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = int(this.mMap.getTileIndexToTileX(this.mMovementCurrentTileIndex));
         var _loc2_:int = int(this.mMap.getTileIndexToTileY(this.mMovementCurrentTileIndex));
         var _loc3_:TileData = this.mMap.getTileData(_loc1_,_loc2_);
         if(_loc3_ != null && _loc3_.isPassable())
         {
            _loc4_ = this.wanderChooseDirection(this.mMovementCurrentTileIndex);
            this.movementSetTurnCenterPos(this.mMovementCurrentTileIndex,this.mMovementCurrentDirectionId,_loc4_);
         }
         else
         {
            this.stateChangeState(STATE_MOVEMENT_END);
         }
      }
      
      private function viewDOSetPos(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:DisplayObject = this.viewDOGet(param1);
         _loc4_.x = param2;
         _loc4_.y = param3;
      }
      
      public function setPause() : void
      {
         this.mPaused = true;
      }
      
      public function isEnabled() : Boolean
      {
         return this.mEnabled;
      }
      
      private function viewStart() : void
      {
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            this.mViewBody.visible = true;
            this.viewDOGet(VIEW_DO_POINT_CHECK).visible = true;
         }
         if(this.mViewCurrentAnimation != null)
         {
            this.mViewCurrentAnimation.visible = true;
         }
      }
      
      private function movementStartMovement(param1:int, param2:int) : void
      {
         this.mMovementCurrentTileIndex = param1;
         this.movementSetCurrentDirection(param2);
         this.movementSetTurnCenterPos(param1,this.mMovementCurrentDirectionId,this.mMovementCurrentDirectionId);
         var _loc3_:int = int(this.mMap.getTileIndexToTileX(param1));
         var _loc4_:int = int(this.mMap.getTileIndexToTileY(param1));
         var _loc5_:int = this.mMap.getTileXToWorld(_loc3_);
         var _loc6_:int = this.mMap.getTileYToWorld(_loc4_);
         var _loc7_:int = param2 == DIRECTION_DOWN || param2 == DIRECTION_RIGHT ? MOVEMENT_CIRCLE_INNER_RADIUS : MOVEMENT_CIRCLE_OUTER_RADIUS;
         if(this.movementIsHorizontal(param2))
         {
            x = _loc5_ + (this.mMap.tileWidth >> 1);
            y = _loc6_ + (this.mMap.tileHeight - _loc7_);
         }
         else
         {
            x = _loc5_ + _loc7_;
            y = _loc6_ + (this.mMap.tileHeight >> 1);
         }
         this.stateChangeState(STATE_MOVEMENT_START);
      }
      
      private function wanderCheckTrafficOut() : void
      {
         var _loc5_:Array = null;
         var _loc1_:int = int(this.mMap.getTileIndexToTileX(this.mMovementCurrentTileIndex));
         var _loc2_:int = int(this.mMap.getTileIndexToTileY(this.mMovementCurrentTileIndex));
         _loc1_ += this.mMovementCurrentDirection.x;
         _loc2_ += this.mMovementCurrentDirection.y;
         var _loc3_:int = this.mMap.getTileXYToTileIndex(_loc1_,_loc2_);
         var _loc4_:TileData = this.mMap.getTileData(_loc1_,_loc2_);
         if(_loc3_ == this.mMovementPrevTileIndex)
         {
            this.mMovementTrafficRules = false;
         }
         else if(_loc4_ != null && _loc4_.isPassable())
         {
            _loc5_ = this.getPossibleDirections(_loc3_);
            if(_loc5_.length >= 2)
            {
               this.mMovementPrevTileIndex = _loc3_;
               this.mMovementTrafficRules = true;
            }
            else
            {
               this.mMovementTrafficRules = false;
            }
         }
         else
         {
            this.mMovementTrafficRules = false;
         }
      }
      
      public function getFrontCollisionPoint() : Vector2D
      {
         return this.mFrontCollisionPointWorld;
      }
      
      public function wanderChooseDirection(param1:int, param2:int = -1) : int
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:TileData = null;
         var _loc13_:Boolean = false;
         var _loc3_:TileData = this.mMap.getTileDataFromIndex(param1);
         var _loc4_:int = DIRECTION_NONE;
         var _loc5_:Boolean = _loc3_ != null && _loc3_.isPassable();
         if(_loc5_)
         {
            _loc6_ = new Array();
            _loc7_ = int(this.mMap.getTileIndexToTileX(param1));
            _loc8_ = int(this.mMap.getTileIndexToTileY(param1));
            _loc9_ = 0;
            while(_loc9_ < DIRECTION_COUNT)
            {
               _loc10_ = _loc7_ + DIRECTION_COL_OFFSET[_loc9_];
               _loc11_ = _loc8_ + DIRECTION_ROW_OFFSET[_loc9_];
               _loc12_ = this.mMap.getTileData(_loc10_,_loc11_);
               _loc13_ = true;
               if(_loc12_ != null && this.mMovementCurrentDirectionId != DIRECTION_NONE)
               {
                  if(_loc9_ != this.mMovementCurrentDirectionId && (_loc9_ % 2 == this.mMovementCurrentDirectionId % 2 || this.mMap.mapData[_loc12_.tileIndex] == 65 && this.mMap.mapData[param1] == 67 || this.mMap.mapData[_loc12_.tileIndex] == 67 && this.mMap.mapData[param1] == 65 || this.mMap.mapData[_loc12_.tileIndex] == 63 && this.mMap.mapData[param1] == 69 || this.mMap.mapData[_loc12_.tileIndex] == 69 && this.mMap.mapData[param1] == 63))
                  {
                     _loc13_ = false;
                  }
               }
               if(_loc13_ && _loc12_ != null && _loc12_.isPassable())
               {
                  _loc6_.push(_loc9_);
               }
               _loc9_++;
            }
            if(_loc6_.length > 0)
            {
               if(param2 == -1)
               {
                  param2 = Math.random() * _loc6_.length;
               }
               _loc4_ = int(_loc6_[param2]);
            }
            else
            {
               _loc5_ = false;
            }
         }
         if(_loc5_ && this.mMovementCurrentDirectionId == DIRECTION_NONE)
         {
            this.movementStartMovement(param1,_loc4_);
         }
         return _loc4_;
      }
      
      public function end() : void
      {
         if(this.mDepth != -1)
         {
            if(this.mMap.mItemObjectsLayerCars[this.mDepth].contains(this))
            {
               this.mMap.mItemObjectsLayerCars[this.mDepth].removeChild(this);
            }
         }
         this.stateEnd();
         this.movementEnd();
      }
      
      public function getState() : int
      {
         return this.mState;
      }
      
      public function unsetWaiting() : void
      {
         this.waiting = false;
      }
      
      private function drawColText(param1:int) : void
      {
         if(!this.mIndexColText)
         {
            if(Config.CHEAT_TRAFFIC_AGENT)
            {
               this.mIndexColText = new TextField();
            }
         }
         if(contains(this.mIndexColText))
         {
            removeChild(this.mIndexColText);
         }
         this.mIndexColText.textColor = 65280;
         this.mIndexColText.text = param1.toString();
         this.mIndexColText.x = 7;
         addChild(this.mIndexColText);
      }
      
      private function movementGetAngle(param1:Vector2D) : Number
      {
         var _loc2_:Number = param1.angle;
         if(_loc2_ == 90 || _loc2_ == -90)
         {
            _loc2_ *= -1;
         }
         if(_loc2_ == -90)
         {
            _loc2_ = 270;
         }
         return _loc2_;
      }
      
      public function load() : void
      {
         this.wanderLoad();
         this.viewLoad();
      }
      
      public function movementGetPreviousDirection() : Vector2D
      {
         return this.mMovementPreviousDirection;
      }
      
      private function movementStart() : void
      {
         this.mMovementCurrentDirectionId = DIRECTION_NONE;
         this.mMovementNextDirectionId = DIRECTION_NONE;
         this.mMovementSpeed = this.mTrafficAgentDefinition.speed / 1000;
      }
      
      private function viewDrawRect(param1:Sprite, param2:int, param3:int, param4:Boolean = false, param5:uint = 16711680) : void
      {
         var _loc6_:Graphics = param1.graphics;
         _loc6_.lineStyle(1,param5,1,false,LineScaleMode.VERTICAL,CapsStyle.NONE,JointStyle.MITER,10);
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param4)
         {
            _loc7_ -= param2 >> 1;
            _loc8_ -= param3 >> 1;
         }
         _loc6_.drawRect(_loc7_,_loc8_,param2,param3);
      }
      
      private function getPossibleDirections(param1:int) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:TileData = null;
         var _loc9_:Boolean = false;
         var _loc2_:Array = new Array();
         var _loc3_:int = int(this.mMap.getTileIndexToTileX(param1));
         var _loc4_:int = int(this.mMap.getTileIndexToTileY(param1));
         var _loc5_:int = 0;
         while(_loc5_ < DIRECTION_COUNT)
         {
            _loc6_ = _loc3_ + DIRECTION_COL_OFFSET[_loc5_];
            _loc7_ = _loc4_ + DIRECTION_ROW_OFFSET[_loc5_];
            _loc8_ = this.mMap.getTileData(_loc6_,_loc7_);
            _loc9_ = true;
            if(_loc8_ != null && this.mMovementCurrentDirectionId != DIRECTION_NONE)
            {
               if(_loc5_ != this.mMovementCurrentDirectionId && (_loc5_ % 2 == this.mMovementCurrentDirectionId % 2 || this.mMap.mapData[_loc8_.tileIndex] == 65 && this.mMap.mapData[param1] == 67 || this.mMap.mapData[_loc8_.tileIndex] == 67 && this.mMap.mapData[param1] == 65 || this.mMap.mapData[_loc8_.tileIndex] == 63 && this.mMap.mapData[param1] == 69 || this.mMap.mapData[_loc8_.tileIndex] == 69 && this.mMap.mapData[param1] == 63))
               {
                  _loc9_ = false;
               }
            }
            if(_loc9_ && _loc8_ != null && _loc8_.isPassable())
            {
               _loc2_.push(_loc5_);
            }
            _loc5_++;
         }
         return _loc2_;
      }
      
      private function movementGetTurnSign(param1:Vector2D, param2:Vector2D) : int
      {
         var _loc3_:int = 1;
         if(param1.y * param2.x < param2.y * param1.x)
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }
      
      private function viewLoad() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Graphics = null;
         var _loc5_:int = 0;
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            _loc2_ = -this.mViewWidth >> 1;
            _loc3_ = -this.mViewHeight >> 1;
            this.mViewBody = new Sprite();
            _loc4_ = this.mViewBody.graphics;
            _loc4_.beginFill(16711680);
            _loc4_.drawRect(_loc2_,_loc3_,this.mViewWidth,this.mViewHeight);
            _loc4_.endFill();
            this.mViewHeading = new Sprite();
            _loc4_ = this.mViewHeading.graphics;
            _loc4_.beginFill(0);
            _loc4_.drawRect(_loc2_ + this.mViewWidth - 5,_loc3_,5,this.mViewHeight);
            _loc4_.endFill();
            this.mViewBody.addChild(this.mViewHeading);
            this.mViewHeadingLine = new Sprite();
            _loc4_ = this.mViewHeading.graphics;
            _loc4_.lineStyle(1,16766720,1,false,LineScaleMode.VERTICAL,CapsStyle.NONE,JointStyle.MITER,10);
            _loc4_.moveTo(0,0);
            _loc4_.lineTo(this.mWanderHeadingLength,0);
            this.mViewBody.addChild(this.mViewHeadingLine);
            addChild(this.mViewBody);
            this.mViewDOs = new Array(VIEW_DO_COUNT);
            _loc5_ = 0;
            while(_loc5_ < VIEW_DO_COUNT)
            {
               this.mViewDOs[_loc5_] = new Sprite();
               this.mMap.mItemObjectsLayerCars[0].addChild(this.mViewDOs[_loc5_]);
               this.viewDODraw(_loc5_);
               _loc5_++;
            }
         }
         this.mDepth = -1;
         var _loc1_:Class = DCResourceManager.getInstance().getSWFClass(this.mTrafficAgentDefinition.sku,"car_new");
         if(_loc1_ == null)
         {
            _loc1_ = DCResourceManager.getInstance().getSWFClass(this.mTrafficAgentDefinition.sku,"car");
         }
         this.mViewCurrentAnimation = new _loc1_() as MovieClip;
         this.mViewFramesCount = this.mViewCurrentAnimation.totalFrames;
         this.mViewAngleOffByFrame = 360 / this.mViewFramesCount;
         addChild(this.mViewCurrentAnimation);
      }
      
      public function setResume() : void
      {
         this.mPaused = false;
      }
      
      private function wanderLoad() : void
      {
         this.mWanderHeadingLength = this.mMap.tileWidth >> 1;
      }
      
      public function isTagged() : Boolean
      {
         return this.mTag;
      }
      
      private function printCollisionList() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.mCollisionAgentList.length)
         {
            _loc1_ = _loc1_ + ", " + (this.mCollisionAgentList[_loc2_] as TrafficAgent).mIndex;
            _loc2_++;
         }
         trace("Agent " + this.mIndex + " collides with Agents: " + _loc1_);
      }
      
      private function movementIsHorizontal(param1:int) : Boolean
      {
         return DIRECTION_COL_OFFSET[param1] != 0;
      }
      
      private function viewDOGet(param1:int) : Sprite
      {
         return this.mViewDOs[param1];
      }
      
      private function movementGetCircleRadius(param1:int, param2:int) : int
      {
         var _loc3_:int = MOVEMENT_CIRCLE_OUTER_RADIUS;
         if(param2 == -1)
         {
            if(param1 == DIRECTION_DOWN || param1 == DIRECTION_RIGHT)
            {
               _loc3_ = MOVEMENT_CIRCLE_INNER_RADIUS;
            }
         }
         else if(param1 == DIRECTION_LEFT && param2 == DIRECTION_UP || param1 == DIRECTION_UP && param2 == DIRECTION_RIGHT || param1 == DIRECTION_RIGHT && param2 == DIRECTION_DOWN || param1 == DIRECTION_DOWN && param2 == DIRECTION_LEFT)
         {
            _loc3_ = MOVEMENT_CIRCLE_INNER_RADIUS;
         }
         return _loc3_;
      }
      
      public function setTrafficAhead(param1:TrafficAgent) : void
      {
         this.mTrafficList[TRAFFIC_AHEAD] = param1;
      }
      
      private function movementSetTurnCenterPos(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Vector2D = DIRECTION_VECT_UNIT[param2];
         var _loc5_:Vector2D = new Vector2D(0,0);
         var _loc6_:Vector2D = new Vector2D(_loc4_);
         if(param3 != DIRECTION_NONE && param3 != param2)
         {
            this.mMovementNextDirectionId = param3;
            _loc5_ = DIRECTION_VECT_UNIT[param3];
            this.stateChangeState(STATE_MOVEMENT_TURNING);
            _loc6_.times(-1);
            _loc6_.plus(_loc5_);
         }
         var _loc7_:Vector2D = new Vector2D(_loc6_);
         _loc7_.times(this.mMap.tileWidth >> 1);
         var _loc8_:Vector2D = this.mMap.getTileIndexToWorldCenterPos(param1);
         this.mMovementTurnCenterPos = _loc8_.plus(_loc7_);
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            this.viewDOSetPos(VIEW_DO_POINT_TURN_CENTER,this.mMovementTurnCenterPos.x,this.mMovementTurnCenterPos.y);
            this.viewDOSetPos(VIEW_DO_AREA_TILE,this.mMovementTurnCenterPos.x,this.mMovementTurnCenterPos.y);
         }
      }
      
      private function viewDODraw(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc2_:Sprite = this.viewDOGet(param1);
         var _loc3_:uint = uint(VIEW_DO_COLOR[param1]);
         switch(VIEW_DO_TYPE[param1])
         {
            case VIEW_DO_TYPE_POINT:
               this.viewDrawPoint(_loc2_,_loc3_);
               break;
            case VIEW_DO_TYPE_DRAW_RECT:
               _loc4_ = int(this.mMap.tileWidth);
               _loc5_ = int(this.mMap.tileHeight);
               _loc6_ = false;
               if(param1 == VIEW_DO_AREA_CAR_BOUND)
               {
                  _loc4_ = this.mViewWidth;
                  _loc5_ = this.mViewHeight;
               }
               else
               {
                  _loc4_ = int(this.mMap.tileWidth);
                  _loc5_ = int(this.mMap.tileHeight);
               }
               this.viewDrawRect(_loc2_,_loc4_,_loc5_,_loc6_,_loc3_);
               break;
            case VIEW_DO_BOUNDING_BOX:
               _loc4_ = this.mViewWidth;
               _loc5_ = this.mViewHeight + 50;
               this.viewDrawRect(_loc2_,-this.mViewWidth >> 1,_loc5_,true,_loc3_);
         }
      }
      
      private function movementSetCurrentDirection(param1:int) : void
      {
         this.mMovementPreviousDirectionId = this.mMovementCurrentDirectionId;
         this.mMovementPreviousDirection = this.mMovementCurrentDirection;
         this.mMovementCurrentDirectionId = param1;
         this.mMovementCurrentDirection = DIRECTION_VECT_UNIT[param1];
         this.movementSetRotation(this.mMovementCurrentDirection.angle);
         var _loc2_:int = this.mDepth;
         this.mDepth = param1 == DIRECTION_RIGHT ? 1 : 0;
         if(_loc2_ != -1 && this.mDepth != _loc2_)
         {
            this.mMap.mItemObjectsLayerCars[_loc2_].removeChild(this);
            this.mMap.mItemObjectsLayerCars[this.mDepth].addChild(this);
         }
      }
      
      public function getBRadius() : Number
      {
         return this.mBoundingRadius;
      }
      
      private function stateChangeState(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Vector2D = null;
         var _loc4_:Vector2D = null;
         var _loc5_:Vector2D = null;
         var _loc6_:Vector2D = null;
         var _loc7_:Vector2D = null;
         var _loc8_:Number = NaN;
         if(this.mState != param1)
         {
            this.mState = param1;
            switch(this.mState)
            {
               case STATE_END:
                  this.viewEnd();
                  this.movementEnd();
                  break;
               case STATE_MOVEMENT_START:
                  this.viewStart();
                  this.mMovementAlphaTimer = MOVEMENT_ALPHA_TIME_MS;
                  this.mMovementAlphaType = MOVEMENT_ALPHA_INCREASE;
                  this.mMovementExpireTimer = TrafficAgentManagerDefinition.getInstance().agentExpireTime;
                  if(Config.CHEAT_TRAFFIC_AGENT)
                  {
                     this.viewDOSetPos(VIEW_DO_AREA_CAR_BOUND,x - this.mViewWidth / 2,y - this.mViewHeight / 2);
                  }
                  this.stateChangeState(STATE_MOVEMENT_RUNNING);
                  break;
               case STATE_MOVEMENT_TURNING:
                  _loc2_ = this.movementGetCurrentCircleRadius();
                  _loc3_ = new Vector2D(DIRECTION_VECT_UNIT[this.mMovementNextDirectionId]);
                  _loc3_.times(-_loc2_);
                  _loc4_ = new Vector2D(this.mMovementCurrentDirection);
                  _loc4_.times(_loc2_);
                  this.mMovementAngleSpeedSign = this.movementGetTurnSign(_loc3_,_loc4_);
                  this.mMovementCurrentRotation = this.mMovementCurrentDirection.angle;
                  this.mMovementCurrentAngle = 0;
                  break;
               case STATE_MOVEMENT_END:
                  this.mMovementAlphaTimer = MOVEMENT_ALPHA_TIME_MS;
                  this.mMovementAlphaType = MOVEMENT_ALPHA_DECREASE;
                  break;
               case STATE_NEAR_CROSSING:
                  _loc5_ = new Vector2D(this.mMap.getTileIndexToWorldX(this.mMovementPrevTileIndex),this.mMap.getTileIndexToWorldY(this.mMovementPrevTileIndex));
                  _loc6_ = new Vector2D(_loc5_.x + this.mMap.tileWidth / 2,_loc5_.y + this.mMap.tileWidth / 2);
                  _loc7_ = new Vector2D(_loc6_).plus(new Vector2D(this.mMovementCurrentDirection).invert().times(this.mMap.tileWidth / 2));
                  _loc8_ = new Vector2D(_loc7_).minus(new Vector2D(x,y).plus(new Vector2D(this.mMovementCurrentDirection).times(this.mViewWidth / 2))).magnitude;
                  this.mMovementDistanceToCrossing = _loc8_;
                  this.mMovementCrossingPoint = new Vector2D(x,y).plus(new Vector2D(this.mMovementCurrentDirection).times(this.mMovementDistanceToCrossing));
                  break;
               case STATE_WAITING:
                  this.mTrafficTimer = this.mMaxTrafficTimer;
            }
         }
      }
      
      private function viewDrawPoint(param1:Sprite, param2:uint = 16711680) : void
      {
         var _loc3_:Graphics = param1.graphics;
         _loc3_.lineStyle(1,param2,1,false,LineScaleMode.VERTICAL,CapsStyle.NONE,JointStyle.MITER,10);
         _loc3_.moveTo(-2,0);
         _loc3_.lineTo(2,0);
         _loc3_.moveTo(0,-2);
         _loc3_.lineTo(0,2);
      }
      
      public function setWaiting() : void
      {
         this.waiting = true;
      }
      
      private function viewDestroy() : void
      {
         var _loc1_:Sprite = null;
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            removeChild(this.mViewBody);
            this.mViewBody = null;
            this.mViewHeading = null;
            this.mViewHeadingLine = null;
            if(this.mViewDOs != null)
            {
               for each(_loc1_ in this.mViewDOs)
               {
                  this.mMap.mItemObjectsLayerCars[0].removeChild(_loc1_);
               }
               this.mViewDOs = null;
            }
         }
         if(Boolean(this.mViewCurrentAnimation) && contains(this.mViewCurrentAnimation))
         {
            removeChild(this.mViewCurrentAnimation);
            this.mViewCurrentAnimation = null;
         }
      }
      
      public function tag() : void
      {
         this.mTag = true;
      }
      
      private function movementEnd() : void
      {
         this.movementStart();
      }
      
      public function wanderStart(param1:int, param2:int = -1) : void
      {
         this.stateChangeState(STATE_END);
         this.wanderChooseDirection(param1,param2);
      }
      
      public function getCurrentDirectionId() : int
      {
         return this.mMovementCurrentDirectionId;
      }
      
      private function clearTrafficList() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.mTrafficList.length)
         {
            this.mTrafficList.splice(_loc1_,1);
            _loc1_++;
         }
      }
      
      public function isWaiting() : Boolean
      {
         return this.waiting;
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Vector2D = null;
         var _loc10_:Vector2D = null;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:int = 0;
         var _loc21_:TrafficAgent = null;
         if(!this.mPaused)
         {
            if(this.mMovementAlphaTimer > 0)
            {
               this.mMovementAlphaTimer -= param1;
               if(this.mMovementAlphaTimer < 0)
               {
                  this.mMovementAlphaTimer = 0;
               }
               if(this.mMovementAlphaType == MOVEMENT_ALPHA_DECREASE)
               {
                  alpha = this.mMovementAlphaTimer / MOVEMENT_ALPHA_TIME_MS;
               }
               else
               {
                  alpha = 1 - this.mMovementAlphaTimer / MOVEMENT_ALPHA_TIME_MS;
               }
            }
            switch(this.mState)
            {
               case STATE_MOVEMENT_END:
                  if(this.mMovementAlphaTimer <= 0)
                  {
                     this.stateChangeState(STATE_END);
                     TrafficAgentManager.getInstance().removeAgent(this);
                  }
                  break;
               case STATE_MOVEMENT_RUNNING:
                  if(this.mMovementExpireTimer > 0)
                  {
                     this.mMovementExpireTimer -= param1;
                     if(this.mMovementExpireTimer <= 0)
                     {
                        this.stateChangeState(STATE_MOVEMENT_END);
                     }
                  }
                  if(this.mMovementExpireTimer > 0)
                  {
                     if(!this.checkEndOfRoad())
                     {
                        this.checkCarStopped(param1);
                        this.wanderCheckTrafficOut();
                        if(this.mMovementTrafficRules)
                        {
                           this.stateChangeState(STATE_NEAR_CROSSING);
                        }
                        _loc2_ = TrafficAgentManager.getInstance().avoidObstacles(this);
                        _loc3_ = _loc2_.isColliding as Boolean;
                        _loc9_ = _loc2_.carDir as Vector2D;
                        _loc10_ = _loc2_.colPoint as Vector2D;
                        if(Config.CHEAT_TRAFFIC_AGENT)
                        {
                           this.drawText();
                        }
                        if(_loc3_)
                        {
                           if(Config.CHEAT_TRAFFIC_AGENT)
                           {
                              this.drawColText(_loc2_.index);
                           }
                           if(Boolean(_loc2_.turning) || Boolean(_loc2_.crossing))
                           {
                              this.mMaxSpeed = _loc2_.v as Number;
                           }
                           else
                           {
                              _loc4_ = _loc2_.v as Number;
                              _loc5_ = _loc2_.d as Number;
                              if(this.COLLISION_DISTANCE - (this.COLLISION_DISTANCE - _loc5_) <= 2.5 * this.mViewWidth)
                              {
                                 this.mMaxSpeed = _loc4_;
                              }
                              else
                              {
                                 _loc6_ = (_loc5_ - 2.5 * this.mViewWidth) * 100 / (this.COLLISION_DISTANCE - 2.5 * this.mViewWidth) / 100;
                                 if(_loc6_ * 100 >= 0 && _loc6_ * 100 <= 5)
                                 {
                                    this.mMaxSpeed = _loc4_;
                                 }
                                 else
                                 {
                                    this.mMaxSpeed = _loc4_ + (this.mTrafficAgentDefinition.speed / 1000 - _loc4_) * _loc6_;
                                 }
                              }
                           }
                        }
                        else
                        {
                           if(Config.CHEAT_TRAFFIC_AGENT)
                           {
                              this.cleanColText();
                           }
                           this.mMaxSpeed = this.mTrafficAgentDefinition.speed / 1000;
                        }
                        this.mMaxSpeed = Math.min(this.mMaxSpeed,this.mTrafficAgentDefinition.speed / 1000);
                        this.mVelocity += this.mAcceleration * param1;
                        this.mVelocity = Math.min(this.mMaxSpeed,this.mVelocity);
                        this.mVelocity = Math.max(MIN_SPEED,this.mVelocity);
                        this.offset.set(this.mMovementCurrentDirection.x * (this.mMovementSpeed * param1),this.mMovementCurrentDirection.x * (this.mMovementSpeed * param1));
                        this.oldPos.set(x - this.mMovementTurnCenterPos.x,y - this.mMovementTurnCenterPos.y);
                        this.oldPos.project(this.mMovementCurrentDirection);
                        this.vel.set(this.mMovementCurrentDirection.x * this.mVelocity,this.mMovementCurrentDirection.y * this.mVelocity);
                        this.curPos.set(x + this.vel.x * param1,y + this.vel.y * param1);
                        this.mPrevPos.set(x,y);
                        x = this.curPos.x;
                        y = this.curPos.y;
                        this.currentPos.set(x - this.mMovementTurnCenterPos.x,y - this.mMovementTurnCenterPos.y);
                        this.currentPos.project(this.mMovementCurrentDirection);
                        _loc7_ = this.currentPos.dot(this.oldPos);
                        this.frontPoint.set(x + this.mMovementCurrentDirection.x * (this.mViewWidth / 2),y + this.mMovementCurrentDirection.y * (this.mViewWidth / 2));
                        _loc8_ = this.mMap.getWorldToTileIndex(x,y,0);
                        if(_loc8_ != this.mMovementCurrentTileIndex)
                        {
                           this.advanceTile();
                        }
                        if(_loc7_ <= 0)
                        {
                           this.advanceTurnCenterPoint();
                        }
                        break;
                     }
                     this.stateChangeState(STATE_MOVEMENT_END);
                     break;
                  }
                  this.stateChangeState(STATE_MOVEMENT_END);
                  break;
               case STATE_MOVEMENT_TURNING:
                  if(!this.checkEndOfRoad())
                  {
                     this.checkCarStopped(param1);
                     this.mMovementRealCurrentDirection = this.getRealDirection();
                     _loc2_ = TrafficAgentManager.getInstance().avoidObstacles(this);
                     _loc3_ = _loc2_.isColliding as Boolean;
                     if(Config.CHEAT_TRAFFIC_AGENT)
                     {
                        this.drawText();
                     }
                     if(_loc3_)
                     {
                        if(Config.CHEAT_TRAFFIC_AGENT)
                        {
                           this.drawColText(_loc2_.index);
                        }
                        _loc4_ = _loc2_.v as Number;
                        _loc5_ = _loc2_.d as Number;
                        _loc6_ = _loc5_ * 100 / this.COLLISION_DISTANCE / 100;
                        this.mVelocity = _loc4_;
                        this.mMaxSpeed = _loc4_;
                     }
                     else if(Config.CHEAT_TRAFFIC_AGENT)
                     {
                        this.cleanColText();
                     }
                     this.axisPos.set(0,0);
                     this.offAxis.set(DIRECTION_VECT_UNIT[this.mMovementNextDirectionId]);
                     this.offAxis.times(-1);
                     this.axisPos.plus(this.offAxis);
                     _loc11_ = this.movementGetAngle(this.axisPos);
                     _loc12_ = this.movementGetCurrentCircleRadius();
                     _loc13_ = DChocMath.degree2Rad(_loc11_);
                     _loc14_ = this.mVelocity / _loc12_ * this.mMovementAngleSpeedSign;
                     _loc15_ = _loc14_ * param1;
                     this.mMovementCurrentAngle += _loc15_;
                     _loc13_ += this.mMovementCurrentAngle;
                     this.off.set(Math.cos(_loc13_),-Math.sin(_loc13_));
                     this.off.times(_loc12_);
                     _loc16_ = DChocMath.rad2Degree(_loc13_);
                     _loc16_ = _loc16_ % 360;
                     this.mPrevPos = new Vector2D(x,y);
                     x = this.off.x + this.mMovementTurnCenterPos.x;
                     y = this.off.y + this.mMovementTurnCenterPos.y;
                     this.mMovementCurrentRotation -= DChocMath.rad2Degree(_loc15_);
                     _loc17_ = this.mMovementCurrentRotation;
                     if(this.mViewFramesCount > 0)
                     {
                        _loc19_ = this.mViewAngleOffByFrame / 4;
                        _loc20_ = _loc17_ / _loc19_;
                        _loc17_ = _loc20_ * _loc19_;
                     }
                     this.movementSetRotation(_loc17_);
                     _loc18_ = Math.abs(DChocMath.rad2Degree(this.mMovementCurrentAngle));
                     if(Math.abs(DChocMath.rad2Degree(this.mMovementCurrentAngle)) >= 90)
                     {
                        this.movementSetCurrentDirection(this.mMovementNextDirectionId);
                        this.mMovementNextDirectionId = DIRECTION_NONE;
                        this.stateChangeState(STATE_MOVEMENT_RUNNING);
                        this.movementAdvanceTile();
                     }
                     break;
                  }
                  this.stateChangeState(STATE_MOVEMENT_END);
                  break;
               case STATE_NEAR_CROSSING:
                  if(this.mVelocity == 0)
                  {
                     this.clearTrafficList();
                     TrafficAgentManager.getInstance().checkTrafficCollisions(this);
                     if(this.mTrafficList)
                     {
                        if(this.mTrafficList.length > 0)
                        {
                           for each(_loc21_ in this.mTrafficList)
                           {
                              if(!_loc21_.isWaiting())
                              {
                                 this.setWaiting();
                                 this.stateChangeState(STATE_WAITING);
                              }
                           }
                           if(this.mState == STATE_NEAR_CROSSING)
                           {
                              _loc2_ = TrafficAgentManager.getInstance().avoidObstacles(this);
                              _loc3_ = _loc2_.isColliding as Boolean;
                              if(!_loc3_)
                              {
                                 this.stateChangeState(STATE_MOVEMENT_RUNNING);
                                 break;
                              }
                              if(Config.CHEAT_TRAFFIC_AGENT)
                              {
                                 this.cleanColText();
                              }
                           }
                           break;
                        }
                        if(!_loc3_)
                        {
                           this.stateChangeState(STATE_MOVEMENT_RUNNING);
                           break;
                        }
                        if(Config.CHEAT_TRAFFIC_AGENT)
                        {
                           this.cleanColText();
                        }
                     }
                     break;
                  }
                  _loc2_ = TrafficAgentManager.getInstance().avoidObstacles(this);
                  _loc3_ = _loc2_.isColliding as Boolean;
                  if(_loc3_)
                  {
                     if(Config.CHEAT_TRAFFIC_AGENT)
                     {
                        this.drawColText(_loc2_.index);
                     }
                     if(Boolean(_loc2_.turning) || Boolean(_loc2_.crossing))
                     {
                        this.mMaxSpeed = _loc2_.v as Number;
                     }
                     else
                     {
                        _loc4_ = _loc2_.v as Number;
                        _loc5_ = _loc2_.d as Number;
                        if(this.COLLISION_DISTANCE - (this.COLLISION_DISTANCE - _loc5_) <= 2.5 * this.mViewWidth)
                        {
                           this.mMaxSpeed = _loc4_;
                        }
                        else
                        {
                           _loc6_ = (_loc5_ - 2.5 * this.mViewWidth) * 100 / (this.COLLISION_DISTANCE - 2.5 * this.mViewWidth) / 100;
                           if(_loc6_ * 100 >= 0 && _loc6_ * 100 <= 5)
                           {
                              this.mMaxSpeed = _loc4_;
                           }
                           else
                           {
                              this.mMaxSpeed = _loc4_ + (this.mTrafficAgentDefinition.speed / 1000 - _loc4_) * _loc6_;
                           }
                        }
                     }
                  }
                  else
                  {
                     if(Config.CHEAT_TRAFFIC_AGENT)
                     {
                        this.cleanColText();
                     }
                     _loc5_ = new Vector2D(this.mMovementCrossingPoint).minus(new Vector2D(x,y)).magnitude;
                     _loc6_ = _loc5_ * 100 / this.mMovementDistanceToCrossing / 100;
                     if(_loc6_ * 100 >= 0 && _loc6_ * 100 <= 9)
                     {
                        this.mMaxSpeed = 0;
                     }
                     else
                     {
                        this.mMaxSpeed = this.mTrafficAgentDefinition.speed / 1000 * _loc6_;
                     }
                  }
                  this.mVelocity += this.mAcceleration * param1;
                  this.mMaxSpeed = Math.min(this.mMaxSpeed,this.mTrafficAgentDefinition.speed / 1000);
                  this.mVelocity = Math.min(this.mMaxSpeed,this.mVelocity);
                  this.mVelocity = Math.max(MIN_SPEED,this.mVelocity);
                  this.vel.set(this.mMovementCurrentDirection.x * this.mVelocity,this.mMovementCurrentDirection.y * this.mVelocity);
                  this.curPos.set(x + this.vel.x * param1,y + this.vel.y * param1);
                  this.oldPos.set(x - this.mMovementTurnCenterPos.x,y - this.mMovementTurnCenterPos.y);
                  this.oldPos.project(this.mMovementCurrentDirection);
                  x = this.curPos.x;
                  y = this.curPos.y;
                  this.currentPos.set(x - this.mMovementTurnCenterPos.x,y - this.mMovementTurnCenterPos.y);
                  this.currentPos.project(this.mMovementCurrentDirection);
                  _loc7_ = this.currentPos.dot(this.oldPos);
                  _loc8_ = this.mMap.getWorldToTileIndex(x,y,0);
                  if(_loc8_ != this.mMovementCurrentTileIndex)
                  {
                     this.advanceTile();
                  }
                  if(_loc7_ <= 0)
                  {
                     this.advanceTurnCenterPoint();
                  }
                  break;
               case STATE_WAITING:
                  if(this.mTrafficTimer > 0)
                  {
                     this.mTrafficTimer = Math.max(0,this.mTrafficTimer - param1);
                     if(this.mTrafficTimer <= 0)
                     {
                        this.unsetWaiting();
                        this.stateChangeState(STATE_NEAR_CROSSING);
                     }
                  }
            }
         }
      }
      
      private function getRealDirection() : Vector2D
      {
         var _loc1_:Vector2D = DIRECTION_VECT_UNIT[this.mMovementNextDirectionId];
         var _loc2_:Vector2D = new Vector2D(this.mMovementCurrentDirection).plus(DIRECTION_VECT_UNIT[this.mMovementNextDirectionId]).normalize();
         return new Vector2D(this.mMovementCurrentDirection).plus(DIRECTION_VECT_UNIT[this.mMovementNextDirectionId]).normalize();
      }
      
      public function getNextDirectionId() : int
      {
         return this.mMovementNextDirectionId;
      }
      
      private function movementSetRotation(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            this.mViewBody.rotation = param1;
         }
         if(this.mViewFramesCount > 0)
         {
            _loc2_ = param1 / this.mViewAngleOffByFrame;
            if(_loc2_ < 0)
            {
               _loc2_ += 360;
            }
            _loc2_++;
            this.mViewCurrentAnimation.gotoAndStop(_loc2_);
         }
      }
      
      private function drawCollisionPoint() : void
      {
         if(this.mCollisionPointLocal)
         {
            if(this.mCollisionPointSprite)
            {
               if(contains(this.mCollisionPointSprite))
               {
                  removeChild(this.mCollisionPointSprite);
               }
            }
            this.mCollisionPointSprite = new Sprite();
            addChild(this.mCollisionPointSprite);
            this.mCollisionPointSprite.graphics.beginFill(61680);
            this.mCollisionPointSprite.graphics.drawCircle(this.mCollisionPointLocal.x,this.mCollisionPointLocal.y,2);
            this.mCollisionPointSprite.graphics.endFill();
         }
      }
      
      public function movementGetCurrentCircleRadius() : int
      {
         return this.movementGetCircleRadius(this.mMovementCurrentDirectionId,this.mMovementNextDirectionId);
      }
      
      public function setTrafficAtRight(param1:TrafficAgent) : void
      {
         this.mTrafficList[TRAFFIC_RIGHT] = param1;
      }
      
      private function viewEnd() : void
      {
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            this.mViewBody.visible = false;
            this.viewDOGet(VIEW_DO_POINT_CHECK).visible = false;
         }
         if(this.mViewCurrentAnimation != null && contains(this.mViewCurrentAnimation))
         {
            this.mViewCurrentAnimation.visible = false;
         }
      }
      
      public function destroy() : void
      {
         this.mEnabled = false;
         this.wanderDestroy();
         this.viewDestroy();
      }
   }
}

