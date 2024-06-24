class_name AutoArrowSync
extends Node
## Use this to add or remove [AutoArrow]s.
## Sends the information to the other clients.


@export var game: Game


## Returns true if the client is allowed to add or remove autoarrows.
func can_apply_changes(country: Country) -> bool:
	if not MultiplayerUtils.is_online(multiplayer):
		return true
	return _client_can_apply_changes(multiplayer.get_unique_id(), country)


func add(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_online(multiplayer):
		_apply_add(country, auto_arrow)
		return
	
	var data: Dictionary = AutoArrowToDict.new().result(auto_arrow)
	if multiplayer.is_server():
		_handle_request_auto_arrow_added(country.id, data)
	else:
		_handle_request_auto_arrow_added.rpc_id(1, country.id, data)


func remove(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_online(multiplayer):
		_apply_remove(country, auto_arrow)
		return
	
	var data: Dictionary = AutoArrowToDict.new().result(auto_arrow)
	if multiplayer.is_server():
		_handle_request_auto_arrow_removed(country.id, data)
	else:
		_handle_request_auto_arrow_removed.rpc_id(1, country.id, data)


func clear_province(country: Country, province: Province) -> void:
	if not MultiplayerUtils.is_online(multiplayer):
		_apply_clear_province(country, province)
	elif multiplayer.is_server():
		_handle_request_auto_arrows_cleared(country.id, province.id)
	else:
		_handle_request_auto_arrows_cleared.rpc_id(1, country.id, province.id)


func _apply_add(country: Country, auto_arrow: AutoArrow) -> void:
	country.auto_arrows.add(auto_arrow)


func _apply_remove(country: Country, auto_arrow: AutoArrow) -> void:
	country.auto_arrows.remove(auto_arrow)


func _apply_clear_province(country: Country, province: Province) -> void:
	country.auto_arrows.remove_all_from_province(province)


#region Synchronize when an autoarrow is added
@rpc("any_peer", "call_remote", "reliable")
func _handle_request_auto_arrow_added(
		country_id: int, arrow_data: Dictionary
) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	# Check if the sender is allowed to add an autoarrow.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	var country: Country = game.countries.country_from_id(country_id)
	if not _client_can_apply_changes(request_sender_id, country):
		return
	
	_receive_auto_arrow_added.rpc(country_id, arrow_data)


@rpc("authority", "call_local", "reliable")
func _receive_auto_arrow_added(
		country_id: int, arrow_data: Dictionary
) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	if country == null:
		return
	_apply_add(country, AutoArrowFromDict.new().result(game, arrow_data))
#endregion


#region Synchronize when an autoarrow is removed
@rpc("any_peer", "call_remote", "reliable")
func _handle_request_auto_arrow_removed(
		country_id: int, arrow_data: Dictionary
) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	# Check if the sender is allowed to remove an autoarrow.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	var country: Country = game.countries.country_from_id(country_id)
	if not _client_can_apply_changes(request_sender_id, country):
		return
	
	_receive_auto_arrow_removed.rpc(country_id, arrow_data)


@rpc("authority", "call_local", "reliable")
func _receive_auto_arrow_removed(
		country_id: int, arrow_data: Dictionary
) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	if country == null:
		return
	_apply_remove(country, AutoArrowFromDict.new().result(game, arrow_data))
#endregion


#region Synchronize when all autoarrows are removed from a province
@rpc("any_peer", "call_remote", "reliable")
func _handle_request_auto_arrows_cleared(
		country_id: int, province_id: int
) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	# Check if the sender is allowed to remove the autoarrows.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	var country: Country = game.countries.country_from_id(country_id)
	if not _client_can_apply_changes(request_sender_id, country):
		return
	
	_receive_auto_arrows_cleared.rpc(country_id, province_id)


@rpc("authority", "call_local", "reliable")
func _receive_auto_arrows_cleared(country_id: int, province_id: int) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	if country == null:
		return
	var province: Province = game.world.provinces.province_from_id(province_id)
	if province == null:
		return
	_apply_clear_province(country, province)
#endregion


func _client_can_apply_changes(multiplayer_id: int, country: Country) -> bool:
	return game.game_players.client_controls_country(multiplayer_id, country)
