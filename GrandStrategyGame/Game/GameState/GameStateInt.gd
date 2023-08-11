class_name GameStateInt
extends GameStateData


var data: int = 0


func _init(key: String, value: int):
	super(key)
	data = value


func duplicate() -> GameStateData:
	return GameStateInt.new(String(_key), data)
