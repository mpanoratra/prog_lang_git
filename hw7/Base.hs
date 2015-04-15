module Base where

data BinaryOp = Add | Sub | Mul | Div | And | Or
              | Greater | Less | LessEqual | GreaterEqual | Equal
  deriving (Show, Eq)

data UnaryOp = Neg | Not deriving (Show, Eq)

type Env = [(String, Value)]

data Value = IntV  Int
           | BoolV Bool
           | ClosureV String Exp Env
           | AddressV Int
           | UndefinedV
  deriving (Eq, Show)

data Exp = Literal   Value
         | Unary     UnaryOp Exp
         | Binary    BinaryOp Exp Exp
         | If        Exp Exp Exp
         | Variable  String
         | Declare   String Exp Exp
         | Function  String Exp
         | Call      Exp Exp
         | Return    Exp
         | Seq       Exp Exp
         | Mutable   Exp
         | Access    Exp
         | Assign    Exp Exp
  deriving (Eq, Show)

type Memory = [Value]

data Checked a = Good a | Error String | Returning Value deriving (Eq, Show)

--data Returning a = Checked a deriving (Eq, Show)