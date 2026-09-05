class_name TurnOrderElement
extends Control
## Displays information about given [GamePlayer].
## Allows the user to rename the player and to toggle between human and AI.
## If applicable, shows with an arrow if it's this player's turn to play.

signal new_player_requested(game_player: GamePlayer)
signal delete_pressed(game_player: GamePlayer)

@export var username_color_human: Color
@export var username_color_ai: Color
@export var bg_color_human: Color
@export var bg_color_ai: Color

var player: GamePlayer:
	set(value):
		if player != null:
			player.human_status_changed.disconnect(_on_human_status_changed)
			player.username_changed.disconnect(_refresh_username_label)
			player.player_human_changed.disconnect(_on_human_status_changed)
			if player.is_human and player.player_human != null:
				player.player_human.sync_finished.disconnect(_refresh)
				player.player_human.multiplayer_id_changed.disconnect(_refresh)

		player = value
		_refresh()

		player.human_status_changed.connect(_on_human_status_changed.unbind(1))
		player.username_changed.connect(_refresh_username_label.unbind(1))
		player.player_human_changed.connect(_on_human_status_changed)

## May be null,
## in which case the arrow that shows whose turn it is will not appear.
var turn: GameTurn = null:
	set(value):
		if turn != null:
			turn.playing_country_changed.disconnect(_refresh_turn_arrow)

		turn = value
		_refresh_turn_arrow()

		if turn != null:
			turn.playing_country_changed.connect(_refresh_turn_arrow.unbind(1))

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
@onready var _arrow_label := %ArrowLabel as Label
@onready var _username_label := %UsernameLabel as Label
@onready var _username_edit := %UsernameEdit as Control
@onready var _username_line_edit := %UsernameLineEdit as LineEdit
@onready var _remote_indicator := %RemoteIndicator as Control
@onready var _circle_buttons := %CircleButtons as CircleButtons
@onready var _add_button := %AddButton as Control
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


## To be called when this node is created.
func init() -> void:
	custom_minimum_size.y = ($Contents as Control).size.y


func _refresh() -> void:
	if not is_node_ready():
		return

	_refresh_username_label()
	_refresh_turn_arrow()
	_refresh_buttons()
	_refresh_remote_indicator()

	if player.is_human:
		_username_label.add_theme_color_override(
				&"font_color", username_color_human
		)
		_color_rect.color = bg_color_human
	else:
		_username_label.add_theme_color_override(
				&"font_color", username_color_ai
		)
		_color_rect.color = bg_color_ai


func _refresh_username_label() -> void:
	if not is_node_ready():
		return

	_username_label.text = player.username_or_default()
	if not player.is_human:
		_username_label.text += " (AI)"
	if player.is_spectating():
		_username_label.text += " (Spectator)"


func _refresh_turn_arrow() -> void:
	if not is_node_ready():
		return

	if turn != null and turn.playing_country() == player.playing_country:
		_arrow_label.text = "->"
	else:
		_arrow_label.text = ""


func _refresh_buttons() -> void:
	if not is_node_ready():
		return

	_add_button.visible = not player.is_human and not _is_renaming
	_refresh_remove_button()
	_rename_button.visible = not _is_renaming and _can_edit()
	_confirm_button.visible = _is_renaming


func _refresh_remove_button() -> void:
	_remove_button.visible = (
			player.is_human
			and _can_edit()
			and not is_the_only_local_human
			and not _is_renaming
	)


func _refresh_remote_indicator() -> void:
	_remote_indicator.visible = (
			player.player_human != null and player.player_human.is_remote()
	)


## Returns true if you're able to edit this player.
## The server has full control over all players,
## while clients only have control over local players.
func _can_edit() -> bool:
	return (
			MultiplayerUtils.has_authority(multiplayer)
			or (
					player.is_human
					and player.player_human != null
					and not player.player_human.is_remote()
			)
	)


func _submit_username_change() -> void:
	player.username = _username_line_edit.text.strip_edges()


func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _on_username_line_edit_focus_exited() -> void:
	if _is_renaming:
		_is_renaming = false


func _on_human_status_changed() -> void:
	_refresh()

	# We are possibly dealing with a new [Player] instance,
	# so we need to connect signals.
	if player == null or not player.is_human or player.player_human == null:
		return
	if not player.player_human.sync_finished.is_connected(_refresh):
		player.player_human.sync_finished.connect(_refresh.unbind(1))
	if not player.player_human.multiplayer_id_changed.is_connected(_refresh):
		player.player_human.multiplayer_id_changed.connect(_refresh.unbind(1))


func _on_add_button_pressed() -> void:
	if player.is_human:
		push_warning("Player is already human!")
		return

	new_player_requested.emit(player)


func _on_remove_button_pressed() -> void:
	if not player.is_human:
		push_warning("Player is already not human!")
		return
	if is_the_only_local_human:
		push_warning("Tried to remove the only local player.")
		return

	if player.player_human != null:
		delete_pressed.emit(player)
	else:
		push_warning("GamePlayer's player_human is null, weird.")
		player.is_human = false


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
