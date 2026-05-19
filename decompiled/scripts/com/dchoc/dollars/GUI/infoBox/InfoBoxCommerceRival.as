package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxCommerceRival extends InfoBox
   {
      
      private var mTextColor:uint;
      
      public function InfoBoxCommerceRival(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_left_sell_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_right_sell_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_left_sell"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_right_sell"))();
         }
         super(param1);
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         TextManager.reformatTextField(TextField(param1.getChildByName("TopText")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Bonus")));
         TextManager.reformatTextField(TextField(mBox.getChildByName("Income_Time")));
         TextField(param1.getChildByName("TopText")).text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextField(param1.getChildByName("Income_Bonus")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT));
         TextField(mBox.getChildByName("Income_Time")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT_TIME));
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         addChild(mBox);
      }
      
      override public function setTimer(param1:ItemObject, param2:Number) : void
      {
         if(isVisible())
         {
            TextManager.reformatTextField(TextField(mBox.getChildByName("IncomeIn")));
            TextField(mBox.getChildByName("IncomeIn")).text = TextManager.convertTimeToString(param2,true);
         }
      }
      
      override public function setIncome(param1:int) : void
      {
         var _loc2_:TextField = TextField(mBox.getChildByName("DailyIncomeMoney"));
         if(param1 == 0)
         {
            _loc2_.textColor = 16711680;
         }
         else
         {
            _loc2_.textColor = this.mTextColor;
         }
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,6);
      }
      
      override public function setAttendance(param1:int) : void
      {
         var _loc2_:TextField = TextField(mBox.getChildByName("attendance_number"));
         if(param1 == 0)
         {
            _loc2_.textColor = 16711680;
         }
         else
         {
            _loc2_.textColor = this.mTextColor;
         }
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = "" + param1;
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         TextManager.reformatTextField(TextField(param1.getChildByName("attendance")));
         TextField(param1.getChildByName("attendance")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_ATTENDANCE));
         this.mTextColor = TextField(param1.getChildByName("DailyIncomeMoney")).textColor;
      }
   }
}

