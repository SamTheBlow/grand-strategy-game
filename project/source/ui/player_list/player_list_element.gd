class_name PlayerListElement
extends Control
## Displays information about given [Player].
## Allows the user to remove or rename the player.

signal delete_pressed(player: Player)

@export var username_color_human: Color
@export var bg_color_human: Color

var player: Player:
	set(value):
		if player != null:
			player.multiplayer_id_changed.disconnect(_refresh)
			player.username_changed.disconnect(_refresh_username_label)
			player.sync_finished.disconnect(_refresh)

		player = value
		_refresh()

		player.multiplayer_id_changed.connect(_refresh.unbind(1))
		player.username_changed.connect(_refresh_username_label.unbind(1))
		player.sync_finished.connect(_refresh.unbind(1))

## This is for when you want to prevent the user from removing
## a [Player] when it's their last local player.
var is_the_only_local_human: bool = false:
	set(value):
		is_the_only_local_human = value
		if is_node_ready():
			_refresh_remove_button()

var _is_renaming: bool = false:
	set(value):
		_is_renaming = value
		_username_label.visible = not _is_renaming
		_username_edit.visible = _is_renaming
		if _is_renaming:
			_username_line_edit.text = ""
			_username_line_edit.grab_focus()
		else:
			_submit_username_change()
		_circle_buttons.always_show = _is_renaming
		_refresh_buttons()

@onready var _color_rect := %ColorRect as ColorRect
@onready var _username_label := %UsernameLabel as Label
@onready var _username_edit := %UsernameEdit as Control
@onready var _username_line_edit := %UsernameLineEdit as LineEdit
@onready var _remote_indicator := %RemoteIndicator as Control
@onready var _circle_buttons := %CircleButtons as CircleButtons
@onready var _remove_button := %RemoveButton as Control
@onready var _rename_button := %RenameButton as Control
@onready var _confirm_button := %ConfirmButton as Control


func _ready() -> void:
	_username_label.visible = true
	_username_edit.visible = false
	_refresh()

	multiplayer.connected_to_server.connect(_refresh)
	multiplayer.server_disconnected.connect(_refresh)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"submit") and _is_renaming:
		_is_renaming = false

	if not _is_renaming or event is not InputEventMouseButton:
		return
	var event_mouse_button := event as InputEventMouseButton

	if (
			event_mouse_button.button_index == MOUSE_BUTTON_LEFT
			and event_mouse_button.pressed
			and not _is_mouse_inside()
	):
		_is_renaming = false


func _refresh() -> void:
	if not is_node_ready():
		return

	_refresh_username_label()
	_refresh_buttons()
	_refresh_remote_indicator()

	_username_label.add_theme_color_override(
			&"font_color", username_color_human
	)
	_color_rect.color = bg_color_human


func _refresh_username_label() -> void:
	if not is_node_ready():
		return

	_username_label.text = player.username()


func _refresh_buttons() -> void:
	if not is_node_ready():
		return

	_refresh_remove_button()
	_rename_button.visible = not _is_renaming and _can_edit()
	_confirm_button.visible = _is_renaming


func _refresh_remove_button() -> void:
	_remove_button.visible = (
			_can_edit()
			and not is_the_only_local_human
			and not _is_renaming
	)


func _refresh_remote_indicator() -> void:
	_remote_indicator.visible = player.is_remote()


## Returns true if you're able to edit this player.
## The server has full control over all players,
## while clients only have control over local players.
func _can_edit() -> bool:
	return MultiplayerUtils.has_authority(multiplayer) or not player.is_remote()


func _submit_username_change() -> void:
	var new_username: String = _username_line_edit.text.strip_edges()
	if new_username == "":
		return
	player.set_username(new_username)


func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _on_username_line_edit_focus_exited() -> void:
	if _is_renaming:
		_is_renaming = false


func _on_remove_button_pressed() -> void:
	if is_the_only_local_human:
		push_warning("Tried to remove the only local player.")
		return

	delete_pressed.emit(player)


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
