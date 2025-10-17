class_name CountryParsing
## Parses [Country] data.

const _COUNTRY_ID_KEY: String = "id"
const _COUNTRY_NAME_KEY: String = "country_name"
const _COUNTRY_COLOR_KEY: String = "color"
const _COUNTRY_MONEY_KEY: String = "money"


## Always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards countries with an already-in-use id.
static func countries_from_raw_data(raw_data: Variant) -> Countries:
	var countries := Countries.new()

	if raw_data is not Array:
		return countries
	var raw_array: Array = raw_data

	for country_data: Variant in raw_array:
		_add_country_from_raw_data(countries, country_data)

	return countries


static func countries_to_raw_array(country_list: Array[Country]) -> Array:
	var output: Array = []

	for country in country_list:
		output.append(country_to_raw_dict(country))

	return output


static func country_to_raw_dict(country: Country) -> Dictionary:
	var output: Dictionary = { _COUNTRY_ID_KEY: country.id }

	if country.country_name != "":
		output.merge({ _COUNTRY_NAME_KEY: country.country_name })

	if country.color != Country.DEFAULT_COLOR:
		output.merge({
			# Don't include transparency
			_COUNTRY_COLOR_KEY: country.color.to_html(false)
		})

	if country.money != 0:
		output.merge({ _COUNTRY_MONEY_KEY: country.money })

	# Relationships
	var raw_relationships: Array = (
			DiplomacyRelationshipsToRaw.result(country.relationships)
			if country.relationships != null else []
	)
	if not raw_relationships.is_empty():
		output.merge({
			CountryRelationshipsFromRaw.COUNTRY_RELATIONSHIPS_KEY:
				raw_relationships
		})

	# Notifications
	var raw_notifications: Array = (
			GameNotificationsToRaw.result(country.notifications)
	)
	if not raw_notifications.is_empty():
		output.merge({
			CountryNotificationsFromRaw.COUNTRY_NOTIFICATIONS_KEY:
				raw_notifications
		})

	# Autoarrows
	var raw_auto_arrows: Array = (
			AutoArrowsToRaw.result(country.auto_arrows)
	)
	if not raw_auto_arrows.is_empty():
		output.merge({
			AutoArrowsFromRaw.COUNTRY_AUTOARROWS_KEY: raw_auto_arrows
		})

	return output


## No effect if data is invalid.
static func _add_country_from_raw_data(
		countries: Countries, raw_data: Variant
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var country := Country.new()

	# Id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _COUNTRY_ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, _COUNTRY_ID_KEY)
	country.id = id

	# Name
	if ParseUtils.dictionary_has_string(raw_dict, _COUNTRY_NAME_KEY):
		country.country_name = raw_dict[_COUNTRY_NAME_KEY]

	# Color
	country.color = _country_color_from_raw(raw_dict.get(_COUNTRY_COLOR_KEY))

	# Money
	if ParseUtils.dictionary_has_number(raw_dict, _COUNTRY_MONEY_KEY):
		country.money = ParseUtils.dictionary_int(raw_dict, _COUNTRY_MONEY_KEY)

	countries.add(country)


static func _country_color_from_raw(raw_data: Variant) -> Color:
	var parsed_color: Color = (
			ParseUtils.color_from_raw(raw_data, Country.DEFAULT_COLOR)
	)
	parsed_color.a = 1.0
	return parsed_color
