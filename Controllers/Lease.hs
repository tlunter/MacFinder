{-# LANGUAGE OverloadedStrings #-}

module Controllers.Lease (
    lease
) where

import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Control.Monad.IO.Class (liftIO)
import qualified Database.Redis as R
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as LT
import qualified Types as M
import Util (convertTextToByteString)
import Smtp

lease :: R.Connection -> LT.Text -> LT.Text -> ScottyH' ()
lease redisConn username password = post "/lease" $ do
    textMac <- param "mac"
    let bsMac = convertTextToByteString textMac

    value <- liftIO $ R.runRedis redisConn $ R.hgetall (B.concat ["macs:", bsMac])
    let mac  = buildMac value
        name = fmap M.name mac
    maybe next (liftIO . sendMailForName username password) name

    text "Success"

buildMac :: Either R.Reply [(B.ByteString, B.ByteString)] -> Maybe M.Mac
buildMac (Left _)  = Nothing
buildMac (Right x) = M.newMac x
