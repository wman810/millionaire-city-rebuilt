package com.dchoc.dollars.GUI.infoBox
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class InfoBoxAbandoned extends InfoBox
   {
      
      private var mTid2:int;
      
      private var mTitleSize:Number;
      
      private var mTid1:int;
      
      public function InfoBoxAbandoned(param1:DisplayObjectContainer, param2:ItemDefinition, param3:int = -1, param4:int = -1)
      {
         mItemDefinition = param2;
         mBoxLeft = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_left_empty"))();
         mBoxRight = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_info_house_right_empty"))();
         this.mTid1 = param3;
         this.mTid2 = param4;
         super(param1);
      }
      
      override protected function setUpBox(param1:Sprite) : void
      {
         this.mTitleSize = TextField(param1.getChildByName("TopText")).defaultTextFormat.size as Number;
         var _loc2_:TextField = TextField(param1.getChildByName("TopText"));
         TextManager.restoreOriginalSize(_loc2_,this.mTitleSize);
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[mItemDefinition.textID]);
         TextManager.setTextScaled(_loc2_);
         var _loc3_:String = TextManager.getText(this.mTid1);
         var _loc4_:TextField = TextField(param1.getChildByName("Text"));
         TextManager.reformatTextField(_loc4_);
         _loc4_.text = _loc3_ + "\n" + TextManager.getText(this.mTid2);
         var _loc5_:int = _loc3_.length;
         var _loc6_:TextFormat = _loc4_.defaultTextFormat;
         _loc6_.color = 16711680;
         _loc4_.setTextFormat(_loc6_,_loc5_,_loc4_.text.length);
      }
      
      override public function updateInfo(param1:Sprite) : void
      {
         if(contains(mBox))
         {
            removeChild(mBox);
         }
         mBox = param1;
         this.setUpBox(param1);
         addChild(mBox);
      }
   }
}

