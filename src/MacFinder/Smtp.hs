{-# LANGUAGE OverloadedStrings #-}
module MacFinder.Smtp (
    sendMailForName
) where

import Network.Mail.Mime
import qualified Network.Mail.Client.Gmail as G
import qualified Data.Text.Lazy as T

simpleMessage :: T.Text -> T.Text
simpleMessage name = T.concat [name, " is here!"]

sendMailForName :: T.Text -> T.Text -> T.Text -> IO ()
sendMailForName username password name = G.sendGmail username password me [ifttt] [] [] "#dooralarm" (simpleMessage name) []

me :: Address
me = Address
        { addressName = Just "Todd Lunter"
        , addressEmail = "tlunter@gmail.com"
        }

ifttt :: Address
ifttt = Address
        { addressName = Nothing
        , addressEmail = "trigger@ifttt.com"
        }
