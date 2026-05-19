package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.model.ReadXMLAction;
   import com.dchoc.dollars.utils.definitions.*;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import flash.events.Event;
   
   public class ActionGetDefinitions extends ReadXMLAction
   {
      
      protected var mDefinitionsManager:DefinitionManager;
      
      protected var mTid:int;
      
      protected var mType:int;
      
      protected var mLoadResourcesOnComplete:Boolean;
      
      public function ActionGetDefinitions(param1:DefinitionManager, param2:String, param3:int, param4:int = 0, param5:Boolean = true)
      {
         super(param2);
         this.mTid = param3;
         this.mType = param4;
         this.mDefinitionsManager = param1;
         this.mLoadResourcesOnComplete = param5;
      }
      
      override protected function doCompleteHandler(param1:Event) : void
      {
         if(this.mLoadResourcesOnComplete)
         {
            this.mDefinitionsManager.requestLoadResources(PriorityLoader.QUEUE_LOADING);
         }
      }
      
      protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:Definition = this.instanciateDefinition();
         _loc2_.sku = param1.@sku;
         _loc2_.level = int(param1.@level);
         if("@feedImg" in param1)
         {
            _loc2_.setFeedImg(param1.@feedImg);
         }
         if("tid" in param1)
         {
            _loc2_.tid = this.mTid + param1.@tid;
         }
         else
         {
            if("@tidsCount" in param1)
            {
               _loc2_.setTidsCount(int(param1.@tidsCount));
            }
            _loc2_.tid = this.mTid;
            this.mTid += _loc2_.getTidsCount();
         }
         return _loc2_;
      }
      
      protected function instanciateDefinition() : Definition
      {
         return new Definition(this.mType);
      }
      
      override protected function fromXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         for each(_loc2_ in param1.Definition)
         {
            this.mDefinitionsManager.addDefinition(this.itemFromXML(_loc2_));
         }
      }
      
      override public function destroy() : void
      {
         if(this.mDefinitionsManager != null)
         {
            this.mDefinitionsManager.destroy();
         }
      }
   }
}

