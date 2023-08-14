class_name GameState
## The game state's root.


var _data: GameStateArray


func _init(data_: GameStateArray):
	_data = data_


func data() -> GameStateArray:
	return _data


## Creates a deep copy of the game state. Particularly useful.
## Make sure to duplicate the game state when sharing it with
## different components so that they can't alter the real game state.
func duplicate() -> GameState:
	return GameState.new(_data.duplicate())


func new_countries() -> Array[Country]:
	var countries_data: Array[GameStateData] = (
		data().get_array("countries").data()
	)
	var number_of_countries: int = countries_data.size()
	var output: Array[Country] = []
	for i in number_of_countries:
		var country_data := countries_data[i] as GameStateArray
		var country: Country = Country.new()
		country.country_name = String(country_data.get_string("name").data)
		country.color = Color.hex(country_data.get_int("color").data)
		country._key = country_data.key()
		output.append(country)
	return output


func human_player() -> String:
	return data().get_string("human_player").data


func player_country(player_key: String) -> String:
	var players_data: GameStateArray = data().get_array("players")
	var player_data: GameStateArray = players_data.get_array(player_key)
	return String(player_data.get_string("playing_country").data)


func provinces() -> GameStateArray:
	return data().get_array("provinces")


func province(province_key: String) -> GameStateArray:
	return provinces().get_array(province_key)


func province_links(province_key: String) -> GameStateArray:
	return province(province_key).get_array("links")


func province_owner(province_key: String) -> GameStateString:
	return province(province_key).get_string("owner")


func province_population(province_key: String) -> GameStateInt:
	return province(province_key).get_int("population")


func armies(province_key: String) -> GameStateArray:
	return province(province_key).get_array("armies")


func army(province_key: String, army_key: String) -> GameStateArray:
	return armies(province_key).get_array(army_key)


func new_province_armies(
	province_key: String,
	army_scene: PackedScene
) -> Array[Army]:
	var output: Array[Army] = []
	var armies_data: Array[GameStateData] = armies(province_key).data()
	for army_data in armies_data:
		var new_army := army_scene.instantiate() as Army
		new_army._key = army_data.key()
		output.append(new_army)
	return output


func army_owner(province_key: String, army_key: String) -> GameStateString:
	return army(province_key, army_key).get_string("owner")


func army_troop_count(province_key: String, army_key: String) -> GameStateInt:
	return army(province_key, army_key).get_int("troop_count")
