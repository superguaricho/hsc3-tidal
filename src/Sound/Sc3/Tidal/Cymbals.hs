module Sound.Sc3.Tidal.Cymbals where

import Sound.Sc3
import Sound.Sc3.Tidal

-- | Frecuencias exponenciales distribuidas (100 resonadores)
expFreqs :: [Double]
expFreqs = [300 * (20000/300)**(i/99) | i <- [0..99]]

-- | Frecuencias para Ride (más altas, desde 1kHz)
rideFreqs :: [Double]
rideFreqs = [1000 * (20000/1000)**(i/99) | i <- [0..99]]

-- | hsc3Cym: Basic "Bwoosh" approach
hsc3Cym :: Synthdef
hsc3Cym =
    let dur = s_sustain
        p = s_pan
        cutoffenv = envGen ar 1 1 0 1 DoNothing (envPerc 0.5 dur) * 20000 + 10
        lodriver = lpf (whiteNoiseId 'a' ar * 0.1) cutoffenv
        res = mceMean (ringz lodriver (mce (map constant expFreqs)) 1.0)
    in dirtSynthDef "hsc3Cym" (dirtPan2 res p 1.0)

-- | hsc3CymS: "Add a stick" approach
hsc3CymS :: Synthdef
hsc3CymS =
    let dur = s_sustain 
        p = s_pan
        locutoffenv = envGen ar 1 1 0 1 DoNothing (envPerc 0.5 (dur * 0.8)) * 20000 + 10
        hicutoffenv = 10001 - (envGen ar 1 1 0 1 DoNothing (envPerc 1 (dur * 0.5)) * 10000)
        hiamplenv   = envGen ar 1 0.25 0 1 DoNothing (envPerc 1 (dur * 0.4))
        thwack      = envGen ar 1 1 0 1 DoNothing (envPerc 0.001 0.001)
        lodriver = lpf (whiteNoiseId 'b' ar * 0.1) locutoffenv
        hidriver = hpf (whiteNoiseId 'c' ar * 0.1) hicutoffenv * hiamplenv
        freqs = mce (map constant expFreqs)
        res = mceMean (ringz (lodriver + hidriver + thwack) freqs 1.0)
        sig = (res * 1.0) + (lodriver * 2.0) + thwack
    in dirtSynthDef "hsc3CymS" (dirtPan2 sig p 1.0)

-- | hsc3CymSusp: Suspended Cymbal (soft mallets)
-- Characteristics: Slower attack, long resonance.
hsc3CymSusp :: Synthdef
hsc3CymSusp =
    let dur = s_sustain
        p = s_pan
        atk = dur * 0.2
        -- Smooth excitation envelope
        excEnv = envGen ar 1 0.05 0 1 DoNothing (envPerc atk (dur - atk))
        excitation = lpf (whiteNoiseId 'd' ar * excEnv) 3000
        -- Long ring time (2.0)
        freqs = mce (map constant expFreqs)
        res = mceMean (ringz excitation freqs 2.0)
    in dirtSynthDef "hsc3CymSusp" (dirtPan2 res p 1.0)

-- | hsc3CymSplash: Orchestral Splash/Clash Cymbal
-- Characteristics: Violent explosive attack.
hsc3CymSplash :: Synthdef
hsc3CymSplash =
    let dur = s_sustain
        p = s_pan
        -- Violent thwack
        thwack = envGen ar 1 1.5 0 1 DoNothing (envPerc 0.001 0.05) * whiteNoiseId 'e' ar
        -- Broad excitation
        locEnv = line ar 20000 200 dur DoNothing
        lodriver = lpf (whiteNoiseId 'f' ar * 0.2) locEnv
        hidriver = hpf (whiteNoiseId 'g' ar * 0.2) 5000 * line ar 1 0 0.5 DoNothing
        -- Resonators
        freqs = mce (map constant expFreqs)
        res = mceMean (ringz (lodriver + hidriver + thwack) freqs 0.8)
        sig = (res * 1.2) + thwack
    in dirtSynthDef "hsc3CymSplash" (dirtPan2 sig p 1.0)

-- | hsc3Ride: Bright Jazz Ride
-- Focused on "ping" definition and high-frequency shimmer.
hsc3Ride :: Synthdef
hsc3Ride =
    let dur = s_sustain
        p = s_pan
        -- Stick "Ping": very short, very high frequency
        stickEnv = envGen ar 1 1 0 1 DoNothing (envPerc 0.001 0.005)
        stick = hpf (whiteNoiseId 'h' ar * stickEnv * 0.4) 10000
        -- Shimmer excitation (bright)
        shimmerEnv = envGen ar 1 1 0 1 DoNothing (envPerc 0.001 0.05)
        shimmerExc = hpf (whiteNoiseId 'i' ar * shimmerEnv * 0.02) 8000
        -- High resonance klank focusing on rideFreqs
        freqs = mce (map constant rideFreqs)
        res = mceMean (ringz (stick + shimmerExc) freqs 1.2)
        -- Final mix with extra high-pass to ensure clarity
        sig = hpf res 2000 + (stick * 0.5)
    in dirtSynthDef "hsc3Ride" (dirtPan2 sig p 1.0)

-- | Load all cymbal models and notify SuperDirt
loadCymbals :: IO ()
loadCymbals = do
    putStrLn "Loading hsc3 Cymbals..."
    mapM_ dirtSendOnly [ hsc3Cym, hsc3CymS, hsc3CymSusp, hsc3CymSplash, hsc3Ride ]
    dirtReload
    putStrLn "Cymbal models loaded and registered for Tidal."
