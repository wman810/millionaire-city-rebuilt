package com.dchoc.dollars.utils.traffic
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.math.Vector2D;
   import com.dchoc.dollars.world.companies.Company;
   
   public class TrafficAgentManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:TrafficAgentManager;
      
      private var mAgentsActive:Boolean;
      
      private var mSpawnTrafficAgentManagerDefinition:TrafficAgentManagerDefinition;
      
      private var mAgentList:Array;
      
      private var mSpawnTimer:int;
      
      private var mSpawnMinSquareDistanceBetweenAgents:int;
      
      private var mMap:Map;
      
      public function TrafficAgentManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: TrafficAgentManager Error: Instantiation failed: Use TrafficAgentManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : TrafficAgentManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new TrafficAgentManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:TrafficAgent = null;
         if(this.mAgentsActive)
         {
            for each(_loc2_ in this.mAgentList)
            {
               if(_loc2_.isEnabled())
               {
                  _loc2_.logicUpdate(param1);
               }
            }
            this.spawnLogicUpdate(param1);
         }
      }
      
      public function getCloserNeighbor(param1:TrafficAgent) : TrafficAgent
      {
         var _loc5_:int = 0;
         var _loc6_:TrafficAgent = null;
         var _loc7_:Number = NaN;
         var _loc2_:Array = param1.getCollisionAgentList();
         var _loc3_:TrafficAgent = _loc2_[0];
         var _loc4_:Number = 9999999999999;
         while(_loc5_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc5_] as TrafficAgent;
            _loc7_ = new Vector2D(_loc6_.x,_loc6_.y).minus(new Vector2D(param1.x,param1.y)).magnitude;
            if(_loc7_ < _loc4_)
            {
               _loc4_ = _loc7_;
               _loc3_ = _loc6_;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function spawnLogicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TrafficAgent = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:TileData = null;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:* = 0;
         var _loc16_:TrafficAgent = null;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:Company = null;
         var _loc20_:Array = null;
         var _loc21_:Array = null;
         var _loc22_:TrafficAgentDefinition = null;
         var _loc23_:TrafficAgent = null;
         var _loc24_:TrafficAgent = null;
         var _loc25_:String = null;
         if(this.mSpawnTimer > 0 && !Config.CHEAT_TRAFFIC_AGENT)
         {
            this.mSpawnTimer -= param1;
            if(this.mSpawnTimer <= 0)
            {
               this.mSpawnTimer = this.mSpawnTrafficAgentManagerDefinition.spawnAskForANewAgentTime;
               _loc2_ = 0;
               for each(_loc3_ in this.mAgentList)
               {
                  if(_loc3_.isEnabled())
                  {
                     _loc2_++;
                  }
               }
               _loc4_ = Math.min(this.getNumberOfPlots(),this.mSpawnTrafficAgentManagerDefinition.spawnAgentsLimit);
               _loc4_ = Math.max(_loc4_,this.mSpawnTrafficAgentManagerDefinition.spawnAgentsMin);
               if(_loc2_ < _loc4_)
               {
                  Debug.trace("Number of agents in the world: " + _loc2_);
                  _loc5_ = 100;
                  if(_loc2_ > this.mSpawnTrafficAgentManagerDefinition.spawnAgentsMin)
                  {
                     _loc7_ = (this.mSpawnTrafficAgentManagerDefinition.spawnProbabilityMax - this.mSpawnTrafficAgentManagerDefinition.spawnAgentsMin) / (this.mSpawnTrafficAgentManagerDefinition.spawnAgentsMax - this.mSpawnTrafficAgentManagerDefinition.spawnAgentsMin);
                     _loc5_ = this.mSpawnTrafficAgentManagerDefinition.spawnProbabilityMax - _loc2_ * _loc7_;
                  }
                  _loc6_ = Math.random() * 100;
                  if(_loc6_ <= _loc5_)
                  {
                     _loc8_ = this.mMap.getRoadTilesData();
                     _loc6_ = Math.random() * _loc8_.length;
                     _loc9_ = _loc8_[_loc6_];
                     if(_loc9_ != null && _loc9_.isPassable())
                     {
                        _loc10_ = true;
                        _loc11_ = int(this.mMap.getTileIndexToTileX(_loc9_.tileIndex));
                        _loc12_ = int(this.mMap.getTileIndexToTileY(_loc9_.tileIndex));
                        _loc13_ = this.mMap.getTileXToWorld(_loc11_);
                        _loc14_ = this.mMap.getTileYToWorld(_loc12_);
                        _loc15_ = int(this.mAgentList.length - 1);
                        while(_loc15_ > -1 && _loc10_)
                        {
                           _loc16_ = this.mAgentList[_loc15_];
                           _loc17_ = Math.abs(_loc16_.x - _loc13_);
                           _loc18_ = Math.abs(_loc16_.y - _loc14_);
                           if(_loc17_ * _loc17_ + _loc18_ * _loc18_ < this.mSpawnMinSquareDistanceBetweenAgents)
                           {
                              _loc10_ = false;
                           }
                           _loc15_--;
                        }
                        if(_loc10_)
                        {
                           _loc19_ = DollarsGame.getCurrentWorld().getCompanyMine();
                           _loc20_ = TrafficAgentDefinitionManager.getInstance().getDefinitions();
                           _loc21_ = new Array();
                           for each(_loc22_ in _loc20_)
                           {
                              for each(_loc25_ in _loc22_.spawnCondition)
                              {
                                 if(_loc25_ == "" || _loc19_.registerOccurrenceGetAmount(_loc25_) > 0)
                                 {
                                    _loc21_.push(_loc22_);
                                    break;
                                 }
                              }
                           }
                           for each(_loc24_ in this.mAgentList)
                           {
                              if(!_loc24_.isEnabled())
                              {
                                 _loc23_ = _loc24_;
                              }
                           }
                           if(_loc23_ == null)
                           {
                              _loc23_ = new TrafficAgent(this.mMap);
                              this.addAgent(_loc23_);
                           }
                           _loc23_.setup(_loc21_[int(Math.random() * (_loc21_.length - 1))]);
                           _loc23_.start();
                           _loc23_.wanderStart(_loc9_.tileIndex);
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function tagNeighbors(param1:TrafficAgent) : void
      {
         var _loc4_:Vector2D = null;
         var _loc6_:TrafficAgent = null;
         var _loc7_:int = 0;
         var _loc8_:Vector2D = null;
         var _loc9_:Vector2D = null;
         var _loc10_:Number = NaN;
         var _loc11_:Vector2D = null;
         var _loc12_:Boolean = false;
         var _loc13_:Vector2D = null;
         var _loc14_:Vector2D = null;
         var _loc15_:Number = NaN;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc2_:Vector2D = new Vector2D(param1.movementGetCurrentDirection());
         var _loc3_:Vector2D = new Vector2D(param1.x,param1.y);
         var _loc5_:int = param1.mIndex;
         for each(_loc6_ in this.mAgentList)
         {
            if(_loc6_ != param1)
            {
               param1.removeCollisionAgent(_loc6_);
               _loc4_ = new Vector2D(_loc6_.x,_loc6_.y);
               _loc7_ = _loc6_.mIndex;
               _loc8_ = new Vector2D(_loc6_.x,_loc6_.y).minus(new Vector2D(param1.x,param1.y));
               _loc9_ = new Vector2D(param1.movementGetCurrentDirection());
               _loc10_ = _loc8_.dot(_loc9_);
               _loc11_ = _loc6_.movementGetCurrentDirection();
               _loc12_ = _loc2_.isEqualTo(_loc6_.movementGetCurrentDirection());
               _loc13_ = new Vector2D(_loc6_.x,_loc6_.y).plus(new Vector2D(_loc6_.movementGetCurrentDirection()).times(_loc6_.getWidth() / 2));
               _loc14_ = new Vector2D(_loc6_.x,_loc6_.y).plus(new Vector2D(_loc6_.movementGetCurrentDirection()).invert().times(_loc6_.getWidth() / 2));
               if(_loc10_ >= 0)
               {
                  _loc15_ = param1.movementGetCurrentDirection().angleBetween(_loc6_.movementGetCurrentDirection());
                  _loc16_ = param1.movementGetCurrentCircleRadius();
                  _loc17_ = _loc6_.movementGetCurrentCircleRadius();
                  if(Math.abs(_loc15_) <= 90)
                  {
                     _loc18_ = new Vector2D(_loc13_).minus(new Vector2D(param1.x,param1.y)).magnitude;
                     _loc19_ = new Vector2D(_loc14_).minus(new Vector2D(param1.x,param1.y)).magnitude;
                     if(_loc18_ > _loc19_)
                     {
                        param1.addCollisionAgent(_loc6_);
                     }
                  }
               }
            }
         }
      }
      
      public function avoidObstacles(param1:TrafficAgent) : Object
      {
         var _loc2_:Object = null;
         var _loc4_:Vector2D = null;
         var _loc7_:TrafficAgent = null;
         var _loc8_:Vector2D = null;
         var _loc9_:Number = NaN;
         var _loc10_:Boolean = false;
         var _loc11_:Number = NaN;
         var _loc12_:Vector2D = null;
         var _loc13_:Vector2D = null;
         var _loc14_:Number = NaN;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc3_:int = param1.COLLISION_DISTANCE;
         var _loc5_:Vector2D = new Vector2D(param1.x,param1.y);
         _loc4_ = new Vector2D(_loc5_).plus(new Vector2D(param1.movementGetCurrentDirection()).times(_loc3_));
         this.tagNeighbors(param1);
         var _loc6_:Array = param1.getCollisionAgentList();
         if((Boolean(_loc6_)) && _loc6_.length > 0)
         {
            _loc7_ = this.getCloserNeighbor(param1);
            _loc8_ = new Vector2D(_loc7_.x,_loc7_.y);
            _loc9_ = new Vector2D(_loc8_).minus(_loc5_).magnitude;
            if(_loc3_ > _loc9_)
            {
               param1.removeCollisionAgent(_loc7_);
               _loc10_ = false;
               _loc12_ = new Vector2D(_loc8_).minus(_loc5_);
               _loc13_ = new Vector2D(_loc7_.movementGetCurrentDirection());
               _loc14_ = _loc12_.dot(_loc13_);
               _loc15_ = false;
               _loc16_ = false;
               if(_loc14_ < 0)
               {
                  _loc10_ = true;
               }
               if(_loc7_.getState() == TrafficAgent.STATE_MOVEMENT_TURNING)
               {
                  _loc15_ = true;
               }
               else if(_loc7_.getState() == TrafficAgent.STATE_NEAR_CROSSING)
               {
                  _loc16_ = true;
               }
               return {
                  "isColliding":true,
                  "v":_loc7_.getVelocity(),
                  "d":_loc9_,
                  "index":_loc7_.mIndex,
                  "distOver":_loc12_,
                  "turning":_loc15_,
                  "crossing":_loc16_,
                  "carDir":_loc7_.movementGetCurrentDirection(),
                  "colPoint":_loc8_
               };
            }
         }
         return {
            "isColliding":false,
            "velObj":0,
            "distOb":0,
            "index":-1,
            "distOver":null,
            "turning":false,
            "crossing":false,
            "carDir":null,
            "colPoint":null
         };
      }
      
      private function getNumberOfPlots() : int
      {
         var _loc1_:Array = DollarsGame.getProfile().plots;
         var _loc2_:Array = RulesFacade.getInstance().getArrayExpansions();
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            if(_loc1_[_loc4_] == 2)
            {
               _loc3_ += _loc2_[_loc4_];
            }
            _loc4_++;
         }
         _loc3_ *= 0.5;
         return int(Math.ceil(_loc3_));
      }
      
      public function removeAgent(param1:TrafficAgent) : void
      {
         param1.destroy();
      }
      
      public function deactivateAgents() : void
      {
         var _loc1_:TrafficAgent = null;
         for each(_loc1_ in this.mAgentList)
         {
            _loc1_.destroy();
         }
         this.mAgentList = null;
         this.mAgentsActive = false;
      }
      
      public function addAgent(param1:TrafficAgent) : void
      {
         this.mAgentList.push(param1);
      }
      
      private function load() : void
      {
         this.mSpawnTrafficAgentManagerDefinition = TrafficAgentManagerDefinition.getInstance();
         this.mAgentList = new Array();
      }
      
      private function spawnStart() : void
      {
         this.mSpawnMinSquareDistanceBetweenAgents = this.mSpawnTrafficAgentManagerDefinition.spawnMinTilesBetweenAgents * this.mMap.tileWidth;
         this.mSpawnMinSquareDistanceBetweenAgents *= this.mSpawnMinSquareDistanceBetweenAgents;
         this.mSpawnTimer = this.mSpawnTrafficAgentManagerDefinition.spawnAskForANewAgentTime;
      }
      
      public function activateAgents() : void
      {
         this.mAgentsActive = true;
         this.mAgentList = new Array();
      }
      
      public function assignMap(param1:Map) : void
      {
         this.mMap = param1;
         this.spawnStart();
      }
      
      public function resume() : void
      {
         this.mAgentsActive = true;
      }
      
      public function pause() : void
      {
         this.mAgentsActive = false;
      }
      
      public function reportMouseClick(param1:int, param2:int, param3:int = -1) : void
      {
         var _loc6_:TrafficAgent = null;
         var _loc7_:TileData = null;
         var _loc8_:TrafficAgentDefinitionManager = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:TrafficAgentDefinition = null;
         var _loc12_:TrafficAgent = null;
         var _loc4_:TrafficAgent = null;
         var _loc5_:* = int(this.mAgentList.length - 1);
         while(_loc5_ > -1 && _loc4_ == null)
         {
            _loc6_ = this.mAgentList[_loc5_];
            if(_loc6_.viewContainsPoint(param1,param2))
            {
               _loc4_ = _loc6_;
            }
            _loc5_--;
         }
         if(_loc4_ != null)
         {
            _loc4_.setResume();
         }
         else
         {
            _loc7_ = this.mMap.getTileDataFromIndex(param3);
            if(_loc7_.isPassable())
            {
               _loc8_ = TrafficAgentDefinitionManager.getInstance();
               _loc9_ = _loc8_.getDefinitions();
               _loc10_ = Math.random() * _loc9_.length;
               _loc11_ = _loc9_[_loc10_] as TrafficAgentDefinition;
               _loc12_ = new TrafficAgent(this.mMap);
               _loc12_.setup(_loc11_);
               if(TrafficAgent.SPAWN_STATUS == 0)
               {
                  _loc12_.start(false);
               }
               else
               {
                  _loc12_.start(true);
               }
               _loc12_.wanderStart(param3,TrafficAgent.SPAWN_DIRECTION);
               TrafficAgentManager.getInstance().addAgent(_loc12_);
               trace(this.mMap.mapData[param3]);
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:TrafficAgent = null;
         for each(_loc1_ in this.mAgentList)
         {
            _loc1_.destroy();
         }
         this.mAgentList = null;
         smInstance = null;
      }
      
      public function getTrafficAgentList() : Array
      {
         return this.mAgentList;
      }
      
      public function checkTrafficCollisions(param1:TrafficAgent) : void
      {
         var _loc6_:TrafficAgent = null;
         var _loc7_:int = 0;
         var _loc8_:Vector2D = null;
         var _loc9_:Vector2D = null;
         var _loc10_:Number = NaN;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:TrafficAgent = null;
         var _loc14_:Vector2D = null;
         var _loc15_:Vector2D = null;
         var _loc16_:Number = NaN;
         var _loc2_:Number = 30;
         var _loc3_:Vector2D = new Vector2D(param1.x,param1.y);
         var _loc4_:Vector2D = new Vector2D(_loc3_).plus(new Vector2D(param1.movementGetCurrentDirection()).times(this.mMap.tileWidth));
         var _loc5_:Array = new Array();
         for each(_loc6_ in this.mAgentList)
         {
            if(_loc6_.mIndex != param1.mIndex)
            {
               _loc8_ = new Vector2D(_loc6_.x,_loc6_.y);
               _loc9_ = new Vector2D(_loc8_).plus(new Vector2D(_loc6_.movementGetCurrentDirection()).times(this.mMap.tileWidth / 2));
               _loc10_ = new Vector2D(_loc9_).minus(_loc4_).magnitude;
               _loc11_ = false;
               if(_loc10_ < _loc2_)
               {
                  _loc12_ = 0;
                  while(_loc12_ < _loc5_.length)
                  {
                     _loc13_ = _loc5_[_loc12_] as TrafficAgent;
                     if(_loc13_.movementGetCurrentDirection() == _loc6_.movementGetCurrentDirection())
                     {
                        _loc14_ = new Vector2D(_loc13_.x,_loc13_.y);
                        _loc15_ = new Vector2D(_loc14_).plus(new Vector2D(_loc13_.movementGetCurrentDirection()).times(this.mMap.tileWidth / 2));
                        _loc16_ = new Vector2D(_loc15_).minus(_loc4_).magnitude;
                        if(_loc16_ < _loc10_)
                        {
                           _loc11_ = true;
                           _loc5_.splice(_loc12_,1);
                           _loc5_.push(_loc13_);
                        }
                     }
                     _loc12_++;
                  }
                  if(!_loc11_)
                  {
                     _loc5_.push(_loc6_);
                  }
               }
            }
         }
         _loc7_ = 0;
         while(_loc7_ < _loc5_.length)
         {
            param1.addTrafficAtCrossing(_loc5_[_loc7_]);
            _loc5_.splice(_loc7_,1);
            _loc7_++;
         }
         _loc5_ = null;
      }
   }
}

