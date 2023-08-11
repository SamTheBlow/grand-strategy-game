class_name GameStateFloat
extends GameStateData


var data: float = 0.0


func _init(key: String, value: float):
	super(key)
	data = value


func duplicate() -> GameStateData:
	return GameStateFloat.new(String(_key), data)
