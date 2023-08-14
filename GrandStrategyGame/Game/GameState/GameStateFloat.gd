class_name GameStateFloat
extends GameStateData


var data: float = 0.0


func _init(key_: String, data_: float):
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateFloat.new(String(_key), data)
