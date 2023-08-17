class_name GameStateData


var _key: String


func _init(key_: String) -> void:
	_key = key_


func key() -> String:
	return _key


## To be implemented by subclasses
func duplicate() -> GameStateData:
	return null


## To be implemented by subclasses
func to_raw_data() -> Variant:
	return null


static func from_raw_data(
		raw_data: Variant,
		key_: String = "root"
) -> GameStateData:
	if raw_data is Array:
		return _from_array(raw_data as Array, key_)
	elif raw_data is Dictionary:
		return _from_dictionary(raw_data as Dictionary, key_)
	elif raw_data is int:
		return GameStateInt.new(key_, raw_data as int)
	elif raw_data is float:
		return GameStateFloat.new(key_, raw_data as float)
	elif raw_data is String:
		return GameStateString.new(key_, raw_data as String)
	elif raw_data is bool:
		return GameStateBool.new(key_, raw_data as bool)
	
	return null


static func _from_array(array: Array, key_: String) -> GameStateArray:
	var processed_data: Array[GameStateData] = []
	
	for element in array:
		var dictionary := element as Dictionary
		var element_key := dictionary.keys()[0] as String
		processed_data.append(
				GameStateData.from_raw_data(element[element_key], element_key)
		)
	
	return GameStateArray.new(key_, processed_data, true)


static func _from_dictionary(
		dictionary: Dictionary,
		key_: String
) -> GameStateArray:
	var processed_data: Array[GameStateData] = []
	
	var keys: Array = dictionary.keys()
	for element_key in keys:
		processed_data.append(
				GameStateData.from_raw_data(
						dictionary[element_key],
						element_key as String
				)
		)
	
	return GameStateArray.new(key_, processed_data, false)
