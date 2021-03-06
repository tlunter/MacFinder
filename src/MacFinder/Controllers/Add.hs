{-# LANGUAGE OverloadedStrings #-}

module MacFinder.Controllers.Add (
    add
) where

import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Control.Monad.IO.Class (liftIO)
import qualified Database.Redis as R
import qualified Data.Text.Lazy as T
import Control.Monad (when)

import qualified MacFinder.Types as M

add :: R.Connection -> ScottyH' ()
add redisConn = post "/add" $ do
    textMac <- param "mac"
    textName <- param "name"

    when ((T.length . T.strip $ textMac) < 17) (raise "Bad MAC")
    when ((T.length . T.strip $ textName) == 0) (raise "Bad name")
    
    let mac           = M.Mac { M.name = textName, M.mac = T.toLower textMac }
        (key, fields) = M.deconstructMac mac
    _ <- liftIO $ R.runRedis redisConn $ R.hmset key fields
    redirect "/"
    `rescue`
    text
