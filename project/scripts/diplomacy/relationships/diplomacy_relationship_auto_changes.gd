class_name DiplomacyRelationshipAutoChanges
## Class responsible for automatic changes in a [DiplomacyRelationship].
## For example, when its game rule is enabled, countries automatically
## fight back when a country starts fighting them.
##
## No setup needed.


var _game: Game


func _init(game: Game) -> void:
	_game = game
	
	# TODO bad code: private member access
	for country in _game.countries.list():
		for relationship in country.relationships._list:
			_connect_relationship(relationship)
		country.relationships.relationship_created.connect(
				_on_relationship_created
		)


func _connect_relationship(relationship: DiplomacyRelationship) -> void:
	relationship.military_access_changed.connect(_on_military_access_changed)
	relationship.trespassing_changed.connect(_on_trespassing_changed)
	relationship.fighting_changed.connect(_on_fighting_changed)


func _apply_data(
		relationship: DiplomacyRelationship, data: Dictionary
) -> void:
	(
			relationship.recipient_country.relationships
			.with_country(relationship.source_country)
			.apply_action_data(data, _game.turn.current_turn())
	)


func _on_relationship_created(relationship: DiplomacyRelationship) -> void:
	_connect_relationship(relationship)


func _on_military_access_changed(relationship: DiplomacyRelationship) -> void:
	if (
			_game.rules.is_military_access_mutual.value
			and relationship.grants_military_access()
	):
		_apply_data(relationship, {"grants_military_access": true})


func _on_trespassing_changed(relationship: DiplomacyRelationship) -> void:
	if (
			_game.rules.automatically_fight_trespassers.value
			and relationship.is_trespassing()
	):
		_apply_data(relationship, {"is_fighting": true})


func _on_fighting_changed(relationship: DiplomacyRelationship) -> void:
	if (
			_game.rules.is_military_access_revoked_when_fighting.value
			and relationship.is_fighting()
	):
		_apply_data(relationship, {"grants_military_access": false})
	
	if (
			_game.rules.automatically_fight_back.value
			and relationship.is_fighting()
	):
		_apply_data(relationship, {"is_fighting": true})
