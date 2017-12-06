> module Test.Rufous.SigParser
>    ( OperationType(..)
>    , Arg(..)
>    , OperationSig(..)
>    , parseSig
>    ) where
> 
> import Text.Parsec (Parsec, parse, many, string, space, char, sepBy, eof)
> import Control.Applicative ((<*), (*>), (<|>))

Operations are functions whose signatures conform to a simple grammar
These signatures are essentially combinations of Version / NonVersion first-order arguments

> data Arg = Version | NonVersion
>    deriving (Eq, Show)

Each operation falls into 1 of 3 categories, depending on the signature. 
    - Generators take NonVersion arguments and return Version's
    - Observers return NonVersion
    - Mutator's return Versions

> data OperationType = Mutator | Observer | Generator
>    deriving (Eq, Show)
> 
> classifyArgs :: [Arg] -> OperationType
> classifyArgs args =
>    if last args /= Version then
>       Observer
>    else
>       if Version `elem` init args then
>          Mutator
>       else
>          Generator

Hence an operation's signature is simply a pair, the function signature and its categorical type:

> data OperationSig =
>    OperationSig
>       { opArgs :: [Arg]
>       , opType :: OperationType
>       }
>    deriving (Eq, Show)

These signatures are built by a simple parser with the grammar:
    <sig> ::= <arg> | <arg> "->" <sig>
    <arg> ::= <version> | <nonversion>
    <version>    ::= "T a"
    <nonversion> ::= "a"

The parser is a straight-forward parser built from combinators for each production in the grammar.

> parseSig :: String -> OperationSig
> parseSig s =
>    case parse parseSignature "<string>" s of
>       Right op -> op
>       Left  e  -> error (show e)
> 
> 
> parseSignature :: Parsec String () OperationSig
> parseSignature = (\as -> OperationSig as (classifyArgs as)) <$> (sepBy parseArg parseArrow <* eof)
> 
> parseArrow :: Parsec String () String
> parseArrow = many space *> string "->" <* many space
> 
> parseVersion :: Parsec String () Arg
> parseVersion = const Version <$> (char 'T' *> space *> char 'a')
> 
> parseNonVersion :: Parsec String () Arg
> parseNonVersion = const NonVersion <$> char 'a'
> 
> parseArg :: Parsec String () Arg
> parseArg = parseVersion <|> parseNonVersion