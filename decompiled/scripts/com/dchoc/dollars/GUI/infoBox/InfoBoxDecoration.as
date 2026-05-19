package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxDecoration extends InfoBox
   {
      
      private var mPercentageIncreaseValue:TextField;
      
      private var mTitle:TextField;
      
      private var mTitleSize:Number;
      
      public function InfoBoxDecoration(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_decorations_left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_decorations_right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_decorations_left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_decorations_right"))();
         }
         super(param1);
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         var _loc2_:TextField = TextField(param1.getChildByName("TopText"));
         TextManager.restoreOriginalSize(_loc2_,this.mTitleSize);
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(_loc2_);
         var _loc3_:String = "+" + TextManager.convertNumberToString(mItemDefinition.getInfluenceValue(),0,0);
         TextManager.reformatTextField(TextField(param1.getChildByName("DailyIncomeMoney")));
         TextField(param1.getChildByName("DailyIncomeMoney")).text = TextManager.replaceParameters(TextIDs.TID_GEN_PERCENTAGE,new Array(_loc3_));
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         addChild(mBox);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc2_:TextField = param1.getChildByName("DailyIncome") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_DECORATION_INFO_HOUSES_BONUS));
         this.mTitleSize = TextField(param1.getChildByName("TopText")).defaultTextFormat.size as Number;
      }
   }
}

