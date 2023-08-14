class_name GameStateString
extends GameStateData


var data: String = ""


func _init(key_: String, data_: String):
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateString.new(String(_key), String(data))
