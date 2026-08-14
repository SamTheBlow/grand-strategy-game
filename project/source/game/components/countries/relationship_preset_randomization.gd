class_name RelationshipPresetRandomization
extends GameComponent
## Randomizes the relationship preset between all countries.
## Ignores and overwrites existing relationships.

const KEY: String = "relationship_preset_randomization"


func _init() -> void:
	priority_index = 40


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	if not (
			game.rules.is_diplomacy_presets_enabled()
			and game.rules.starts_with_random_relationship_preset.value
	):
		return

	var country_list: Array[Country] = game.countries.list()
	var number_of_countries: int = game.countries.size()
	for i in number_of_countries:
		var country_1: Country = country_list[i]
		for j in range(i + 1, number_of_countries):
			var country_2: Country = country_list[j]
			var random_preset_id: int = 1 + game.rng.randi() % 3
			country_1.relationships.with_country(country_2)._set_preset_id(random_preset_id)
			country_2.relationships.with_country(country_1)._set_preset_id(random_preset_id)
