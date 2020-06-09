module Test.Rufous.Internal.Evaluation.Results
   ( mergeResults
   , splitResultFailures
   , splitResults
   )
where

import Control.Lens

import qualified Data.Map as M

import qualified Test.Rufous.Profile as P

import Test.Rufous.Internal.Evaluation.Types

mergeResults :: Result -> Result -> Result
mergeResults r1 r2 =
   Result
      { _resultDUG=(r1^.resultDUG)
      , _resultProfile=mergeProfiles (r1^.resultProfile) (r2^.resultProfile)
      , _resultOpCounts=mergeMaps (r1^.resultOpCounts) (r2^.resultOpCounts)
      , _resultTimes=mergeResultTimes (r1^.resultTimes) (r2^.resultTimes)
      }

mergeResultTimes :: Either b TimingInfo -> Either b TimingInfo -> Either b TimingInfo
mergeResultTimes rt1 rt2 =
   case (rt1,rt2) of
      (Right r1, Right r2) -> Right $ mergeTimes r1 r2
      (Right _, Left x) -> Left x
      (Left x, _) -> Left x

mergeTimes :: TimingInfo -> TimingInfo -> TimingInfo
mergeTimes t1 t2 =
   TInfo
      { _nullTime=mergeFractionals (t1^.nullTime) (t2^.nullTime)
      , _times=mergeFMaps (t1^.times) (t2^.times)
      }

mergeProfiles :: P.Profile -> P.Profile -> P.Profile
mergeProfiles p1 p2 =
   P.Profile
      { P._operationWeights=mergeFMaps (p1^.P.operationWeights) (p2^.P.operationWeights)
      , P._persistentApplicationWeights=mergeFMaps (p1^.P.persistentApplicationWeights) (p2^.P.persistentApplicationWeights)
      , P._mortality=mergeFractionals (p1^.P.mortality) (p2^.P.mortality)
      , P._size=mergeInts (p1^.P.size) (p2^.P.size)
      }

mergeMaps :: Ord k => M.Map k Int -> M.Map k Int -> M.Map k Int
mergeMaps m1 m2 =
   M.unionWith mergeInts m1 m2

mergeFMaps :: (Ord k, Fractional a) => M.Map k a -> M.Map k a -> M.Map k a
mergeFMaps m1 m2 =
   M.unionWith mergeFractionals m1 m2

mergeFractionals :: Fractional a => a -> a -> a
mergeFractionals f1 f2 = (f1 + f2) / 2.0

mergeInts :: Int -> Int -> Int
mergeInts n1 n2 = (n1 + n2) `div` 2


-- | Given a list of possible results extract either the first failure
-- if it exists, or the list of successes if none failed.
splitResultFailures :: [Either ResultFailure a] -> Either ResultFailure [a]
splitResultFailures [] = error "Rufous: internal: unreachable: could not split results failures. got []."
splitResultFailures [Left f] = Left f
splitResultFailures [Right r] = Right [r]
splitResultFailures (Left f : _) = Left f
splitResultFailures (Right t : rs) =
   case splitResultFailures rs of
      Left f -> Left f
      Right xs -> Right (t : xs)

-- | Given a list of possible results extract either the first failure
-- if it exists, or the list of successes if none failed.
splitResults :: [Result] -> Either ResultFailure [Result]
splitResults [] = Left $ ResultFail "Cannot split Results: No Results?"
splitResults [r] =
   case r^.resultTimes of
      Left f -> Left f
      Right _ -> Right [r]
splitResults (r:rs) =
   case r^.resultTimes of
      Left f -> Left f
      Right _ ->
         case splitResults rs of
            Left f -> Left f
            Right xs -> Right (r:xs)