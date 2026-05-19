package com.dchoc.dollars.world.items.notifications
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class NotificationConstructionEnd extends Notification
   {
      
      public function NotificationConstructionEnd(param1:StateMachine, param2:Boolean = true)
      {
         super(param1,param2);
      }
      
      override protected function getButtonClass() : DisplayObject
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Contract_anim"))();
      }
      
      override protected function getButtonEndClass() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Contract_anim_ok"))();
      }
      
      override protected function onAccept(param1:MouseEvent = null) : void
      {
         mItemObject.getCurrentState().setNotification(null,false);
         mItemObject.company.initItemAfterConstruction(mItemObject);
         if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_INSTANT_BUILD_ID)
         {
            Tutorial.activeOkButton();
         }
      }
   }
}

