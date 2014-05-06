{-# LANGUAGE OverloadedStrings #-}

module MacFinder.Controllers.Delete (
    deleteMac
) where

import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Control.Monad.IO.Class (liftIO)
import qualified Database.Redis as R
import qualified Data.Text.Lazy as T
import qualified Data.ByteString as B
import Control.Monad (when, unless)

import MacFinder.Util (convertTextToByteString)

deleteMac :: R.Connection -> ScottyH' ()
deleteMac redisConn = post "/delete" $ do
    textMac <- param "mac"

    when ((T.length . T.strip $ textMac) < 17) (raise "Bad MAC")
    
    let keyToDelete = B.concat ["macs:", convertTextToByteString . T.toLower $ textMac]
    value <- liftIO $ R.runRedis redisConn $ R.del [keyToDelete]
    liftIO $ print value
    either couldntDelete checkNumDeleted value
    redirect "/"
    `rescue`
    text
    where checkNumDeleted x = unless (x > 0) (couldntDelete ())
          couldntDelete   _ = raise "Couldn't delete"

