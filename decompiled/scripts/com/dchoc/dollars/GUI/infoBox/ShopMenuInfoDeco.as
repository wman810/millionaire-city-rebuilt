package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ShopMenuInfoDeco extends InfoBox
   {
      
      public function ShopMenuInfoDeco(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_decoration_left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_decoration_right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_decoration_left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_decoration_right"))();
         }
         super(param1);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         TextManager.reformatTextField(TextField(param1.getChildByName("TopText")));
         TextField(param1.getChildByName("TopText")).text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(TextField(param1.getChildByName("TopText")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Size")));
         TextField(param1.getChildByName("Size")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_INFO_SIZE));
         TextManager.reformatTextField(TextField(param1.getChildByName("plots")));
         TextField(param1.getChildByName("plots")).text = mItemDefinition.baseCols + "x" + mItemDefinition.baseRows;
         TextManager.reformatTextField(TextField(param1.getChildByName("Influence_name")));
         TextField(param1.getChildByName("Influence_name")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOPE_INFO_INFLUENCE));
         TextManager.reformatTextField(TextField(param1.getChildByName("Influence")));
         TextField(param1.getChildByName("Influence")).text = mItemDefinition.getInfluenceSideX() + "x" + mItemDefinition.getInfluenceSideY();
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Bonus")));
         TextField(param1.getChildByName("Income_Bonus")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_DECORATION_INFO_HOUSES_BONUS));
         var _loc2_:String = "+" + TextManager.convertNumberToString(mItemDefinition.getInfluenceValue(),0,0);
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Bonus_Number")));
         TextField(param1.getChildByName("Income_Bonus_Number")).text = TextManager.replaceParameters(TextIDs.TID_GEN_PERCENTAGE,new Array(_loc2_));
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

