{-# LANGUAGE OverloadedStrings #-}

--import Text.Hastache
import Text.Hastache
import Text.Hastache.Context
import Web.Scotty.Trans as S
import Web.Scotty.Hastache
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as LT
import qualified Data.Text as T
import qualified Database.Redis as R
import Data.Maybe

import Util (convertTextToByteString, convertByteStringToText)
import Smtp (sendMailForName)
import Config (getConfig, getUsername, getPassword, checkValid)

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
      setTemplatesDir "templates"
      post "/lease" $ do
        textMac <- param "mac"
        let bsMac = convertTextToByteString textMac

        value <- liftIO $ R.runRedis redisConn $ R.hgetall (B.concat ["macs:", bsMac])

        let name = getName value
        maybe next (liftIO . sendMailForName username password) name

        text "Success"

      get "/" $ do
        keys <- liftIO $ R.runRedis redisConn $ R.keys "macs:*"
        values <- liftIO $ R.runRedis redisConn $ R.mget $ getKeys keys
        setH "keys" $ MuList $ map (mkStrContext . mkListContext) $ zip (getKeys keys) (getValues values)
        hastache "index.html"
        where mkListContext (key, _) "key"     = MuVariable key
              mkListContext (_, value) "value" = MuVariable value

getName :: Either R.Reply [(B.ByteString, B.ByteString)] -> Maybe LT.Text
getName (Left _)  = Nothing
getName (Right x) = getName' x

getName' :: [(B.ByteString, B.ByteString)] -> Maybe LT.Text
getName' []              = Nothing
getName' (("name", x):_) = Just $ convertByteStringToText x
getName' (_:fields)      = getName' fields

getKeys :: Either R.Reply [B.ByteString] -> [B.ByteString]
getKeys (Left _)         = []
getKeys (Right x)        = x

getValues :: Either R.Reply [Maybe B.ByteString] -> [B.ByteString]
getValues (Left _)  = []
getValues (Right x) = catMaybes x
