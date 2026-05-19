package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ShopMenuInfoWonder extends InfoBox
   {
      
      public function ShopMenuInfoWonder(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_wonder_left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_wonder_right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_wonder_left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_wonder_right"))();
         }
         super(param1);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:WonderTypeDefinition = mItemDefinition.getWonderType();
         if(_loc2_ != null)
         {
            TextManager.reformatTextField(TextField(param1.getChildByName("TopText")));
            TextField(param1.getChildByName("TopText")).text = TextManager.getText(TextIDs[mItemDefinition.textID]);
            TextManager.setTextScaled(TextField(param1.getChildByName("TopText")));
            TextManager.reformatTextField(TextField(param1.getChildByName("Size")));
            TextField(param1.getChildByName("Size")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_INFO_SIZE));
            TextManager.reformatTextField(TextField(param1.getChildByName("plots")));
            TextField(param1.getChildByName("plots")).text = mItemDefinition.baseCols + "x" + mItemDefinition.baseRows;
            TextManager.reformatTextField(TextField(param1.getChildByName("Time")));
            TextField(param1.getChildByName("Time")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_BUILD_TIME));
            TextManager.setTextScaled(TextField(param1.getChildByName("Time")));
            TextManager.reformatTextField(TextField(param1.getChildByName("Time_Number")));
            TextField(param1.getChildByName("Time_Number")).text = TextManager.convertTimeToString(mItemDefinition.getConstructionTime(),true);
            _loc3_ = "" + mItemDefinition.getIncomeValue();
            TextManager.reformatTextField(TextField(param1.getChildByName("Text")));
            _loc4_ = TextManager.replaceParameters(_loc2_.getTidDescription(mItemDefinition.target),new Array(_loc3_));
            if(mItemDefinition.sku == "wonder_clock_tower")
            {
               _loc4_ = TextManager.replaceParameters(TextIDs.TID_WONDER_TYPE_MULTIPLIER_CLOCK_INFO,new Array(_loc3_));
            }
            TextField(param1.getChildByName("Text")).text = _loc4_;
            TextManager.setTextScaled(TextField(param1.getChildByName("Text")));
         }
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         addChild(mBox);
      }
   }
}

