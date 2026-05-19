package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Sprite;
   import flash.text.Font;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class TipBox extends Sprite
   {
      
      private var tipText:TextField;
      
      private var mCurrentWidth:Number;
      
      private const MAX_WIDTH:uint = 200;
      
      public function TipBox(param1:String)
      {
         super();
         this.tipText = new TextField();
         var _loc2_:Font = new AssetManager.HelveticaRounded() as Font;
         var _loc3_:String = _loc2_.fontName;
         this.tipText.embedFonts = true;
         if(TextManager.smChangeFont)
         {
            this.tipText.embedFonts = false;
            _loc3_ = TextManager.ARIAL_UNICODE_FONT;
         }
         this.tipText.defaultTextFormat = new TextFormat(_loc3_,12,4920320);
         this.tipText.selectable = false;
         this.tipText.text = param1;
         this.tipText.autoSize = TextFieldAutoSize.LEFT;
         if(this.tipText.textWidth > this.MAX_WIDTH)
         {
            this.tipText.multiline = true;
            this.tipText.wordWrap = true;
            this.tipText.width = this.MAX_WIDTH;
         }
         this.tipText.width = this.tipText.textWidth;
         this.tipText.x = 5;
         this.tipText.y = 5;
         this.mCurrentWidth = this.tipText.width;
         graphics.lineStyle(3,10039040);
         graphics.beginFill(16773261);
         graphics.drawRoundRect(0,0,this.tipText.width + 10,this.tipText.height + 10,10,10);
         graphics.endFill();
         this.addChild(this.tipText);
      }
      
      public function setText(param1:String) : void
      {
         this.tipText.text = param1;
         if(this.mCurrentWidth != this.tipText.width)
         {
            graphics.clear();
            graphics.lineStyle(3,10039040);
            graphics.beginFill(16773261);
            graphics.drawRoundRect(0,0,this.tipText.width + 10,this.tipText.height + 10,10,10);
            graphics.endFill();
            this.mCurrentWidth = this.tipText.width;
         }
      }
   }
}

