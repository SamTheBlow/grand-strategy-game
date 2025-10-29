class_name MapModeSetup
extends Node
## Applies a map mode to the world.

signal overlay_created(node: Node)

enum MapMode {
	POLITICAL,
	EDITOR_ADJACENCY,
}

var _is_setup: bool = false
var _world_visuals: WorldVisuals2D

var _current_map_mode := MapMode.POLITICAL

@onready var _node_political := %MapModePolitical as MapModePolitical
@onready var _node_editor_adj := %MapModeEditorAdj as MapModeEditorAdjacency


func _ready() -> void:
	_node_editor_adj.overlay_created.connect(overlay_created.emit)
	if _is_setup:
		_update()


func setup(world_visuals: WorldVisuals2D) -> void:
	_world_visuals = world_visuals
	_is_setup = true

	if is_node_ready():
		_update()


func set_map_mode(map_mode: MapMode) -> void:
	if _current_map_mode == map_mode:
		return

	if not (_is_setup and is_node_ready()):
		_current_map_mode = map_mode
		return

	match _current_map_mode:
		MapMode.POLITICAL:
			_node_political.is_enabled = false
		MapMode.EDITOR_ADJACENCY:
			_node_editor_adj.is_enabled = false
		_:
			_node_political.is_enabled = false

	_current_map_mode = map_mode
	_enable_map_mode()


func _update() -> void:
	_node_political.setup(
			_world_visuals.world.armies,
			_world_visuals.world.provinces,
			PlayingCountry.new(_world_visuals.project.game.turn),
			_world_visuals.world.armies_in_each_province,
			_world_visuals.province_selection
	)
	_node_editor_adj.setup(
			_world_visuals.province_selection,
			PolygonEditEdgeCase.new(_world_visuals.world)
	)

	_enable_map_mode()


func _enable_map_mode() -> void:
	match _current_map_mode:
		MapMode.POLITICAL:
			_node_political.is_enabled = true
		MapMode.EDITOR_ADJACENCY:
			_node_editor_adj.is_enabled = true
		_:
			push_error("Unrecognized map mode.")
			_node_political.is_enabled = true
