-- Taylor Smith tls2864 smithleet@utexas.edu
-- Danny Nguyen dtn384 dannytnguyen91@gmail.com

module CheckedStateful where

import Base
import Pieces

import Control.Applicative
import Control.Monad
  
--This version of CheckedStateful can be parameterized on the type of state
--(We will just use Memory)
data CheckedStateful s a = CheckedStateful (s -> (Checked a, s))

instance Monad (CheckedStateful s) where
  return a = cst $ \s -> (a, s)
  (CheckedStateful first) >>= secondF = CheckedStateful $ \m -> let
    (firstV, m') = first m
    in case firstV of
      (Good v) -> let
        (CheckedStateful second) = secondF v
        in second m'
      Error msg -> (Error msg, m')
      (Returning val) -> (Returning val, m')

instance Monad Checked where
  return = Good
  ca >>= cf = case ca of
    Good v  -> cf v
    Error s -> Error s

--Write boring instances so that we can use fmap and
--to eliminate warnings in recent versions of GHC
instance Functor Checked where
  fmap = liftM

instance Applicative Checked where
  pure  = return
  (<*>) = ap

instance Functor (CheckedStateful s) where
  fmap = liftM

instance Applicative (CheckedStateful s) where
  pure  = return
  (<*>) = ap

--Utility functions for the CheckedStateful monad.   

throwError :: String -> CheckedStateful s a
throwError msg = CheckedStateful $ \s -> (Error msg, s)

--Turn a Maybe value into a CheckedStateful value
--(adding an error message if it is Nothing)
liftMaybe :: String -> Maybe v -> CheckedStateful s v
liftMaybe _ (Just v) = return v
liftMaybe m Nothing  = throwError m

liftChecked :: Checked a -> CheckedStateful s a
liftChecked v = CheckedStateful (\m -> (v, m))

--Supply the initial state to a CheckedStateful computation
runCST :: s -> CheckedStateful s a -> (Checked a, s)
runCST si (CheckedStateful f) = f si

--Turn a state-transforming function into a CheckedStateful
--(sort of like liftStateful)
cst :: (s -> (a, s)) -> CheckedStateful s a
cst f = CheckedStateful $ \m -> let (v, m') = f m in (Good v, m')

--Get the current state
get :: CheckedStateful s  s
get = cst $ \s -> (s, s)

--Replace the state
put :: s -> CheckedStateful s ()
put v = cst $ \s -> ((), v)

--Get a function of the current state
gets :: (s -> a) -> CheckedStateful s a
gets f = get >>= return . f

--Modify the current state by applying a function to it
modify :: (s -> s) -> CheckedStateful s ()
modify f = cst $ \s -> ((), f s)

