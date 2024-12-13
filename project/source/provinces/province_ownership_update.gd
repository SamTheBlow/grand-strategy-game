class_name ProvinceOwnershipUpdate
## Updates given [Province]'s owner country at the end of each player's turn.
## Once it is determined, it is applied immediately.

var _armies_in_province: ArmiesInProvince
var _province: Province


func _init(
		province: Province,
		armies_in_province: ArmiesInProvince,
		player_turn_ended: Signal
) -> void:
	_province = province
	_armies_in_province = armies_in_province
	player_turn_ended.connect(_on_player_turn_ended)


func _update_ownership() -> void:
	var current_owner: Country = _province.owner_country
	var new_owner: Country = current_owner

	for army in _armies_in_province.list:
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
		if not army.is_trespassing():
			continue

		new_owner = army.owner_country

	_province.owner_country = new_owner


func _on_player_turn_ended(_player: GamePlayer) -> void:
	_update_ownership()
