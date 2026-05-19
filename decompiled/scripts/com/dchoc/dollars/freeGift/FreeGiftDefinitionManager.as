package com.dchoc.dollars.freeGift
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.storage.StoredItem;
   import com.dchoc.dollars.utils.definitions.*;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class FreeGiftDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:FreeGiftDefinitionManager;
      
      private var mPrizeList:Array;
      
      private var mPrizeSequence:Array;
      
      private var mPrizeSequencePosition:Array;
      
      private var mPrizeSequenceData:XML;
      
      public function FreeGiftDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: FreeGiftDefinitionManager Error: Instantiation failed: Use FreeGiftDefinitionManager.getInstance() instead of new.");
         }
         load();
         this.mPrizeSequencePosition = new Array();
      }
      
      public static function getInstance() : FreeGiftDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new FreeGiftDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function openBox(param1:String) : FreeGiftPrize
      {
         var _loc3_:int = 0;
         var _loc4_:FreeGiftPrize = null;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc2_:Array = this.mPrizeSequence[param1];
         if(_loc2_ != null)
         {
            _loc3_ = int(this.mPrizeSequencePosition[param1]);
            _loc3_ %= _loc2_.length;
            _loc4_ = _loc2_[_loc3_];
            if(_loc4_ != null)
            {
               switch(_loc4_.mType)
               {
                  case FreeGiftPrize.TYPE_CASH:
                     DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + int(_loc4_.mValue) * DollarsGame.getProfile().level;
                     break;
                  case FreeGiftPrize.TYPE_EXP:
                     _loc5_ = int(_loc4_.mValue) / 100;
                     _loc6_ = DollarsGame.getProfile().maxExp - RulesFacade.getLevelXP(DollarsGame.getProfile().level - 1);
                     DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + _loc6_ * _loc5_;
                     break;
                  case FreeGiftPrize.TYPE_GOLD:
                     DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + int(_loc4_.mValue);
                     break;
                  case FreeGiftPrize.TYPE_MOVE:
                     StorageManager.getInstance().addItem("move",int(_loc4_.mValue));
                     StorageManager.getInstance().sortStorage();
                     break;
                  case FreeGiftPrize.TYPE_ITEM:
                     StorageManager.getInstance().addItem(_loc4_.mValue,1);
               }
               UserDataFacade.getInstance().updateMoney(StoredItem.ACTION_OPENBOX,{
                  "prize":_loc4_.mSku,
                  "type":_loc4_.mType,
                  "value":_loc4_.mValue
               });
               _loc3_ = (_loc3_ + 1) % _loc2_.length;
               this.mPrizeSequencePosition[param1] = _loc3_;
               return _loc4_;
            }
         }
         return null;
      }
      
      public function setSequencePosition(param1:String, param2:int) : void
      {
         this.mPrizeSequencePosition[param1] = param2;
      }
      
      public function destroySequenceData() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.mPrizeSequence.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.mPrizeSequence[_loc1_].length)
            {
               delete this.mPrizeSequence[_loc1_][_loc2_];
               _loc2_++;
            }
            delete this.mPrizeSequence[_loc1_];
            delete this.mPrizeSequencePosition[_loc1_];
            _loc1_++;
         }
         this.mPrizeSequence = null;
         this.mPrizeSequencePosition = null;
      }
      
      public function saveSequenceData(param1:XML) : void
      {
         this.mPrizeSequenceData = param1;
      }
      
      public function getDefinition(param1:String, param2:String = null) : Definition
      {
         var _loc4_:FreeGiftDefinition = null;
         var _loc3_:Array = FreeGiftDefinitionManager.getInstance().getDefinitions();
         var _loc5_:int = 0;
         var _loc6_:* = _loc3_;
         while(true)
         {
            loop0:
            for each(_loc4_ in _loc6_)
            {
               if(_loc4_.giftType != param1)
               {
                  continue;
               }
               switch(param1)
               {
                  case "item":
                     if(_loc4_.value == param2)
                     {
                        return _loc4_;
                     }
                     break;
                  default:
                     break loop0;
               }
            }
            return null;
         }
         return _loc4_;
      }
      
      public function buildSequenceData() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         this.mPrizeSequence = new Array();
         var _loc1_:XMLList = this.mPrizeSequenceData.Definition;
         for each(_loc2_ in _loc1_)
         {
            if(this.mPrizeList[_loc2_.@sku] != null)
            {
               _loc3_ = (this.mPrizeList[_loc2_.@sku] as FreeGiftPrize).mSource;
               if(this.mPrizeSequence[_loc3_] == null)
               {
                  this.mPrizeSequence[_loc3_] = new Array();
               }
               if(this.mPrizeSequencePosition[_loc3_] == null)
               {
                  this.mPrizeSequencePosition[_loc3_] = 0;
               }
               this.setSequencePosition(_loc3_,0);
               this.mPrizeSequence[_loc3_].push(this.mPrizeList[_loc2_.@sku]);
            }
         }
      }
      
      public function buildPrizeListData(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:FreeGiftPrize = null;
         this.mPrizeList = new Array();
         var _loc2_:XMLList = param1.Definition;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = this.mPrizeList[_loc3_.@sku];
            mLoader.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_FREEGIFTS + _loc3_.@resname + ".png",_loc3_.@resname,".png");
            if(_loc3_.@giftType == "item")
            {
               mLoader.queueLoad(PriorityLoader.QUEUE_ASYNC,Config.getRoot() + ModelConfig.DIR_ITEMS + _loc3_.@value + ".swf",_loc3_.@value,".swf");
            }
            this.mPrizeList[_loc3_.@sku] = new FreeGiftPrize(_loc3_.@sku,_loc3_.@item,_loc3_.@giftType,_loc3_.@value,_loc3_.@resname,_loc3_.@tid);
         }
      }
      
      override public function getDefinitionBySku(param1:String) : Definition
      {
         var _loc2_:Definition = super.getDefinitionBySku(param1) as Definition;
         if(_loc2_ == null)
         {
            _loc2_ = super.getDefinitionBySku("default") as Definition;
         }
         return _loc2_;
      }
   }
}

