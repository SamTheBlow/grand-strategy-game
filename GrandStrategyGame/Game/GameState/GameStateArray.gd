class_name GameStateArray
extends GameStateData
## Contains an list of game state data.


var _is_ordered_list: bool

var _data: Array[GameStateData] = []


func _init(
	key: String,
	data_: Array[GameStateData],
	is_ordered_list_: bool
):
	super(key)
	_data = data_
	_is_ordered_list = is_ordered_list_


func is_ordered_list() -> bool:
	return _is_ordered_list


func data() -> Array[GameStateData]:
	return _data


func duplicate() -> GameStateData:
	return clone(String(_key))


## It's the same thing as duplicate(), but here you can give it a new key
func clone(key: String) -> GameStateData:
	var output: Array[GameStateData] = []
	for game_state_data in _data:
		output.append(game_state_data.duplicate())
	return GameStateArray.new(key, output, is_ordered_list())



## Returns -1 if the key doesn't match anything.
func index_of(key: String) -> int:
	var size: int = _data.size()
	for i in size:
		if _data[i].get_key() == key:
			return i
	return -1


func get_data(key: String) -> GameStateData:
	var index: int = index_of(key)
	if index == -1:
		return null
	return _data[index]


func get_array(key: String) -> GameStateArray:
	return get_data(key) as GameStateArray


func get_int(key: String) -> GameStateInt:
	return get_data(key) as GameStateInt


func get_float(key: String) -> GameStateFloat:
	return get_data(key) as GameStateFloat


func get_string(key: String) -> GameStateString:
	return get_data(key) as GameStateString


func get_bool(key: String) -> GameStateBool:
	return get_data(key) as GameStateBool


## Gives a random positive number that isn't already an existing key.
func new_unique_key() -> String:
	var random_string: String
	while true:
		random_string = str(randi())
		if index_of(random_string) == -1:
			break
	return random_string


## Gives an arbitrary amount of different unique keys
func new_unique_keys(number_of_keys: int) -> Array[String]:
	var output: Array[String] = []
	var simulation: GameStateArray = duplicate()
	for i in number_of_keys:
		var new_key: String = simulation.new_unique_key()
		output.append(new_key)
		simulation.data().append(GameStateData.new(new_key))
	return output
