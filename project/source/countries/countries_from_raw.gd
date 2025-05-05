class_name CountriesFromRaw
## Converts raw data into [Countries].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards countries with an already-in-use id.

const COUNTRY_ID_KEY: String = "id"
const COUNTRY_NAME_KEY: String = "country_name"
const COUNTRY_COLOR_KEY: String = "color"
const COUNTRY_MONEY_KEY: String = "money"


static func parsed_from(raw_data: Variant) -> Countries:
	var countries := Countries.new()
	# Keep track of already-in-use ids,
	# to make sure all countries have a unique id.
	var used_ids: Array[int] = []

	if raw_data is not Array:
		return countries
	var raw_array: Array = raw_data

	for country_data: Variant in raw_array:
		var country: Country = _parsed_country(country_data, used_ids)
		if country == null:
			continue
		countries.add(country)
		used_ids.append(country.id)

	return countries


## This can fail, in which case it returns null.
static func _parsed_country(raw_data: Variant, used_ids: Array[int]) -> Country:
	# Fails when the data is not a dictionary
	if raw_data is not Dictionary:
		return null
	var raw_dict: Dictionary = raw_data

	var country := Country.new()

	# Id
	# Fails when there is no id, or the id is not a number
	if not ParseUtils.dictionary_has_number(raw_dict, COUNTRY_ID_KEY):
		return null
	# Fails when the id is out of bounds (i.e. negative number)
	# Fails when the id is already in use by another country
	var id: int = ParseUtils.dictionary_int(raw_dict, COUNTRY_ID_KEY)
	if (id < 0) or (id in used_ids):
		return null
	country.id = id

	# Name
	if ParseUtils.dictionary_has_string(raw_dict, COUNTRY_NAME_KEY):
		country.country_name = raw_dict[COUNTRY_NAME_KEY]

	# Color
	country.color = _parsed_country_color(raw_dict.get(COUNTRY_COLOR_KEY))

	# Money
	if ParseUtils.dictionary_has_number(raw_dict, COUNTRY_MONEY_KEY):
		country.money = ParseUtils.dictionary_int(raw_dict, COUNTRY_MONEY_KEY)

	return country


static func _parsed_country_color(raw_data: Variant) -> Color:
	var parsed_color: Color = (
			ParseUtils.color_from_raw(raw_data, Country.DEFAULT_COLOR)
	)
	parsed_color.a = 1.0
	return parsed_color
