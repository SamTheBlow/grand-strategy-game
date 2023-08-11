class_name GameStateString
extends GameStateData


var data: String = ""


func _init(key: String, value: String):
	super(key)
	data = value


func duplicate() -> GameStateData:
	return GameStateString.new(String(_key), String(data))
