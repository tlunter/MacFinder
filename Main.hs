{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Network.Wai.Middleware.Static (addBase, staticPolicy)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Monad.IO.Class (liftIO)
import qualified Data.Text.Lazy as LT
import qualified Data.Text as T
import qualified Database.Redis as R
import Data.Maybe

import Config (getConfig, getUsername, getPassword, checkValid)
import Controllers.Index (index)
import Controllers.Lease (lease)

main :: IO ()
main = do
    redisConn <- liftIO $ R.connect R.defaultConnectInfo

    config <- getConfig
    checkValid config
    maybeUsername <- getUsername config
    maybePassword <- getPassword config
    let username = LT.pack . T.unpack $ fromJust maybeUsername
        password = LT.pack . T.unpack $ fromJust maybePassword

    scottyH' 3000 $ do
      middleware $ staticPolicy (addBase "public")
      middleware logStdoutDev
      setTemplatesDir "templates"
      setTemplateFileExt ".mustache"

      lease redisConn username password

      index redisConn
