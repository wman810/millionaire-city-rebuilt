package com.dchoc.dollars.storage
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftDefinition;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class StorageManager
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:StorageManager;
      
      private var mChanged:Boolean;
      
      private var mItems:Array;
      
      public function StorageManager()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: StorageManager Error: Instantiation failed: Use StorageManager.getInstance() instead of new.");
         }
         this.mItems = new Array();
         this.mChanged = false;
      }
      
      public static function getInstance() : StorageManager
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new StorageManager();
            smAllowed = false;
         }
         return smInstance;
      }
      
      public function getItem(param1:String) : StoredItem
      {
         var _loc2_:StoredItem = null;
         for each(_loc2_ in this.mItems)
         {
            if(_loc2_.mSku == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function hasChanged() : Boolean
      {
         return this.mChanged;
      }
      
      public function addItem(param1:String, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:ItemDefinition = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:FreeGiftDefinition = null;
         var _loc3_:StoredItem = this.getItem(param1);
         var _loc4_:int = -1;
         if(_loc3_)
         {
            _loc6_ = _loc3_.getAmount() + param2;
            _loc4_ = _loc3_.getMaxAmount();
            if(_loc4_ > -1 && _loc6_ > _loc4_)
            {
               _loc6_ = _loc4_;
            }
            _loc3_.setAmount(_loc6_);
         }
         else
         {
            _loc7_ = -1;
            _loc8_ = ItemDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDefinition;
            _loc9_ = param1;
            _loc10_ = "";
            _loc11_ = null;
            if(_loc8_ != null)
            {
               _loc9_ = "item";
               _loc10_ = _loc8_.textID;
               _loc11_ = "place";
               _loc7_ += 100001 + _loc8_.type;
               ItemDefinitionManager.getInstance().requestLoadResourcesByDefinition(_loc8_,PriorityLoader.QUEUE_ASYNC);
            }
            _loc12_ = FreeGiftDefinitionManager.getInstance().getDefinition(_loc9_,param1) as FreeGiftDefinition;
            if(_loc12_ != null)
            {
               _loc10_ = _loc12_.textID;
               _loc4_ = _loc12_.maxAmount;
               _loc11_ = _loc12_.giftAction;
               if(_loc7_ < 0)
               {
                  _loc7_ = _loc12_.order;
               }
            }
            if(_loc7_ > -1 && param2 > 0)
            {
               this.mItems.push(new StoredItem(param1,param2,_loc9_,_loc4_,_loc10_,_loc11_,_loc7_));
            }
         }
         var _loc5_:Role = DollarsGame.getCurrentRole();
         if(_loc5_ != null && _loc5_.toolsBar != null && param2 > 0)
         {
            DollarsGame.getCurrentRole().toolsBar.setVaultAlert(true);
         }
         this.mChanged = true;
      }
      
      public function getItems() : Array
      {
         this.mChanged = false;
         return this.mItems;
      }
      
      public function sortStorage() : void
      {
         if(this.mItems != null)
         {
            this.mItems.sortOn(["mOrder","mSku"],[Array.NUMERIC,Array.CASEINSENSITIVE]);
            this.mChanged = true;
         }
      }
      
      public function build() : void
      {
         var _loc3_:XML = null;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_STORAGE_LIST);
         var _loc2_:XMLList = _loc1_.item;
         this.mItems.length = 0;
         for each(_loc3_ in _loc2_)
         {
            this.addItem(_loc3_.@sku,_loc3_.@amount);
         }
         this.sortStorage();
      }
      
      public function removeItem(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:StoredItem = this.getItem(param1);
         if(_loc2_)
         {
            _loc2_.setAmount(_loc2_.getAmount() - 1);
            if(_loc2_.getAmount() <= 0)
            {
               _loc3_ = this.mItems.indexOf(_loc2_);
               this.mItems.splice(_loc3_,1);
            }
         }
         this.mChanged = true;
      }
   }
}

