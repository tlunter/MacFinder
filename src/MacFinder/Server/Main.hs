{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Network.Wai.Middleware.Static (addBase, staticPolicy)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Monad.IO.Class (liftIO)
import qualified Database.Redis as R

import MacFinder.Controllers.Index (index)
import MacFinder.Controllers.Add   (add)
import MacFinder.Controllers.Delete (deleteMac)

main :: IO ()
main = do
    redisConn <- liftIO $ R.connect R.defaultConnectInfo

    scottyH' 3000 $ do
      middleware $ staticPolicy (addBase "public")
      middleware logStdoutDev
      setTemplatesDir "templates"
      setTemplateFileExt ".mustache"

      index redisConn
      add redisConn
      deleteMac redisConn
