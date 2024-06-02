@tool
class_name TurnOrderElement
extends Control
## Class for a [Player] as displayed in the [TurnOrderList] interface.
## This interface allows the user to rename the player,
## and to turn it into either a local human or an AI.
## It also shows with an arrow if it's this player's turn to play.
## The circular buttons only appear when the mouse hovers over the box
## (except when renaming a player).
## [br][br]
## To use, you'll need to call "init()" and set the "player" property.
## You also have to set the "turn" property if you want the arrow to appear.
## [br][br]
## For this to work, you need to make sure that the mouse filter
## in the scene's Control nodes is set to "Pass".


signal new_player_requested(game_player: GamePlayer)

@export var username_color_human: Color
@export var username_color_ai: Color
@export var bg_color_human: Color
@export var bg_color_ai: Color

var player: GamePlayer:
	set(value):
		if player:
			player.human_status_changed.disconnect(_on_human_status_changed)
			player.username_changed.disconnect(_on_username_changed)
			if player.player_human:
				player.player_human.sync_finished.disconnect(
						_on_player_sync_finished
				)
		
		player = value
		_update_appearance()
		
		if player:
			player.human_status_changed.connect(_on_human_status_changed)
			player.username_changed.connect(_on_username_changed)
			if player.player_human:
				player.player_human.sync_finished.connect(
						_on_player_sync_finished
				)

## It's okay to leave this [code]null[/code] if you want.
var turn: GameTurn:
	set(value):
		if turn:
			turn.player_changed.disconnect(_on_player_turn_changed)
		
		turn = value
		_update_turn_indicator()
		
		if turn:
			turn.player_changed.connect(_on_player_turn_changed)

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
@onready var arrow_container := %ArrowContainer as Control
@onready var arrow_label := %ArrowLabel as Label
@onready var username_label := %UsernameLabel as Label
@onready var username_edit := %UsernameEdit as Control
@onready var username_line_edit := %UsernameLineEdit as LineEdit
@onready var _online_status := %OnlineStatus as Control
@onready var circle_buttons := %CircleButtons as Control
@onready var add_button := %AddButton as Control
@onready var remove_button := %RemoveButton as Control
@onready var rename_button := %RenameButton as Control
@onready var confirm_button := %ConfirmButton as Control


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	username_label.visible = true
	username_edit.visible = false
	_update_turn_indicator()
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
## To be called when this node is created.
func init() -> void:
	custom_minimum_size.y = ($Contents as Control).size.y


func _update_shown_username() -> void:
	if not player:
		print_debug("Player was not initialized")
		username_label.text = ""
		return
	
	username_label.text = player.username
	if not player.is_human:
		username_label.text += " (AI)"
	if player.is_spectating():
		username_label.text += " (Spectator)"


func _update_turn_indicator() -> void:
	if not is_inside_tree():
		return
	
	if (not turn) or (not player):
		arrow_label.text = ""
		return
	
	if turn.playing_player() == player:
		arrow_label.text = "->"
	else:
		arrow_label.text = ""


func _update_appearance() -> void:
	if not is_inside_tree():
		return
	
	_update_shown_username()
	
	if (not player) or player.is_human:
		username_label.add_theme_color_override(
				"font_color", username_color_human
		)
		color_rect.color = bg_color_human
	else:
		username_label.add_theme_color_override(
				"font_color", username_color_ai
		)
		color_rect.color = bg_color_ai
	
	_online_status.visible = (
			player and player.player_human and player.player_human.is_remote()
	)
	
	_update_button_visibility()


func _update_button_visibility() -> void:
	if not is_inside_tree():
		return
	
	add_button.visible = (
			player
			and not player.is_human
			and not _is_renaming
	)
	_update_remove_button_visibility()
	rename_button.visible = (not _is_renaming) and _can_edit()
	confirm_button.visible = _is_renaming


func _update_remove_button_visibility() -> void:
	if not remove_button:
		return
	
	remove_button.visible = (
			player
			and player.is_human
			and _can_edit()
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
			or (
					player
					and player.player_human
					and (not player.player_human.is_remote())
			)
	)


func _submit_username_change() -> void:
	if not player:
		print_debug("Tried to change someone's username, but player is null!")
		return
	
	var new_username: String = username_line_edit.text.strip_edges()
	if new_username == "" or new_username == player.username:
		return
	player.username = new_username


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


func _on_human_status_changed(_changed_player: GamePlayer) -> void:
	_update_appearance()


func _on_player_turn_changed(_playing_player: GamePlayer) -> void:
	_update_turn_indicator()


func _on_add_button_pressed() -> void:
	if not player:
		print_debug("Tried to make a player human, but player is null!")
		return
	if player.is_human:
		print_debug("Player is already human!")
		return
	
	new_player_requested.emit(player)


func _on_remove_button_pressed() -> void:
	if not player:
		print_debug("Tried to remove human player, but player is null!")
		return
	if not player.is_human:
		print_debug("Player is already not human!")
		return
	if is_the_only_local_human:
		print_debug("Tried to remove the only local player.")
		return
	
	if player.player_human:
		player.player_human.request_deletion()
	else:
		print_debug("GamePlayer's player_human is null, weird.")
		player.is_human = false


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


## After disconnecting as a client, you're able to rename AI players again
func _on_server_disconnected() -> void:
	_update_button_visibility()
