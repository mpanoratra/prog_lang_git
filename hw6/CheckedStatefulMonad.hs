module CheckedStatefulMonad where

import StatefulMonad
import Prelude hiding (LT, GT, EQ, id)
import Base
import Data.Maybe
import Stateful hiding (Stateful, evaluate)
import CheckedMonad
--import FirstClassFunctions hiding (evaluate)
--import ErrorChecking hiding (evaluate)

data CheckedStateful t = CST (Memory -> (Checked t, Memory)) 

instance Monad CheckedStateful where
  return val = CST (\m -> (Good val, m))
  (CST c) >>= f =
  	case c of
  		Error msg = injectError msg
  		Good a = 
  			
    CST (\m ->
      let (val, m') = c m in
        let CST f' = f val in 
          f' m'
      )

evaluate :: Exp -> Env -> CheckedStateful Value
evaluate (Literal v) env = return v
evaluate (Unary op a) env = do
	av <- evaluate

evaluate (Call f a) env =
	do fv <- evaluate f env
	av <- evaluate a env
	case fv of
		ClosureV x b env' =>
			evaluate b ((x, av):env')
		_ => injectError "Not a function"

injectError :: String -> CheckedStateful a
injectError str = 
	CST (\m -> (Error str, m))

liftChecked :: Checked a -> CheckedStateful a
liftChecked Good a = CST (\m -> (Good a, m))
liftChecked Error str = injectError str