extends Node
## Emits a signal to apply decoration visibility according to editor settings.

signal changed(value: bool)

@export var _editor_settings: AppEditorSettings


func _ready() -> void:
	_emit_changed()
	_editor_settings.show_decorations.value_changed.connect(
			_emit_changed.unbind(1)
	)


func _emit_changed() -> void:
	changed.emit(_editor_settings.show_decorations.value)
