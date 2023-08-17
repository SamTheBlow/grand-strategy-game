class_name GameStateFloat
extends GameStateData


var data: float


func _init(key_: String, data_: float) -> void:
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateFloat.new(String(_key), data)


func to_raw_data() -> Variant:
	return data
