package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.framework.graphics.DCResourceManager;
   
   public class PopupMessageSmall extends PopupMessage
   {
      
      public function PopupMessageSmall()
      {
         super();
      }
      
      override protected function setBox() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_missage"))();
      }
   }
}

