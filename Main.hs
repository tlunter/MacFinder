{-# LANGUAGE OverloadedStrings #-}
import Web.Scotty
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as T
import qualified Database.Redis as R

import Util (convertTextToByteString, convertByteStringToText)

main :: IO ()
main = do
    conn <- liftIO $ R.connect R.defaultConnectInfo
    scotty 3000 $ 
      post "/lease" $ do
        textMac <- param "mac"
        let bsMac :: B.ByteString
            bsMac = convertTextToByteString textMac
        value <- liftIO $ R.runRedis conn $ R.get (B.concat ["macs:", bsMac])
        let name = getName value
        maybe next text name

getName :: Either R.Reply (Maybe B.ByteString) -> Maybe T.Text
getName (Left _)         = Nothing
getName (Right Nothing)  = Nothing
getName (Right (Just x)) = Just $ convertByteStringToText x
