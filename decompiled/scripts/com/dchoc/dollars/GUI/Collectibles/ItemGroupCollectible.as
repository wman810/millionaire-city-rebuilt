package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class ItemGroupCollectible extends Sprite
   {
      
      private var mGroup:CollectibleGroupObject;
      
      private var mItems:Array;
      
      private var mTitle:TextField;
      
      private var mBox:Sprite;
      
      public function ItemGroupCollectible(param1:int, param2:CollectibleGroupObject, param3:Boolean = false)
      {
         var _loc7_:CollectibleObject = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:DisplayObject = null;
         var _loc14_:CollectibleObject = null;
         var _loc15_:MovieClip = null;
         var _loc16_:Boolean = false;
         var _loc17_:CollectibleRewardDefinition = null;
         var _loc18_:Boolean = false;
         var _loc19_:ItemCollectibleUnit = null;
         super();
         this.mGroup = param2;
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"collectableItemGroup"))();
         addChild(this.mBox);
         this.mTitle = this.mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs[this.mGroup.getCollectibleGroupDefinition().textID]);
         TextManager.setTextScaled(this.mTitle);
         this.mItems = new Array();
         var _loc4_:Dictionary = this.mGroup.getCollectibles();
         var _loc5_:Array = new Array();
         var _loc6_:Array = new Array(4);
         for each(_loc7_ in _loc4_)
         {
            _loc12_ = _loc7_.getCollectibleDefinition().orderInCollection - 1;
            _loc6_[_loc12_] = _loc7_;
         }
         _loc8_ = 0;
         _loc9_ = 0;
         while(_loc9_ < this.mBox.numChildren)
         {
            _loc13_ = this.mBox.getChildAt(_loc9_);
            if(_loc13_.name.indexOf("item") > -1)
            {
               _loc14_ = _loc6_[_loc8_] as CollectibleObject;
               _loc15_ = _loc13_ as MovieClip;
               _loc16_ = param3 && _loc8_ == 0;
               _loc17_ = CollectibleRewardDefinition(CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mGroup.getCollectibleGroupDefinition().rewardSku));
               _loc18_ = false;
               if(_loc17_.rewardType == "set")
               {
                  _loc18_ = true;
               }
               _loc19_ = new ItemCollectibleUnit(_loc15_,_loc6_[_loc8_],this.mGroup,_loc16_,_loc18_);
               _loc19_.start();
               this.mItems.push(_loc19_);
               _loc8_++;
            }
            _loc9_++;
         }
         var _loc10_:MovieClip = this.mBox.getChildByName("reward") as MovieClip;
         switch(param2.getState())
         {
            case CollectibleGroupObject.STATE_INCOMPLETED:
               _loc10_.gotoAndStop(2);
               break;
            case CollectibleGroupObject.STATE_LOCKED:
               _loc10_.gotoAndStop(2);
               break;
            case CollectibleGroupObject.STATE_PENDING_TO_GET_REWARD:
            case CollectibleGroupObject.STATE_COMPLETED:
               _loc10_.gotoAndStop(1);
         }
         var _loc11_:ItemCollectibleReward = new ItemCollectibleReward(_loc10_ as Sprite,param2,param1);
         _loc11_.start();
         this.mItems.push(_loc11_);
      }
   }
}

