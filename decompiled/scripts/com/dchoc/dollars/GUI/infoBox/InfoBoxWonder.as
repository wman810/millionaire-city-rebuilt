package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxWonder extends InfoBox
   {
      
      private var mTitleSize:Number;
      
      public function InfoBoxWonder(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_wonder_left"))();
         mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_wonder_right"))();
         super(param1);
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         this.setUpBox(param1);
         addChild(mBox);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc4_:WonderTypeDefinition = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         this.mTitleSize = TextField(param1.getChildByName("TopText")).defaultTextFormat.size as Number;
         var _loc2_:TextField = TextField(param1.getChildByName("TopText"));
         var _loc3_:TextField = TextField(param1.getChildByName("Text"));
         TextManager.restoreOriginalSize(_loc2_,this.mTitleSize);
         TextManager.reformatTextField(_loc2_);
         TextManager.reformatTextField(_loc3_);
         if(mItemDefinition != null)
         {
            _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
            if(mItemDefinition.type == ItemDefinition.TYPE_WONDERS_ID)
            {
               _loc4_ = mItemDefinition.getWonderType();
               if(_loc4_ != null)
               {
                  _loc5_ = "" + mItemDefinition.getIncomeValue();
                  _loc6_ = TextManager.replaceParameters(_loc4_.getTidDescription(mItemDefinition.target),new Array(_loc5_));
                  if(mItemDefinition.sku == "wonder_clock_tower")
                  {
                     _loc6_ = TextManager.replaceParameters(TextIDs.TID_WONDER_TYPE_MULTIPLIER_CLOCK_INFO,new Array(_loc5_));
                  }
                  _loc3_.text = _loc6_;
               }
            }
            else
            {
               _loc3_.text = TextManager.getText(TextIDs[mItemDefinition.getTidDescription()]);
            }
            TextManager.setTextScaled(_loc2_);
            TextManager.setTextScaled(_loc3_,false);
         }
      }
      
      override public function setCustomText(param1:String, param2:String) : void
      {
         var _loc3_:TextField = TextField(mBox.getChildByName("TopText"));
         TextManager.restoreOriginalSize(_loc3_,this.mTitleSize);
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = param1;
         TextManager.setTextScaled(_loc3_);
         TextField(mBox.getChildByName("Text")).text = param2;
         TextManager.setTextScaled(TextField(mBox.getChildByName("Text")),false);
      }
   }
}

