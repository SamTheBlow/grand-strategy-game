class_name WorldDecorationsNode
extends Node2D
## Generates and holds sprites of given [WorldDecorations].

var world_decorations := WorldDecorations.new():
	set(value):
		if is_node_ready():
			_disconnect_signals()
			world_decorations = value
			_update()
		else:
			world_decorations = value

## Maps a world decoration to its corresponding sprite.
var _map: Dictionary[WorldDecoration, Sprite2D] = {}


func _ready() -> void:
	_update()


func _update() -> void:
	_clear()

	for decoration in world_decorations.list():
		_add(decoration)

	_connect_signals()


func _add(decoration: WorldDecoration) -> void:
	var sprite := Sprite2D.new()
	decoration.apply_to_sprite(sprite)
	_map[decoration] = sprite
	add_child(sprite)
	decoration.changed.connect(_on_decoration_changed)


## Resets internal data, removes all existing sprites.
func _clear() -> void:
	NodeUtils.remove_all_children(self)
	for decoration in _map:
		decoration.changed.disconnect(_on_decoration_changed)
	_map = {}


func _connect_signals() -> void:
	world_decorations.added.connect(_on_decoration_added)
	world_decorations.removed.connect(_on_decoration_removed)


func _disconnect_signals() -> void:
	world_decorations.added.disconnect(_on_decoration_added)
	world_decorations.removed.disconnect(_on_decoration_removed)


func _on_decoration_added(decoration: WorldDecoration) -> void:
	_add(decoration)


func _on_decoration_removed(decoration: WorldDecoration) -> void:
	remove_child(_map[decoration])
	decoration.changed.disconnect(_on_decoration_changed)
	_map.erase(decoration)


func _on_decoration_changed(decoration: WorldDecoration) -> void:
	decoration.apply_to_sprite(_map[decoration])
