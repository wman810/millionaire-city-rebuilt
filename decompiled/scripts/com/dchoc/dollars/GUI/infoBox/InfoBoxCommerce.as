package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxCommerce extends InfoBox
   {
      
      private var mFillBar:DCFillBar;
      
      private var mTextColor:uint;
      
      private var mTitleSize:Number;
      
      public function InfoBoxCommerce(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_left"))();
         mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_commerce_right"))();
         super(param1);
      }
      
      override public function setTimer(param1:ItemObject, param2:Number) : void
      {
         var _loc3_:int = 0;
         if(isVisible())
         {
            _loc3_ = int(param1.incomeTime);
            this.mFillBar.setMaxValue(_loc3_);
            TextManager.reformatTextField(TextField(mBox.getChildByName("IncomeIn")));
            TextField(mBox.getChildByName("IncomeIn")).text = TextManager.convertTimeToString(param2,false);
            this.mFillBar.setValueWithoutBarAnimation(_loc3_ - param2);
         }
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         var _loc2_:TextField = TextField(param1.getChildByName("TopText"));
         TextManager.restoreOriginalSize(_loc2_,this.mTitleSize);
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(_loc2_);
         var _loc3_:MovieClip = param1.getChildByName("FillBar") as MovieClip;
         this.mFillBar = new DCFillBar(_loc3_,0,0);
         var _loc4_:int = mItemDefinition.getIncomeTime();
         this.mFillBar.setMaxValue(_loc4_);
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         addChild(mBox);
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
         TextManager.reformatTextField(_loc2_);
         if(param1 == 0)
         {
            _loc2_.textColor = 16711680;
         }
         else
         {
            _loc2_.textColor = this.mTextColor;
         }
         _loc2_.text = "" + param1;
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc2_:TextField = param1.getChildByName("Income_Bonus") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT));
         TextManager.reformatTextField(TextField(param1.getChildByName("attendance")));
         TextField(param1.getChildByName("attendance")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_ATTENDANCE));
         this.mTextColor = TextField(param1.getChildByName("DailyIncomeMoney")).textColor;
         this.mTitleSize = TextField(param1.getChildByName("TopText")).defaultTextFormat.size as Number;
      }
   }
}

