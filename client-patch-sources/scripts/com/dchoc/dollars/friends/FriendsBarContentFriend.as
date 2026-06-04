package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.ui.Mouse;
   
   public class FriendsBarContentFriend extends FriendsBarContent
   {
      
      public static const TYPE_MYSELF:int = 0;
      
      public static const TYPE_PARTNER:int = 1;
      
      public static const TYPE_NORMAL:int = 2;
      
      private var mCurrentCursor:int;
      
      private var mLevelField:TextField;
      
      private var isOver:Boolean;
      
      private var mFriendPhoto:Sprite;
      
      private var mNameField:TextField;
      
      private var mPositionField:TextField;
      
      private var mColorTransform:ColorTransform;
      
      private var mMoneyField:TextField;
      
      public function FriendsBarContentFriend(param1:int)
      {
         super();
         switch(param1)
         {
            case TYPE_MYSELF:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box_yourself"))();
               break;
            case TYPE_PARTNER:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box_partner"))();
               break;
            default:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box"))();
         }
         this.mNameField = mBox.getChildByName("Name") as TextField;
         TextManager.reformatTextField(this.mNameField);
         this.mLevelField = mBox.getChildByName("ExLevel") as TextField;
         this.mMoneyField = mBox.getChildByName("Dollars") as TextField;
         this.mPositionField = TextField(mBox.getChildByName("position"));
         this.mFriendPhoto = mBox.getChildByName("photo") as Sprite;
         this.mFriendPhoto.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.mFriendPhoto.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.mFriendPhoto.mouseChildren = false;
         this.mColorTransform = this.mFriendPhoto.transform.colorTransform;
         mBox.addEventListener(MouseEvent.CLICK,this.onVisit);
         mBox.buttonMode = true;
      }
      
      private function onMouseOver(param1:MouseEvent = null) : void
      {
         if(!this.isOver)
         {
            Mouse.show();
            this.mCurrentCursor = Dollars.getCurrentCursor().mCurrentCursorID;
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
            this.mFriendPhoto.transform.colorTransform = FiltersManager.setInk(this.mColorTransform,16777215,0.5);
            this.isOver = true;
         }
      }
      
      override public function loadImage() : void
      {
         this.mFriendPhoto.addChildAt(mNeighborObject.loadImage(),1);
      }
      
      private function onMouseOut(param1:MouseEvent = null) : void
      {
         if(this.isOver)
         {
            Mouse.hide();
            Dollars.getCurrentCursor().changeCursor(this.mCurrentCursor);
            this.mFriendPhoto.transform.colorTransform = this.mColorTransform;
            this.isOver = false;
         }
      }
      
      override public function updateExp() : void
      {
         var _loc1_:TextField = mBox.getChildByName("ExLevel") as TextField;
         if(this.mNameField != null && mNeighborObject != null)
         {
            this.mNameField.text = mNeighborObject.nameFriend;
         }
         _loc1_.text = "" + this.calculateLevel(mNeighborObject.exp);
      }
      
      private function onVisit(param1:MouseEvent) : void
      {
         Debug.trace("Visiting neighbor id=" + mNeighborObject.userId);
         DollarsGame.visitUniverse(mNeighborObject.userId);
      }
      
      override public function loadFriend(param1:NeighborObject, param2:int) : void
      {
         var _loc4_:Sprite = null;
         super.loadFriend(param1,param2);
         mNeighborObject = param1;
         this.mNameField.text = mNeighborObject.nameFriend;
         this.mLevelField.text = "" + this.calculateLevel(mNeighborObject.exp);
         this.mMoneyField.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberRanking(mNeighborObject.companyValue);
         this.mPositionField.text = "" + param2;
         var _loc3_:Sprite = mBox["position_1"];
         _loc4_ = mBox["position_2"];
         var _loc5_:Sprite = mBox["position_3"];
         _loc3_.visible = false;
         _loc4_.visible = false;
         _loc5_.visible = false;
         if(param2 == 1)
         {
            _loc3_.visible = true;
         }
         else if(param2 == 2)
         {
            _loc4_.visible = true;
         }
         else if(param2 == 3)
         {
            _loc5_.visible = true;
         }
      }
      
      override public function updateCompanyValue() : void
      {
         var _loc1_:TextField = mBox.getChildByName("Dollars") as TextField;
         _loc1_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberRanking(mNeighborObject.companyValue);
      }
      
      private function calculateLevel(param1:Number) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < RulesFacade.maxLevel)
         {
            if(param1 < RulesFacade.getLevelXP(_loc2_))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 1;
      }
   }
}
