# hsc3-tidal

`hsc3-tidal` is a bridge between **hsc3** (Haskell SuperCollider) and **TidalCycles**. It allows you to define SuperCollider `SynthDef`s using the hsc3 DSL and seamlessly use them in your live coding sessions with Tidal.

This project emulates the workflow of `vivid-tidal` but leverages the power and flexibility of `hsc3`.

## Features

- **Standard SuperDirt Integration**: Automatically maps Tidal parameters (`freq`, `sustain`, `pan`, `accelerate`) to hsc3 UGens.
- **Hot-Reloading**: Sends `SynthDef`s directly to the server and notifies `sclang/SuperDirt` to register them instantly without restarting.
- **Persistence**: Writes `.scsyndef` files to the SuperCollider directory so SuperDirt can read parameter metadata.
- **Rich Examples**: Includes a suite of translated synths: Subtractive Bass, FM, Granular Samplers, Time-stretching Warps, and more.
- **Buffer Utilities**: Request a "Cheat Sheet" of loaded sample buffers directly from Haskell to use with granular synths.

## Prerequisites

- **SuperCollider** with the **SuperDirt** quark installed.
- **TidalCycles** (Haskell library).
- **hsc3** and **hosc** libraries.

## Setup

### 1. SuperCollider Configuration
Use the provided `superdirt_start.scd` to boot your SuperDirt instance. It includes an OSC listener that enables the hot-reloading feature.

### 2. Haskell Project
Ensure your `cabal` project is configured. You can build the library with:
```bash
cabal build
```

## Usage Workflow

1. **Boot SuperCollider**: Run `superdirt_start.scd` in SC.
2. **Start GHCI**:
   ```bash
   cabal repl --repl-options="-ghci-script BootTidal.hs"
   ```
3. **Load and Send Synths**:
   ```haskell
   import Sound.Sc3.Tidal.Examples
   loadExamples
   ```
4. **Play from Tidal**:
   ```tidal
   d1 $ s "hsc3Bass" # n "c2 e2 g2 f2" # sustain 1 # pF "cutoff" 1200
   ```

## Example Synths

| Name | Description | Key Parameters |
| :--- | :--- | :--- |
| `hsc3Bass` | Subtractive resonant bass | `cutoff`, `rq` |
| `hsc3FM` | 2-operator FM synthesis | `modIndex`, `modRatio` |
| `hsc3Sampler` | Granular sample playback | `buf`, `grainDensity`, `grainDur` |
| `hsc3Warp` | Time-stretching warp | `buf`, `pos` |
| `hsc3Metallic` | Resonator bank | `decayScale` |

## Buffer Cheat Sheet
For granular synths requiring a `buf` number, run the following in GHCI:
```haskell
dirtCheatSheet
```
Check the SuperCollider post window for a list of common sample buffer IDs (e.g., `bd`, `sn`, `arpy`).

## License
BSD-3-Clause
