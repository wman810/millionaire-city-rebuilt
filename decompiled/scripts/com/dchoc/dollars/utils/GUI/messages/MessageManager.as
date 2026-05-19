package com.dchoc.dollars.utils.GUI.messages
{
   import com.dchoc.dollars.flow.DollarsGame;
   
   public class MessageManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:MessageManager;
      
      private var mConsecutiveMessagesEnabled:Boolean;
      
      private var mMessages:Array;
      
      public function MessageManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: MessageManager Error: Instantiation failed: Use ItemDefinitionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : MessageManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new MessageManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function stageResize() : void
      {
         var _loc1_:Message = null;
         for each(_loc1_ in this.mMessages)
         {
            _loc1_.stageResize();
         }
      }
      
      public function load() : void
      {
         this.mMessages = new Array();
      }
      
      public function setVisible(param1:Boolean) : void
      {
         var _loc2_:Message = null;
         for each(_loc2_ in this.mMessages)
         {
            _loc2_.setVisible(param1);
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:Message = null;
         if(this.mMessages != null)
         {
            for each(_loc1_ in this.mMessages)
            {
               _loc1_.destroy();
            }
            this.mMessages.splice(0,this.mMessages.length);
            this.mMessages = null;
         }
         smInstance = null;
      }
      
      public function removeMessage(param1:Message) : void
      {
         var _loc2_:int = this.mMessages.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.mMessages.splice(_loc2_,1);
         }
      }
      
      public function addMessage(param1:Message) : void
      {
         param1.setParent(DollarsGame.smInstance.mMessageClip);
         this.mMessages.push(param1);
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc4_:Message = null;
         var _loc2_:int = int(this.mMessages.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.mMessages[_loc3_];
            _loc4_.logicUpdate(param1);
            if(!this.mConsecutiveMessagesEnabled && !_loc4_.isActive())
            {
               _loc3_ = _loc2_;
            }
            _loc3_++;
         }
      }
   }
}

