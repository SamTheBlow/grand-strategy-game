class_name CountryPlacementGeneration
## Tries to give each of given [Game]'s countries
## control over one province on the world map.


static func apply(game: Game) -> void:
	# Keep track of unassigned provinces.
	var unassigned_provinces: Array[Province] = []

	# Remove all existing province ownership.
	for province in game.world.provinces.list():
		province.owner_country = null
		unassigned_provinces.append(province)

	# Go through all the countries
	# and try to give to each of them one unassigned province.
	for country: Country in game.countries.list():
		# If we run out of provinces to give, then we're done.
		# Some countries won't have a province.
		if unassigned_provinces.is_empty():
			break

		var random_index: int = randi() % unassigned_provinces.size()
		unassigned_provinces[random_index].owner_country = country
		unassigned_provinces.remove_at(random_index)
