class_name ProvinceOwnershipUpdate
## Updates given [Province]'s owner country at the end of each player's turn.
## Once it is determined, it is applied immediately.


var _province: Province
var _armies: Armies


func _init(
		province: Province, armies: Armies, player_turn_ended: Signal
) -> void:
	_province = province
	_armies = armies
	player_turn_ended.connect(_on_player_turn_ended)


func _update_ownership() -> void:
	var current_owner: Country = _province.owner_country
	var new_owner: Country = current_owner
	
	for army in _armies.armies_in_province(_province):
		# If this province's owner has an army here,
		# then it can't be taken by someone else.
		if army.owner_country == _province.owner_country:
			return
		
		# Priority goes to the first army that landed here.
		# WARNING assumes that armies_in_province returns the armies
		# in order of first one arrived to last one arrived
		if new_owner != current_owner:
			continue
		
		# If this army's owner is not trespassing,
		# then it won't take control over the province.
		if not (
				army.owner_country.relationships
				.with_country(_province.owner_country).is_trespassing()
		):
			continue
		
		new_owner = army.owner_country
	
	_province.owner_country = new_owner


func _on_player_turn_ended(_player: GamePlayer) -> void:
	_update_ownership()
