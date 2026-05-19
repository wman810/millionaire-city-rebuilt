package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.containers.ContractBox;
   import com.dchoc.dollars.containers.ContractItem;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxContract extends InfoBox
   {
      
      private var mContractItem:ContractItem;
      
      private var mIndex:int;
      
      public function InfoBoxContract(param1:DisplayObjectContainer, param2:ContractItem, param3:int, param4:int = 0)
      {
         var _loc5_:String = null;
         this.mContractItem = param2;
         this.mIndex = param3;
         _loc5_ = "";
         if(param4 == ItemDefinition.TYPE_CLUBS_ID)
         {
            _loc5_ = "club_";
         }
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_info_box_" + _loc5_ + "left_rtl"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_info_box_" + _loc5_ + "right_rtl"))();
         }
         else
         {
            mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_info_box_" + _loc5_ + "left"))();
            mBoxRight = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_info_box_" + _loc5_ + "right"))();
         }
         super(param1);
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
      
      override protected function setUpBox(param1:Sprite) : void
      {
         TextManager.reformatTextField(TextField(param1.getChildByName("Caption")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Income")));
         TextManager.reformatTextField(TextField(param1.getChildByName("XP")));
         TextManager.reformatTextField(TextField(param1.getChildByName("Income_Number")));
         TextManager.reformatTextField(TextField(param1.getChildByName("DailyXP")));
         TextField(param1.getChildByName("Caption")).text = this.mContractItem.getContractName();
         TextField(param1.getChildByName("Income")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT));
         TextField(param1.getChildByName("XP")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_SHOP_RENT_XP));
         TextField(param1.getChildByName("Income_Number")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.mContractItem.getIncomeCoins(),TextManager.TRUNCATE_MILLIONS,6);
         TextField(param1.getChildByName("DailyXP")).text = "" + this.mContractItem.getIncomeXP();
         var _loc2_:TextField = TextField(param1.getChildByName("attendance"));
         if(_loc2_ != null)
         {
            TextManager.reformatTextField(_loc2_);
            _loc2_.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_CURRENT_STATUS));
         }
         _loc2_ = TextField(param1.getChildByName("attendance_number"));
         if(_loc2_ != null)
         {
            TextManager.reformatTextField(_loc2_);
            _loc2_.text = "" + this.mContractItem.getPopulation();
         }
         var _loc3_:MovieClip = param1.getChildByName("dollar") as MovieClip;
         _loc3_.stop();
      }
   }
}

