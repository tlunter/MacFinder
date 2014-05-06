{-# LANGUAGE OverloadedStrings #-}

module MacFinder.Controllers.Index (
    index
) where

import Web.Scotty.Trans as S
import Text.Hastache
import Text.Hastache.Context
import Web.Scotty.Hastache
import Control.Monad.IO.Class (liftIO)
import qualified Database.Redis as R
import qualified Data.ByteString as B
import Data.Maybe

import qualified MacFinder.Types as M

index :: R.Connection -> ScottyH' ()
index redisConn = get "/" $ do
    keys <- liftIO $ R.runRedis redisConn $ R.keys "macs:*"
    values <- liftIO $ R.runRedis redisConn $ mapM R.hgetall (getKeys keys)
    let maybeMacs = map buildMac values
        macs      = catMaybes maybeMacs
    setH "keys" $ MuList $ map (mkStrContext . mkListContext) $ macs
    hastache "index"
    where mkListContext mac "mac"  = MuVariable $ M.mac mac
          mkListContext mac "name" = MuVariable $ M.name mac

buildMac :: Either R.Reply [(B.ByteString, B.ByteString)] -> Maybe M.Mac
buildMac (Left _)  = Nothing
buildMac (Right x) = M.newMac x

getKeys :: Either R.Reply [B.ByteString] -> [B.ByteString]
getKeys (Left _)         = []
getKeys (Right x)        = x
