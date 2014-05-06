{-# LANGUAGE OverloadedStrings #-}

module MacFinder.Config (
    getConfig,
    getUsername,
    getPassword,
    checkValid
) where

import System.Directory
import System.Exit
import System.IO
import qualified Data.Configurator as C
import qualified Data.Configurator.Types as CT
import qualified Data.Text as T
import Control.Monad
import Data.Maybe

getConfig :: IO CT.Config
getConfig = do
    homeDir <- getHomeDirectory
    (config, _) <- C.autoReload C.autoConfig [C.Optional "/etc/mac_finder/config.cfg", C.Optional (homeDir ++ "/.mac_finder")]
    return config

getUsername :: CT.Config -> IO (Maybe T.Text)
getUsername c = C.lookup c "username"

getPassword :: CT.Config -> IO (Maybe T.Text)
getPassword c = C.lookup c "password"

checkValid :: CT.Config -> IO ()
checkValid config = do
    maybeUsername <- getUsername config
    maybePassword <- getPassword config
    when (isNothing maybeUsername) printConfigFailure
    when (isNothing maybePassword) printConfigFailure

printConfigFailure :: IO ()
printConfigFailure = do
    hPutStrLn stderr "Malformed Config! Must have Gmail username and password in either `/etc/mac_finder/config.cfg` or `~/.mac_finder`"
    exitFailure
