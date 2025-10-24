@tool
class_name ComponentUI
extends Control
## Interface that appears around a given [ProvinceVisuals2D].
## Provides information about the province
## and has buttons with different functionalities.

signal button_pressed(button_id: int)
signal country_button_pressed(country: Country)

@export_group("Line")

@export var line_top: float = -64.0:
	set(value):
		line_top = value
		_update_frame()
		_reposition_side_nodes()

@export var line_bottom: float = 0.0:
	set(value):
		line_bottom = value
		_update_frame()
		_reposition_side_nodes()

@export var line_length_x: float = 64.0:
	set(value):
		line_length_x = value
		_update_frame()
		_reposition_side_nodes()

## May be null, in which case some functionalities will be disabled.
var _game: Game
## May be null, in which case some functionalities will be disabled.
var _province_visuals: ProvinceVisuals2D

@onready var _frame := %Frame as ComponentUIFrame

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
	_update_frame()
	_reposition_side_nodes()

	# Prevent error caused by Godot bug (see Godot engine issue #49428)
	if Engine.is_editor_hint():
		return

	_update_nodes_game()
	_update_nodes_province()

	_country_button.pressed.connect(country_button_pressed.emit)


func _process(_delta: float) -> void:
	if _province_visuals == null:
		return

	# Follow the object's position
	var world_position: Vector2 = _province_visuals.global_position_army_host()
	var zoom: Vector2 = get_viewport().get_camera_2d().zoom
	var cam_position: Vector2 = get_viewport().get_camera_2d().global_position
	var half_viewport_size: Vector2 = get_viewport_rect().size * 0.5
	position = zoom * (world_position - cam_position) + half_viewport_size


func setup(game: Game, province_visuals: ProvinceVisuals2D) -> void:
	if _game != null:
		_game.turn.player_changed.disconnect(_on_turn_player_changed)

	_game = game
	_province_visuals = province_visuals

	if _game != null:
		_game.turn.player_changed.connect(_on_turn_player_changed)

	if is_node_ready():
		_update_nodes_game()
		_update_nodes_province()


func _update_frame() -> void:
	if not is_node_ready():
		return

	_frame.line_top = line_top
	_frame.line_bottom = line_bottom
	_frame.line_length_x = line_length_x
	_frame.update()


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
	for node in side_nodes:
		if not node.visible:
			continue

		node.position.x = offset_x - node.size.x * 0.5
		node.position.y = offset_y + line_top
		offset_y += node.size.y


func _update_nodes_game() -> void:
	if _game != null:
		_left_side_nodes[0].visible = _game.rules.build_fortress_enabled.value
		_left_side_nodes[1].visible = _game.rules.recruitment_enabled.value

		_build_fortress_button.game = _game
		_recruit_button.game = _game
		_relationship_preset_label_update.is_disabled = (
				not _game.rules.is_diplomacy_presets_enabled()
		)

		_update_nodes_playing_player(_game.turn.playing_player())
		_update_income_money()
	else:
		_left_side_nodes[0].visible = false
		_left_side_nodes[1].visible = false

		_build_fortress_button.game = null
		_recruit_button.game = null
		_relationship_preset_label_update.is_disabled = true

		_update_nodes_playing_player(null)


func _update_nodes_province() -> void:
	if _province_visuals == null:
		return

	var province: Province = _province_visuals.province
	if province == null:
		return

	_build_fortress_button.province = province
	_recruit_button.province = province

	_population_size_label_update.province = province
	_update_income_money()

	_country_button_province_update.province = province

	_relationship_preset_label_update.country_to_relate_to = (
			province.owner_country
	)


func _update_income_money() -> void:
	if _game == null or _province_visuals == null:
		return
	_income_money_label_update.income_money = (
			IncomeMoney.new(_game.rules, _province_visuals.province)
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
