module Sound.Sc3.Tidal.Examples where

import Sound.Sc3
import Sound.Sc3.Tidal

-- | A subtractive bass synth with a resonant low-pass filter
hsc3Bass :: Synthdef
hsc3Bass =
    let cutoff = control kr "cutoff" 800
        rq = control kr "rq" 0.5
        env = line ar 1 0 s_sustain RemoveSynth
        sig = saw ar (s_freq * dirtFreqScale)
        filt = rlpf sig cutoff rq
    in dirtSynthDef "hsc3Bass" (dirtPan2 filt s_pan env)

-- | A simple 2-operator FM synth
hsc3FM :: Synthdef
hsc3FM =
    let modIndex = control kr "modIndex" 10
        modRatio = control kr "modRatio" 2
        env = line ar 1 0 s_sustain RemoveSynth
        -- Modulator
        modFreq = s_freq * modRatio
        modSig = sinOsc ar modFreq 0 * modIndex * s_freq
        -- Carrier
        carSig = sinOsc ar (s_freq * dirtFreqScale + modSig) 0
    in dirtSynthDef "hsc3FM" (dirtPan2 carSig s_pan env)

-- | A percussive noise synth for hats or textures
-- Adjusted: lower cutoff and higher gain for a more "solid" sound
hsc3Hats :: Synthdef
hsc3Hats =
    let cutoff = control kr "cutoff" 8000
        env = line ar 1 0 s_sustain RemoveSynth
        sig = hpf (whiteNoiseId 'α' ar) cutoff * 4.0
    in dirtSynthDef "hsc3Hats" (dirtPan2 sig s_pan env)

-- | A synth that demonstrates pitch glides using Tidal's 'accelerate'
hsc3Glide :: Synthdef
hsc3Glide =
    let env = line ar 1 0 s_sustain RemoveSynth
        sig = saw ar (s_freq * dirtFreqScale)
    in dirtSynthDef "hsc3Glide" (dirtPan2 sig s_pan env)

-- | A granular cloud synthesizer
hsc3Cloud :: Synthdef
hsc3Cloud =
    let grainDensity = control kr "grainDensity" 20
        grainDur = control kr "grainDur" 0.1
        freqVar = control kr "freqVar" 100
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr grainDensity
        noise = whiteNoiseId 'β' kr
        randVal = latch noise trig_
        grainFreq = s_freq + (randVal * freqVar)
        grainEnv = decay2 trig_ 0.01 grainDur
        sig = sinOsc ar grainFreq 0 * grainEnv
    in dirtSynthDef "hsc3Cloud" (dirtPan2 sig s_pan env)

-- | A granular cloud with built-in reverberation
hsc3CloudRev :: Synthdef
hsc3CloudRev =
    let grainDensity = control kr "grainDensity" 20
        grainDur = control kr "grainDur" 0.1
        freqVar = control kr "freqVar" 100
        revMix = control kr "revMix" 0.5
        revRoom = control kr "revRoom" 0.5
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr grainDensity
        noise = whiteNoiseId 'β' kr
        randVal = latch noise trig_
        grainFreq = s_freq + (randVal * freqVar)
        grainEnv = decay2 trig_ 0.01 grainDur
        sig = sinOsc ar grainFreq 0 * grainEnv
        panned = dirtPan2 sig s_pan env
        wet = mce (map (\s -> freeVerb s revMix revRoom 0.5) (mceChannels panned))
    in dirtSynthDef "hsc3CloudRev" wet

-- | A classic sampler (non-granular)
-- Parameters: buf, speed, begin (0..1)
hsc3Sample :: Synthdef
hsc3Sample =
    let buf = control kr "buf" 0
        speed = control kr "speed" 1
        begin = control kr "begin" 0
        env = line ar 1 0 s_sustain RemoveSynth
        frames = bufFrames kr buf
        sig = playBuf 1 ar buf (speed * bufRateScale kr buf) 1 (begin * frames) NoLoop DoNothing
    in dirtSynthDef "hsc3Sample" (dirtPan2 sig s_pan env)

-- | A granular sampler that uses SuperDirt buffers
-- Improved: denser default grain and better grain envelope
hsc3Sampler :: Synthdef
hsc3Sampler =
    let buf = control kr "buf" 0
        speed = control kr "speed" 1
        begin = control kr "begin" 0
        end = control kr "end" 1
        grainDensity = control kr "grainDensity" 40
        grainDur = control kr "grainDur" 0.2
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr grainDensity
        frames = bufFrames kr buf
        startFrame = frames * begin
        endFrame = frames * end
        range_val = endFrame - startFrame
        noise = whiteNoiseId 'β' kr * 0.5 + 0.5
        posRand = latch noise trig_
        grainStart = startFrame + (posRand * range_val)
        -- Smooth grain envelope
        grainEnv = decay2 trig_ 0.01 grainDur
        sig = playBuf 1 ar buf (speed * bufRateScale kr buf) trig_ grainStart Loop DoNothing
    in dirtSynthDef "hsc3Sampler" (dirtPan2 (sig * grainEnv) s_pan env)

-- | A time-stretching granular warp synth
hsc3Warp :: Synthdef
hsc3Warp =
    let buf = control kr "buf" 0
        speed = control kr "speed" 1
        pos = control kr "pos" 0
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr 100
        frames = bufFrames kr buf
        rate = bufRateScale kr buf
        phase = phasor kr 0 (rate * pos) 0 frames 0
        grainStart = latch phase trig_
        grainEnv = decay2 trig_ 0.01 0.1
        sig = playBuf 1 ar buf speed trig_ grainStart Loop DoNothing
    in dirtSynthDef "hsc3Warp" (dirtPan2 (sig * grainEnv) s_pan env)

