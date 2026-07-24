class_name Countries
## An encapsulated list of [Country] objects.

signal added(country: Country)
signal removed(country: Country)

## Maps each country to its unique id.
var _list: Dictionary[int, Country] = {}

## Tracks the insertion order of countries.
## Ensures that adding, removing and re-adding
## a country preserves the insertion order.
var _ordered_ids: Array[int] = []

var _unique_id_system := UniqueIdSystem.new()


## If given country's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given country's id is already in use,
## or if given country is already in the list.
func add(country: Country) -> void:
	_add(country)


## No effect if given country is not on the list.
func remove(country_id: int) -> void:
	if not _list.has(country_id):
		return
	var country: Country = _list[country_id]

	_list.erase(country_id)
	_ordered_ids.erase(country_id)

	# We have to unclaim the id because, if we want to bring this country
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(country_id)

	removed.emit(country)


## Returns null if there is no country with given id.
func country_from_id(id: int) -> Country:
	return _list[id] if _list.has(id) else null


## Returns a new copy of this list.
func list() -> Array[Country]:
	var output: Array[Country] = []
	for country_id in _ordered_ids:
		output.append(_list[country_id])
	return output


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()


## Returns the position of given country in the list,
## or -1 if there is no country in this list with given id.
func position_of(country_id: int) -> int:
	return _ordered_ids.find(country_id)


## Removes a country, using given [UndoRedo] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		country: Country, undo_redo: UndoRedo, provinces: Provinces
) -> void:
	# Save relationships state before removal
	var raw_relationships: Array = (
			DiplomacyRelationshipParsing.to_raw_array(country.relationships)
	)

	# Save which other countries referenced this country
	var referencing_country_ids: Array[int] = []
	for other_id: int in _list:
		var other: Country = _list[other_id]
		if other.relationships.list.has(country):
			referencing_country_ids.append(other.id)

	undo_redo.create_action("Delete country")
	undo_redo.add_do_method(remove.bind(country.id))

	# Ensure the country's position in the list is restored on undo
	var country_index: int = _ordered_ids.find(country.id)
	undo_redo.add_undo_method(_add.bind(country, country_index))

	# Ensure the country's relationships are restored on undo
	undo_redo.add_undo_method(_restore_relationships.bind(
			country, raw_relationships, referencing_country_ids
	))

	# Ensure province ownership is restored on undo
	var province_id_list: Array[int] = []
	for province in provinces.list():
		if province.owner_country == country:
			province_id_list.append(province.id)
	undo_redo.add_undo_method(
			_restore_ownership.bind(country, province_id_list, provinces)
	)

	undo_redo.commit_action()


## Restores relationships after a country is un-done (re-added).
## Re-creates the country's own relationships from raw data
## and re-inserts this country into other countries' relationship lists.
func _restore_relationships(
		country: Country,
		raw_relationships: Array,
		referencing_country_ids: Array[int]
) -> void:
	# Restore own relationships
	country.relationships = DiplomacyRelationshipParsing.from_raw_data(
			raw_relationships, country.relationships._game, country
	)

	# Restore references from other countries
	for other_id: int in referencing_country_ids:
		var other: Country = _list.get(other_id)
		if other != null and not other.relationships.list.has(country):
			# Re-create a basic relationship entry for this country
			other.relationships.add(country)


## Restores province ownership after a country is re-added on undo.
func _restore_ownership(
		country: Country, province_id_list: Array[int], provinces: Provinces
) -> void:
	for province_id in province_id_list:
		var province: Province = provinces.province_from_id(province_id)
		if province == null:
			push_error("Province doesn't exist")
			continue
		province.owner_country = country


## Keeps the insertion index a private feature.
func _add(country: Country, insertion_index: int = -1) -> void:
	if _list.has(country.id):
		print_debug("Country is already in the list.")
		return
	if not _unique_id_system.is_id_valid(country.id):
		country.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(country.id):
		print_debug(
				"Country id is already in use. (id: " + str(country.id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(country.id)

	_list[country.id] = country

	if insertion_index < 0 or insertion_index >= _ordered_ids.size():
		_ordered_ids.append(country.id)
	else:
		_ordered_ids.insert(insertion_index, country.id)

	added.emit(country)
