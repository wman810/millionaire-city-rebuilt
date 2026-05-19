package com.dchoc.dollars.model.newsFeeds
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class NewsFeedDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:NewsFeedDefinitionManager;
      
      public function NewsFeedDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: NewsFeedDefinitionManager Error: Instantiation failed: Use NewsFeedDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : NewsFeedDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new NewsFeedDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
   }
}

