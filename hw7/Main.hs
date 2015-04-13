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

t2 = parseExp ("var x = mutable 3;"++
     "var y = mutable 7;"++
     "x = @x + @y;"++
     "y = @y * @x")

--main :: IO ()
main = do
  print $ eval t1
  print $ eval t2

  
