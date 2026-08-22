class_name CountryGeneration
extends GameComponent
## During game setup, generates new countries.

const KEY: String = "country_generation"
const TITLE: String = "Country Generation"
const DESCRIPTION: String = "During game setup, generates new countries."
const SETTINGS: Array = [
	{ "property_name": _NUMBER_OF_COUNTRIES_KEY, "text": "Number of countries", "type": "int", "min": 1 },
	{ "property_name": _STARTING_MONEY_KEY, "text": "Starting money", "type": "int" },
]

const _NUMBER_OF_COUNTRIES_KEY: String = "number_of_countries"
const _STARTING_MONEY_KEY: String = "starting_money"

var number_of_countries: int = 1
var starting_money: int = 0


func _init() -> void:
	priority_index = 5


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	for i in number_of_countries:
		var new_country: Country = Country.Factory.new(game).new_country()
		var color_r: float = game.rng.randf()
		var color_g: float = game.rng.randf()
		var color_b: float = game.rng.randf()
		new_country.color = Color(color_r, color_g, color_b, 1.0)
		new_country.money = starting_money
		game.countries.add(new_country)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if number_of_countries != 1:
		output[_NUMBER_OF_COUNTRIES_KEY] = number_of_countries
	if starting_money != 0:
		output[_STARTING_MONEY_KEY] = starting_money
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	# Number of countries
	if ParseUtils.dictionary_has_number(raw_dict, _NUMBER_OF_COUNTRIES_KEY):
		number_of_countries = (
				ParseUtils.dictionary_int(raw_dict, _NUMBER_OF_COUNTRIES_KEY)
		)
	else:
		number_of_countries = 1

	# Starting money
	if ParseUtils.dictionary_has_number(raw_dict, _STARTING_MONEY_KEY):
		starting_money = (
				ParseUtils.dictionary_int(raw_dict, _STARTING_MONEY_KEY)
		)
	else:
		starting_money = 0
