extends Node

var uuid = preload("res://src/autoload/utils/uuid.gd")
	

func uuid4(dig:int=32):
	return uuid.v4().left(dig)


func uuid4rng(rng:RandomNumberGenerator, dig:int=32):
	return uuid.v4_rng(rng).left(dig)
	
