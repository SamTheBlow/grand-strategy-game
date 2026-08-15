class_name MilitaryAccessLossBehavior
extends GameComponent
## Handles what to do to armies that lose military access in a province.
##
## Option 0: no effect. (Default)
## Option 1: delete the armies.
## Option 2: teleport the armies to the nearest valid location.

const KEY: String = "military_access_loss_behavior"

const _OPTION_KEY: String = "option"

## What to do to the armies that lose military access.
## 0 = no effect, 1 = delete them, 2 = teleport them out.
var option: int = 0

var _game: Game


func _init() -> void:
	priority_index = 0


func register(game: Game) -> void:
	_game = game

	for country in game.countries.list():
		_connect_country(country)

	game.countries.added.connect(_connect_country)
	game.countries.removed.connect(_disconnect_country)
	game.world.provinces.province_owner_changed.connect(
			_on_province_owner_changed
	)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if option != 0:
		output[_OPTION_KEY] = option
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _OPTION_KEY):
		option = clampi(ParseUtils.dictionary_int(raw_dict, _OPTION_KEY), 0, 2)
	else:
		option = 0

	error = false
	error_message = ""


func _connect_country(country: Country) -> void:
	country.relationships.relationship_created.connect(_connect_relationship)


func _disconnect_country(country: Country) -> void:
	country.relationships.relationship_created.disconnect(_connect_relationship)
	for other_country in country.relationships.list:
		(
				country.relationships.list[other_country]
				.military_access_changed
				.disconnect(_on_military_access_changed)
		)


func _connect_relationship(relationship: DiplomacyRelationship) -> void:
	relationship.military_access_changed.connect(_on_military_access_changed)


func _apply(
		affected_countries: Array[Country], affected_provinces: Array[Province]
) -> void:
	match option:
		0:
			pass
		1:
			_delete_armies(affected_countries, affected_provinces)
		2:
			_teleport_armies_out(affected_countries, affected_provinces)
		_:
			push_warning("Unrecognized military access loss behavior.")


func _delete_armies(
		affected_countries: Array[Country], affected_provinces: Array[Province]
) -> void:
	for affected_country in affected_countries:
		for province in affected_provinces:
			for army in (
					_game.world.armies_in_each_province
					.dictionary[province.id].ordered_list
			):
				if army.owner_country == affected_country:
					army.destroy()


func _teleport_armies_out(
		affected_countries: Array[Country], affected_provinces: Array[Province]
) -> void:
	for affected_country in affected_countries:
		for affected_province in affected_provinces:
			var armies_in_province: Array[Army] = (
					_game.world.armies_in_each_province
					.dictionary[affected_province.id].ordered_list
			)
			if armies_in_province.size() == 0:
				continue

			var province_filter: Callable = func(province: Province) -> bool:
				return affected_country.has_permission_to_move_into_country(
						province.owner_country
				)
			var nearest_provinces: Array[Province] = (
					affected_province.nearest_provinces(
							_game.world.provinces, province_filter
					)
			)

			if nearest_provinces.size() == 0:
				for army in armies_in_province:
					if army.owner_country == affected_country:
						army.destroy()
				continue

			var province_to_move_to: Province = nearest_provinces[0]

			# Give priority to the army's home territory
			for province in nearest_provinces:
				if province.owner_country == affected_country:
					province_to_move_to = province
					break

			for army in armies_in_province:
				if army.owner_country != affected_country:
					continue

				army.teleport_to_province(province_to_move_to.id)
				army.exhaust()

				# TODO merge armies automatically from outside this class
				_game.world.armies.merge_armies(
						_game.world.armies_in_each_province
						.dictionary[province_to_move_to.id].ordered_list,
						_game.turn.playing_country()
				)


func _on_military_access_changed(relationship: DiplomacyRelationship) -> void:
	if relationship.grants_military_access():
		return

	var affected_provinces: Array[Province] = (
			_game.world.provinces_of_each_country
			.dictionary[relationship.source_country].list.keys()
	)
	_apply([relationship.recipient_country], affected_provinces)


func _on_province_owner_changed(province: Province) -> void:
	var affected_countries: Array[Country] = []
	for country in _game.countries.list():
		if not country.has_permission_to_move_into_country(
				province.owner_country
		):
			affected_countries.append(country)

	_apply(affected_countries, [province])
