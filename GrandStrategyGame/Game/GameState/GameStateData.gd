class_name GameStateData


var _key: String = ""


func _init(key: String):
	_key = key


func get_key() -> String:
	return _key


## To be implemented by subclasses
func duplicate() -> GameStateData:
	return GameStateData.new(String(_key))
