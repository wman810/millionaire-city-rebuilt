package com.dchoc.dollars.model
{
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   
   public class ActionGetCrewMechanicsDefinitions extends ReadXMLAction
   {
      
      private var mCrewMechanicsManager:CrewMechanicsManager = CrewMechanicsManager.getInstance();
      
      public function ActionGetCrewMechanicsDefinitions()
      {
         super(Config.getRoot() + ModelConfig.CREW_MECHANICS_XML_FILE);
      }
      
      override public function destroy() : void
      {
         this.mCrewMechanicsManager.destroy();
      }
      
      override protected function fromXML(param1:XML) : void
      {
         this.mCrewMechanicsManager.build(param1);
      }
   }
}

