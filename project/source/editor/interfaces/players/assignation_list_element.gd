class_name AssignationListElement
extends Control
## Allows the user to change the username and assigned [GamePlayer]
## of this assignation, and allows them to delete this assignation.

signal username_changed(old_value: String, new_value: String)
signal choose_pressed()
signal delete_pressed()

var username: String = "":
	set(value):
		var old_value: String = username
		if old_value == value:
			return
		username = value
		if is_node_ready():
			_username_edit.text = username
		username_changed.emit(old_value, username)

var game_player: GamePlayer:
	set(value):
		if game_player != null:
			game_player.playing_country_changed.disconnect(_refresh_country)

		game_player = value
		if is_node_ready():
			_refresh_country()

		game_player.playing_country_changed.connect(_refresh_country)

@onready var _username_edit := %UsernameEdit as LineEdit
@onready var _country_button := %CountryButton as CountryButton


func _ready() -> void:
	_username_edit.text = username
	_username_edit.text_submitted.connect(_on_username_submitted.unbind(1))
	_username_edit.focus_exited.connect(_on_username_submitted)
	_refresh_country()


func _refresh_country() -> void:
	_country_button.country = game_player.playing_country


func _on_username_submitted() -> void:
	username = _username_edit.text


func _on_choose_pressed() -> void:
	choose_pressed.emit()


func _on_delete_pressed() -> void:
	delete_pressed.emit()
