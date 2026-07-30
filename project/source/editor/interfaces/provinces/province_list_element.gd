class_name ProvinceListElement
extends Control
## A button representing a [Province].

signal pressed(this: ProvinceListElement)

var province: Province

@onready var _preview := %ProvincePreview as ProvincePreviewNode
@onready var _name_label := %NameLabel as Label


func _ready() -> void:
	_preview.setup(province)

	_refresh_name()
	province.name_changed.connect(_refresh_name)


func _refresh_name(_new_name: String = "") -> void:
	_name_label.text = province.name_or_default()


func _on_button_pressed() -> void:
	pressed.emit(self)
