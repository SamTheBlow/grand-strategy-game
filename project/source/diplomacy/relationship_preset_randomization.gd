class_name RelationshipPresetRandomization
extends GameComponent
## During game setup, randomizes the relationship preset between all countries.

const KEY: String = "relationship_preset_randomization"
const TITLE: String = "Relationship Preset Randomization"
const DESCRIPTION: String = "During game setup, randomizes the relationship preset between all countries."
const SETTINGS: Array = []


func _init() -> void:
	priority_index = 40


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	var number_of_countries: int = game.countries.list.size()
	for i in number_of_countries:
		var country_1: Country = game.countries.list[i]
		for j in range(i + 1, number_of_countries):
			var country_2: Country = game.countries.list[j]
			var random_preset_id: int = 1 + game.rng.randi() % 3
			country_1.relationships.with_country(country_2)._set_preset_id(random_preset_id)
			country_2.relationships.with_country(country_1)._set_preset_id(random_preset_id)
