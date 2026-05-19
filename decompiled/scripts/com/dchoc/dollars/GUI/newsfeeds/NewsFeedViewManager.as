package com.dchoc.dollars.GUI.newsfeeds
{
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class NewsFeedViewManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:NewsFeedViewManager;
      
      public function NewsFeedViewManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: NewsFeedViewManager Error: Instantiation failed: Use NewsFeedViewManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : NewsFeedViewManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new NewsFeedViewManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function setupNewsFeedPrePopup(param1:Sprite, param2:String) : void
      {
         var _loc5_:TextField = null;
         var _loc3_:Sprite = param1.getChildByName("new_feed") as Sprite;
         if(_loc3_ == null)
         {
            _loc3_ = param1;
         }
         var _loc4_:NewsFeedDefinition = NewsFeedDefinitionManager.getInstance().getDefinitionBySku(param2) as NewsFeedDefinition;
         if(_loc4_ != null && _loc4_.hasReward())
         {
            _loc5_ = _loc3_.getChildByName("TextInfo_02") as TextField;
            TextManager.reformatTextField(_loc5_);
            if(_loc5_ == null && Config.DEBUG_ASSERTS)
            {
               Debug.trace("############# ERROR in NewsFeedViewManager.setupNewsFeedPrePopup(): box doesn\'t contain any TextInfo_02 resource for sku = " + param2);
            }
            else
            {
               TextField(_loc3_.getChildByName("TextInfo_02")).text = TextManager.getText(TextIDs[_loc4_.getTextID()]);
            }
         }
         else
         {
            _loc3_.visible = false;
         }
      }
   }
}

