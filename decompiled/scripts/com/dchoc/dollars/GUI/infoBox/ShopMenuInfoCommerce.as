package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ShopMenuInfoCommerce extends InfoBox
   {
      
      public function ShopMenuInfoCommerce(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_commerce_left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_commerce_right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_commerce_left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_info_box_commerce_right"))();
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
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Bonus")));
         TextField(param1.getChildByName("Income_Bonus")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT));
         TextManager.setTextScaled(TextField(param1.getChildByName("Income_Bonus")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Number")));
         TextField(param1.getChildByName("Income_Number")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(mItemDefinition.getIncomeValue(),TextManager.TRUNCATE_THOUSAND,6);
         TextManager.setTextScaled(TextField(param1.getChildByName("Income_Number")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Influence_name")));
         TextField(param1.getChildByName("Influence_name")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOPE_INFO_INFLUENCE));
         TextManager.setTextScaled(TextField(param1.getChildByName("Influence_name")));
         var _loc2_:TextField = param1.getChildByName("Influence") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = mItemDefinition.getInfluenceSideX() + "x" + mItemDefinition.getInfluenceSideY();
         TextManager.setTextScaled(_loc2_);
         var _loc3_:MovieClip = param1.getChildByName("gold") as MovieClip;
         _loc3_.stop();
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

