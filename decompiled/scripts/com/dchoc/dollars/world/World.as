package com.dchoc.dollars.world
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.*;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManager;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.companies.*;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.BitmapData;
   
   public class World
   {
      
      private static const BUILD_MAP_STEP_START:int = 0;
      
      private static const BUILD_MAP_STEP_END:int = BUILD_MAP_STEP_START + Map.BUILD_STEPS_COUNT - 1;
      
      private static const BUILD_COMPANY_RIVAL_STEP_START:int = BUILD_MAP_STEP_END + 1;
      
      private static const BUILD_COMPANY_RIVAL_STEP_END:int = BUILD_COMPANY_RIVAL_STEP_START;
      
      private static const BUILD_COMPANY_MINE_STEP_START:int = BUILD_COMPANY_RIVAL_STEP_END + 1;
      
      private static const BUILD_COMPANY_MINE_STEP_END:int = BUILD_COMPANY_MINE_STEP_START + Company.BUILD_STEPS_COUNT - 1;
      
      private static const CONNECT_ITEMS_STEP_START:int = BUILD_COMPANY_MINE_STEP_END + 1;
      
      private static const CONNECT_ITEMS_STEP_END:int = CONNECT_ITEMS_STEP_START + CONNECT_ITEMS_STEPS_COUNT - 1;
      
      private static const CREATE_EXPANSIONS_START:int = CONNECT_ITEMS_STEP_END + 1;
      
      private static const CREATE_EXPANSIONS_END:int = CREATE_EXPANSIONS_START;
      
      private static const SORT_DISPLAY_LIST_START:int = CREATE_EXPANSIONS_END + 1;
      
      private static const SORT_DISPLAY_LIST_END:int = SORT_DISPLAY_LIST_START + SORT_DISPLAY_LIST_STEPS_COUNT - 1;
      
      public static const BUILD_STEPS_COUNT:int = SORT_DISPLAY_LIST_END + 1;
      
      public static const CONNECT_ITEMS_STEPS_COUNT:int = 10;
      
      public static const SORT_DISPLAY_LIST_STEPS_COUNT:int = 20;
      
      public static const CONNECTION_TO_HQ_TYPE_REGISTER_HQ:int = 0;
      
      public static const CONNECTION_TO_HQ_TYPE_REGISTER_ROAD:int = 1;
      
      public static const CONNECTION_TO_HQ_TYPE_UNREGISTER_ROAD:int = 2;
      
      private static const CONNECTION_TO_HQ_MAX_ITEMS_PER_STEP:int = 50;
      
      private var mRole:Role;
      
      private var mConnectionToHQTileIndex:int = 0;
      
      private var mPersistenceAttributesChanged:Boolean;
      
      private var mBuildShortFormatItems:Array;
      
      public var mEnabled:Boolean;
      
      private var mConnectionToHQItemsCountPerStep:int = 0;
      
      public var mSid:String = "";
      
      private var mMap:Map;
      
      private var mConnectionToHQTotalSteps:int = 0;
      
      private var mOwner:String;
      
      private var mExpansion:int;
      
      private var mConnectionToHQCurrentStep:int = 0;
      
      private var mCompanies:Array;
      
      private var mConnectionToHQType:int = -1;
      
      private var mPersistence:XML;
      
      private var mConnectionToHQItems:Array;
      
      public function World()
      {
         super();
         this.load();
      }
      
      public static function getPersistenceDefaultWorld() : XML
      {
         var _loc1_:XML = <World/>;
         _loc1_.appendChild(CompanyMine.getPersistenceDefaultCompany());
         return _loc1_;
      }
      
      public function connectionToHQLoad() : void
      {
         if(this.mConnectionToHQItems == null)
         {
            this.mConnectionToHQItems = new Array();
         }
         else
         {
            this.mConnectionToHQItems.splice(0,this.mConnectionToHQItems.length);
         }
      }
      
      public function getCompanyRival() : Company
      {
         return this.mCompanies[Company.WHOSE_RIVAL];
      }
      
      public function enable() : void
      {
         this.mEnabled = true;
         this.mMap.enable();
      }
      
      public function connectionToHQLogicUpdate() : void
      {
         var _loc4_:int = 0;
         var _loc5_:ItemObject = null;
         var _loc1_:int = this.mConnectionToHQItemsCountPerStep;
         var _loc2_:int = this.mConnectionToHQCurrentStep * _loc1_;
         if(this.mConnectionToHQItems.length - _loc2_ < _loc1_)
         {
            _loc1_ = this.mConnectionToHQItems.length - _loc2_;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            _loc4_ = _loc2_ + _loc3_;
            _loc5_ = this.mConnectionToHQItems[_loc4_];
            _loc5_.searchHQConnection();
            _loc3_++;
         }
         ++this.mConnectionToHQCurrentStep;
         if(this.mConnectionToHQCurrentStep == this.mConnectionToHQTotalSteps)
         {
            this.connectionToHQEnd();
         }
      }
      
      public function set map(param1:Map) : void
      {
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("Setting previous map " + this.mMap + " to new value " + param1);
         }
         this.mMap = param1;
      }
      
      public function areaBuy(param1:int) : void
      {
         var _loc2_:Company = null;
         for each(_loc2_ in this.mCompanies)
         {
            _loc2_.areaBuy(param1);
         }
         this.mMap.areaBuy(param1);
      }
      
      public function getCompanyMine() : Company
      {
         return this.mCompanies[Company.WHOSE_MINE];
      }
      
      public function get expansion() : int
      {
         return this.mExpansion;
      }
      
      public function connectionToHQStart(param1:int, param2:int = -1) : void
      {
         var _loc3_:Company = null;
         var _loc4_:int = 0;
         this.mConnectionToHQCurrentStep = 0;
         this.mConnectionToHQType = param1;
         this.mConnectionToHQTileIndex = param2;
         for each(_loc3_ in this.mCompanies)
         {
            _loc3_.connectionToHQRegisterItems(param1,param2);
         }
         _loc4_ = int(this.mConnectionToHQItems.length);
         if(this.mConnectionToHQType == CONNECTION_TO_HQ_TYPE_REGISTER_HQ)
         {
            this.mConnectionToHQTotalSteps = CONNECT_ITEMS_STEPS_COUNT;
         }
         else
         {
            this.mConnectionToHQTotalSteps = _loc4_ / CONNECTION_TO_HQ_MAX_ITEMS_PER_STEP;
            if(_loc4_ % CONNECTION_TO_HQ_MAX_ITEMS_PER_STEP > 0)
            {
               ++this.mConnectionToHQTotalSteps;
            }
            this.map.currentTool.disable();
         }
         if(_loc4_ < this.mConnectionToHQTotalSteps)
         {
            this.mConnectionToHQItemsCountPerStep = _loc4_;
         }
         else
         {
            this.mConnectionToHQItemsCountPerStep = _loc4_ / this.mConnectionToHQTotalSteps;
            if(_loc4_ % this.mConnectionToHQTotalSteps > 0)
            {
               ++this.mConnectionToHQItemsCountPerStep;
            }
         }
      }
      
      public function getCompany(param1:int) : Company
      {
         return this.mCompanies[param1];
      }
      
      private function buildShortFormatResetList() : void
      {
         if(this.mBuildShortFormatItems == null)
         {
            this.mBuildShortFormatItems = new Array();
         }
         else
         {
            this.mBuildShortFormatItems.splice(0,this.mBuildShortFormatItems.length);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Company = null;
         if(this.mConnectionToHQCurrentStep > -1)
         {
            this.connectionToHQLogicUpdate();
         }
         if(this.mEnabled)
         {
            if(this.mMap != null)
            {
               this.mMap.logicUpdate(param1);
            }
            if(this.mRole.needsToBeUpdated())
            {
               for each(_loc2_ in this.mCompanies)
               {
                  _loc2_.logicUpdate(param1);
               }
            }
            if(this.mRole.isProgressEnabled() && this.mPersistenceAttributesChanged)
            {
               this.mPersistenceAttributesChanged = false;
            }
         }
      }
      
      public function buildShortFormatAddItem(param1:String) : void
      {
         if(this.mBuildShortFormatItems != null)
         {
            if(param1 != null && param1 != "")
            {
               this.mBuildShortFormatItems.push(param1);
            }
         }
      }
      
      public function connectionToHQEnd() : void
      {
         if(this.mConnectionToHQType != CONNECTION_TO_HQ_TYPE_REGISTER_HQ)
         {
            this.map.currentTool.enable();
         }
         this.mConnectionToHQItems.splice(0,this.mConnectionToHQItems.length);
         this.mConnectionToHQCurrentStep = -1;
      }
      
      public function buildUpdate(param1:int) : void
      {
         var _loc2_:Company = null;
         for each(_loc2_ in this.mCompanies)
         {
            _loc2_.buildUpdate(param1);
         }
      }
      
      public function connectionToHQDestroy() : void
      {
         if(this.mConnectionToHQItems != null)
         {
            this.mConnectionToHQItems.splice(0,this.mConnectionToHQItems.length);
            this.mConnectionToHQItems = null;
         }
      }
      
      public function get companies() : Array
      {
         return this.mCompanies;
      }
      
      public function get map() : Map
      {
         return this.mMap;
      }
      
      public function setPersistence(param1:XML) : void
      {
         var _loc4_:XML = null;
         var _loc5_:uint = 0;
         var _loc6_:Company = null;
         this.mPersistence = param1;
         this.mSid = param1.@sid;
         var _loc2_:int = int(param1.@sid);
         if(DollarsGame.smWorldSid <= _loc2_)
         {
            DollarsGame.smWorldSid = _loc2_ + 1;
         }
         var _loc3_:XML = XMLUtil.XMLListToXML(param1.Decorations);
         for each(_loc4_ in this.mPersistence.Company)
         {
            _loc5_ = uint(_loc4_.@whose);
            _loc6_ = this.mCompanies[_loc5_];
            _loc6_.setPersistence(_loc4_,_loc3_);
         }
         this.map.setPersistence(XMLUtil.XMLListToXML(param1.Map));
      }
      
      public function changeCompanyItem(param1:ItemObject, param2:uint) : void
      {
         param1.company.removeItem(param1,false);
         var _loc3_:Company = this.mCompanies[param2];
         _loc3_.addItem(param1,false);
         _loc3_.registerItemInArea(param1);
         param1.refresh();
      }
      
      public function end() : void
      {
      }
      
      private function load() : void
      {
         this.mExpansion = 0;
         this.map = new Map(this);
         this.mCompanies = new Array();
         this.mCompanies.push(Company.getCompany(this,Company.WHOSE_MINE));
         this.mCompanies.push(Company.getCompany(this,Company.WHOSE_RIVAL));
         this.connectionToHQLoad();
      }
      
      public function disable() : void
      {
         this.mEnabled = false;
         this.mMap.disable();
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc3_:Company = null;
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:XMLUtil = null;
         if(this.mSid == "")
         {
            this.mSid = "" + DollarsGame.smWorldSid;
            ++DollarsGame.smWorldSid;
         }
         var _loc2_:XML = <World sid={this.mSid}/>;
         if(!param1)
         {
            if(Config.OPT_USE_BUILD_SHORT_FORMAT)
            {
               this.buildShortFormatResetList();
            }
            for each(_loc3_ in this.mCompanies)
            {
               _loc2_.appendChild(_loc3_.getPersistence());
            }
            _loc2_.appendChild(this.map.getPersistence());
            if(Config.OPT_USE_BUILD_SHORT_FORMAT)
            {
               _loc4_ = <Decorations/>;
               _loc5_ = <Items/>;
               _loc6_ = new XMLUtil(_loc5_,this.mBuildShortFormatItems);
               _loc6_.addToXML(_loc4_);
               _loc2_.appendChild(_loc4_);
            }
         }
         this.mPersistence = _loc2_;
         return this.mPersistence;
      }
      
      public function registerRoad() : void
      {
         this.connectionToHQStart(CONNECTION_TO_HQ_TYPE_REGISTER_ROAD);
      }
      
      public function connectioToHQAddItem(param1:ItemObject) : void
      {
         this.mConnectionToHQItems.push(param1);
      }
      
      public function attachRole(param1:Role) : void
      {
         var _loc2_:Company = null;
         if(param1 == this.mRole)
         {
            return;
         }
         for each(_loc2_ in this.mCompanies)
         {
            if(this.mRole != null)
            {
               _loc2_.unattachRole(this.mRole);
            }
            _loc2_.attachRole(param1);
         }
         this.mRole = param1;
      }
      
      private function buildShortFormatDestroy() : void
      {
         if(this.mBuildShortFormatItems != null)
         {
            this.buildShortFormatResetList();
            this.mBuildShortFormatItems = null;
         }
      }
      
      public function get role() : Role
      {
         return this.mRole;
      }
      
      public function destroy() : void
      {
         var _loc1_:uint = 0;
         if(this.mCompanies != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mCompanies.length)
            {
               this.mCompanies[_loc1_].destroy();
               this.mCompanies[_loc1_] = null;
               _loc1_++;
            }
            this.mCompanies = null;
         }
         if(this.mMap != null)
         {
            this.mMap.destroy(false);
            Debug.trace("Destroying map!");
            this.map = null;
         }
         this.buildShortFormatDestroy();
         this.connectionToHQDestroy();
      }
      
      public function unregisterRoad(param1:int) : void
      {
         this.connectionToHQStart(CONNECTION_TO_HQ_TYPE_UNREGISTER_ROAD,param1);
      }
      
      public function build(param1:int) : void
      {
         var _loc2_:BitmapData = null;
         var _loc3_:int = 0;
         if(param1 >= BUILD_MAP_STEP_START && param1 <= BUILD_MAP_STEP_END)
         {
            if(param1 == BUILD_MAP_STEP_START)
            {
               this.mMap.mItemObjectsLayerBottom.sortSetIsEnabled(false);
            }
            _loc2_ = DCResourceManager.getInstance().get(ModelConfig.TILESET_PIC);
            this.mMap.build(param1 - BUILD_MAP_STEP_START,_loc2_);
         }
         else if(param1 >= BUILD_COMPANY_RIVAL_STEP_START && param1 <= BUILD_COMPANY_RIVAL_STEP_END)
         {
            if(param1 == BUILD_COMPANY_RIVAL_STEP_START)
            {
               TrafficAgentManager.getInstance().assignMap(this.mMap);
            }
            _loc3_ = 0;
            while(_loc3_ < Company.BUILD_STEPS_COUNT)
            {
               this.getCompanyRival().build(_loc3_);
               _loc3_++;
            }
         }
         else if(param1 >= BUILD_COMPANY_MINE_STEP_START && param1 <= BUILD_COMPANY_MINE_STEP_END)
         {
            this.getCompanyMine().build(param1 - BUILD_COMPANY_MINE_STEP_START);
         }
         else if(param1 >= CONNECT_ITEMS_STEP_START && param1 <= CONNECT_ITEMS_STEP_END)
         {
            this.connectionToHQLogicUpdate();
         }
         else if(param1 >= CREATE_EXPANSIONS_START && param1 <= CREATE_EXPANSIONS_END)
         {
            this.mMap.createExpansions();
            this.mEnabled = true;
            if(param1 == CREATE_EXPANSIONS_END)
            {
               trace("numChildren = " + this.mMap.mItemObjectsLayerBottom.numChildren);
               this.mMap.mItemObjectsLayerBottom.sortSetIsEnabled(true);
            }
         }
         else if(param1 >= SORT_DISPLAY_LIST_START && param1 <= SORT_DISPLAY_LIST_END)
         {
            this.map.mItemObjectsLayerBottom.sortDisplayList(param1 - SORT_DISPLAY_LIST_START,SORT_DISPLAY_LIST_STEPS_COUNT);
         }
      }
      
      public function set expansion(param1:int) : void
      {
         this.mExpansion = param1;
         this.mPersistenceAttributesChanged = true;
      }
   }
}

