package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ItemCollectible extends Sprite
   {
      
      public static const EVENT_MODIFY_COUNTER:String = "eventmodifycounter";
      
      protected var mGiftNumber:TextField;
      
      protected var mTitle:TextField;
      
      protected var mCollectibleObject:CollectibleObject;
      
      protected var textF:TextField;
      
      protected var mBox:MovieClip;
      
      public function ItemCollectible(param1:MovieClip, param2:CollectibleObject)
      {
         var _loc3_:MovieClip = null;
         super();
         this.mCollectibleObject = param2;
         this.mBox = param1;
         _loc3_ = this.mBox.getChildByName("mark") as MovieClip;
         var _loc4_:MovieClip = this.mBox.getChildByName("gift") as MovieClip;
         var _loc5_:String = this.mCollectibleObject.getCollectibleDefinition().sku;
         var _loc6_:MovieClip = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,_loc5_))();
         _loc6_.x = _loc3_.x;
         _loc6_.y = _loc3_.y;
         this.mBox.removeChild(_loc3_);
         this.mBox.removeChild(_loc4_);
         this.mGiftNumber = this.mBox.getChildByName("gift_number") as TextField;
         switch(this.mCollectibleObject.getState())
         {
            case CollectibleObject.STATE_PENDING:
               _loc6_.transform.colorTransform = FiltersManager.setInk(_loc6_.transform.colorTransform,3368601,1);
               this.mBox.addChildAt(_loc6_,this.mBox.getChildIndex(this.mGiftNumber));
               this.mBox.gotoAndStop(1);
               break;
            case CollectibleObject.STATE_COLLECTED:
               this.mBox.addChildAt(_loc6_,this.mBox.getChildIndex(this.mGiftNumber));
               this.mBox.gotoAndStop(2);
         }
         this.mCollectibleObject.setCount(Math.min(this.mCollectibleObject.getCount(),RulesFacade.getInstance().settingsGetCollectibleMaxUnitsPerItem()));
         TextManager.reformatTextField(this.mGiftNumber);
         TextManager.setTextScaled(this.mGiftNumber);
         if(this.mCollectibleObject.getCount() > 0)
         {
            if(this.mCollectibleObject.getCount() < 10)
            {
               this.mGiftNumber.text = "x0" + this.mCollectibleObject.getCount().toString();
            }
            else
            {
               this.mGiftNumber.text = "x" + this.mCollectibleObject.getCount().toString();
            }
         }
         else
         {
            this.mGiftNumber.visible = false;
         }
         this.mTitle = this.mBox.getChildByName("mTitle") as TextField;
         TextManager.reformatTextField(this.mTitle);
         var _loc7_:CollectibleDefinition = this.mCollectibleObject.getCollectibleDefinition();
         if(_loc7_ == null)
         {
            this.mTitle.text = "";
         }
         else
         {
            this.mTitle.text = TextManager.getText(TextIDs[_loc7_.textID]);
         }
         TextManager.setTextScaled(this.mTitle);
      }
      
      public function refreshCollectible() : void
      {
         this.mCollectibleObject.setState(CollectibleObject.STATE_COLLECTED);
      }
      
      public function getCollectibleInfo() : CollectibleObject
      {
         return this.mCollectibleObject;
      }
      
      public function destroy() : void
      {
         this.mTitle = null;
      }
   }
}

