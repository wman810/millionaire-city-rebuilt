package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Sprite;
   import flash.text.Font;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class Particles extends Sprite
   {
      
      protected var mTextField:TextField;
      
      protected var mFormat:TextFormat;
      
      protected var mAlive:Boolean;
      
      public function Particles()
      {
         super();
         this.mTextField = new TextField();
         var _loc1_:Font = new AssetManager.HelveticaRounded() as Font;
         this.mFormat = new TextFormat(_loc1_.fontName,18);
         this.mTextField.embedFonts = true;
         this.mTextField.autoSize = TextFieldAutoSize.LEFT;
         TextManager.reformatTextField(this.mTextField);
         this.mAlive = true;
         mouseEnabled = false;
         mouseChildren = false;
      }
      
      public function start() : void
      {
      }
      
      public function isAlive() : Boolean
      {
         return this.mAlive;
      }
      
      public function update(param1:int) : void
      {
      }
      
      public function get text() : String
      {
         if(this.mTextField != null)
         {
            return this.mTextField.text;
         }
         return null;
      }
      
      public function destroy() : void
      {
      }
      
      public function kill() : void
      {
         this.mAlive = false;
      }
   }
}

