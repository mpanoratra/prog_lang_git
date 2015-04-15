module Main where

import Base
import CheckedStateful
import Evaluate
import StatefulParse

parseEval :: String -> Checked Value
parseEval = eval . parseExp

t1 = parseExp ("var x = mutable 3;"++
     "var y = mutable true;"++
     "if (@y) { x = @x + 1 } else { x };"++
     "@x")
-- good 4

t2 = parseExp ("var x = mutable 3;"++
     "var y = mutable 7;"++
     "x = @x + @y;"++
     "y = @y * @x")
-- good 70

-- Returning a value makes the function call expression evaluate to the value returned
t3 = parseExp ("var id = function (x) { return x }; id(3)")
-- Good 3

-- Calls to functions that do not use return evaluate to Undefined
t4 = parseExp ("var proc = function (z) { z };" ++
			   "proc(2)")
--Good Undefined

-- Return exits the function body immediately
t5 = parseExp ("var early = function (x) { (return x); x / 0 };" ++
			   "early(2)")
--Good 2

-- Good (IntV 4)
t6 = parseExp ("var x = mutable 3;"++
                           "var f = function (ptr) { ptr = 1 + @ptr; (return @ptr); ptr = 0 };"++
                           "f(x); @x")

-- Good (BoolV True)
t7 = parseExp ("var v = undefined;"++
                            "var f = function (x) { x };"++
                            "v == f(2)")

-- Good (IntV 2)
t8 = parseExp ("var id = function (x) { return x };"++
                          "id(2)")

--main :: IO ()
main = do
  print $ eval t1
  print $ eval t2
  print $ eval t3
  print $ eval t4
  print $ eval t5

  print $ eval t6
  print $ eval t7
  print $ eval t8

  
