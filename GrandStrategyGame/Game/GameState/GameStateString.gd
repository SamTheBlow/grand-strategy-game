class_name GameStateString
extends GameStateData


var data: String


func _init(key_: String, data_: String) -> void:
	super(key_)
	data = data_


func duplicate() -> GameStateData:
	return GameStateString.new(String(_key), String(data))


func to_raw_data() -> Variant:
	return data
