class_name Countries
## An encapsulated list of [Country] objects.

signal added(country: Country)
signal removed(country: Country)
signal order_changed(country_id: int, old_index: int, new_index: int)

## Maps each country to its unique id.
var _list: Dictionary[int, Country] = {}

## The order in which the items are in the list.
var _order: Array[int] = []

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
	_order.erase(country_id)

	# We have to unclaim the id because, if we want to bring this country
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(country_id)

	removed.emit(country)


## Shuffles the list's order using given [GameRNG].
func shuffle_order(rng: GameRNG) -> void:
	for i in _order.size() - 1:
		reorder(_order[rng.randi_range(i, _order.size() - 1)], i)


## Moves country with given id to be at given index position in the list.
## No effect if either input is invalid.
func reorder(country_id: int, new_index: int) -> void:
	if country_id not in _order or new_index < 0 or new_index >= _order.size():
		return

	# Don't do anything if the resulting order will be unchanged
	var old_index: int = _order.find(country_id)
	if old_index == new_index:
		return

	_order.insert(new_index, _order.pop_at(old_index))
	order_changed.emit(country_id, old_index, new_index)


## Returns null if there is no country with given id.
func country_from_id(id: int) -> Country:
	return _list[id] if _list.has(id) else null


## Returns null if given index is invalid.
func country_from_index(index: int) -> Country:
	if index < 0 or index >= _order.size():
		return null
	return _list[_order[index]]


## Returns a new copy of this list.
func list() -> Array[Country]:
	var output: Array[Country] = []
	for id in _order:
		output.append(_list[id])
	return output


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()


## Returns the position of given country in the list,
## or -1 if there is no country in this list with given id.
func position_of(country_id: int) -> int:
	return _order.find(country_id)


## Removes a country, using given [UndoRedoResource] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		country: Country,
		undo_redo: UndoRedoResource,
		provinces: Provinces,
		armies: Armies,
		armies_of_each_country: ArmiesOfEachCountry,
		armies_in_each_province: ArmiesInEachProvince
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

	# Save all of this country's armies and their positions
	var armies_with_positions: Array[ArmyWithPositions] = (
			armies.list_with_positions(
					armies_of_each_country.dictionary[country].list.keys(),
					armies_in_each_province
			)
	)

	undo_redo.create_action("Delete country")
	undo_redo.add_do_method(remove.bind(country.id))

	# Ensure the country's position in the list is restored on undo
	var country_index: int = _order.find(country.id)
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

	# Ensure the country's armies are restored on undo
	undo_redo.add_undo_method(armies.add_list_with_positions.bind(
			armies_with_positions, armies_in_each_province
	))

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
	DiplomacyRelationshipParsing.load_from_raw_data(
			country.relationships, raw_relationships
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

	if insertion_index < 0 or insertion_index >= _order.size():
		_order.append(country.id)
	else:
		_order.insert(insertion_index, country.id)

	added.emit(country)
