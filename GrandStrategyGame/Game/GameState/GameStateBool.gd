class_name GameStateBool
extends GameStateData


var data: bool


func _init(key_: String, data_: bool) -> void:
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateBool.new(String(_key), data)
