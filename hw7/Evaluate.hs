module Evaluate where

import Base
import Pieces
import CheckedStateful

import Control.Monad ((=<<))

type Interpreter r = CheckedStateful Memory r

--Start with empty memory and return only the Checked result
execInterpreter :: Interpreter a -> Checked a
execInterpreter i = let (v, m) = runCST [] i in v

--runInterpreter :: Interpreter a -> Memory -> (Checked a, Memory)

--Evaluate an expression starting with an empty environment
eval :: Exp -> Checked Value
eval e = execInterpreter (evaluate e [])

handleReturn :: Interpreter Value -> Interpreter Value
handleReturn (CheckedStateful f) = 
  CheckedStateful(\m -> 
    let (cv, m') = f m in
      (case cv of
        Error msg -> Error msg
        Good v -> Good UndefinedV
        Returning v -> Good v, m'))

evaluate :: Exp -> Env -> Interpreter Value
evaluate e env = case e of
  (Literal v)     -> return v
  (Unary op a)    -> do
    av <- evaluate a env
    liftMaybe "invalid unary operation" $ unary op av

  (Binary op le re) -> do
    lv <- evaluate le env
    rv <- evaluate re env
    liftMaybe "invalid binary operation" $ binary op lv rv    

  (If cond ifb elseb) -> do
    cr <- (liftMaybe "if condition not a BoolV" . asBool) =<< evaluate cond env
    case cr of
      True  -> evaluate ifb env
      False -> evaluate elseb env

  (Variable name) -> case lookup name env of 
    (Just val) -> return val
    Nothing    -> throwError $ "undefined variable: " ++ name

  (Declare name exp body) -> do
    val <- evaluate exp env
    evaluate body $ (name, val) : env

  (Function argname body) -> return $ ClosureV argname body env

  (Call f arg) -> do
    fun <- evaluate f env
    case fun of
      ClosureV argname body clEnv -> do
        argval <- evaluate arg env
        handleReturn(evaluate body $ (argname, argval) : clEnv)
      val -> throwError $ show val ++ " is not a function"
    
  (Seq a b)   -> evaluate a env >> evaluate b env

  (Return ret) -> do
    v <- evaluate ret env
    liftChecked (Returning v)

  (Mutable e) -> do
    ev <- evaluate e env
    mem <- get
    put $ mem ++ [ev]
    return $ AddressV $ length mem

  (Access addrexp) -> do
    aval <- evaluate addrexp env
    case aval of
      AddressV addr -> do
        len <- gets length
        if (addr >= len) then
          throwError $ show (addr, len)
          else gets (!! addr)
      _ -> throwError "expected address"

  (Assign addrexp valexp) -> do
    aval <- evaluate addrexp env
    case aval of
      AddressV addr -> do
        val  <- evaluate valexp env
        modify $ update addr val
        return val
      _ -> throwError "expected address"

