class_name CountryRelationshipsFromRaw
## Converts raw data into [DiplomacyRelationships] for each [Country].
## All the countries have to be loaded before using this.
## Overwrites the relationships property of all countries.
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.

const COUNTRY_RELATIONSHIPS_KEY: String = "relationships"


# WARNING: this implementation assumes that the game's countries and
# the data's countries are in the same order.
# If you're going to use this class right after using [CountryParsing],
# then this won't be a problem.
static func parse_using(raw_countries_data: Variant, game: Game) -> void:
	var default_relationship_data: Dictionary = (
			DiplomacyRelationships.new_default_data(game.rules)
	)
	var base_actions: Array[int] = (
			DiplomacyRelationships.new_base_actions(game.rules)
	)
	var country_list: Array[Country] = game.countries.list()

	var is_data_valid: bool = true
	var raw_countries_array: Array
	if raw_countries_data is Array:
		raw_countries_array = raw_countries_data
		if raw_countries_array.size() < country_list.size():
			is_data_valid = false
	else:
		is_data_valid = false

	for i in country_list.size():
		var relationships_data: Variant
		if is_data_valid and raw_countries_array[i] is Dictionary:
			var country_dict: Dictionary = raw_countries_array[i]
			relationships_data = country_dict.get(COUNTRY_RELATIONSHIPS_KEY)

		var country: Country = country_list[i]
		country.relationships = DiplomacyRelationshipsFromRaw.parsed_from(
				relationships_data,
				game,
				country,
				default_relationship_data,
				base_actions,
		)
