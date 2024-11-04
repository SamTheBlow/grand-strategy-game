class_name SettingFloatNode
extends MarginContainer


signal value_changed(key: String, value: float)

var key: String
var value: float
var text: String

@onready var _label := %Label as Label
@onready var _spin_box := %SpinBox as SpinBox


func _ready() -> void:
	_spin_box.value = value
	_label.text = text
	
	_spin_box.value_changed.connect(_on_spin_box_value_changed)


func _on_spin_box_value_changed(new_value: float) -> void:
	value = new_value
	value_changed.emit(key, value)
