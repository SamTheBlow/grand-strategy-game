class_name MilitaryAccessLossBehavior
## Class responsible for what to do when military access is lost.
##
## No setup needed.

var _game: Game


## Note that given game must already have its countries and world loaded.
func _init(game: Game) -> void:
	_game = game

	if game.countries == null:
		push_error(
				"Created a military access loss behavior, but "
				+ "the game's countries is null! It will have no effect."
		)
		return

	if game.world == null:
		push_error(
				"Created a military access loss behavior, but "
				+ "the game's world is null! It will have no effect."
		)
		return

	for country in game.countries.list():
		_on_country_added(country)

	game.countries.country_added.connect(_on_country_added)
	game.world.provinces.province_owner_changed.connect(
			_on_province_owner_changed
	)


func _on_country_added(country: Country) -> void:
	country.relationships.relationship_created.connect(_on_relationship_created)


func _on_relationship_created(relationship: DiplomacyRelationship) -> void:
	relationship.military_access_changed.connect(_on_military_access_changed)


func _on_military_access_changed(relationship: DiplomacyRelationship) -> void:
	if relationship.grants_military_access():
		return

	var affected_provinces: Array[Province] = (
			_game.world.provinces_of_each_country
			.of_country(relationship.source_country).list
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


func _apply(
		affected_countries: Array[Country],
		affected_provinces: Array[Province]
) -> void:
	# TODO bad code: hard coded values
	match _game.rules.military_access_loss_behavior_option.selected_value():
		0:
			pass
		1:
			_delete_armies(affected_countries, affected_provinces)
		2:
			_teleport_armies_out(affected_countries, affected_provinces)
		_:
			push_warning("Unrecognized military access loss behavior.")


func _delete_armies(
		affected_countries: Array[Country],
		affected_provinces: Array[Province]
) -> void:
	for affected_country in affected_countries:
		for province in affected_provinces:
			var armies_in_province: Array[Army] = (
					_game.world.armies_in_each_province
					.in_province(province).list
			)
			for army in armies_in_province:
				if army.owner_country == affected_country:
					army.destroy()


func _teleport_armies_out(
		affected_countries: Array[Country],
		affected_provinces: Array[Province]
) -> void:
	for affected_country in affected_countries:
		for affected_province in affected_provinces:
			var armies_in_province: Array[Army] = (
					_game.world.armies_in_each_province
					.in_province(affected_province).list
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

				army.teleport_to_province(province_to_move_to)
				army.exhaust()

				# TODO merge armies automatically from outside this class
				_game.world.armies.merge_armies(
						_game.world.armies_in_each_province
						.in_province(province_to_move_to),
						_game.turn.playing_player().playing_country
				)
