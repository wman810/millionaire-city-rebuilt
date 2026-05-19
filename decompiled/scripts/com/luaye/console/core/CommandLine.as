package com.luaye.console.core
{
   import com.luaye.console.Console;
   import com.luaye.console.utils.Utils;
   import com.luaye.console.utils.WeakObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.flash_proxy;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class CommandLine extends EventDispatcher
   {
      
      public static const CHANGED_SCOPE:String = "changedScope";
      
      private static const VALUE_CONST:String = "#";
      
      private static const MAX_INTERNAL_STACK_TRACE:int = 1;
      
      private var _values:Array;
      
      private var _reserved:Array;
      
      private var _master:Console;
      
      private var _saved:WeakObject;
      
      private var _scope:*;
      
      private var _tools:CommandTools;
      
      private var _prevScope:*;
      
      public function CommandLine(param1:Console)
      {
         super();
         this._master = param1;
         this._tools = new CommandTools(this.report);
         this._saved = new WeakObject();
         this._scope = param1;
         this._saved.set("C",param1);
         this._reserved = new Array("returned","base","C");
      }
      
      public function get scopeString() : String
      {
         return Utils.shortClassName(this._scope);
      }
      
      public function run(param1:String) : *
      {
         var v:*;
         var isclean:Boolean;
         var str:String = param1;
         this.report("&gt; " + str,5,false);
         if(!this._master.commandLineAllowed)
         {
            this.report("CommandLine is disabled.",10);
            return null;
         }
         v = null;
         isclean = this._values == null;
         if(isclean)
         {
            this._values = [];
         }
         try
         {
            if(str.charAt(0) == "/")
            {
               this.execCommand(str);
            }
            else
            {
               v = this.exec(str);
            }
         }
         catch(e:Error)
         {
            reportError(e);
         }
         if(isclean)
         {
            this._values = null;
         }
         return v;
      }
      
      public function get base() : Object
      {
         return this._saved.get("base");
      }
      
      private function makeNew(param1:String) : *
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc2_:int = param1.indexOf("(");
         var _loc3_:String = _loc2_ > 0 ? param1.substring(0,_loc2_) : param1;
         _loc3_ = this.ignoreWhite(_loc3_);
         var _loc4_:* = this.execValue(_loc3_).value;
         if(_loc2_ > 0)
         {
            _loc5_ = param1.indexOf(")",_loc2_);
            _loc6_ = param1.substring(_loc2_ + 1,_loc5_);
            _loc6_ = _loc6_.replace(/\s/g,"");
            _loc7_ = [];
            if(_loc6_)
            {
               _loc7_ = this.execValue(_loc6_).value;
            }
            _loc8_ = int(_loc7_.length);
            if(_loc8_ == 0)
            {
               return new _loc4_();
            }
            if(_loc8_ == 1)
            {
               return new _loc4_(_loc7_[0]);
            }
            if(_loc8_ == 2)
            {
               return new _loc4_(_loc7_[0],_loc7_[1]);
            }
            if(_loc8_ == 3)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2]);
            }
            if(_loc8_ == 4)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3]);
            }
            if(_loc8_ == 5)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4]);
            }
            if(_loc8_ == 6)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5]);
            }
            if(_loc8_ == 7)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6]);
            }
            if(_loc8_ == 8)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7]);
            }
            if(_loc8_ == 9)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8]);
            }
            if(_loc8_ == 10)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9]);
            }
            if(_loc8_ == 11)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10]);
            }
            if(_loc8_ == 12)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10],_loc7_[11]);
            }
            if(_loc8_ == 13)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10],_loc7_[11],_loc7_[12]);
            }
            if(_loc8_ == 14)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10],_loc7_[11],_loc7_[12],_loc7_[13]);
            }
            if(_loc8_ == 15)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10],_loc7_[11],_loc7_[12],_loc7_[13],_loc7_[14]);
            }
            if(_loc8_ >= 16)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9],_loc7_[10],_loc7_[11],_loc7_[12],_loc7_[13],_loc7_[14],_loc7_[15]);
            }
         }
         return null;
      }
      
      private function operate(param1:*, param2:String, param3:*) : *
      {
         switch(param2)
         {
            case "=":
               return param3;
            case "+":
               return param1 + param3;
            case "-":
               return param1 - param3;
            case "*":
               return param1 * param3;
            case "/":
               return param1 / param3;
            case "%":
               return param1 % param3;
            case "^":
               return param1 ^ param3;
            case "&":
               return param1 & param3;
            case ">>":
               return param1 >> param3;
            case ">>>":
               return param1 >>> param3;
            case "<<":
               return param1 << param3;
            case "~":
               return ~param3;
            case "|":
               return param1 | param3;
            case "!":
               return !param3;
            case ">":
               return param1 > param3;
            case ">=":
               return param1 >= param3;
            case "<":
               return param1 < param3;
            case "<=":
               return param1 <= param3;
            case "||":
               return param1 || param3;
            case "&&":
               return param1 && param3;
            case "is":
               return param1 is param3;
            case "typeof":
               return typeof param3;
            case "==":
               return param1 == param3;
            case "===":
               return param1 === param3;
            case "!=":
               return param1 != param3;
            case "!==":
               return param1 !== param3;
            default:
               return;
         }
      }
      
      public function destory() : void
      {
         this._saved = null;
         this._master = null;
         this._reserved = null;
         this._tools = null;
      }
      
      private function execNest(param1:String) : *
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:* = 0;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:* = undefined;
         param1 = this.ignoreWhite(param1);
         var _loc2_:int = param1.lastIndexOf("(");
         while(_loc2_ >= 0)
         {
            _loc4_ = param1.indexOf(")",_loc2_);
            if(param1.substring(_loc2_ + 1,_loc4_).search(/\w/) >= 0)
            {
               _loc5_ = _loc2_;
               _loc6_ = _loc2_ + 1;
               while(_loc5_ >= 0 && _loc5_ < _loc6_)
               {
                  _loc5_++;
                  _loc5_ = param1.indexOf("(",_loc5_);
                  _loc6_ = param1.indexOf(")",_loc6_ + 1);
               }
               _loc7_ = param1.substring(_loc2_ + 1,_loc6_);
               _loc8_ = false;
               _loc9_ = int(_loc2_ - 1);
               while(true)
               {
                  _loc10_ = param1.charAt(_loc9_);
                  if(Boolean(_loc10_.match(/[^\s]/)) || _loc9_ <= 0)
                  {
                     break;
                  }
                  _loc9_--;
               }
               if(_loc10_.match(/\w/))
               {
                  _loc8_ = true;
               }
               if(_loc8_)
               {
                  _loc11_ = _loc7_.split(",");
                  param1 = this.tempValue(param1,new Value(_loc11_),_loc2_ + 1,_loc6_);
                  for(_loc12_ in _loc11_)
                  {
                     _loc11_[_loc12_] = this.execOperations(this.ignoreWhite(_loc11_[_loc12_])).value;
                  }
               }
               else
               {
                  _loc13_ = new Value(_loc13_);
                  param1 = this.tempValue(param1,_loc13_,_loc2_,_loc6_ + 1);
                  _loc13_.value = this.execOperations(this.ignoreWhite(_loc7_)).value;
               }
            }
            _loc2_ = param1.lastIndexOf("(",_loc2_ - 1);
         }
         var _loc3_:* = this.execOperations(param1).value;
         this.doReturn(_loc3_);
         return _loc3_;
      }
      
      private function doReturn(param1:*, param2:Boolean = false) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = typeof param1;
         if(param1)
         {
            this._saved.set("returned",param1,true);
            if(param1 !== this._scope && (param2 || _loc4_ == "object" || _loc4_ == "xml"))
            {
               _loc3_ = true;
               this._prevScope = this._scope;
               this._scope = param1;
               dispatchEvent(new Event(CHANGED_SCOPE));
            }
         }
         var _loc5_:String = String(param1);
         _loc5_ = _loc5_.replace(/</gim,"&lt;");
         _loc5_ = _loc5_.replace(/>/gim,"&gt;");
         this.report((_loc3_ ? "<b>+</b> " : "") + "Returned " + getQualifiedClassName(param1) + ": <b>" + _loc5_ + "</b>",-2);
      }
      
      private function execOperations(param1:String) : Value
      {
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:String = null;
         var _loc2_:RegExp = /\s*(((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\=\=?|\!\=|\>\>?\>?|\<\<?)\=?)|=|\~|\sis\s|typeof\s)\s*/g;
         var _loc3_:Object = _loc2_.exec(param1);
         var _loc4_:Array = [];
         if(_loc3_ == null)
         {
            _loc4_.push(param1);
         }
         else
         {
            _loc11_ = 0;
            while(_loc3_ != null)
            {
               _loc12_ = int(_loc3_.index);
               _loc13_ = _loc3_[0];
               _loc3_ = _loc2_.exec(param1);
               if(_loc3_ == null)
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(_loc13_.replace(/\s/g,""));
                  _loc4_.push(param1.substring(_loc12_ + _loc13_.length));
               }
               else
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(_loc13_.replace(/\s/g,""));
                  _loc11_ = _loc12_ + _loc13_.length;
               }
            }
         }
         var _loc5_:int = int(_loc4_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_[_loc6_] = this.execSimple(_loc4_[_loc6_]);
            _loc6_ += 2;
         }
         var _loc9_:RegExp = /((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\>\>\>?|\<\<)\=)|=/;
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc7_.replace(_loc9_,"") != "")
            {
               _loc8_ = this.operate(_loc4_[_loc6_ - 1].value,_loc7_,_loc4_[_loc6_ + 1].value);
               _loc4_[_loc6_ - 1].value = _loc8_;
               _loc4_.splice(_loc6_,2);
               _loc6_ -= 2;
               _loc5_ -= 2;
            }
            _loc6_ += 2;
         }
         _loc4_.reverse();
         var _loc10_:Value = _loc4_[0];
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc7_.replace(_loc9_,"") == "")
            {
               _loc10_ = _loc4_[_loc6_ + 1];
               if(_loc7_.length > 1)
               {
                  _loc7_ = _loc7_.substring(0,_loc7_.length - 1);
               }
               _loc8_ = this.operate(_loc10_.value,_loc7_,_loc4_[_loc6_ - 1].value);
               _loc10_.value = _loc8_;
               if(_loc10_.base != null)
               {
                  _loc10_.base[_loc10_.prop] = _loc10_.value;
               }
            }
            _loc6_ += 2;
         }
         return _loc10_;
      }
      
      private function exec(param1:String) : *
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc2_:RegExp = /('(.*?)[^\\]')|("(.*?)[^\\]")|''|""/;
         var _loc3_:Object = _loc2_.exec(param1);
         while(_loc3_ != null)
         {
            _loc7_ = _loc3_[0];
            _loc8_ = _loc7_.charAt(0);
            _loc9_ = _loc7_.indexOf(_loc8_);
            _loc10_ = _loc7_.lastIndexOf(_loc8_);
            _loc11_ = _loc7_.substring(_loc9_ + 1,_loc10_).replace(/\\(.)/g,"$1");
            param1 = this.tempValue(param1,new Value(_loc11_),_loc3_.index + _loc9_,_loc3_.index + _loc10_ + 1);
            _loc3_ = _loc2_.exec(param1);
         }
         if(param1.search(/'|"/) >= 0)
         {
            throw new Error("Bad syntax extra quotation marks");
         }
         var _loc4_:* = null;
         var _loc5_:Array = param1.split(/\s*;\s*/);
         for each(_loc6_ in _loc5_)
         {
            if(_loc6_.length)
            {
               _loc4_ = this.execNest(_loc6_);
            }
         }
         return _loc4_;
      }
      
      public function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         var _loc4_:String = null;
         param3 = param3 || this._master.strongRef || param2 is Function;
         param1 = param1.replace(/[^\w]*/g,"");
         if(this._reserved.indexOf(param1) >= 0)
         {
            this.report("ERROR: The name [" + param1 + "] is reserved",10);
            return;
         }
         this._saved.set(param1,param2,param3);
         if(!this._master.quiet)
         {
            _loc4_ = param3 ? "STRONG" : "WEAK";
            this.report("Stored <p5>$" + param1 + "</p5> for <b>" + getQualifiedClassName(param2) + "</b> using <b>" + _loc4_ + "</b> reference.",-1);
         }
      }
      
      private function execSimple(param1:String) : Value
      {
         var reg:RegExp;
         var result:Object;
         var previndex:int;
         var firstparts:Array = null;
         var newstr:String = null;
         var defclose:int = 0;
         var newobj:* = undefined;
         var classstr:String = null;
         var def:* = undefined;
         var havemore:Boolean = false;
         var index:int = 0;
         var isFun:Boolean = false;
         var basestr:String = null;
         var newv:Value = null;
         var newbase:* = undefined;
         var closeindex:int = 0;
         var paramstr:String = null;
         var params:Array = null;
         var nss:Array = null;
         var ns:Namespace = null;
         var nsv:* = undefined;
         var str:String = param1;
         var v:Value = new Value();
         if(str.indexOf("new ") == 0)
         {
            newstr = str;
            defclose = str.indexOf(")");
            if(defclose >= 0)
            {
               newstr = str.substring(0,defclose + 1);
            }
            newobj = this.makeNew(newstr.substring(4));
            str = this.tempValue(str,new Value(newobj,newobj,newstr),0,newstr.length);
         }
         reg = /\.|\(/g;
         result = reg.exec(str);
         if(result == null || !isNaN(Number(str)))
         {
            return this.execValue(str,null);
         }
         firstparts = str.split("(")[0].split(".");
         if(firstparts.length > 0)
         {
            while(firstparts.length)
            {
               classstr = firstparts.join(".");
               try
               {
                  def = getDefinitionByName(this.ignoreWhite(classstr));
                  havemore = str.length > classstr.length;
                  str = this.tempValue(str,new Value(def,def,classstr),0,classstr.length);
                  if(havemore)
                  {
                     reg.lastIndex = 0;
                     result = reg.exec(str);
                     break;
                  }
                  return this.execValue(str,null);
               }
               catch(e:Error)
               {
                  firstparts.pop();
               }
            }
         }
         previndex = 0;
         while(true)
         {
            if(result == null)
            {
               return v;
            }
            index = int(result.index);
            isFun = str.charAt(index) == "(";
            basestr = this.ignoreWhite(str.substring(previndex,index));
            newv = this.execValue(basestr,v.base);
            newbase = newv.value;
            v.base = newv.base;
            if(isFun)
            {
               closeindex = str.indexOf(")",index);
               paramstr = str.substring(index + 1,closeindex);
               paramstr = paramstr.replace(/\s/g,"");
               params = [];
               if(paramstr)
               {
                  params = this.execValue(paramstr).value;
               }
               if(!(newbase is Function))
               {
                  try
                  {
                     nss = [AS3,flash_proxy];
                     for each(ns in nss)
                     {
                        nsv = v.base.ns::[basestr];
                        if(nsv is Function)
                        {
                           newbase = nsv;
                           break;
                        }
                     }
                  }
                  catch(e:Error)
                  {
                  }
                  if(!(newbase is Function))
                  {
                     break;
                  }
               }
               v.value = (newbase as Function).apply(v.base,params);
               v.base = v.value;
               index = closeindex + 1;
            }
            else
            {
               v.value = newbase;
            }
            v.prop = basestr;
            previndex = index + 1;
            reg.lastIndex = index + 1;
            result = reg.exec(str);
            if(result != null)
            {
               v.base = v.value;
            }
            else if(index + 1 < str.length)
            {
               v.base = v.value;
               reg.lastIndex = str.length;
               result = {"index":str.length};
            }
         }
         throw new Error(basestr + " is not a function.");
      }
      
      private function execValue(param1:String, param2:* = null) : Value
      {
         var v:Value = null;
         var vv:Value = null;
         var key:String = null;
         var str:String = param1;
         var base:* = param2;
         var nobase:Boolean = base ? false : true;
         v = new Value(null,base,str);
         base = base ? base : this._scope;
         if(nobase && (!base || !base.hasOwnProperty(str)))
         {
            if(str == "true")
            {
               v.value = true;
            }
            else if(str == "false")
            {
               v.value = false;
            }
            else if(str == "this")
            {
               v.base = this._scope;
               v.value = this._scope;
            }
            else if(str == "null")
            {
               v.value = null;
            }
            else if(str == "NaN")
            {
               v.value = NaN;
            }
            else if(str == "Infinity")
            {
               v.value = Infinity;
            }
            else if(str == "undefined")
            {
               v.value = undefined;
            }
            else if(!isNaN(Number(str)))
            {
               v.value = Number(str);
            }
            else if(str.indexOf(VALUE_CONST) == 0)
            {
               vv = this._values[str.substring(VALUE_CONST.length)];
               v.base = vv.base;
               v.value = vv.value;
            }
            else if(str.charAt(0) == "$")
            {
               key = str.substring(1);
               v.value = this._saved[key];
               if(this._reserved.indexOf(key) < 0)
               {
                  if(v.value == null)
                  {
                     this.store(key,v.value);
                  }
                  v.base = this._saved;
                  v.prop = key;
               }
            }
            else
            {
               try
               {
                  v.value = getDefinitionByName(str);
                  v.base = v.value;
               }
               catch(e:Error)
               {
                  v.base = base;
                  v.value = base[str];
               }
            }
         }
         else
         {
            v.base = base;
            v.value = base[str];
         }
         return v;
      }
      
      public function set base(param1:Object) : void
      {
         if(this.base)
         {
            this.report("Set new commandLine base from " + this.base + " to " + param1,10);
         }
         else
         {
            this._scope = param1;
            dispatchEvent(new Event(CHANGED_SCOPE));
         }
         this._saved.set("base",param1,this._master.strongRef);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         this._tools.map(param1,param2);
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         this._tools.inspect(param1,param2);
      }
      
      private function reportError(param1:Error) : void
      {
         var _loc10_:String = null;
         var _loc2_:String = param1.hasOwnProperty("getStackTrace") ? param1.getStackTrace() : String(param1);
         if(!_loc2_)
         {
            _loc2_ = String(param1);
         }
         var _loc3_:Array = _loc2_.split(/\n\s*/);
         var _loc4_:* = 10;
         var _loc5_:int = 0;
         var _loc6_:String = getQualifiedClassName(this);
         var _loc7_:int = int(_loc3_.length);
         var _loc8_:Array = [];
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_)
         {
            _loc10_ = _loc3_[_loc9_];
            if(MAX_INTERNAL_STACK_TRACE >= 0 && _loc10_.search(new RegExp("\\s*at " + _loc6_)) == 0)
            {
               if(_loc5_ >= MAX_INTERNAL_STACK_TRACE && _loc9_ > 0)
               {
                  break;
               }
               _loc5_++;
            }
            _loc8_.push("<p" + _loc4_ + ">&gt;&nbsp;" + _loc10_.replace(/\s/,"&nbsp;") + "</p" + _loc4_ + ">");
            if(_loc4_ > 6)
            {
               _loc4_--;
            }
            _loc9_++;
         }
         this.report(_loc8_.join("\n"),9);
      }
      
      private function ignoreWhite(param1:String) : String
      {
         param1 = param1.replace(/\s*(.*)/,"$1");
         var _loc2_:* = int(param1.length - 1);
         while(_loc2_ > 0)
         {
            if(!param1.charAt(_loc2_).match(/\s/))
            {
               break;
            }
            param1 = param1.substring(0,_loc2_);
            _loc2_--;
         }
         return param1;
      }
      
      private function execCommand(param1:String) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc9_:Boolean = false;
         var _loc2_:int = param1.indexOf(" ");
         var _loc3_:String = param1.substring(1,_loc2_ > 0 ? _loc2_ : param1.length);
         var _loc4_:String = _loc2_ > 0 ? param1.substring(_loc2_ + 1) : "";
         if(_loc3_ == "help")
         {
            this._tools.printHelp();
         }
         else if(_loc3_ == "remap")
         {
            this.doReturn(this._tools.reMap(_loc4_,this._master.stage));
         }
         else if(_loc3_ == "strong")
         {
            if(_loc4_ == "true")
            {
               this._master.strongRef = true;
               this.report("Now using STRONG referencing.",10);
            }
            else if(_loc4_ == "false")
            {
               this._master.strongRef = false;
               this.report("Now using WEAK referencing.",10);
            }
            else if(this._master.strongRef)
            {
               this.report("Using STRONG referencing. \'/strong false\' to use weak",-2);
            }
            else
            {
               this.report("Using WEAK referencing. \'/strong true\' to use strong",-2);
            }
         }
         else if(_loc3_ == "save" || _loc3_ == "store" || _loc3_ == "savestrong" || _loc3_ == "storestrong")
         {
            if(this._scope)
            {
               _loc4_ = _loc4_.replace(/[^\w]/g,"");
               if(!_loc4_)
               {
                  this.report("ERROR: Give a name to save.",10);
               }
               else
               {
                  this.store(_loc4_,this._scope,_loc3_ == "savestrong" || _loc3_ == "storestrong");
               }
            }
            else
            {
               this.report("Nothing to save",10);
            }
         }
         else if(_loc3_ == "string")
         {
            this.report("String with " + _loc4_.length + " chars stored. Use /save <i>(name)</i> to save.",-2);
            this._scope = _loc4_;
            dispatchEvent(new Event(CHANGED_SCOPE));
         }
         else if(_loc3_ == "saved" || _loc3_ == "stored")
         {
            this.report("Saved vars: ",-1);
            _loc5_ = 0;
            _loc6_ = 0;
            for(_loc7_ in this._saved)
            {
               _loc8_ = this._saved[_loc7_];
               _loc5_++;
               if(_loc8_ == null)
               {
                  _loc6_++;
               }
               this.report("<b>$" + _loc7_ + "</b> = " + (_loc8_ == null ? "null" : getQualifiedClassName(_loc8_)),-2);
            }
            this.report("Found " + _loc5_ + " item(s), " + _loc6_ + " empty (or garbage collected).",-1);
         }
         else if(_loc3_ == "filter" || _loc3_ == "search")
         {
            this._master.filterText = param1.substring(8);
         }
         else if(_loc3_ == "inspect" || _loc3_ == "inspectfull")
         {
            if(this._scope)
            {
               _loc9_ = _loc3_ == "inspectfull" ? true : false;
               this.inspect(this._scope,_loc9_);
            }
            else
            {
               this.report("Empty",10);
            }
         }
         else if(_loc3_ == "map")
         {
            if(this._scope)
            {
               this.map(this._scope as DisplayObjectContainer,int(_loc4_));
            }
            else
            {
               this.report("Empty",10);
            }
         }
         else if(_loc3_ == "/")
         {
            this.doReturn(this._prevScope ? this._prevScope : this.base);
         }
         else if(_loc3_ == "scope")
         {
            this.doReturn(this._saved["returned"],true);
         }
         else if(_loc3_ == "base")
         {
            this.doReturn(this.base);
         }
         else
         {
            this.report("Undefined command <b>/help</b> for info.",10);
         }
      }
      
      public function report(param1:*, param2:Number = 1, param3:Boolean = true) : void
      {
         this._master.report(param1,param2,param3);
      }
      
      private function tempValue(param1:String, param2:*, param3:int, param4:int) : String
      {
         param1 = Utils.replaceByIndexes(param1,VALUE_CONST + this._values.length,param3,param4);
         this._values.push(param2);
         return param1;
      }
   }
}

class Value
{
   
   public var value:*;
   
   public var prop:String;
   
   public var base:Object;
   
   public function Value(param1:* = null, param2:Object = null, param3:String = null)
   {
      super();
      this.base = param2;
      this.prop = param3;
      this.value = param1;
   }
}
