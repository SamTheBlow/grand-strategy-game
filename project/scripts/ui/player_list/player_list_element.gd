@tool
class_name PlayerListElement
extends Control
## Class for a [Player] as displayed in the [PlayerList] interface.
## This interface allows the user to remove or rename the player.
## The circular buttons only appear when the mouse hovers over the box
## (except when renaming a player).
## [br][br]
## To use, you'll need to call "init()" and set the "player" property.
## [br][br]
## For this to work, you need to make sure that the mouse filter
## in the scene's Control nodes is set to "Pass".
# TODO DRY: a LOT of code here is copy/pasted from [TurnOrderElement]


# TODO this is the same as in [TurnOrderElement]...
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

## This is for when you want to prevent the user from removing
## a [Player] when it's their last local player.
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

@onready var color_rect := $ColorRect as ColorRect
@onready var username_label := %UsernameLabel as Label
@onready var username_edit := %UsernameEdit as Control
@onready var username_line_edit := %UsernameLineEdit as LineEdit
@onready var _online_status := %OnlineStatus as Control
@onready var circle_buttons := %CircleButtons as Control
@onready var remove_button := %RemoveButton as Control
@onready var rename_button := %RenameButton as Control
@onready var confirm_button := %ConfirmButton as Control


func _ready() -> void:
	username_label.visible = true
	username_edit.visible = false
	_update_appearance()
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


# TODO this is ugly, find a way to get rid of this
# (and get rid of it in [TurnOrderElement] too)
## To be called when this node is created.
func init() -> void:
	custom_minimum_size.y = ($Contents as Control).size.y


func _update_shown_username() -> void:
	if not player:
		push_error("Player was not initialized.")
		username_label.text = ""
		return
	
	username_label.text = player.username()


func _update_appearance() -> void:
	if not is_inside_tree():
		return
	
	_update_shown_username()
	
	username_label.add_theme_color_override(
			"font_color", username_color_human
	)
	color_rect.color = bg_color_human
	
	_online_status.visible = player.is_remote()
	
	_update_button_visibility()


func _update_button_visibility() -> void:
	if not is_inside_tree():
		return
	
	_update_remove_button_visibility()
	rename_button.visible = (not _is_renaming) and _can_edit()
	confirm_button.visible = _is_renaming


func _update_remove_button_visibility() -> void:
	if not remove_button:
		return
	
	remove_button.visible = (
			_can_edit()
			and not is_the_only_local_human
			and not _is_renaming
	)


## Returns true if you're able to edit this player.
## When connected to a server, you only have control over local players.
## If you're the server, you have full control over everything.
func _can_edit() -> bool:
	return (
			not MultiplayerUtils.is_online(multiplayer)
			or multiplayer.is_server()
			or (player and (not player.is_remote()))
	)


func _submit_username_change() -> void:
	if not player:
		push_error("Tried to change someone's username, but player is null!")
		return
	
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
	if not player:
		push_error("Tried to remove the player, but player is null!")
		return
	if is_the_only_local_human:
		push_warning("Tried to remove the only local player.")
		return
	
	player.request_deletion()


func _on_rename_button_pressed() -> void:
	if _is_renaming:
		push_warning("Pressed the rename button, but already renaming!")
		return
	
	_is_renaming = true


func _on_confirm_button_pressed() -> void:
	if not _is_renaming:
		push_warning(
				"Pressed the confirm button, but there is nothing to confirm!"
		)
		return
	
	_is_renaming = false


func _on_player_sync_finished(_player: Player) -> void:
	_update_appearance()
