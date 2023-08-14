class_name GameStateInt
extends GameStateData


var data: int = 0


func _init(key_: String, data_: int):
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateInt.new(String(_key), data)
