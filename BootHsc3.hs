:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""
:set -i./src

-- Project modules
import Sound.Tidal.Boot
import Sound.Sc3
import Sound.Sc3.Tidal
import Sound.Sc3.Tidal.Examples
import Sound.Sc3.Tidal.Cymbals

default (Rational, Integer, Double, Pattern String)

-- Tidal Initialization
tidalInst <- mkTidal
instance Tidally where tidal = tidalInst

-- Load all SynthDefs and register them in SuperDirt
loadExamples
loadCymbals

-- Custom Tidal Parameters for hsc3 Synths
:{
let grainDensity = pF "grainDensity"
    grainDur = pF "grainDur"
    freqVar = pF "freqVar"
    cutoff = pF "cutoff"
    rq = pF "rq"
    modIndex = pF "modIndex"
    modRatio = pF "modRatio"
    revMix = pF "revMix"
    revRoom = pF "revRoom"
    pos = pF "pos"
    glideTime = pF "glideTime"
    noiseType = pF "noiseType"
    beatsPerSec = pF "beatsPerSec"
    decayScale = pF "decayScale"
:}

:{
hsc3TidalSplash = unlines $ [
  " __                                     __   ",
  "|  |--.-----.----.----.-----.----.----.----. ",
  "|     |__ --|  __|  __|__ --|  __|  __|__ --|",
  "|__|__|_____|____|____|_____|____|____|_____|",
  " ",
  "Sound synthesis with hsc3.",
  "Unified Boot Environment (Examples + Cymbals)",
  " "]
:}

:set prompt "tidal> "
:set prompt-cont "λ| "
    
putStrLn hsc3TidalSplash
putStrLn "hsc3-tidal ready! Try: d1 $ s \"hsc3Cymbal*4\" # sustain 0.5"
