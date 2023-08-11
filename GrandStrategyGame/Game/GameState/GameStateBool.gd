class_name GameStateBool
extends GameStateData


var data: bool = false


func _init(key: String, value: bool):
	super(key)
	data = value


func duplicate() -> GameStateData:
	return GameStateBool.new(String(_key), data)
