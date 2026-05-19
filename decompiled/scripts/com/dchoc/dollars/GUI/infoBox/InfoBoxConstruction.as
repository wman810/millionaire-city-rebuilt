package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfoBoxConstruction extends InfoBox
   {
      
      private var mFillBar:DCFillBar;
      
      private var mTitleSize:Number = TextField(mBoxRight.getChildByName("TopText")).defaultTextFormat.size as Number;
      
      public function InfoBoxConstruction(param1:DisplayObjectContainer, param2:ItemDefinition)
      {
         mItemDefinition = param2;
         mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_building_left"))();
         mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_building_right"))();
         super(param1);
      }
      
      override public function setTimer(param1:ItemObject, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(isVisible())
         {
            _loc3_ = param1.itemDefinition.getConstructionTime();
            if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_COLLECT_RENT_ID - 1)
            {
               _loc3_ = Tutorial.TUTORIAL_BUILD_HOUSE_TIME;
            }
            this.mFillBar.setMaxValue(_loc3_);
            TextManager.reformatTextField(TextField(mBox.getChildByName("IncomeIn")));
            TextField(mBox.getChildByName("IncomeIn")).text = TextManager.convertTimeToString(param2,false,true);
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
         var _loc4_:Number = mItemDefinition.getConstructionTime();
         this.mFillBar.setMaxValue(_loc4_);
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         addChild(mBox);
      }
   }
}

