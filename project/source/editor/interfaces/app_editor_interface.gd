class_name AppEditorInterface
extends Control
## Base class for the editing interface in the [Editor].

var editor_settings := AppEditorSettings.new():
	set(value):
		editor_settings = value
		_update_editor_settings()

var game_settings := GameSettings.new():
	set(value):
		game_settings = value
		_update_game_settings()


func _ready() -> void:
	_update_editor_settings()
	_update_game_settings()


func _update_editor_settings() -> void:
	pass


func _update_game_settings() -> void:
	pass
