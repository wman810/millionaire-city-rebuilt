package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.model.ReadXMLAction;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManagerDefinition;
   
   public class ActionGetTrafficAgentManagerDefinition extends ReadXMLAction
   {
      
      public function ActionGetTrafficAgentManagerDefinition(param1:String)
      {
         super(param1);
      }
      
      override protected function fromXML(param1:XML) : void
      {
         TrafficAgentManagerDefinition.getInstance().setPersistence(param1);
      }
   }
}

