@tool
class_name PlayerListElement
extends Control
## Class for a player as displayed in the player list interface.[br]
## [br]
## The circular buttons only appear when the mouse hovers over the box
## (except when renaming a player).[br]
## For this to work, you need to make sure that the mouse filter
## of Control nodes in the player list is set to "Pass".


@export_category("Child nodes")
@export var color_rect: ColorRect
@export var container: Control
@export var username_label: Label
@export var username_edit: Control
@export var username_line_edit: LineEdit
@export var circle_buttons: Control
@export var remove_button: Control
@export var rename_button: Control
@export var confirm_button: Control

@export_category("Variables")
@export var username_color_human: Color
@export var bg_color_human: Color

var player: Player:
	set(value):
		if player:
			player.username_changed.disconnect(_on_username_changed)
			player.sync_finished.disconnect(_on_player_sync_finished)
		player = value
		player.username_changed.connect(_on_username_changed)
		player.sync_finished.connect(_on_player_sync_finished)
		_update_appearance()

var is_the_only_local_human: bool = false:
	set(value):
		is_the_only_local_human = value
		_update_remove_button_visibility()

var _is_renaming: bool = false:
	set(value):
		_is_renaming = value
		username_label.visible = not _is_renaming
		username_edit.visible = _is_renaming
		if _is_renaming:
			username_line_edit.text = ""
			username_line_edit.grab_focus()
		else:
			_submit_username_change()
		circle_buttons.visible = _is_renaming or _is_mouse_inside()
		_update_button_visibility()


func _ready() -> void:
	if not player:
		player = Player.new()
	username_label.visible = true
	username_edit.visible = false
	_update_button_visibility()


func _process(_delta: float) -> void:
	if _is_renaming and Input.is_action_just_pressed("submit"):
		_is_renaming = false


func _input(event: InputEvent) -> void:
	if (not _is_renaming) or (not event is InputEventMouseButton):
		return
	
	if (
			(event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
			and (event as InputEventMouseButton).pressed
			and not _is_mouse_inside()
	):
		_is_renaming = false


## To be called when this node is created.
func init() -> void:
	_update_appearance()
	custom_minimum_size.y = container.size.y


func _update_shown_username() -> void:
	username_label.text = player.username()


func _update_appearance() -> void:
	_update_shown_username()
	
	username_label.add_theme_color_override(
			"font_color", username_color_human
	)
	color_rect.color = bg_color_human
	
	(%OnlineStatus as Control).visible = player.is_remote()
	
	_update_button_visibility()


func _update_button_visibility() -> void:
	_update_remove_button_visibility()
	rename_button.visible = (not _is_renaming) and _can_edit()
	confirm_button.visible = _is_renaming


func _update_remove_button_visibility() -> void:
	remove_button.visible = (
			_can_edit()
			and not is_the_only_local_human
			and not _is_renaming
	)


## Returns true if you're able to edit this player.
## When connected to a server, you only have control over local players.
## If you're the server, you have full control over everything.
func _can_edit() -> bool:
	if not (
		multiplayer
		and multiplayer.multiplayer_peer
		and multiplayer.multiplayer_peer.get_connection_status()
		== MultiplayerPeer.CONNECTION_CONNECTED
	):
		return true
	return (not player.is_remote()) or multiplayer.is_server()


func _submit_username_change() -> void:
	var new_username: String = username_line_edit.text.strip_edges()
	if new_username == "" or new_username == player.username():
		return
	player.custom_username = new_username


func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _on_mouse_entered() -> void:
	circle_buttons.visible = true


func _on_mouse_exited() -> void:
	circle_buttons.visible = _is_renaming


func _on_username_line_edit_focus_exited() -> void:
	if _is_renaming:
		_is_renaming = false


func _on_username_changed(_new_username: String) -> void:
	_update_shown_username()


func _on_remove_button_pressed() -> void:
	if is_the_only_local_human:
		print_debug("Tried to remove the only local player.")
		return
	
	player.request_deletion()


func _on_rename_button_pressed() -> void:
	if _is_renaming:
		print_debug("Pressed the rename button, but already renaming!")
		return
	
	_is_renaming = true


func _on_confirm_button_pressed() -> void:
	if not _is_renaming:
		print_debug(
				"Pressed the confirm button, but there is nothing to confirm!"
		)
		return
	
	_is_renaming = false


func _on_player_sync_finished(_player: Player) -> void:
	_update_appearance()
