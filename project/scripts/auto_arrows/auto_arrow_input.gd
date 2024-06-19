class_name AutoArrowInput
extends Node
## Listens to a right click done on any [Province].
## Creates a new [AutoArrowNode2D] and updates it to show the arrow
## to the user when they hold right click.
## Creates a new [AutoArrow] and adds it to the user's playing [Country]
## when they release the right click, if applicable.
##
## WARNING: this node needs to be above the provinces in the scene tree,
## because inputs need to be handled by the provinces first.


@export var game: Game

var _new_auto_arrow_node: AutoArrowNode2D


func _ready() -> void:
	var provinces: Provinces = (game.world as GameWorld2D).provinces
	provinces.province_unhandled_mouse_event_occured.connect(
			_on_province_unhandled_mouse_event
	)
	provinces.province_mouse_event_occured.connect(_on_province_mouse_event)


func _unhandled_input(event: InputEvent) -> void:
	if _new_auto_arrow_node == null or not (event is InputEventMouseButton):
		return
	
	var event_mouse_button := event as InputEventMouseButton
	if (
			not event_mouse_button.pressed
			and event_mouse_button.button_index == MOUSE_BUTTON_RIGHT
	):
		# Released right click: remove the node
		_new_auto_arrow_node.removed.emit(_new_auto_arrow_node)
		_new_auto_arrow_node = null


func _input(event: InputEvent) -> void:
	if _new_auto_arrow_node != null and (event is InputEventMouseMotion):
		_update_arrow_destination()


func _update_arrow_destination() -> void:
	if (
			_new_auto_arrow_node.destination_province != null
			and not
			_new_auto_arrow_node.destination_province.mouse_is_inside_shape()
	):
		_new_auto_arrow_node.destination_province = null
	
	_new_auto_arrow_node.world_destination = (
			PositionScreenToWorld.new()
			.result(get_viewport().get_mouse_position(), get_viewport())
	)


func _start_arrow(province: Province) -> void:
	if _new_auto_arrow_node:
		push_warning(
				"Received a new right click, but the AutoArrow node for the "
				+ "previous right click is still here. Removing it."
		)
		_new_auto_arrow_node.removed.emit(_new_auto_arrow_node)
	
	_new_auto_arrow_node = AutoArrowNode2D.new()
	_new_auto_arrow_node.source_province = province
	(
			(game.world as GameWorld2D).auto_arrow_container
			.arrows_of_country(game.turn.playing_player().playing_country)
			.add(_new_auto_arrow_node)
	)
	_update_arrow_destination()


func _release_arrow(province: Province) -> void:
	if _new_auto_arrow_node == null:
		return
	
	# It's only valid if the destination is linked to the source
	if not province.is_linked_to(_new_auto_arrow_node.source_province):
		_new_auto_arrow_node.removed.emit(_new_auto_arrow_node)
		_new_auto_arrow_node = null
		return
	
	var auto_arrow := AutoArrow.new()
	auto_arrow.source_province = _new_auto_arrow_node.source_province
	auto_arrow.destination_province = province
	
	# This exact arrow already exists? Remove it
	var country_arrows: AutoArrows = (
			game.turn.playing_player().playing_country.auto_arrows
	)
	if country_arrows.is_duplicate(auto_arrow):
		country_arrows.remove(auto_arrow)
		_new_auto_arrow_node.removed.emit(_new_auto_arrow_node)
		_new_auto_arrow_node = null
		return
	
	_new_auto_arrow_node.auto_arrow = auto_arrow
	_new_auto_arrow_node = null
	game.turn.playing_player().playing_country.auto_arrows.add(auto_arrow)


func _on_province_unhandled_mouse_event(
		event: InputEventMouse, province: Province
) -> void:
	if not (event is InputEventMouseButton):
		return
	
	var event_button := event as InputEventMouseButton
	if event_button.button_index == MOUSE_BUTTON_RIGHT:
		if event_button.pressed:
			_start_arrow(province)
			if event_button.double_click:
				# Double right click: remove all [AutoArrow]s from the province
				(
						game.turn.playing_player().playing_country
						.auto_arrows.remove_all_from_province(province)
				)
		else:
			_release_arrow(province)
		get_viewport().set_input_as_handled()


func _on_province_mouse_event(
		event: InputEventMouse, province: Province
) -> void:
	# Cursor is on a province: snap arrow to the province, if applicable
	if not (event is InputEventMouseMotion):
		return
	if _new_auto_arrow_node == null:
		return
	if not province.is_linked_to(_new_auto_arrow_node.source_province):
		return
	_new_auto_arrow_node.destination_province = province
