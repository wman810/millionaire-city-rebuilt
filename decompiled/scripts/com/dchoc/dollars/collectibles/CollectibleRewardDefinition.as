package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   
   public class CollectibleRewardDefinition extends Definition
   {
      
      public static const TYPE_HQ:String = "hq";
      
      public static const TYPE_PLANE:String = "plane";
      
      public static const TYPE_ITEM:String = "item";
      
      public static const TYPE_CASH:String = "cash";
      
      public static const TYPE_COINS:String = "coins";
      
      public static const TYPE_EXP:String = "exp";
      
      public static const TYPE_SET:String = "set";
      
      private var mValue:String;
      
      private var mTextID:String;
      
      private var mRewardType:String;
      
      public function CollectibleRewardDefinition(param1:int)
      {
         super(param1);
      }
      
      public function set Value(param1:String) : void
      {
         this.mValue = param1;
      }
      
      public function get rewardType() : String
      {
         return this.mRewardType;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return true;
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function get Value() : String
      {
         return this.mValue;
      }
      
      public function set rewardType(param1:String) : void
      {
         this.mRewardType = param1;
      }
      
      public function getIconDO() : DisplayObject
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,mSku))();
      }
   }
}

