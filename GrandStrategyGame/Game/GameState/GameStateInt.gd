class_name GameStateInt
extends GameStateData


var data: int


func _init(key_: String, data_: int) -> void:
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateInt.new(String(_key), data)


func to_raw_data() -> Variant:
	return data
