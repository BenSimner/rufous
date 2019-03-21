{-# LANGUAGE ExistentialQuantification #-}
module Test.Rufous.Options
   ( RufousOptions(..)
   , DebugOptions(..)

   -- | Aggregation Options
   , AggregatorType(..)
   , AggregationOptions(..)

   -- | Aggreagtors
   , KMeansOptions(..)

   -- | Mutators over Options
   , debugFlag
   , debugOpt

   -- | default option sets
   , debugArgs
   , args
   , kmeansArgs
   , aggregationArgs
   )
where

import qualified Test.Rufous.Signature as S
import qualified Test.Rufous.Profile as P
import qualified Test.Rufous.DUG as D

import Test.Rufous.Internal.Aggregation.Types

data RufousOptions =
   RufousOptions
      { signature :: S.Signature
      , profiles :: [P.Profile]
      , dugs :: [D.DUG]
      , averageDugSize :: Int
      , numberOfTests :: Int
      , debug :: Bool
      , debugOptions :: DebugOptions
      , aggregationOptions :: AggregationOptions
      , aggregator :: AggregatorType
      }

data DebugOptions =
   DebugOptions {
        dumpDir :: String
      , dumpDugs :: Bool
      , dumpPhaseTiming :: Bool
      , showNullTimes :: Bool
   }

debugOpt :: (DebugOptions -> a) -> a -> RufousOptions -> a
debugOpt f x r = if debug r then f (debugOptions r) else x

debugFlag :: (DebugOptions -> Bool) -> RufousOptions -> Bool
debugFlag f r = debugOpt f False r

{- Default Options -}
debugArgs :: DebugOptions
debugArgs =
   DebugOptions
      { dumpDugs=False
      , dumpDir="./"
      , dumpPhaseTiming=True
      , showNullTimes=True
      }

args :: RufousOptions
args =
   RufousOptions
      { signature=error "args :: no signature specified"
      , profiles=[]
      , dugs=[]
      , averageDugSize=1000
      , numberOfTests=100
      , debug=False
      , debugOptions=debugArgs
      , aggregator=KMeans
      , aggregationOptions=aggregationArgs
      }
