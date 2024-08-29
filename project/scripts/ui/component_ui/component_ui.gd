@tool
class_name ComponentUI
extends Control
## Interface that appears around a given [ProvinceVisuals2D].
## Provides information about the province
## and has buttons with different functionalities.


signal button_pressed(button_id: int)

@export_group("Line")

@export var line_top: float = -64.0:
	set(value):
		line_top = value
		_reposition_side_nodes()
		queue_redraw()

@export var line_bottom: float = 0.0:
	set(value):
		line_bottom = value
		_reposition_side_nodes()
		queue_redraw()

@export var line_length_x: float = 64.0:
	set(value):
		line_length_x = value
		_reposition_side_nodes()
		queue_redraw()

# TODO Make it possible to change this value.
# (The only culprit is _initialize() I think)
## This may only be set once.
## Changing its value later may give unexpected results and crash the game.
var province_visuals: ProvinceVisuals2D:
	set(value):
		if province_visuals == value:
			return
		province_visuals = value
		province_visuals.deselected.connect(_on_province_deselected)
		_update_nodes_province()

@onready var _build_fortress_button := (
		%BuildFortressButton as BuildFortressButton
)
@onready var _recruit_button := %RecruitButton as RecruitButton

@onready var _population_size_label_update := (
		%PopulationSizeLabelUpdate as PopulationSizeLabelUpdate
)
@onready var _income_money_label_update := (
		%IncomeMoneyLabelUpdate as IncomeMoneyLabelUpdate
)

@onready var _left_side_nodes: Array[Control] = [
	$Control1 as Control,
	$Control2 as Control,
]
@onready var _right_side_nodes: Array[Control] = [
	$Control3 as Control,
	$Control4 as Control,
]

@onready var _country_button := %CountryButton as CountryButton
@onready var _country_button_province_update := (
		%CountryButtonProvinceUpdate as CountryButtonProvinceUpdate
)
@onready var _relationship_preset_label_update := (
		%RelationshipPresetLabelUpdate as RelationshipPresetLabelUpdate
)


func _ready() -> void:
	_initialize()
	_reposition_side_nodes()
	_update_nodes_province()


func _process(_delta: float) -> void:
	if province_visuals == null:
		return
	
	# Follow the object's position
	var world_position: Vector2 = province_visuals.global_position_army_host()
	var zoom: Vector2 = get_viewport().get_camera_2d().zoom
	var cam_position: Vector2 = get_viewport().get_camera_2d().global_position
	var half_viewport_size: Vector2 = get_viewport_rect().size * 0.5
	position = zoom * (world_position - cam_position) + half_viewport_size


func _draw() -> void:
	# Top line
	draw_line(
			Vector2(-line_length_x, line_top),
			Vector2(line_length_x, line_top),
			Color.BLACK,
			3.0
	)
	draw_line(
			Vector2(-line_length_x, line_top),
			Vector2(line_length_x, line_top),
			Color.WHITE
	)
	# Left line
	draw_line(
			Vector2(-line_length_x, line_top),
			Vector2(-line_length_x, line_bottom),
			Color.BLACK,
			3.0
	)
	draw_line(
			Vector2(-line_length_x, line_top),
			Vector2(-line_length_x, line_bottom),
			Color.WHITE
	)
	# Right line
	draw_line(
			Vector2(line_length_x, line_top),
			Vector2(line_length_x, line_bottom),
			Color.BLACK,
			3.0
	)
	draw_line(
			Vector2(line_length_x, line_top),
			Vector2(line_length_x, line_bottom),
			Color.WHITE
	)


func _initialize() -> void:
	if province_visuals == null:
		return
	var province: Province = province_visuals.province
	
	var node0: Control = _left_side_nodes[0]
	var node1: Control = _left_side_nodes[1]
	
	if not province.game.rules.build_fortress_enabled.value:
		node0.hide()
		_left_side_nodes.erase(node0)
	
	if not province.game.rules.recruitment_enabled.value:
		node1.hide()
		_left_side_nodes.erase(node1)
	
	_country_button.pressed.connect(province.game._on_country_button_pressed)


func _reposition_side_nodes() -> void:
	# Left side
	_update_side_node_positions(_left_side_nodes, -line_length_x)
	# Right side
	_update_side_node_positions(_right_side_nodes, line_length_x)


func _update_side_node_positions(
		side_nodes: Array[Control], offset_x: float
) -> void:
	if not is_node_ready():
		return
	
	var offset_y: float = 64.0
	for i in side_nodes.size():
		side_nodes[i].position.x = offset_x - side_nodes[i].size.x * 0.5
		side_nodes[i].position.y = offset_y + line_top
		offset_y += side_nodes[i].size.y


func _update_nodes_province() -> void:
	var province: Province = province_visuals.province
	if not is_node_ready() or province == null:
		return
	
	_build_fortress_button.province = province
	_recruit_button.province = province
	
	_population_size_label_update.province = province
	_income_money_label_update.province = province
	
	_country_button_province_update.province = province
	
	_relationship_preset_label_update.is_relationship_presets_enabled = (
			province.game.rules.diplomacy_presets_option.selected != 0
			if province else false
	)
	_relationship_preset_label_update.country_to_relate_to = (
			province.owner_country if province else null
	)
	
	_update_nodes_playing_player(
			province.game.turn.playing_player() if province else null
	)


func _update_nodes_playing_player(playing_player: GamePlayer) -> void:
	if not is_node_ready():
		return
	
	_build_fortress_button.player = playing_player
	_recruit_button.player = playing_player
	
	_relationship_preset_label_update.country = (
			playing_player.playing_country if playing_player else null
	)


func _on_build_fortress_button_pressed() -> void:
	button_pressed.emit(0)


func _on_recruit_button_pressed() -> void:
	button_pressed.emit(1)


func _on_turn_player_changed(player: GamePlayer) -> void:
	_update_nodes_playing_player(player)


func _on_province_deselected() -> void:
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
