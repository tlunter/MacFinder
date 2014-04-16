module Util (
    convertTextToByteString,
    convertByteStringToText
) where

import qualified Data.ByteString as B
import qualified Data.Text.Lazy as T

convertEnum :: (Enum a, Enum b) => a -> b
convertEnum = toEnum . fromEnum

convertStringToByteString :: String -> B.ByteString
convertStringToByteString s = B.pack $ map convertEnum s

convertTextToString :: T.Text -> String
convertTextToString = T.unpack

convertTextToByteString :: T.Text -> B.ByteString
convertTextToByteString = convertStringToByteString . convertTextToString

convertByteStringToString :: B.ByteString -> String
convertByteStringToString s = map convertEnum (B.unpack s)

convertStringToText :: String -> T.Text
convertStringToText = T.pack

convertByteStringToText :: B.ByteString -> T.Text
convertByteStringToText = convertStringToText . convertByteStringToString
