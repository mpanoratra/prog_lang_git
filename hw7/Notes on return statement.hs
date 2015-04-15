--Notes on return statement
handleReturn :: CheckedStateful Value -> CheckedStateful Value
--Takes a value and Good -> Good undefined
--Returning v -> Good v
CST(\m -> (Checked Value, Memory))
handleReturn (CST f) = 
	CST(\m -> 
		let (cv, m') = f m in
			(case cv of
				Error msg -> Error msg
				Good v -> Good undefined
				Returning v -> Good v, m'))

-- How to use handleReturn:
evaluate(Call f a) env =
	a<-f
	?
	ClosureV a b env'
	handleReturn(evaluate b ((x, va) env'))
	

