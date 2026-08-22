class_name CountryParsing
## Parses raw data from/to [Country] instances.

const _ID_KEY: String = "id"
const _NAME_KEY: String = "country_name"
const _COLOR_KEY: String = "color"
const _MONEY_KEY: String = "money"
const _AUTOARROWS_KEY: String = "auto_arrows"
const _RELATIONSHIPS_KEY: String = "relationships"
const _NOTIFICATIONS_KEY: String = "notifications"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards countries with an already-in-use id.
static func load_from_raw_data(raw_data: Variant, game: Game) -> void:
	game.countries = Countries.new()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	# 1st pass
	var valid_country_data: Dictionary[Country, Dictionary] = {}
	for country_data: Variant in raw_array:
		var country: Country = _country_from_raw_data(country_data)
		if country != null:
			game.countries.add(country)
			valid_country_data[country] = country_data as Dictionary

	# 2nd pass (relationships)
	for country in game.countries.list():
		country.relationships = DiplomacyRelationshipParsing.from_raw_data(
				valid_country_data[country].get(_RELATIONSHIPS_KEY),
				game,
				country
		)

	# 3rd pass (notifications)
	for country in game.countries.list():
		GameNotificationParsing.load_from_raw_data(
				valid_country_data[country].get(_NOTIFICATIONS_KEY),
				game,
				country
		)


static func to_raw_array(countries: Countries) -> Array:
	var output: Array = []

	for country_id in countries._order:
		output.append(_country_to_raw_dict(countries._list[country_id]))

	return output


static func _country_to_raw_dict(country: Country) -> Dictionary:
	var output: Dictionary = { _ID_KEY: country.id }

	if country.country_name != "":
		output.merge({ _NAME_KEY: country.country_name })

	if country.color != Country.DEFAULT_COLOR:
		# Don't include transparency
		output.merge({ _COLOR_KEY: country.color.to_html(false) })

	if country.money != 0:
		output.merge({ _MONEY_KEY: country.money })

	# Relationships
	var raw_relationships: Array = (
			DiplomacyRelationshipParsing.to_raw_array(country.relationships)
			if country.relationships != null else []
	)
	if not raw_relationships.is_empty():
		output.merge({ _RELATIONSHIPS_KEY: raw_relationships })

	# Notifications
	var raw_notifications: Array = (
			GameNotificationParsing.to_raw_array(country.notifications)
	)
	if not raw_notifications.is_empty():
		output.merge({ _NOTIFICATIONS_KEY: raw_notifications })

	# Autoarrows
	var auto_arrow_data: Variant = country.auto_arrows.to_raw_data()
	if auto_arrow_data is not Array or not auto_arrow_data.is_empty():
		output.merge({ _AUTOARROWS_KEY: auto_arrow_data })

	return output


## Returns null if data is invalid.
static func _country_from_raw_data(raw_data: Variant) -> Country:
	if raw_data is not Dictionary:
		return null
	var raw_dict: Dictionary = raw_data

	# Id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return null

	var country := Country.new()
	country.id = ParseUtils.dictionary_int(raw_dict, _ID_KEY)

	# Name
	if ParseUtils.dictionary_has_string(raw_dict, _NAME_KEY):
		country.country_name = raw_dict[_NAME_KEY]

	# Color
	country.color = _country_color_from_raw(raw_dict.get(_COLOR_KEY))

	# Money
	if ParseUtils.dictionary_has_number(raw_dict, _MONEY_KEY):
		country.money = ParseUtils.dictionary_int(raw_dict, _MONEY_KEY)

	# Autoarrows
	if raw_dict.has(_AUTOARROWS_KEY):
		country.auto_arrows = (
				AutoArrows.from_raw_data(raw_dict[_AUTOARROWS_KEY])
		)

	return country


static func _country_color_from_raw(raw_data: Variant) -> Color:
	var parsed_color: Color = (
			ParseUtils.color_from_raw(raw_data, Country.DEFAULT_COLOR)
	)
	parsed_color.a = 1.0
	return parsed_color
