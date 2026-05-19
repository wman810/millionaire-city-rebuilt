package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ShopMenuInfoHouse extends InfoBox
   {
      
      public function ShopMenuInfoHouse(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_right"))();
         }
         super(param1);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc2_:TextField = param1["TopText"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(_loc2_);
         _loc2_ = param1["Size"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_INFO_SIZE));
         TextManager.setTextScaled(_loc2_);
         _loc2_ = param1["plots"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = mItemDefinition.baseCols + "x" + mItemDefinition.baseRows;
         TextManager.setTextScaled(_loc2_);
         _loc2_ = param1["Time"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_BUILD_TIME));
         TextManager.setTextScaled(_loc2_);
         _loc2_ = param1["Time_Number"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.convertTimeToString(mItemDefinition.getConstructionTime(),true,true);
         TextManager.setTextScaled(_loc2_,true,22);
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

