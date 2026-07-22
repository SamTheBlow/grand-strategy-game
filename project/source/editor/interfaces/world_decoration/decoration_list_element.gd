class_name WorldDecorationListElement
extends Control
## A button representing a [WorldDecoration].
## Automatically updates itself when its [WorldDecoration] is modified.
# Note. It may seem pointless to automatically update this node
# when it isn't possible to edit a decoration while inside the list interface.
# But it isn't pointless: you can still edit decorations by pressing undo/redo!

signal pressed(this: WorldDecorationListElement)

var world_decoration: WorldDecoration:
	set(value):
		if world_decoration != null:
			world_decoration.changed.disconnect(_refresh)

		world_decoration = value

		_refresh()
		world_decoration.changed.connect(_refresh)

var project_textures: ProjectTextures

@onready var _decoration_preview := %DecorationPreview as TextureRect
@onready var _position_label := %PositionLabel as Label


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if world_decoration == null:
		world_decoration = WorldDecoration.new()

	_refresh()


func _process(_delta: float) -> void:
	# Make sure the decoration preview always rotates around its center
	_decoration_preview.pivot_offset = _decoration_preview.size * 0.5


func _refresh(_world_decoration: WorldDecoration = null) -> void:
	if not is_node_ready():
		return
	world_decoration.apply_preview(_decoration_preview, project_textures)
	_position_label.text = str(world_decoration.position)


func _on_button_pressed() -> void:
	pressed.emit(self)
