class_name EditorPlayerListElement
extends Control
## A button representing a [GamePlayer].

signal pressed(this: EditorPlayerListElement)

var game_player: GamePlayer:
	set(value):
		if game_player != null:
			game_player.username_changed.disconnect(_refresh_username)
			game_player.human_status_changed.disconnect(_refresh_status)

		game_player = value

		_refresh()
		game_player.username_changed.connect(_refresh_username)
		game_player.human_status_changed.connect(_refresh_status)

@onready var _name_label := %NameLabel as Label
@onready var _status_label := %StatusLabel as Label


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if game_player == null:
		game_player = GamePlayer.new()

	_refresh()


func _refresh() -> void:
	_refresh_username()
	_refresh_status()


func _refresh_username(_game_player: GamePlayer = null) -> void:
	if not is_node_ready():
		return
	_name_label.text = game_player.username


func _refresh_status(_game_player: GamePlayer = null) -> void:
	if not is_node_ready():
		return
	if game_player.is_human:
		_status_label.text = "Human"
	else:
		_status_label.text = "AI"


func _on_button_pressed() -> void:
	pressed.emit(self)
