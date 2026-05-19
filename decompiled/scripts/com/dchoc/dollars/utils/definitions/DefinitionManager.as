package com.dchoc.dollars.utils.definitions
{
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import flash.utils.Dictionary;
   
   public class DefinitionManager
   {
      
      protected var mDirectoryPath:String;
      
      protected var mDefinitions:Array;
      
      protected var mDefinitionDictionary:Array;
      
      protected var mTypeSkus:Array;
      
      protected var mLoader:PriorityLoader;
      
      protected var mTypePerSku:Dictionary;
      
      public function DefinitionManager()
      {
         super();
         this.mLoader = PriorityLoader.getInstance();
      }
      
      public function getItemsByLevel(param1:int, param2:int = -1, param3:Function = null) : Array
      {
         return this.getDefinitionsWithCondition(this.checkLevel,param1,param2,param3);
      }
      
      public function getDefinitionId(param1:String, param2:uint = 0) : int
      {
         var _loc5_:Definition = null;
         var _loc3_:int = -1;
         var _loc4_:* = int(this.mDefinitions[param2].length - 1);
         while(_loc4_ > -1 && _loc3_ == -1)
         {
            _loc5_ = this.mDefinitions[param2][_loc4_];
            if(_loc5_.sku == param1)
            {
               _loc3_ = _loc4_;
            }
            _loc4_--;
         }
         return _loc3_;
      }
      
      public function getTypeSkus() : Array
      {
         return this.mTypeSkus;
      }
      
      public function requestLoadResourcesByDefinition(param1:Definition, param2:int) : void
      {
         var _loc3_:String = null;
         if(param1.needsToLoadSWF() && !param1.mResourcesRequested)
         {
            _loc3_ = param1.getSkuToLoad();
            this.mLoader.queueLoad(param2,this.mDirectoryPath + _loc3_ + ".swf",_loc3_,"swf");
            if(Config.DEBUG_ASSERTS)
            {
               trace("sku: " + _loc3_);
            }
            param1.mResourcesRequested = true;
         }
      }
      
      protected function getTypeEnd() : int
      {
         return this.mDefinitions.length - 1;
      }
      
      protected function sortIsNeeded() : Boolean
      {
         return true;
      }
      
      protected function sortCompareSameLevelFunction(param1:Definition, param2:Definition) : Number
      {
         return 0;
      }
      
      public function requestLoadResources(param1:int) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Definition = null;
         if(this.mDirectoryPath != "")
         {
            _loc2_ = 0;
            while(_loc2_ < this.mDefinitions.length)
            {
               for each(_loc3_ in this.mDefinitions[_loc2_])
               {
                  this.requestLoadResourcesByDefinition(_loc3_,param1);
               }
               _loc2_++;
            }
         }
      }
      
      public function getDefinitions(param1:uint = 0, param2:Array = null) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Definition = null;
         var _loc11_:int = 0;
         var _loc12_:Definition = null;
         if(param2 == null || param2.length == 0)
         {
            _loc3_ = this.mDefinitions[param1];
         }
         else
         {
            _loc3_ = new Array();
            _loc4_ = 0;
            _loc5_ = this.mDefinitions[param1];
            _loc6_ = int(_loc5_.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc10_ = _loc5_[_loc7_] as Definition;
               if(!_loc10_.isDefault())
               {
                  if(_loc4_ == 0)
                  {
                     _loc4_ = _loc7_;
                  }
                  _loc11_ = param2.indexOf(_loc10_.sku);
                  if(_loc11_ == -1)
                  {
                     _loc3_.push(_loc10_);
                  }
               }
               else
               {
                  _loc3_.push(_loc10_);
               }
               _loc7_++;
            }
            _loc8_ = new Array();
            for each(_loc9_ in param2)
            {
               _loc12_ = this.getDefinitionBySku(_loc9_);
               _loc8_.push(_loc12_);
            }
            _loc7_ = 0;
            while(_loc7_ < _loc8_.length)
            {
               _loc3_.splice(_loc4_ + _loc7_,0,_loc8_[_loc7_]);
               _loc7_++;
            }
         }
         return _loc3_;
      }
      
      public function getDefinitionsWithCondition(param1:Function, param2:int, param3:int = -1, param4:Function = null) : Array
      {
         var _loc9_:Definition = null;
         var _loc10_:Boolean = false;
         var _loc5_:Array = new Array();
         var _loc6_:int = param3;
         var _loc7_:int = param3;
         if(param3 == -1)
         {
            _loc6_ = 0;
            _loc7_ = this.getTypeEnd();
         }
         var _loc8_:int = _loc6_;
         while(_loc8_ <= _loc7_)
         {
            for each(_loc9_ in this.mDefinitions[_loc8_])
            {
               _loc10_ = true;
               if(param4 != null)
               {
                  _loc10_ = param4(_loc9_);
               }
               if(_loc10_ && Boolean(param1(_loc9_,param2)))
               {
                  _loc5_.push(_loc9_);
               }
            }
            _loc8_++;
         }
         return _loc5_;
      }
      
      public function addDefinition(param1:Definition) : void
      {
         if(param1 != null)
         {
            param1.createChecksum();
            if(this.mTypePerSku[param1.sku] == null)
            {
               this.mTypePerSku[param1.sku] = param1.type;
               this.mDefinitionDictionary[param1.type][param1.sku] = param1;
               this.mDefinitions[param1.type].push(param1);
            }
         }
      }
      
      public function toString() : String
      {
         var _loc3_:uint = 0;
         var _loc1_:String = "";
         var _loc2_:uint = 0;
         while(_loc2_ < this.mDefinitions.length)
         {
            _loc3_ = 0;
            while(_loc3_ < this.mDefinitions[_loc2_].length)
            {
               _loc1_ += this.mDefinitions[_loc2_][_loc3_].toString() + "\n";
               _loc3_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function checkLevel(param1:Definition, param2:int) : Boolean
      {
         return param1.level == param2;
      }
      
      public function sort() : void
      {
         var _loc1_:int = this.getTypeCount();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.mDefinitions[_loc2_] != null)
            {
               if(this.sortIsNeeded())
               {
                  this.mDefinitions[_loc2_].sort(this.sortCompareFunction);
               }
            }
            _loc2_++;
         }
      }
      
      protected function sortCompareFunction(param1:Definition, param2:Definition) : Number
      {
         var _loc3_:Number = param1.level;
         var _loc4_:Number = param2.level;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         else
         {
            _loc5_ = this.sortCompareSameLevelFunction(param1,param2);
         }
         return _loc5_;
      }
      
      public function getDefinitionsCount(param1:uint = 0) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Array = this.getDefinitions(param1);
         if(_loc3_ != null)
         {
            _loc2_ = int(_loc3_.length);
         }
         return _loc2_;
      }
      
      public function getIdFromTypeSku(param1:String) : int
      {
         return this.mTypeSkus.indexOf(param1);
      }
      
      public function load(param1:String = "") : void
      {
         this.mDirectoryPath = param1;
         this.mDefinitionDictionary = new Array();
         this.mDefinitions = new Array();
         var _loc2_:int = this.getTypeCount();
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            this.mDefinitionDictionary.push(new Dictionary());
            this.mDefinitions.push(new Array());
            _loc3_++;
         }
         this.mTypePerSku = new Dictionary();
         this.mTypeSkus = new Array();
      }
      
      public function addDefinitionType(param1:Definition, param2:int) : void
      {
         var _loc3_:* = 0;
         if(param2 == -1)
         {
            param2 = int(this.mDefinitionDictionary.length);
         }
         if(param2 >= this.mDefinitionDictionary.length)
         {
            _loc3_ = int(param2 - this.mDefinitionDictionary.length);
            while(_loc3_ > -1)
            {
               this.mDefinitionDictionary.push(new Dictionary());
               this.mDefinitions.push(new Array());
               _loc3_--;
            }
         }
         if(this.mDefinitionDictionary[param2][param1.sku] == null)
         {
            this.mTypePerSku[param1.sku] = param2;
            this.mDefinitionDictionary[param2][param1.sku] = param1;
            this.mDefinitions[param2].push(param1);
         }
      }
      
      public function build() : void
      {
         var _loc3_:Definition = null;
         var _loc1_:int = this.getTypeCount();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.mDefinitions[_loc2_] != null)
            {
               for each(_loc3_ in this.mDefinitions[_loc2_])
               {
                  _loc3_.build();
               }
            }
            _loc2_++;
         }
         this.sort();
      }
      
      public function getTypeBySku(param1:String) : int
      {
         var _loc2_:int = -1;
         if(this.mTypePerSku[param1] != null)
         {
            _loc2_ = this.mTypePerSku[param1] as int;
         }
         return _loc2_;
      }
      
      public function removeDefinition(param1:int, param2:String) : void
      {
         var _loc3_:Definition = null;
         var _loc4_:int = 0;
         if(param1 < this.mDefinitionDictionary.length)
         {
            _loc3_ = this.mDefinitionDictionary[param1][param2] as Definition;
            _loc4_ = int(this.mDefinitions[param1].indexOf(_loc3_));
            if(_loc4_ > -1)
            {
               this.mDefinitions[param1].splice(_loc4_,1);
               this.mTypePerSku[param2] = null;
               this.mDefinitionDictionary[param1][param2] = null;
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         if(this.mDefinitions != null)
         {
            _loc1_ = this.mDefinitions.length - 1;
            while(_loc1_ > -1)
            {
               _loc2_ = this.mDefinitions[_loc1_].length - 1;
               while(_loc2_ > -1)
               {
                  this.mDefinitions[_loc1_][_loc2_] = null;
                  _loc2_--;
               }
               this.mDefinitions[_loc1_] = null;
               _loc1_--;
            }
            this.mDefinitions = null;
         }
         if(this.mDefinitionDictionary != null)
         {
            _loc1_ = this.mDefinitionDictionary.length - 1;
            while(_loc1_ > -1)
            {
               this.mDefinitionDictionary[_loc1_] = null;
               _loc1_--;
            }
            this.mDefinitionDictionary = null;
         }
         this.mTypePerSku = null;
         this.mTypeSkus = null;
      }
      
      public function getDefinitionById(param1:int, param2:uint = 0) : Definition
      {
         return this.mDefinitions[param2][param1];
      }
      
      public function getDefinitionBySku(param1:String) : Definition
      {
         var _loc2_:Definition = null;
         var _loc3_:int = this.getTypeBySku(param1);
         if(_loc3_ > -1)
         {
            _loc2_ = this.mDefinitionDictionary[_loc3_][param1];
         }
         return _loc2_;
      }
      
      public function getTypeCount() : int
      {
         return 1;
      }
   }
}

