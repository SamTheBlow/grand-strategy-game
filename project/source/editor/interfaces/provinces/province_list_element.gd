class_name ProvinceListElement
extends Control
## A button representing a [Province].

signal pressed(this: ProvinceListElement)

var province: Province:
	set(value):
		if province != null:
			province.name_changed.disconnect(_refresh_name)

		province = value

		_refresh()
		province.name_changed.connect(_refresh_name)

@onready var _preview := %ProvincePreview as ProvincePreviewNode
@onready var _name_label := %NameLabel as Label


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if province == null:
		province = Province.new()

	_refresh()


func _refresh() -> void:
	_refresh_preview()
	_refresh_name()


func _refresh_preview() -> void:
	if not is_node_ready():
		return
	_preview.setup(province)


func _refresh_name(_new_name: String = "") -> void:
	if not is_node_ready():
		return
	_name_label.text = province.name_or_default()


func _on_button_pressed() -> void:
	pressed.emit(self)
