package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupValue extends Popup
   {
      
      private var mGoldDisabled:Boolean;
      
      public function PopupValue()
      {
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mGoldDisabled = Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc1_.DCCash <= 0;
         if(this.mGoldDisabled)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_value_without_gold"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_value"))();
         }
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_HINT_VALUE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_01")));
         TextField(mBox.getChildByName("TextInfo_01")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_GEN_DCCOINS) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS));
         if(!this.mGoldDisabled)
         {
            TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_02")));
            TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_GEN_DCCASH) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS));
         }
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_03")));
         TextField(mBox.getChildByName("TextInfo_03")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_CV_1) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS));
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_04")));
         TextField(mBox.getChildByName("TextInfo_04")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_CV_2) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS));
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_05")));
         TextField(mBox.getChildByName("TextInfo_05")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_CV_TOTAL) + TextManager.getText(TextIDs.TID_ESPACIO2PUNTOS));
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mBox = null;
      }
      
      public function showpopup() : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow();
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
         {
            TextManager.reformatTextField(TextField(mBox.getChildByName("cash")));
            if(!this.mGoldDisabled)
            {
               TextManager.reformatTextField(TextField(mBox.getChildByName("gold")));
            }
            TextManager.reformatTextField(TextField(mBox.getChildByName("buildings")));
            TextManager.reformatTextField(TextField(mBox.getChildByName("terrain")));
            TextManager.reformatTextField(TextField(mBox.getChildByName("total")));
         }
         TextField(mBox.getChildByName("cash")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc1_.getCompanyValuePerDCCoins(),0,0);
         if(!this.mGoldDisabled)
         {
            TextField(mBox.getChildByName("gold")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc1_.getCompanyValuePerDCCash(),0,0);
         }
         TextField(mBox.getChildByName("buildings")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc1_.getCompanyValuePerBuildings(),0,0);
         TextField(mBox.getChildByName("terrain")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc1_.getCompanyValuePerTerrain(),0,0);
         TextField(mBox.getChildByName("total")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc1_.getCompanyValue(),0,0);
      }
   }
}

