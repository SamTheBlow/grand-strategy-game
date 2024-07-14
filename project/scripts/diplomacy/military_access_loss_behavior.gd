class_name MilitaryAccessLossBehavior
## Class responsible for what to do when military access is lost.


var _game: Game


func _init(game: Game) -> void:
	_game = game
	
	if game.countries == null:
		push_error(
				"Created a military access loss behavior, but "
				+ "the game's countries is null! It will have no effect."
		)
		return
	
	for country in game.countries.list():
		_on_country_added(country)
	
	game.countries.country_added.connect(_on_country_added)


func _on_country_added(country: Country) -> void:
	country.relationships.relationship_created.connect(
			_on_relationship_created
	)


func _on_relationship_created(relationship: DiplomacyRelationship) -> void:
	relationship.military_access_changed.connect(_on_military_access_changed)


func _on_military_access_changed(relationship: DiplomacyRelationship) -> void:
	if relationship.grants_military_access():
		return
	
	match 2: #_game.rules.military_access_loss_behavior_option:
		0:
			pass
		1:
			_delete_armies(
					relationship.source_country, relationship.recipient_country
			)
		2:
			_teleport_armies_out(
					relationship.source_country, relationship.recipient_country
			)
		_:
			push_warning("Unrecognized military access loss behavior.")


func _delete_armies(
		source_country: Country, recipient_country: Country
) -> void:
	var affected_provinces: Array[Province] = (
			_game.world.provinces.provinces_of_country(source_country)
	)
	for province in affected_provinces:
		var armies_to_delete: Array[Army] = (
				_game.world.armies
				.armies_of_country_in_province(recipient_country, province)
		)
		for army in armies_to_delete:
			army.destroy()


func _teleport_armies_out(
		source_country: Country, recipient_country: Country
) -> void:
	var affected_provinces: Array[Province] = (
			_game.world.provinces.provinces_of_country(source_country)
	)
	for affected_province in affected_provinces:
		var armies_to_move: Array[Army] = (
				_game.world.armies.armies_of_country_in_province(
						recipient_country, affected_province
				)
		)
		if armies_to_move.size() == 0:
			continue
		
		var province_filter: Callable = func(province: Province) -> bool:
			return recipient_country.has_permission_to_move_into_country(
					province.owner_country
			)
		var nearest_provinces: Array[Province] = (
				affected_province.nearest_provinces(province_filter)
		)
		
		if nearest_provinces.size() == 0:
			for army in armies_to_move:
				army.destroy()
			continue
		
		var province_to_move_to: Province = nearest_provinces[0]
		
		# Give priority to the army's home territory
		for province in nearest_provinces:
			if province.owner_country == recipient_country:
				province_to_move_to = province
				break
		
		for army in armies_to_move:
			army.teleport_to_province(province_to_move_to)
			army.exhaust()
			# TODO merge armies automatically from outside this class
			# also this is very not optimal performance-wise
			_game.world.armies.merge_armies(province_to_move_to)
