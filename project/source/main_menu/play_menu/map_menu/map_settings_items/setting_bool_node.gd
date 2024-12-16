class_name SettingBoolNode
extends MarginContainer
## Shows a boolean setting.
## Emits a signal when the value changes.

signal value_changed(key: String, value: bool)

var key: String
var value: bool
var text: String

@onready var _label := %Label as Label
@onready var _check_box := %CheckBox as CheckBox


func _ready() -> void:
	_label.text = text
	_check_box.button_pressed = value
	_check_box.toggled.connect(_on_check_box_toggled)


func _on_check_box_toggled(toggled_on: bool) -> void:
	value = toggled_on
	value_changed.emit(key, value)
