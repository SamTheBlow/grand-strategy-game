class_name GameStateData


var _key: String


func _init(key_: String) -> void:
	_key = key_


func key() -> String:
	return _key


## To be implemented by subclasses
func duplicate() -> GameStateData:
	return GameStateData.new(String(_key))
