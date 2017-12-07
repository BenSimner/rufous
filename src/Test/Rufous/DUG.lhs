> module Test.Rufous.DUG where
> 
> import qualified Data.Map as M
> import Data.Maybe
> import Data.List

Each node in the DUG is just the string of the operation name

> type VersionNode = String

Args can be either versiosn from other Nodes in the DUG or non-version arguments
Currently there is no way of representing a non-version argument from the DUG (such as the result of an observation)

> data Arg =
>      VersionNodeArg Int
>    | NonVersionArg  Int
>    deriving (Show)

Then the DUG is just a collection of nodes and a set of edges for each node.

> data DUG =
>    DUG
>       { versions :: [VersionNode]
>       , operations :: M.Map Int [Arg]
>       }
>    deriving (Show)

This representation allows easy displaying, such as a graphviz file

> dug2dot :: DUG -> IO ()
> dug2dot d = do
>   putStrLn "digraph G {"
>   putStrLn . unlines $ [show i ++ "[label=\"" ++ nodeLabel d i ++ "\"]" | (i, _) <- enumerate (versions d)]
>   putStrLn . unlines $ [show i ++ "->" ++ show j | (i, j) <- edges d]
>   putStrLn "}"
> edges :: DUG -> [(Int, Int)]
> edges d = concat $ map args2ints (M.toList (operations d))
>   where
>       args2ints :: (Int, [Arg]) -> [(Int, Int)]
>       args2ints (i, as) = mapMaybe (arg2int . ((,) i)) as
>       arg2int :: (Int, Arg) -> Maybe (Int, Int)
>       arg2int (i, a) =
>           case a of
>               VersionNodeArg j -> Just (j, i)
>               _                -> Nothing
> nodeLabel :: DUG -> Int -> String
> nodeLabel d ix = "\\" ++ intercalate " " lambdaArgs ++ " -> " ++ name ++ " " ++ intercalate " " bodyArgs
>   where
>       args :: [Arg]
>       args = operations d M.! ix
>       name :: String
>       name = versions d !! ix
>       args2defn (a : as) (lambdaArgs, bodyArgs) =
>           case a of
>               VersionNodeArg _ -> 
>                   let vName = "v" ++ (show (length lambdaArgs)) 
>                   in args2defn as (lambdaArgs ++ [vName], bodyArgs ++ [vName])
>               NonVersionArg  k -> args2defn as (lambdaArgs, bodyArgs ++ [show k])
>       args2defn [] vs = vs
>       (lambdaArgs, bodyArgs) = args2defn args ([], [])

Utility functions:

> enumerate :: [a] -> [(Int, a)]
> enumerate xs = zip [0..] xs
