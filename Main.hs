{-# LANGUAGE OverloadedStrings #-}
import Web.Scotty
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

    scotty 3000 $ do
      post "/lease" $ do
        textMac <- param "mac"
        let bsMac = convertTextToByteString textMac

        value <- liftIO $ R.runRedis redisConn $ R.get (B.concat ["macs:", bsMac])

        let name = getName value
        maybe next (liftIO . sendMailForName username password) name

        text "Success"

      get "/test" $ text "Success"

getName :: Either R.Reply (Maybe B.ByteString) -> Maybe LT.Text
getName (Left _)         = Nothing
getName (Right Nothing)  = Nothing
getName (Right (Just x)) = Just $ convertByteStringToText x
