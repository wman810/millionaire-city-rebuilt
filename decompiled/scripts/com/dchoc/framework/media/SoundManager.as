package com.dchoc.framework.media
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundLoaderContext;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class SoundManager
   {
      
      private static var mAllowInstance:Boolean;
      
      private static var mInstance:SoundManager;
      
      private static const SOUND_INITIAL_VOLUME:Number = 1;
      
      public static const TYPE_MUSIC:int = 0;
      
      public static const TYPE_SFX:int = 1;
      
      private var mSoundsDictionary:Dictionary;
      
      private var mSounds:Array;
      
      private var mSfxOn:Boolean;
      
      private var mMusicOn:Boolean;
      
      public function SoundManager()
      {
         super();
         if(!SoundManager.mAllowInstance)
         {
            throw new Error("ERROR: SoundManager Error: Instantiation failed: Use SoundManager.getInstance() instead of new.");
         }
         this.mSoundsDictionary = new Dictionary(true);
         this.mSounds = new Array();
      }
      
      public static function getInstance() : SoundManager
      {
         if(SoundManager.mInstance == null)
         {
            SoundManager.mAllowInstance = true;
            SoundManager.mInstance = new SoundManager();
            SoundManager.mAllowInstance = false;
         }
         return SoundManager.mInstance;
      }
      
      public function isSoundPaused(param1:String) : Boolean
      {
         return this.mSoundsDictionary[param1].paused;
      }
      
      public function isSfxOn() : Boolean
      {
         return this.mSfxOn;
      }
      
      private function soundCompleteHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:SoundChannel = null;
         var _loc4_:SoundChannel = null;
         for each(_loc2_ in this.mSoundsDictionary)
         {
            _loc3_ = _loc2_.channel as SoundChannel;
            _loc4_ = param1.target as SoundChannel;
            if(_loc4_ == _loc3_)
            {
               _loc4_.removeEventListener(Event.SOUND_COMPLETE,this.soundCompleteHandler);
               _loc2_.channel = _loc2_.sound.play(_loc2_.position,_loc2_.loops,new SoundTransform(_loc2_.volume));
               _loc2_.channel.addEventListener(Event.SOUND_COMPLETE,this.soundCompleteHandler);
            }
         }
      }
      
      public function get sounds() : Array
      {
         return this.mSounds;
      }
      
      public function setSfxOn(param1:Boolean) : void
      {
         var on:Boolean = param1;
         this.mSfxOn = on;
         if(this.mMusicOn == false)
         {
            this.stopAll(false,true);
         }
         try
         {
            Dollars.updateGameConfig();
         }
         catch(e:Error)
         {
         }
      }
      
      private function soundExists(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mSounds.length)
         {
            if(this.mSounds[_loc2_].name == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function getSoundDuration(param1:String) : Number
      {
         return this.mSoundsDictionary[param1].sound.length;
      }
      
      public function pauseAll() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.mSounds.length)
         {
            this.pauseSound(this.mSounds[_loc1_].name);
            _loc1_++;
         }
      }
      
      public function getSoundVolume(param1:String) : Number
      {
         return this.mSoundsDictionary[param1].channel.soundTransform.volume;
      }
      
      public function addLibrarySound(param1:*, param2:String, param3:int) : Boolean
      {
         if(this.soundExists(param2))
         {
            return false;
         }
         var _loc4_:Sound = new param1();
         this.createSound(_loc4_,param2,param3);
         return true;
      }
      
      public function setSoundVolume(param1:String, param2:Number) : void
      {
         var _loc3_:Object = this.mSoundsDictionary[param1];
         var _loc4_:SoundTransform = _loc3_.channel.soundTransform;
         _loc4_.volume = param2;
         _loc3_.channel.soundTransform = _loc4_;
      }
      
      private function restoreSettings() : void
      {
      }
      
      public function isMusicOn() : Boolean
      {
         return this.mMusicOn;
      }
      
      private function createSound(param1:Sound, param2:String, param3:int) : void
      {
         var _loc4_:Object = new Object();
         _loc4_.name = param2;
         _loc4_.sound = param1;
         _loc4_.channel = new SoundChannel();
         _loc4_.position = 0;
         _loc4_.paused = true;
         _loc4_.volume = SOUND_INITIAL_VOLUME;
         _loc4_.startTime = 0;
         _loc4_.loops = 0;
         _loc4_.type = param3;
         this.mSoundsDictionary[param2] = _loc4_;
         this.mSounds.push(_loc4_);
      }
      
      public function addExternalSound(param1:String, param2:String, param3:int, param4:Number = 1000, param5:Boolean = false) : Boolean
      {
         var snd:Sound = null;
         var path:String = param1;
         var name:String = param2;
         var type:int = param3;
         var buffer:Number = param4;
         var checkPolicyFile:Boolean = param5;
         if(this.soundExists(name))
         {
            return false;
         }
         try
         {
            snd = new Sound(new URLRequest(path),new SoundLoaderContext(buffer,checkPolicyFile));
            this.createSound(snd,name,type);
         }
         catch(e:Error)
         {
         }
         return true;
      }
      
      public function setMusicOn(param1:Boolean) : void
      {
         var on:Boolean = param1;
         this.mMusicOn = on;
         if(this.mMusicOn)
         {
            this.playSound(DollarsGame.smInstance.getCurrentMusic(),1,0,-1);
         }
         else
         {
            this.stopAll(true);
         }
         try
         {
            Dollars.updateGameConfig();
         }
         catch(e:Error)
         {
         }
      }
      
      public function removeSound(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mSounds.length)
         {
            if(this.mSounds[_loc2_].name == param1)
            {
               this.mSounds[_loc2_] = null;
               this.mSounds.splice(_loc2_,1);
            }
            _loc2_++;
         }
         delete this.mSoundsDictionary[param1];
      }
      
      public function stopSound(param1:String) : void
      {
         var soundObject:Object = null;
         var name:String = param1;
         try
         {
            if(name == null || this.mSoundsDictionary == null || this.mSoundsDictionary[name] == null)
            {
               return;
            }
            soundObject = this.mSoundsDictionary[name];
            if(soundObject == null)
            {
               return;
            }
            soundObject.paused = true;
            soundObject.channel.stop();
            soundObject.position = soundObject.channel.position;
         }
         catch(e:Error)
         {
            Debug.trace("SoundManager.stopSound(): Error trying to stop file " + name);
         }
      }
      
      public function getSoundPosition(param1:String) : Number
      {
         return this.mSoundsDictionary[param1].channel.position;
      }
      
      public function fadeSound(param1:String, param2:Number = 0, param3:Number = 1) : void
      {
      }
      
      public function getSoundObject(param1:String) : Sound
      {
         return this.mSoundsDictionary[param1].sound;
      }
      
      public function pauseSound(param1:String) : void
      {
         var _loc2_:Object = this.mSoundsDictionary[param1];
         _loc2_.paused = true;
         _loc2_.position = _loc2_.channel.position;
         _loc2_.channel.stop();
      }
      
      public function playSound(param1:String, param2:Number = 1, param3:Number = 0, param4:int = 0) : void
      {
         var soundObject:Object = null;
         var name:String = param1;
         var volume:Number = param2;
         var startTime:Number = param3;
         var loops:int = param4;
         try
         {
            if(name == null || this.mSoundsDictionary == null)
            {
               return;
            }
            soundObject = this.mSoundsDictionary[name];
            if(soundObject == null)
            {
               return;
            }
            if(soundObject.type == TYPE_MUSIC)
            {
               if(!this.isMusicOn())
               {
                  return;
               }
            }
            else if(soundObject.type == TYPE_SFX)
            {
               if(!this.isSfxOn())
               {
                  return;
               }
            }
            soundObject.volume = volume;
            soundObject.startTime = startTime;
            soundObject.loops = loops;
            if(soundObject.paused)
            {
               soundObject.channel = soundObject.sound.play(soundObject.position,soundObject.loops,new SoundTransform(soundObject.volume));
            }
            else
            {
               soundObject.channel = soundObject.sound.play(startTime,soundObject.loops,new SoundTransform(soundObject.volume));
            }
            soundObject.paused = false;
            if(loops < 0)
            {
               soundObject.channel.addEventListener(Event.SOUND_COMPLETE,this.soundCompleteHandler);
            }
         }
         catch(error:Error)
         {
            Debug.trace("SoundManager.playSound(): Error trying to play file " + name);
         }
      }
      
      public function removeAll() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.mSounds.length)
         {
            this.mSounds[_loc1_] = null;
            _loc1_++;
         }
         this.mSounds = new Array();
         this.mSoundsDictionary = new Dictionary(true);
      }
      
      public function stopAll(param1:Boolean = false, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         if(this.mSounds != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.mSounds.length)
            {
               if(!(param1 && this.mSounds[_loc3_].type == TYPE_SFX))
               {
                  if(!(param2 && this.mSounds[_loc3_].type == TYPE_MUSIC))
                  {
                     this.stopSound(this.mSounds[_loc3_].name);
                  }
               }
               _loc3_++;
            }
         }
      }
   }
}

