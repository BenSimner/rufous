module Test.Rufous.Internal.Utils where

import Numeric

-- | Format a float
--
-- Use the same format everywhere in Rufous:
--  if 0 then 0.00
--  if can be formatted with 2 digits then 1.23
--  if not then 1.23e-5  or 1.23e+5
floatFmt :: Float -> String
floatFmt f | abs f == 0 = showFFloat (Just 2) f ""
floatFmt f | abs f < 0.01 = showEFloat (Just 2) f ""
floatFmt f | abs f < 10 = showFFloat (Just 2) f ""
floatFmt f = showEFloat (Just 2) f ""