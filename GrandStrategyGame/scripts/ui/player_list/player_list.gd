@tool
class_name PlayerList
extends Control
## Class responsible for displaying a list of players.
## It shows all players by their username, and shows with
## an arrow whose player it is to play.


@export_category("References")
@export var player_list_element: PackedScene
@export var margin: Control
@export var container: Control

@export_category("Variables")
@export var margin_pixels: int = 16 : set = _set_margin_pixels


func _ready() -> void:
	_set_margin_pixels(margin_pixels)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_update_size()


## To be called when this node is created.
func init(game: Game) -> void:
	var players: Array[Player] = game.players.players
	var element: PlayerListElement
	for i in players.size():
		element = player_list_element.instantiate() as PlayerListElement
		element.init(players[i], game.turn)
		container.add_child(element)
	_update_size()


func _set_margin_pixels(value: int) -> void:
	margin_pixels = value
	margin.offset_left = margin_pixels
	margin.offset_right = -margin_pixels
	margin.offset_top = margin_pixels
	margin.offset_bottom = -margin_pixels
	_update_size()


## Manually set this node's size
func _update_size() -> void:
	var new_size: int = 0
	for child in container.get_children():
		if not child is PlayerListElement:
			continue
		new_size += roundi((child as PlayerListElement).size.y)
		
		# I really don't know why we need to add 4, but it just works
		new_size += 4
	
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)
