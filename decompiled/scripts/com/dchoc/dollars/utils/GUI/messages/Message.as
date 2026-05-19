package com.dchoc.dollars.utils.GUI.messages
{
   import com.dchoc.dollars.utils.animations.ItemSprite;
   import com.dchoc.dollars.utils.behaviors.Behavior;
   import flash.display.DisplayObjectContainer;
   
   public class Message
   {
      
      private var mActive:Boolean;
      
      private var mParent:DisplayObjectContainer;
      
      protected var mDO:ItemSprite;
      
      protected var mBehavior:Behavior;
      
      public function Message()
      {
         super();
         this.mDO = new ItemSprite();
         this.setBehavior();
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.mActive)
         {
            this.mBehavior.logicUpdate(param1);
            if(this.isFinished())
            {
               this.mActive = false;
               if(this.mParent.contains(this.mDO))
               {
                  this.mParent.removeChild(this.mDO);
               }
            }
         }
      }
      
      public function isActive() : Boolean
      {
         return this.mActive;
      }
      
      public function setParent(param1:DisplayObjectContainer) : void
      {
         this.mParent = param1;
      }
      
      public function reset() : void
      {
         if(!this.mParent.contains(this.mDO))
         {
            this.mParent.addChild(this.mDO);
         }
         this.mBehavior.reset();
         this.mActive = true;
         this.setVisible(true);
      }
      
      public function setVisible(param1:Boolean) : void
      {
         this.mDO.visible = param1;
      }
      
      protected function setBehavior() : void
      {
      }
      
      public function stageResize() : void
      {
      }
      
      public function destroy() : void
      {
         if(this.mParent != null)
         {
            this.mParent.removeChild(this.mDO);
         }
         this.mDO.destroy();
         this.mDO = null;
         this.mBehavior.destroy();
      }
      
      public function isFinished() : Boolean
      {
         return this.mBehavior.isFinished();
      }
   }
}

