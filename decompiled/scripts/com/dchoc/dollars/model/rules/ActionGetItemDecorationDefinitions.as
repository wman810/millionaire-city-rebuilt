package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinition;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinitionManager;
   
   public class ActionGetItemDecorationDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetItemDecorationDefinitions(param1:String, param2:int, param3:int)
      {
         super(ItemDecorationDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      private function existsAttribute(param1:XML, param2:String) : Boolean
      {
         var _loc3_:XMLList = param1.@*;
         var _loc4_:int = _loc3_.length();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_ && _loc3_[_loc5_].name() != param2)
         {
            _loc5_++;
         }
         return _loc5_ < _loc4_;
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:ItemDecorationDefinition = super.itemFromXML(param1) as ItemDecorationDefinition;
         _loc2_.DCCoins = param1.@priceCoins;
         _loc2_.DCCash = param1.@priceCash;
         _loc2_.exp = param1.@exp;
         _loc2_.level = param1.@level;
         if(this.existsAttribute(param1,"shadowRows"))
         {
            _loc2_.shadowRows = param1.@shadowRows;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ItemDecorationDefinition(mType);
      }
   }
}

