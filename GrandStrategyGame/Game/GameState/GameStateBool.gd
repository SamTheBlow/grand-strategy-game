class_name GameStateBool
extends GameStateData


var data: bool = false


func _init(key_: String, data_: bool):
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateBool.new(String(_key), data)
