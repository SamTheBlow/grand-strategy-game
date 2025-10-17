class_name ProvinceListElement
extends Control
## A button representing a [Province].

signal pressed(this: ProvinceListElement)

var province := Province.new():
	set(value):
		province = value
		_update()

@onready var _shape_preview := %ShapePreview as TextureRect
@onready var _name_label := %NameLabel as Label


func _ready() -> void:
	_update()


func _update() -> void:
	if not is_node_ready():
		return
	# TODO apply preview texture
	_shape_preview.texture = null
	_name_label.text = province.name_or_default()


func _on_button_pressed() -> void:
	pressed.emit(self)
