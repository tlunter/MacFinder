{-# LANGUAGE OverloadedStrings #-}

module Types (
    Mac,
    name,
    mac,
    newMac
) where

import qualified Data.Text.Lazy as T
import qualified Data.ByteString as B
import Util (convertByteStringToText)

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
