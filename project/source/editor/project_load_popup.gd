class_name ProjectLoadPopup
extends VBoxContainer
## The popup that appears when the user wishes to load an [EditorProject].
## See also: [GamePopup]

signal project_loaded(project: EditorProject)

@export var _built_in_map_file_paths: Array[String]

## The scene's root node must be a [MapOptionNode].
@export var _map_option_node_scene: PackedScene

## May be null, in which case no map is currently selected.
var _selected_map: MapOptionNode = null

@onready var _built_in_maps := %BuiltInMaps as Collapsible


func _ready() -> void:
	for map_file_path in _built_in_map_file_paths:
		var map_metadata: MapMetadata = (
				MapMetadata.from_file_path(map_file_path)
		)
		if map_metadata == null:
			push_error("Built-in map file path is invalid.")
			continue

		var new_map := _map_option_node_scene.instantiate() as MapOptionNode
		new_map.map_metadata = map_metadata
		new_map.selected.connect(_on_map_selected)
		_built_in_maps.add_node(new_map)


func buttons() -> Array[String]:
	return ["Cancel", "Load"]


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		var test := EditorProject.new()
		test.name = "Amogus"
		project_loaded.emit(test)


func _on_map_selected(map_option_node: MapOptionNode) -> void:
	if _selected_map != null:
		_selected_map.deselect()

	_selected_map = map_option_node
	map_option_node.select()
