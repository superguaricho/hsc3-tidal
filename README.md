# Project Description

`hsc3-tidal` is a bridge between **hsc3** (Haskell SuperCollider) and
**TidalCycles**. It allows you to define SuperCollider =SynthDef=s using
the hsc3 DSL and seamlessly use them in your live coding sessions with
Tidal.

This project emulates the workflow of `vivid-tidal` but leverages the
power and flexibility of `hsc3`.

# Architecture: Three-Layer Synchronization

The core of this project is a sound synchronization mechanism that
connects three distinct layers of the SuperCollider ecosystem:

1.  *****Haskell (hsc3)*****: The creative layer where SynthDefs are
    defined using a strongly-typed DSL. It handles the persistence of
    definitions to disk and notifies the other layers.
2.  *****scsynth (Audio Server)*****: The real-time engine that receives
    binary SynthDefs (`defineSD`) and generates sound.
3.  *****sclang (SuperDirt)*****: The interpreter that acts as the
    “brain” for TidalCycles. It maintains a dictionary of instruments
    and maps Tidal patterns to server commands.

## Features

- **Standard SuperDirt Integration**: Automatically maps Tidal
  parameters (`freq`, `sustain`, `pan`, `accelerate`) to hsc3 UGens.
- **Hot-Reloading**: Sends
  `SynthDef=s directly to the server and notifies  =sclang/SuperDirt` to
  register them instantly without restarting.
- **Persistence**: Writes `.scsyndef` files to the SuperCollider
  directory so SuperDirt can read parameter metadata.
- **Rich Examples**: Includes a suite of translated synths: Subtractive
  Bass, FM, Granular Samplers, Time-stretching Warps, and more.
- **Buffer Utilities**: Request a “Cheat Sheet” of loaded sample buffers
  directly from Haskell to use with granular synths.

## Prerequisites

- **Haskell**: GHC 9.6.x (via `cabal`).
- **SuperCollider** with the **SuperDirt** quark installed.
- **TidalCycles** (Haskell libraryi for pattern sequencing.

## Usage Workflow

1.  **Boot SuperCollider**: In a terminal run `superdirt_start.scd` in
    SC:

    ``` bash
    cd /path/to/hsc3-tidal
    sclang superdirt_start.scd
    ```

2.  **Start GHCI**: In other terminal:

    ``` bash
    cd /path/to/hsc3-tidal
    cabal repl --repl-options="-ghci-script hsc3-tidal.ghci"
    ```

3.  **Boot TidalCycles**:

    ``` haskell
    :boot
    ```

4.  **Test the system**:

    ``` haskell
    tidal> d1 $ s "hsc3Bass*4"
    tidal> d2 $ s "~ bd bd*2"
    tidal> hush
    ```

5.  **Create your own Synths in hsc3 DSL and Tidal them!**

## Example Synths

| Name           | Description               | Key Parameters                    |
|----------------|---------------------------|-----------------------------------|
| `hsc3Bass`     | Subtractive resonant bass | `cutoff`, `rq`                    |
| `hsc3FM`       | 2-operator FM synthesis   | `modIndex`, `modRatio`            |
| `hsc3Sampler`  | Granular sample playback  | `buf`, `grainDensity`, `grainDur` |
| `hsc3Warp`     | Time-stretching warp      | `buf`, `pos`                      |
| `hsc3Metallic` | Resonator bank            | `decayScale`                      |

## Buffer Cheat Sheet

For granular synths requiring a `buf` number, run the following in GHCI:

``` haskell
dirtCheatSheet
```

Check the SuperCollider post window for a list of common sample buffer
IDs (e.g., `bd`, `sn`, `arpy`).

# Tidal Configuration

To control the custom parameters of these synths, you must define them
in your Tidal session. A comprehensive list of these definitions is
available at the top of `TestSynths.tidal`.

``` haskell
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
```

Example usage:

``` haskell
-- Granular sampling with custom density
d1 $ s "hsc3Sampler" # sound "bd" # grainDensity 60 # grainDur 0.05

-- Time-stretching a clap
d2 $ s "hsc3Warp" # sound "cp" # pos 0.1 # sustain 4
```

## License

BSD-3-Clause
