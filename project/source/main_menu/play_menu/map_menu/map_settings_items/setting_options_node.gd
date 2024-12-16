class_name SettingOptionsNode
extends MarginContainer
## Shows an enum setting.
## Emits a signal when the value changes.

signal value_changed(key: String, value: int)

var key: String
var value: int
var text: String
var options: Array[String]

@onready var _label := %Label as Label
@onready var _option_button := %CustomOptionButton as CustomOptionButton


func _ready() -> void:
	_label.text = text
	for option_name in options:
		_option_button.add_item(option_name)

	_option_button.select_item(value)
	_option_button.item_selected.connect(_on_item_selected)


func _on_item_selected(selected: int) -> void:
	value = selected
	value_changed.emit(key, value)
