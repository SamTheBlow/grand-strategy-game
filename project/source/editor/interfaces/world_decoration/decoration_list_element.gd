class_name WorldDecorationListElement
extends Control
## A button representing a [WorldDecoration].

signal pressed(this: WorldDecorationListElement)

var world_decoration: WorldDecoration:
	set(value):
		world_decoration = value
		_update()

@onready var _decoration_preview := %DecorationPreview as TextureRect
@onready var _position_label := %PositionLabel as Label


func _ready() -> void:
	_update()


func _process(_delta: float) -> void:
	# Make sure the decoration preview always rotates around its center
	_decoration_preview.pivot_offset = _decoration_preview.size * 0.5


func _update() -> void:
	if world_decoration == null or not is_node_ready():
		return
	world_decoration.apply_preview(_decoration_preview)
	_position_label.text = str(world_decoration.position)


func _on_button_pressed() -> void:
	pressed.emit(self)
