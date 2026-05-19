package com.luaye.console.view
{
   import flash.text.StyleSheet;
   import flash.text.TextFormat;
   
   public class Style
   {
      
      public var css:StyleSheet;
      
      public var commandLineColor:Number;
      
      public var bottomLineColor:Number;
      
      public var panelBackgroundAlpha:Number;
      
      public var panelBackgroundColor:int;
      
      public var textFormat:TextFormat;
      
      public var panelScalerColor:Number;
      
      private var _preset:int = 0;
      
      public function Style(param1:int = 1)
      {
         super();
         this.css = new StyleSheet();
         this.preset = param1;
         if(this._preset <= 0)
         {
            this.preset = 1;
         }
      }
      
      public function set preset(param1:int) : void
      {
         if(hasOwnProperty(["preset" + param1]))
         {
            this["preset" + param1]();
            this._preset = param1;
         }
      }
      
      public function preset4() : void
      {
         this.preset2();
         this.panelBackgroundAlpha = 1;
      }
      
      public function preset1() : void
      {
         this.panelBackgroundColor = 0;
         this.panelScalerColor = 8912896;
         this.commandLineColor = 1092096;
         this.bottomLineColor = 16711680;
         this.panelBackgroundAlpha = 0.8;
         this.textFormat = new TextFormat("Arial",12,16777215);
         this.css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         this.css.setStyle("w",{
            "color":"#FFFFFF",
            "fontFamily":"Arial",
            "fontSize":"12",
            "display":"inline"
         });
         this.css.setStyle("s",{
            "color":"#CCCCCC",
            "fontFamily":"Arial",
            "fontSize":"10",
            "display":"inline"
         });
         this.css.setStyle("y",{
            "color":"#DD5500",
            "display":"inline"
         });
         this.css.setStyle("ro",{
            "color":"#DD5500",
            "fontFamily":"Arial",
            "fontSize":"11",
            "display":"inline"
         });
         this.css.setStyle("roBold",{
            "color":"#EE6611",
            "fontWeight":"bold"
         });
         this.css.setStyle("menu",{
            "color":"#FF8800",
            "display":"inline"
         });
         this.css.setStyle("chs",{
            "color":"#FFFFFF",
            "fontSize":"11",
            "leading":"2",
            "display":"inline"
         });
         this.css.setStyle("ch",{
            "color":"#0099CC",
            "display":"inline"
         });
         this.css.setStyle("tooltip",{
            "color":"#DD5500",
            "fontFamily":"Arial",
            "textAlign":"center"
         });
         this.css.setStyle("p",{
            "fontFamily":"Verdana",
            "fontSize":"11"
         });
         this.css.setStyle("l1",{"color":"#0099CC"});
         this.css.setStyle("l2",{"color":"#FF8800"});
         this.css.setStyle("p0",{
            "color":"#336633",
            "display":"inline"
         });
         this.css.setStyle("p1",{
            "color":"#33AA33",
            "display":"inline"
         });
         this.css.setStyle("p2",{
            "color":"#77D077",
            "display":"inline"
         });
         this.css.setStyle("p3",{
            "color":"#AAEEAA",
            "display":"inline"
         });
         this.css.setStyle("p4",{
            "color":"#D6FFD6",
            "display":"inline"
         });
         this.css.setStyle("p5",{
            "color":"#E6E6E6",
            "display":"inline"
         });
         this.css.setStyle("p6",{
            "color":"#FFD6D6",
            "display":"inline"
         });
         this.css.setStyle("p7",{
            "color":"#FFAAAA",
            "display":"inline"
         });
         this.css.setStyle("p8",{
            "color":"#FF7777",
            "display":"inline"
         });
         this.css.setStyle("p9",{
            "color":"#FF2222",
            "display":"inline"
         });
         this.css.setStyle("p10",{
            "color":"#FF2222",
            "display":"inline"
         });
         this.css.setStyle("p100",{
            "color":"#FF0000",
            "fontWeight":"bold",
            "display":"inline"
         });
         this.css.setStyle("p-1",{
            "color":"#0099CC",
            "display":"inline"
         });
         this.css.setStyle("p-2",{
            "color":"#FF8800",
            "display":"inline"
         });
      }
      
      public function preset3() : void
      {
         this.preset1();
         this.panelBackgroundAlpha = 1;
      }
      
      public function preset2() : void
      {
         this.panelBackgroundColor = 16777215;
         this.panelScalerColor = 16711680;
         this.commandLineColor = 6736896;
         this.bottomLineColor = 16711680;
         this.panelBackgroundAlpha = 0.8;
         this.textFormat = new TextFormat("Arial",12,0);
         this.css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         this.css.setStyle("w",{
            "color":"#000000",
            "fontFamily":"Arial",
            "fontSize":"12",
            "display":"inline"
         });
         this.css.setStyle("s",{
            "color":"#333333",
            "fontFamily":"Arial",
            "fontSize":"10",
            "display":"inline"
         });
         this.css.setStyle("y",{
            "color":"#881100",
            "display":"inline"
         });
         this.css.setStyle("ro",{
            "color":"#661100",
            "fontFamily":"Arial",
            "fontSize":"11",
            "display":"inline"
         });
         this.css.setStyle("roBold",{
            "color":"#AA4400",
            "fontWeight":"bold"
         });
         this.css.setStyle("menu",{
            "color":"#CC1100",
            "display":"inline"
         });
         this.css.setStyle("chs",{
            "color":"#000000",
            "fontSize":"11",
            "leading":"2",
            "display":"inline"
         });
         this.css.setStyle("ch",{
            "color":"#0066AA",
            "display":"inline"
         });
         this.css.setStyle("tooltip",{
            "color":"#AA3300",
            "fontFamily":"Arial",
            "textAlign":"center"
         });
         this.css.setStyle("p",{
            "fontFamily":"Verdana",
            "fontSize":"11"
         });
         this.css.setStyle("l1",{"color":"#0099CC"});
         this.css.setStyle("l2",{"color":"#FF8800"});
         this.css.setStyle("p0",{
            "color":"#666666",
            "display":"inline"
         });
         this.css.setStyle("p1",{
            "color":"#339033",
            "display":"inline"
         });
         this.css.setStyle("p2",{
            "color":"#227722",
            "display":"inline"
         });
         this.css.setStyle("p3",{
            "color":"#115511",
            "display":"inline"
         });
         this.css.setStyle("p4",{
            "color":"#003300",
            "display":"inline"
         });
         this.css.setStyle("p5",{
            "color":"#000000",
            "display":"inline"
         });
         this.css.setStyle("p6",{
            "color":"#660000",
            "display":"inline"
         });
         this.css.setStyle("p7",{
            "color":"#990000",
            "display":"inline"
         });
         this.css.setStyle("p8",{
            "color":"#BB0000",
            "display":"inline"
         });
         this.css.setStyle("p9",{
            "color":"#DD0000",
            "display":"inline"
         });
         this.css.setStyle("p10",{
            "color":"#FF0000",
            "display":"inline"
         });
         this.css.setStyle("p100",{
            "color":"#FF0000",
            "fontWeight":"bold",
            "display":"inline"
         });
         this.css.setStyle("p-1",{
            "color":"#0099CC",
            "display":"inline"
         });
         this.css.setStyle("p-2",{
            "color":"#FF6600",
            "display":"inline"
         });
      }
      
      public function preset951() : void
      {
         this.preset1();
         this.panelBackgroundAlpha = 0.55;
      }
      
      public function get preset() : int
      {
         return this._preset;
      }
   }
}

