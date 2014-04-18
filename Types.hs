{-# LANGUAGE OverloadedStrings #-}

module Types (
    Mac(Mac),
    name,
    mac,
    newMac,
    deconstructMac
) where

import qualified Data.Text.Lazy as T
import qualified Data.ByteString as B
import Util (convertByteStringToText, convertTextToByteString)

data Mac = Mac { name :: T.Text
               , mac  :: T.Text
               } deriving (Show, Eq)

emptyMac :: Mac
emptyMac = Mac "" ""

newMac :: [(B.ByteString, B.ByteString)] -> Maybe Mac
newMac [] = Nothing
newMac xs = Just $ foldr fillMac emptyMac xs
    where fillMac ("name", val) struct = struct { name = convertByteStringToText val }
          fillMac ("mac",  val) struct = struct { mac = convertByteStringToText val }
          fillMac _ struct             = struct

deconstructMac :: Mac -> (B.ByteString, [(B.ByteString, B.ByteString)])
deconstructMac m = (B.concat ["macs:", convertTextToByteString . mac $ m], [("mac", convertTextToByteString . mac $ m), ("name", convertTextToByteString . name $ m)])
