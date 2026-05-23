module Sound.Sc3.Tidal where

import           Sound.Osc
import qualified Sound.Osc.Transport.Fd     as Fd
import           Sound.Osc.Transport.Fd.Udp (openUdp)
import           Sound.Sc3
import           System.Directory           (getHomeDirectory)
import           System.FilePath            ((</>))

-- | Standard SuperDirt parameters as hsc3 Controls
s_out :: Ugen
s_out = control kr "out" 0

s_sustain :: Ugen
s_sustain = control kr "sustain" 1

s_pan :: Ugen
s_pan = control kr "pan" 0.5

s_freq :: Ugen
s_freq = control kr "freq" 440

s_accelerate :: Ugen
s_accelerate = control kr "accelerate" 0

-- | Helper for SuperDirt panning (0..1 to -1..1)
dirtPan2 :: Ugen -> Ugen -> Ugen -> Ugen
dirtPan2 sig p level = pan2 sig (p * 2 - 1) level

-- | Helper for an exponential frequency glide based on 'accelerate'
dirtFreqScale :: Ugen
dirtFreqScale =
    let line_ugen = line kr 1 (1 + s_accelerate) s_sustain DoNothing
     in line_ugen

-- | Generate a SynthDef for SuperDirt
dirtSynthDef :: String -> Ugen -> Synthdef
dirtSynthDef name ugenGraph = synthdef name (out s_out ugenGraph)

-- | Get the default SuperCollider synthdef directory
getSynthdefDir :: IO FilePath
getSynthdefDir = do
    home <- getHomeDirectory
    return $ home </> ".local/share/SuperCollider/synthdefs"

-- | Send a single SynthDef to scsynth and write it to disk
dirtSendOnly :: Synthdef -> IO ()
dirtSendOnly sd = do
    -- 1. Write to disk so SuperDirt can read metadata
    dir <- getSynthdefDir
    synthdefWrite_dir dir sd
    -- 2. Send to scsynth memory
    fd <- openUdp "127.0.0.1" 57110
    Fd.sendMessage fd (d_recv sd)
    Fd.close fd

-- | Notify SuperDirt (sclang) to reload all SynthDefs
dirtReload :: IO ()
dirtReload = do
    fd <- openUdp "127.0.0.1" 57120
    Fd.sendMessage fd $ Message "/hsc3/reload" []
    Fd.close fd
    putStrLn "SuperDirt notified: reload triggered."

-- | Request SuperDirt (sclang) to print a list of common buffer numbers
dirtCheatSheet :: IO ()
dirtCheatSheet = do
    fd <- openUdp "127.0.0.1" 57120
    Fd.sendMessage fd $ Message "/hsc3/cheat" []
    Fd.close fd
    putStrLn "Requesting sample cheat sheet from SuperDirt..."

-- | Send SynthDef and notify SuperDirt
dirtSend :: Synthdef -> IO ()
dirtSend sd = do
    dirtSendOnly sd
    dirtReload
    putStrLn $ "SynthDef " ++ synthdefName sd ++ " sent and registered."
