class_name ProvinceOwnershipUpdate
## Updates the owner country of each province at the end of each player's turn.

## Effect does not trigger while disabled.
var is_enabled: bool = false:
	set(value):
		if value == is_enabled:
			return
		is_enabled = value
		if is_enabled:
			_game.turn.player_turn_ended.connect(_on_player_turn_ended)
		else:
			_game.turn.player_turn_ended.disconnect(_on_player_turn_ended)

var _game: Game


func _init(game: Game) -> void:
	_game = game
	is_enabled = true


func _update_ownership() -> void:
	for province in _game.world.provinces.list():
		_update_ownership_of(province)


func _update_ownership_of(province: Province) -> void:
	var current_owner: Country = province.owner_country
	var new_owner: Country = current_owner

	for army in _game.world.armies_in_each_province.in_province(province).list:
		# If the current owner has an army here,
		# then the province can't be taken by someone else.
		if army.owner_country == current_owner:
			return

		# Priority goes to the first army that landed here.
		# Once we've found a new owner, we don't need to search anymore.
		# However, we can't just break out of the loop, because we still
		# need to check for armies owned by the current owner.
		# WARNING assumes that armies_in_province returns the armies
		# in order of first one arrived to last one arrived
		if new_owner != current_owner:
			continue

		# If this army is not trespassing,
		# then it won't take control over the province.
		# See [DiplomacyRelationship]
		if not army.is_trespassing(_game.world.provinces):
			continue

		new_owner = army.owner_country

	province.owner_country = new_owner


func _on_player_turn_ended(_player: GamePlayer) -> void:
	_update_ownership()
