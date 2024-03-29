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
@export var arrow_container: Control
@export var arrow_label: Label
@export var username_label: Label
@export var username_edit: Control
@export var username_line_edit: LineEdit
@export var circle_buttons: Control
@export var add_button: Control
@export var remove_button: Control
@export var rename_button: Control
@export var confirm_button: Control

@export_category("Variables")
@export var username_color_human: Color
@export var username_color_ai: Color
@export var bg_color_human: Color
@export var bg_color_ai: Color

var player: Player:
	set(value):
		if player:
			player.username_changed.disconnect(_on_username_changed)
			player.human_status_changed.disconnect(_on_human_status_changed)
			player.synchronization_finished.disconnect(
					_on_player_sync_finished
			)
		player = value
		player.username_changed.connect(_on_username_changed)
		player.human_status_changed.connect(_on_human_status_changed)
		player.synchronization_finished.connect(_on_player_sync_finished)
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
	arrow_label.text = ""
	_update_appearance()
	custom_minimum_size.y = container.size.y


## To be called when this node is created, if the game is turn-based
func init_turn(turn: GameTurn) -> void:
	turn.player_changed.connect(_on_player_turn_changed)
	_update_turn_indicator(turn.playing_player())


func _update_shown_username() -> void:
	username_label.text = player.username()
	if not player.is_human:
		username_label.text += " (AI)"


func _update_turn_indicator(playing_player: Player) -> void:
	if playing_player == player:
		arrow_label.text = "->"
	else:
		arrow_label.text = ""


func _update_appearance() -> void:
	_update_shown_username()
	
	if player.is_human:
		username_label.add_theme_color_override(
				"font_color", username_color_human
		)
		color_rect.color = bg_color_human
	else:
		username_label.add_theme_color_override(
				"font_color", username_color_ai
		)
		color_rect.color = bg_color_ai
	
	_update_button_visibility()


func _update_button_visibility() -> void:
	add_button.visible = (not player.is_human) and (not _is_renaming)
	_update_remove_button_visibility()
	rename_button.visible = (not _is_renaming) and _can_edit()
	confirm_button.visible = _is_renaming


func _update_remove_button_visibility() -> void:
	remove_button.visible = (
			player.is_human
			and _can_edit()
			and not is_the_only_local_human
			and not _is_renaming
	)


## Returns true if you're able to edit this player.
## When connected to a server, you only have control over local players.
## If you're the server, you have full control over everything.
func _can_edit() -> bool:
	if not multiplayer:
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


func _on_human_status_changed(_changed_player: Player) -> void:
	_update_appearance()


func _on_player_turn_changed(playing_player: Player) -> void:
	_update_turn_indicator(playing_player)


func _on_add_button_pressed() -> void:
	if player.is_human:
		print_debug("Player is already human!")
		return
	
	player.is_human = true


func _on_remove_button_pressed() -> void:
	if not player.is_human:
		print_debug("Player is already not human!")
		return
	
	if is_the_only_local_human:
		print_debug("Tried to remove the only local player.")
		return
	
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
