class_name AutoArrowsFromRaw
## Converts raw data into [AutoArrows] for each [Country].
## The game's countries and provinces must be loaded before using this.
## Overwrites the auto_arrows property of all countries.
##
## This operation always succeeds.
##
## See also: [AutoArrowFromRaw], [AutoArrowsToRaw], [AutoArrow]

const COUNTRY_AUTOARROWS_KEY: String = "auto_arrows"


static func parse_using(raw_countries_data: Variant, game: Game) -> void:
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
		var arrow_data: Variant
		if is_data_valid and raw_countries_array[i] is Dictionary:
			var country_dict: Dictionary = raw_countries_array[i]
			arrow_data = country_dict.get(COUNTRY_AUTOARROWS_KEY)

		country_list[i].auto_arrows = _parsed_arrows(arrow_data, game)


## This always succeeds. Arrows with invalid data are not added.
static func _parsed_arrows(raw_data: Variant, game: Game) -> AutoArrows:
	var auto_arrows := AutoArrows.new()

	if raw_data is not Array:
		return auto_arrows
	var raw_array: Array = raw_data

	for arrow_data: Variant in raw_array:
		var auto_arrow: AutoArrow = (
				AutoArrowFromRaw.parsed_from(arrow_data, game)
		)
		if auto_arrow == null:
			continue

		auto_arrows.add(auto_arrow)

	return auto_arrows