-- | An advanced slide synth using exponential ramps
hsc3Slide :: Synthdef
hsc3Slide =
    let glideTime = control kr "glideTime" 0.1
        targetFreq = xLine kr s_freq (s_freq * (1 + s_accelerate)) glideTime DoNothing
        env = line ar 1 0 s_sustain RemoveSynth
        sig = saw ar targetFreq
    in dirtSynthDef "hsc3Slide" (dirtPan2 sig s_pan env)

-- | A percussive noise synth with selectable noise types
hsc3Noise :: Synthdef
hsc3Noise =
    let nType = control kr "noiseType" 0
        cutoff = control kr "cutoff" 1000
        rq = control kr "rq" 0.1
        env = line ar 1 0 s_sustain RemoveSynth
        w = whiteNoiseId 'α' ar
        p = pinkNoiseId 'β' ar
        b = brownNoiseId 'γ' ar
        sig = select nType (mce [w, p, b])
        filt = bpf sig cutoff rq * 2.0
    in dirtSynthDef "hsc3Noise" (dirtPan2 filt s_pan env)

-- | A synchronous rhythmic granular synth
hsc3GrainBeat :: Synthdef
hsc3GrainBeat =
    let bps = control kr "beatsPerSec" 8
        grainDur = control kr "grainDur" 0.1
        env = line ar 1 0 s_sustain RemoveSynth
        pulseWidth = grainDur * bps
        m = lfPulse ar bps 0 pulseWidth
        sig = saw ar s_freq
    in dirtSynthDef "hsc3GrainBeat" (dirtPan2 (sig * m) s_pan env)

-- | An advanced granular synth with pitch and size jitter
hsc3Grains :: Synthdef
hsc3Grains =
    let grainDensity = control kr "grainDensity" 20
        grainDur = control kr "grainDur" 0.1
        freqVar = control kr "freqVar" 50
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr grainDensity
        noise1 = whiteNoiseId 'β' kr
        noise2 = pinkNoiseId 'γ' kr
        randFreq = latch noise1 trig_
        grainFreq = s_freq + (randFreq * freqVar)
        randDur = latch noise2 trig_
        actualDur = grainDur * (randDur * 0.5 + 1.0)
        grainEnv = decay2 trig_ 0.01 actualDur
        sig = sinOsc ar grainFreq 0 * grainEnv
        grainPan = (s_pan * 2 - 1) + (randFreq * 0.4)
    in dirtSynthDef "hsc3Grains" (pan2 sig grainPan env)

-- | Granular cloud with per-grain filtering
hsc3GrainFilter :: Synthdef
hsc3GrainFilter =
    let grainDensity = control kr "grainDensity" 20
        grainDur = control kr "grainDur" 0.1
        cutoff = control kr "cutoff" 2000
        rq = control kr "rq" 0.1
        env = line ar 1 0 s_sustain RemoveSynth
        trig_ = dustId 'α' kr grainDensity
        noise = whiteNoiseId 'β' kr
        randCutoff = latch noise trig_
        grainCutoff = cutoff + (randCutoff * 1000)
        grainEnv = decay2 trig_ 0.01 grainDur
        sig = saw ar s_freq * grainEnv
        filt = bpf sig grainCutoff rq * 2.0
    in dirtSynthDef "hsc3GrainFilter" (dirtPan2 filt s_pan env)

-- | A metallic resonator bank excited by noise
hsc3Metallic :: Synthdef
hsc3Metallic =
    let dScale = control kr "decayScale" 1
        env = line ar 1 0 s_sustain RemoveSynth
        excitation = pinkNoiseId 'α' ar * line ar 0.1 0 0.01 DoNothing
        resFreqs = mce [1.0, 1.5, 2.1, 3.7, 5.2] * s_freq
        resAmps = mce [1.0, 0.5, 0.3, 0.2, 0.1]
        resDecays = mce [1.0, 0.8, 0.6, 0.4, 0.3]
        sig = klank excitation 1 0 dScale (mce [resFreqs, resAmps, resDecays])
    in dirtSynthDef "hsc3Metallic" (dirtPan2 sig s_pan env)

-- | A proxy synth to route audio through SuperDirt
hsc3Proxy :: Synthdef
hsc3Proxy =
    let in_bus = control kr "in" 0
        env = line ar 1 1 s_sustain RemoveSynth
        sig = in' 1 ar in_bus
    in dirtSynthDef "hsc3Proxy" (dirtPan2 sig s_pan env)

-- | Load all examples into SuperCollider and notify SuperDirt once
loadExamples :: IO ()
loadExamples = do
    putStrLn "Pushing hsc3 SynthDefs to SuperCollider..."
    mapM_ dirtSendOnly [ hsc3Bass, hsc3FM, hsc3Hats, hsc3Glide, hsc3Cloud
                       , hsc3CloudRev, hsc3Sampler, hsc3Sample, hsc3Warp 
                       , hsc3Slide, hsc3Noise, hsc3GrainBeat, hsc3Grains
                       , hsc3GrainFilter, hsc3Metallic, hsc3Proxy ]
    dirtReload
    putStrLn "All examples loaded successfully!"
