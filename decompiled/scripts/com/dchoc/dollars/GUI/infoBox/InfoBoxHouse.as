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
   
   public class InfoBoxHouse extends InfoBox
   {
      
      private var mFillBar:DCFillBar;
      
      private var mTextColor:uint;
      
      private var mTitleSize:Number;
      
      public function InfoBoxHouse(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_right_rtl"))();
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_left_rtl"))();
         }
         else
         {
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_right"))();
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_left"))();
         }
         super(param1);
      }
      
      override public function setTimer(param1:ItemObject, param2:Number) : void
      {
         var _loc3_:int = int(param1.incomeTime);
         this.mFillBar.setMaxValue(_loc3_);
         TextManager.reformatTextField(TextField(mBox.getChildByName("IncomeIn")));
         TextField(mBox.getChildByName("IncomeIn")).text = TextManager.convertTimeToString(param2,false,true);
         this.mFillBar.setValueWithoutBarAnimation(_loc3_ - param2);
      }
      
      override public function setIncome(param1:int) : void
      {
         var _loc2_:TextField = TextField(mBox.getChildByName("DailyIncomeMoney"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.textColor = this.mTextColor;
         if(param1 == 0)
         {
            _loc2_.textColor = 65280;
         }
         _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,6);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         var _loc2_:TextField = param1.getChildByName("Status") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_CURRENT_STATUS));
         var _loc3_:MovieClip = param1.getChildByName("FillBar") as MovieClip;
         this.mFillBar = new DCFillBar(_loc3_,0,0);
         this.mTextColor = _loc2_.textColor;
         this.mTitleSize = TextField(param1.getChildByName("TopText")).defaultTextFormat.size as Number;
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         var _loc2_:TextField = TextField(param1.getChildByName("TopText"));
         TextManager.restoreOriginalSize(_loc2_,this.mTitleSize);
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(_loc2_,false);
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
      
      override public function setAttendance(param1:int) : void
      {
         var _loc2_:TextField = TextField(mBox.getChildByName("attendance_number"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.textColor = this.mTextColor;
         if(param1 == 0)
         {
            _loc2_.textColor = 65280;
         }
         _loc2_.text = "" + param1;
      }
      
      override public function setExp(param1:int) : void
      {
         var _loc2_:TextField = TextField(mBox.getChildByName("DailyXP"));
         _loc2_.textColor = this.mTextColor;
         if(param1 == 0)
         {
            _loc2_.textColor = 16711680;
         }
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.replaceParameters(TextIDs.TID_POINTS_XP,new Array("" + param1));
      }
   }
}

