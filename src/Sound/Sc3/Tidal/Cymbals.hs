module Sound.Sc3.Tidal.Cymbals where

import Sound.Sc3
import Sound.Sc3.Tidal

-- | Frecuencias exponenciales distribuidas (100 resonadores)
expFreqs :: [Double]
expFreqs = [300 * (20000/300)**(i/99) | i <- [0..99]]

-- | hsc3Cymbal: Dan Stowell's cymbal model adapted for Tidal/SuperDirt
-- Parameters: sustain (dur), pan
hsc3Cymbal :: Synthdef
hsc3Cymbal =
    let -- Tidal Controls
        dur = s_sustain 
        p = s_pan
        
        -- Control Envelopes scaled by Tidal's sustain
        locutoffenv = envGen ar 1 1 0 1 DoNothing (envPerc 0.5 (dur * 0.8)) * 20000 + 10
        hicutoffenv = 10001 - (envGen ar 1 1 0 1 DoNothing (envPerc 1 (dur * 0.5)) * 10000)
        hiamplenv   = envGen ar 1 0.25 0 1 DoNothing (envPerc 1 (dur * 0.4))
        thwack      = envGen ar 1 1 0 1 DoNothing (envPerc 0.001 0.001)
        
        -- Excitation Drivers
        lodriver = lpf (whiteNoiseId 'a' ar * 0.1) locutoffenv
        hidriver = hpf (whiteNoiseId 'b' ar * 0.1) hicutoffenv * hiamplenv
        
        -- Resonators
        freqs = mce (map constant expFreqs)
        res = mceMean (ringz (lodriver + hidriver + thwack) freqs 1.0)
        
        -- Final Mix
        sig = (res * 1.0) + (lodriver * 2.0) + thwack
        
    in dirtSynthDef "hsc3Cymbal" (dirtPan2 sig p 1.0)

-- | Load the cymbal SynthDef and notify SuperDirt
loadCymbals :: IO ()
loadCymbals = do
    putStrLn "Loading hsc3 Cymbals..."
    dirtSendOnly hsc3Cymbal
    dirtReload
    putStrLn "Cymbal synth 'hsc3Cymbal' loaded and registered for Tidal."
