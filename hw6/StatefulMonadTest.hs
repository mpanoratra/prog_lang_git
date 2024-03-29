--import Stateful hiding (Stateful, evaluate, execute)
import Base
--import StatefulMonad 
import StatefulParse
import CheckedStatefulMonad

execute exp = runCheckedStateful (evaluate exp [])

t1 = parseExp ("var x = mutable 3;"++
     "var y = mutable true;"++
     "if (@y) { x = @x + 1 } else { x };"++
     "@x")

t2 = parseExp ("var x = mutable 3;"++
     "var y = mutable 7;"++
     "x = @x + @y;"++
     "y = @y * @x")

t3 = parseExp ("var x = mutable 0;"++
     "var y = mutable 7;"++
     "x = @y / @x")

t4 = parseExp ("@99")  -- returns an Error that contents only applies to addresses, not 99

t5 = parseExp ("true = 34") -- returns an Error that assignment requires and address

t6 = parseExp ("var x = 34; x = 8") -- returns an Error that assignment requires and address 

t8 = parseExp ("if (10) {1} else {2}")

main = do
  test "evaluate" execute t1
  test "evaluate" execute t2
  test "evaluate" execute t3
  test "evaluate" execute t4
  test "evaluate" execute t5
  test "evaluate" execute t6
  test "evaluate" execute t8