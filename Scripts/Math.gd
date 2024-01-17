extends Node

func HardPercent(percent:int, amount:int)->float:
	var outp:float=1.0
	
	for i in range(0, amount):
		outp=outp-(outp/100*percent)
	
	return outp
