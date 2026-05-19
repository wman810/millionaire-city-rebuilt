package com.dchoc.dollars.GUI.crosspromotion
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.text.TextManager;
   
   public class CrosspromotionDefinition extends Definition
   {
      
      public static const TEXT_TITLE:int = 0;
      
      public static const TEXT_DESC:int = 1;
      
      public static const TEXT_COUNT:int = 2;
      
      private var mUrl:String;
      
      private var mTidBody:String;
      
      private var mImage:String;
      
      private var mTidTitle:String;
      
      public function CrosspromotionDefinition(param1:uint)
      {
         super(param1);
      }
      
      public function getText(param1:int) : String
      {
         var _loc2_:String = null;
         var _loc3_:int = tid + param1;
         return TextManager.getText(_loc3_);
      }
      
      public function get tidTitle() : String
      {
         return this.mTidTitle;
      }
      
      public function get url() : String
      {
         return this.mUrl;
      }
      
      public function get tidBody() : String
      {
         return this.mTidBody;
      }
      
      public function set tidTitle(param1:String) : void
      {
         this.mTidTitle = param1;
      }
      
      override public function getTidsCount() : int
      {
         return TEXT_COUNT;
      }
      
      public function set tidBody(param1:String) : void
      {
         this.mTidBody = param1;
      }
      
      public function get image() : String
      {
         return this.mImage;
      }
      
      public function set image(param1:String) : void
      {
         this.mImage = param1;
      }
      
      public function set url(param1:String) : void
      {
         this.mUrl = param1;
      }
   }
}

