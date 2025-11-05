class_name AutoArrowInput
extends Node
## Adds and removes autoarrows according to user input.
## When you're a network client, sends requests to the server instead.
## Emits a signal when a new preview arrow is created.

signal preview_arrow_created(
		preview_arrow: AutoArrowPreviewNode2D, country: Country
)

var game: Game

## The country that's currently accepting changes to its autoarrows.
var country_to_edit_id: int = -1


#region Adding an autoarrow
func _add_auto_arrow(country: Country, auto_arrow: AutoArrow) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		country.auto_arrows.add(auto_arrow)
		return

	_receive_add_auto_arrow.rpc_id(1, country.id, auto_arrow.to_raw_data())


## The server receives the request of adding a new [AutoArrow].
@rpc("any_peer", "call_remote", "reliable")
func _receive_add_auto_arrow(country_id: int, arrow_data: Variant) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	# Check if the sender is allowed to add an autoarrow.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	if not _client_can_apply_changes(request_sender_id):
		return

	# Requested accepted
	var country: Country = game.countries.country_from_id(country_id)
	var auto_arrow: AutoArrow = AutoArrow.from_raw_data(arrow_data)
	_add_auto_arrow(country, auto_arrow)
#endregion


#region Removing an autoarrow
func _remove_auto_arrow(country: Country, auto_arrow: AutoArrow) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		country.auto_arrows.remove(auto_arrow)
		return

	_receive_remove_auto_arrow.rpc_id(1, country.id, auto_arrow.to_raw_data())


## The server receives the request of removing an [AutoArrow].
@rpc("any_peer", "call_remote", "reliable")
func _receive_remove_auto_arrow(country_id: int, arrow_data: Variant) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	# Check if the sender is allowed to remove an autoarrow.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	if not _client_can_apply_changes(request_sender_id):
		return

	# Requested accepted
	var country: Country = game.countries.country_from_id(country_id)
	var auto_arrow: AutoArrow = AutoArrow.from_raw_data(arrow_data)
	_remove_auto_arrow(country, auto_arrow)
#endregion


#region Clearing a province
func _clear_province(country: Country, province_id: int) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		country.auto_arrows.remove_all_from_province(province_id)
		return

	_receive_clear_province.rpc_id(1, country.id, province_id)


## The server receives the request of removing all [AutoArrow]s in a province.
@rpc("any_peer", "call_remote", "reliable")
func _receive_clear_province(country_id: int, province_id: int) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	# Check if the sender is allowed to remove autoarrows.
	var request_sender_id: int = multiplayer.get_remote_sender_id()
	if request_sender_id == 0:
		request_sender_id = 1
	if not _client_can_apply_changes(request_sender_id):
		return

	# Requested accepted
	var country: Country = game.countries.country_from_id(country_id)
	_clear_province(country, province_id)
#endregion


func _create_preview_arrow(
		country: Country, province_visuals: ProvinceVisuals2D
) -> void:
	var preview_arrow := AutoArrowPreviewNode2D.new()
	preview_arrow.source_province = province_visuals
	preview_arrow.released.connect(_on_preview_arrow_released.bind(country.id))
	preview_arrow_created.emit(preview_arrow, country)


## Returns true if given client is currently
## allowed to add or remove autoarrows.
func _client_can_apply_changes(multiplayer_id: int) -> bool:
	return game.game_players.client_controls_country(
			multiplayer_id, game.turn.playing_player().playing_country
	)


func _on_provinces_unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	if event is not InputEventMouseButton or country_to_edit_id < 0:
		return
	var mouse_button_event := event as InputEventMouseButton

	if not (
			mouse_button_event.pressed
			and mouse_button_event.button_index == MOUSE_BUTTON_RIGHT
	):
		return

	# Make sure the country to edit still exists
	var country_to_edit: Country = (
			game.countries.country_from_id(country_to_edit_id)
	)
	if country_to_edit == null:
		country_to_edit_id = -1
		return

	# Double right click to remove all autoarrows in the province
	if mouse_button_event.double_click:
		_clear_province(country_to_edit, province_visuals.province.id)

	# Show a preview autoarrow during right click
	_create_preview_arrow(country_to_edit, province_visuals)

	get_viewport().set_input_as_handled()


func _on_preview_arrow_released(
		preview_arrow: AutoArrowPreviewNode2D,
		country_id: int
) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	if country == null:
		# Maybe the country got removed from the game
		# while the user was using the preview arrow.
		return

	var auto_arrow: AutoArrow = preview_arrow.auto_arrow()
	if country.auto_arrows.has_equivalent_in_list(auto_arrow):
		# An equivalent arrow already exists? Remove it
		_remove_auto_arrow(country, auto_arrow)
	else:
		_add_auto_arrow(country, auto_arrow)
