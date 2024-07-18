@tool
class_name ComponentUI
extends Control
## Interface that appears around a given object.
## It can give information about the object and have widgets like buttons.
## (Currently only works on a [Province] object)


signal button_pressed(button_id: int)

@export_group("Line")

@export var line_top: float = -64.0:
	set(value):
		line_top = value
		_update_side_nodes()
		queue_redraw()

@export var line_bottom: float = 0.0:
	set(value):
		line_bottom = value
		_update_side_nodes()
		queue_redraw()

@export var line_length_x: float = 64.0:
	set(value):
		line_length_x = value
		_update_side_nodes()
		queue_redraw()

@onready var _population_size_label := %PopulationLabel as Label
@onready var _income_money_label := %IncomeMoneyLabel as Label
@onready var _build_fortress_button := %BuildFortressButton as Button
@onready var _recruit_button := %RecruitButton as Button

@onready var _country_button := %CountryButton as CountryButton
@onready var _left_side_nodes: Array[Control] = [
	$Control1 as Control,
	$Control2 as Control,
]
@onready var _right_side_nodes: Array[Control] = [
	$Control4 as Control,
	$Control5 as Control,
]

var _playing_player: GamePlayer:
	set(value):
		_playing_player = value
		_update_buttons_disabled()

var _province: Province
var _fortress_build_conditions: FortressBuildConditions
var _army_recruit_limits: ArmyRecruitmentLimits


func _ready() -> void:
	_initialize()
	_update_country_button()
	_update_side_nodes()
	_update_buttons_disabled()


func _process(_delta: float) -> void:
	if not _province:
		return
	
	# Follow the object's position
	var world_position: Vector2 = _province.position_army_host
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


## To be called when creating this node.
func init(province: Province, playing_player: GamePlayer) -> void:
	_province = province
	_playing_player = playing_player


func _initialize() -> void:
	if _province == null:
		return
	
	var node0: Control = _left_side_nodes[0]
	var node1: Control = _left_side_nodes[1]
	
	if _province.game.rules.build_fortress_enabled.value:
		_fortress_build_conditions = FortressBuildConditions.new(
				_playing_player.playing_country, _province
		)
		_fortress_build_conditions.can_build_changed.connect(
				_on_fortress_can_build_changed
		)
		_on_fortress_can_build_changed(_fortress_build_conditions.can_build())
	else:
		node0.hide()
		_left_side_nodes.erase(node0)
	
	if _province.game.rules.recruitment_enabled.value:
		_army_recruit_limits = ArmyRecruitmentLimits.new(
				_playing_player.playing_country, _province
		)
		_army_recruit_limits.maximum_changed.connect(_on_army_maximum_changed)
		_on_army_maximum_changed(_army_recruit_limits.maximum())
	else:
		node1.hide()
		_left_side_nodes.erase(node1)
	
	_country_button.pressed.connect(_province.game._on_country_button_pressed)
	
	_update_population_size_label(_province.population.population_size)
	_province.population.size_changed.connect(_on_population_size_changed)
	
	_update_income_money_label(_province.income_money().total())
	_province.income_money().changed.connect(_on_income_money_changed)


func _update_population_size_label(value: int) -> void:
	if not is_node_ready():
		return
	_population_size_label.text = str(value)


func _update_income_money_label(value: int) -> void:
	if not is_node_ready():
		return
	_income_money_label.text = str(value)


func _update_country_button() -> void:
	if _province == null or _province.owner_country == null:
		_country_button.hide()
		return
	
	_country_button.country = _province.owner_country
	_country_button.show()


func _update_side_nodes() -> void:
	_update_left_side_nodes()
	_update_right_side_nodes()


func _update_left_side_nodes() -> void:
	if not is_node_ready():
		return
	
	var offset_y: float = 64.0
	for i in _left_side_nodes.size():
		_left_side_nodes[i].position.x = (
				-line_length_x - _left_side_nodes[i].size.x * 0.5
		)
		_left_side_nodes[i].position.y = line_top + offset_y
		offset_y += _left_side_nodes[i].size.y


func _update_right_side_nodes() -> void:
	if not is_node_ready():
		return
	
	var offset_y: float = 64.0
	for i in _right_side_nodes.size():
		_right_side_nodes[i].position.x = (
				line_length_x - _right_side_nodes[i].size.x * 0.5
		)
		_right_side_nodes[i].position.y = line_top + offset_y
		offset_y += _right_side_nodes[i].size.y


func _update_buttons_disabled() -> void:
	_update_build_fortress_button_disabled()
	_update_recruit_button_disabled()


func _update_build_fortress_button_disabled() -> void:
	if _fortress_build_conditions == null or not is_node_ready():
		return
	
	_build_fortress_button.disabled = (
			_is_actions_disabled()
			or not _fortress_build_conditions.can_build()
	)


func _update_recruit_button_disabled() -> void:
	if (
			_army_recruit_limits == null
			or _province == null
			or not is_node_ready()
	):
		return
	
	_recruit_button.disabled = (
			_is_actions_disabled() or
			_army_recruit_limits.maximum()
			< _province.game.rules.minimum_army_size.value
	)


## Note that if this node's [code]multiplayer[/code] property is null,
## then this will always return true.
func _is_actions_disabled() -> bool:
	return not MultiplayerUtils.has_gameplay_authority(
			multiplayer, _playing_player
	)


func _on_build_fortress_button_pressed() -> void:
	button_pressed.emit(0)


func _on_recruit_button_pressed() -> void:
	button_pressed.emit(1)


func _on_population_size_changed(new_value: int) -> void:
	_update_population_size_label(new_value)


func _on_income_money_changed(new_value: int) -> void:
	_update_income_money_label(new_value)


func _on_fortress_can_build_changed(_can_build: bool) -> void:
	_update_build_fortress_button_disabled()


func _on_army_maximum_changed(_maximum: int) -> void:
	_update_recruit_button_disabled()


func _on_turn_player_changed(player: GamePlayer) -> void:
	_playing_player = player
