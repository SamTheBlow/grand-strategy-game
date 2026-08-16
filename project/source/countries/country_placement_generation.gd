class_name CountryPlacementGeneration
extends GameComponent
## Tries to ensure each country controls at least one province.

const KEY: String = "country_placement_generation"


func _init() -> void:
	priority_index = 6


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	# Get list of unassigned provinces
	var unassigned_provinces: Array[Province] = (
			game.world.provinces_of_each_country.dictionary[null].list.keys()
	)

	# Go through each country and give it one unassigned province if applicable
	for country: Country in game.countries.list():
		# Skip if country already has a province
		if (
				not game.world.provinces_of_each_country
				.dictionary[country].list.is_empty()
		):
			continue

		# If we run out of provinces to give, then we're done.
		# Some countries won't have a province.
		if unassigned_provinces.is_empty():
			break

		var random_index: int = game.rng.randi() % unassigned_provinces.size()
		unassigned_provinces[random_index].owner_country = country
		unassigned_provinces.remove_at(random_index)
