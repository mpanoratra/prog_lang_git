module CheckedStatefulMonad where

import StatefulMonad hiding (evaluate, newMemory, readMemory, updateMemory)
--import Prelude hiding (LT, GT, EQ, id)
--import Base
--import Data.Maybe
import Stateful hiding (Stateful, evaluate)
--import CheckedMonad hiding (evaluate)
--import FirstClassFunctions hiding (evaluate)
----import qualified FirstClassFunctions as F
import ErrorChecking hiding (evaluate)


data CheckedStateful t = CST (Memory -> (Checked t, Memory)) 

--instance Monad CheckedStateful where
--  return val = CST (\m -> (Good val, m))
--  (CST c) >>= f =
--  	case c of
--  		Error msg = injectError msg
--  		Good a = 

--    CST (\m ->
--      let (val, m') = c m in
--        let CST f' = f val in 
--          f' m'
--      )

--let
--  pat1 = val1
--  pat2 = val2
--  in f val1 val2

instance Monad CheckedStateful where
  return val = CST (\m -> (Good val, m))
  (CST c) >>= f =
    CST (\m -> 
      let (val, m') = c m in
      	let f' = f val
      		in case f' m' of
      			(Good v, m'') -> CST (\m'' -> (Good v, m''))
      			(Error str, m'') -> injectError str
          )

evaluate :: Exp -> Env -> CheckedStateful Value
evaluate (Literal v) env = return v

evaluate (Unary op a) env = do
	av <- evaluate a env
	liftChecked (checked_unary op av)

evaluate (Binary op a b) env = do
	av <- evaluate a env
	bv <- evaluate b env
	liftChecked (checked_binary op av bv)

evaluate (If a b c) env = do
	av <- evaluate a env
	case av of
		(BoolV cond) -> evaluate (if cond then b else c) env
		_ -> injectError ("Expected boolean but found " ++ show av)

evaluate (Declare x e body) env = do
	ev <- evaluate e env
	let newEnv = (x, ev) : env
	evaluate body newEnv

evaluate (Variable x) env =
	case lookup x env of
		Nothing -> injectError ("Variable " ++ x ++ " undefined")
		Just v -> return v

evaluate (Function x body) env = 
	return (ClosureV x body env)

-- mutation operations
evaluate (Seq a b) env = do
	evaluate a env
	evaluate b env

evaluate (Mutable e) env = do
	ev <- evaluate e env
	newMemory ev

evaluate (Access a) env = do
	AddressV i <- evaluate a env
	readMemory i

evaluate (Assign a e) env = do
	AddressV i <- evaluate a env
	ev <- evaluate e env
	updateMemory ev i

evaluate (Call f a) env = do 
	fv <- evaluate f env
	av <- evaluate a env
	case fv of
		ClosureV x b env' ->
			evaluate b ((x, av):env')
		_ -> injectError "Not a function"


newMemory val = CST (\mem-> (Good(AddressV (length mem)), mem ++ [val]))

readMemory i = CST (\mem-> (Good (access i mem), mem))

updateMemory val i = CST (\mem-> (Good val, update i val mem))

injectError :: String -> CheckedStateful a
injectError str = 
	CST (\m -> (Error str, m))

liftChecked :: Checked a -> CheckedStateful a
liftChecked (Good v) = return v

