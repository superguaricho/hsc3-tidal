(
s.reboot { 
  s.options.numBuffers = 1024 * 256; 
  s.options.memSize = 8192 * 32; 
  s.options.numWireBufs = 2048; 
  s.options.maxNodes = 1024 * 32; 
  s.options.numOutputBusChannels = 2;
  s.options.numInputBusChannels = 2; 

  s.waitForBoot { 
    ~dirt.stop; 
    ~dirt = SuperDirt(2, s); 
    ~dirt.loadSoundFiles; 
    ~dirt.start(57120, 0 ! 12); 
    SuperDirt.default = ~dirt;
    s.latency = 0.3;

    // --- hsc3: Reload Listener ---
    OSCFunc({ |msg|
       "hsc3: Syncing Server and SuperDirt...".postln;
       fork {
          s.sendMsg("/d_loadDir", "/home/numa/.local/share/SuperCollider/synthdefs/");
          s.sync;
          SynthDescLib.global.read; 
          0.2.wait; 
          ~dirt.loadSynthDefs; 
          "hsc3: Sync complete. All definitions ready.".postln;
          
          0.5.wait; // Esperar un poco a que sclang respire
          ~printCheatSheet.value;
       }
    }, '/vivid/reload').fix; 

    ~printCheatSheet = {
       "".postln;
       "--- hsc3 Sample Cheat Sheet ---".postln;
       [\bd, \sn, \cp, \hh, \arpy, \casio, \drum].do { |name|
          if (~dirt.buffers[name].notNil) {
             ("Sample '" ++ name ++ "' -> Buffer: " ++ ~dirt.buffers[name][0].bufnum).postln;
          };
       };
       "-------------------------------".postln;
    };

    OSCFunc({ ~printCheatSheet.value; }, '/hsc3/cheat').fix;

    // ---------------------------
  }; 
};
)
