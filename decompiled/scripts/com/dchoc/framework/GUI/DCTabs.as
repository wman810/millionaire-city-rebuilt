package com.dchoc.framework.GUI
{
   import com.dchoc.framework.events.ButtonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   
   public class DCTabs extends EventDispatcher
   {
      
      private var mTabContents:Array;
      
      private var mSelectedTab:int;
      
      private var mParent:DisplayObjectContainer;
      
      private var mTabButtons:Array;
      
      private var mTabClips:Array;
      
      public function DCTabs(param1:DisplayObjectContainer)
      {
         super();
         this.mParent = param1;
         this.mTabClips = new Array();
         this.mTabContents = new Array();
         this.mTabButtons = new Array();
         this.mSelectedTab = 0;
         addEventListener(DCWindow.EVENT_BUTTON_CLICKED,this.tabClicked);
      }
      
      public function selectTab(param1:int) : void
      {
         this.hideTab(this.mSelectedTab);
         this.mSelectedTab = param1;
         this.mTabButtons[param1].select();
         this.mTabButtons[param1].putToFront();
         var _loc2_:DisplayObjectContainer = this.mTabContents[param1] as DisplayObjectContainer;
         _loc2_.visible = true;
      }
      
      private function tabClicked(param1:ButtonEvent) : void
      {
         trace("select tab " + param1.getID());
         this.selectTab(parseInt(param1.getID()));
      }
      
      protected function clean() : void
      {
      }
      
      public function hideTab(param1:int) : void
      {
         this.mTabButtons[param1].unselect();
         this.mTabButtons[param1].putToBack();
         var _loc2_:DisplayObjectContainer = this.mTabContents[param1] as DisplayObjectContainer;
         _loc2_.visible = false;
      }
      
      public function addTab(param1:int, param2:String, param3:MovieClip, param4:DisplayObjectContainer, param5:Boolean = true) : void
      {
         var _loc6_:DCButtonSelected = new DCButtonSelected(this.mParent,param3,DCButton.BUTTON_TYPE_TAB,"" + param1,this);
         if(!param5)
         {
            _loc6_.setEnabled(false);
         }
         _loc6_.setText(param2);
         this.mTabButtons.push(_loc6_);
         this.mTabContents.push(param4);
         this.hideTab(param1);
      }
      
      public function hideAllTabs() : void
      {
         var _loc1_:* = int(this.mTabButtons.length - 1);
         while(_loc1_ >= 0)
         {
            this.hideTab(_loc1_);
            _loc1_--;
         }
      }
      
      public function getSize() : int
      {
         return this.mTabButtons.length;
      }
   }
}

