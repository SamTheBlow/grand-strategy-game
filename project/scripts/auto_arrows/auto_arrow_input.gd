class_name AutoArrowInput
extends Node
## Listens to and reacts to user input related to autoarrows.
##
## Creates, updates and removes the preview arrow
## that appears when the user holds right click.
##
## When the user makes a valid autoarrow, creates a new [AutoArrow]
## and adds it to the user's playing [Country], if allowed.
## Or, if the autoarrow already exists, removes the existing arrow instead.
##
## When the user double right clicks on a [Province],
## removes all autoarrows that point away from the province.
##
## WARNING: in the scene tree, this node needs to be above the world layer,
## because inputs need to be handled by the provinces first.


@export var game: Game
@export var auto_arrow_sync: AutoArrowSync

var _preview_arrow: AutoArrowNode2D:
	set(value):
		if _preview_arrow != null:
			if value != null:
				push_warning(
						"Creating a new preview arrow, but the "
						+ "previous one was never removed. Removing it."
				)
			if _preview_arrow.get_parent() != null:
				_preview_arrow.get_parent().remove_child(_preview_arrow)
			_preview_arrow.queue_free()
		_preview_arrow = value


func _ready() -> void:
	var provinces: Provinces = (game.world as GameWorld2D).provinces
	provinces.province_unhandled_mouse_event_occured.connect(
			_on_province_unhandled_mouse_event
	)
	provinces.province_mouse_event_occured.connect(_on_province_mouse_event)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if _is_right_click_just_released(event as InputEventMouseButton):
			_release_preview_arrow()
	elif event is InputEventMouseMotion:
		_update_arrow_destination()


func _input_mouse_button_on_province(
		event: InputEventMouseButton, province: Province
) -> void:
	if not _is_right_click_just_pressed(event):
		return
	
	if event.double_click:
		_remove_all_arrows_from_province(province)
	
	_setup_new_preview_arrow(province)
	get_viewport().set_input_as_handled()


func _setup_new_preview_arrow(province: Province) -> void:
	var playing_country: Country = _country()
	if not auto_arrow_sync.can_apply_changes(playing_country):
		return
	
	_preview_arrow = AutoArrowNode2D.new()
	_preview_arrow.source_province = province
	(
			(game.world as GameWorld2D).auto_arrow_container
			.arrows_of_country(playing_country).add_child(_preview_arrow)
	)
	_update_arrow_destination()


## Called whenever the mouse cursor moves.
## Updates the preview arrow so that it moves with the cursor.
## Makes the preview arrow no longer snap to a province
## when the cursor moves away from the province.
func _update_arrow_destination() -> void:
	if _preview_arrow == null:
		return
	
	if (
			_preview_arrow.destination_province != null
			and not _preview_arrow.destination_province.mouse_is_inside_shape()
	):
		_preview_arrow.destination_province = null
	
	_preview_arrow.world_destination = (
			PositionScreenToWorld.new()
			.result(get_viewport().get_mouse_position(), get_viewport())
	)


func _snap_preview_arrow_to_province(province: Province) -> void:
	if _preview_arrow == null:
		return
	
	if province.is_linked_to(_preview_arrow.source_province):
		_preview_arrow.destination_province = province


func _release_preview_arrow() -> void:
	if _preview_arrow == null:
		return
	
	if _preview_arrow.destination_province == null:
		_preview_arrow = null
		return
	
	var auto_arrow := AutoArrow.new(
			_preview_arrow.source_province, _preview_arrow.destination_province
	)
	
	_preview_arrow = null
	
	var country: Country = _country()
	if country.auto_arrows.has_equivalent_in_list(auto_arrow):
		# An equivalent arrow already exists? Remove it
		auto_arrow_sync.remove(country, auto_arrow)
	else:
		auto_arrow_sync.add(country, auto_arrow)


func _remove_all_arrows_from_province(province: Province) -> void:
	auto_arrow_sync.clear_province(_country(), province)


func _is_right_click_just_pressed(event: InputEventMouseButton) -> bool:
	return event.pressed and event.button_index == MOUSE_BUTTON_RIGHT


func _is_right_click_just_released(event: InputEventMouseButton) -> bool:
	return (not event.pressed) and event.button_index == MOUSE_BUTTON_RIGHT


func _country() -> Country:
	return game.turn.playing_player().playing_country


func _on_province_unhandled_mouse_event(
		event: InputEventMouse, province: Province
) -> void:
	if not event is InputEventMouseButton:
		return
	
	_input_mouse_button_on_province(event as InputEventMouseButton, province)


func _on_province_mouse_event(
		event: InputEventMouse, province: Province
) -> void:
	if not event is InputEventMouseMotion:
		return
	
	_snap_preview_arrow_to_province(province)
