{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Pipes
import qualified Pipes.Prelude as P
import qualified Database.Redis as R
import qualified Data.ByteString as B
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import Data.Maybe
import Control.Monad

import qualified MacFinder.Types as M
import MacFinder.Config
import MacFinder.Smtp
import MacFinder.Util (convertStringToByteString)

findMac :: LT.Text -> LT.Text -> R.Connection -> Consumer String IO ()
findMac username password redisConn = do
    stringMac <- await
    let bsMac = convertStringToByteString stringMac
    value <- liftIO $ R.runRedis redisConn $ R.hgetall (B.concat ["macs:", bsMac])
    let mac        = buildMac value
        name       = fmap M.name mac
        stringName = fromJust name
    when (isJust name) $ liftIO $ sendMailForName username password stringName
    findMac username password redisConn

buildMac :: Either R.Reply [(B.ByteString, B.ByteString)] -> Maybe M.Mac
buildMac (Left _)  = Nothing
buildMac (Right x) = M.newMac x

main :: IO ()
main = do
    conn <- liftIO $ R.connect R.defaultConnectInfo

    config <- getConfig
    checkValid config
    maybeUsername <- getUsername config
    maybePassword <- getPassword config
    let username = LT.pack . T.unpack $ fromJust maybeUsername
        password = LT.pack . T.unpack $ fromJust maybePassword

    runEffect $ P.stdinLn >-> findMac username password conn
