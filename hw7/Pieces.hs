module Pieces where

import Base 

import Control.Monad (liftM2)

--Implement useful pieces like unary, binary, checked_unary, checked_binary, etc.

--Memory
access :: Int -> Memory -> Value
access i = (!! i)

update :: Int -> Value -> Memory -> Memory
update addr val mem =
  let (before, _ : after) = splitAt addr mem in
    before ++ [val] ++ after

--Operator helpers
asInt :: Value -> Maybe Int
asInt (IntV i) = Just i
asInt _        = Nothing

asBool :: Value -> Maybe Bool
asBool (BoolV b) = Just b
asBool _         = Nothing

unary :: UnaryOp -> Value -> Maybe Value
unary Not = fmap (BoolV . not)    . asBool
unary Neg = fmap (IntV  . negate) . asInt

binary :: BinaryOp -> Value -> Value -> Maybe Value
binary Div (IntV _) (IntV 0) = Nothing
binary op l r = let
  intOp c f = fmap c $ liftM2 f (asInt l) (asInt r)
  boolOp f  = fmap BoolV $ liftM2 f (asBool l) (asBool r)
  in case op of
    --int ops returning int 
    Add -> intOp IntV (+)
    Sub -> intOp IntV (-)
    Mul -> intOp IntV (*)
    Div -> intOp IntV div
    --int ops returning bool
    Less         -> intOp BoolV (<)
    LessEqual    -> intOp BoolV (<=)
    Equal        -> intOp BoolV (==)
    GreaterEqual -> intOp BoolV (>=)
    Greater      -> intOp BoolV (>)
    --bool ops (all return bool)
    And -> boolOp (&&)
    Or  -> boolOp (||)
