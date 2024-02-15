@tool
class_name ComponentUI
extends Control
## Interface that appears around a given object.
## It can give information about the object and have widgets like buttons.
## (Currently only works on a Province object)


signal button_pressed(button_id: int)

@export_category("Line")
@export var line_top: float = -64.0 : set = set_line_top
@export var line_bottom: float = 0.0 : set = set_line_bottom
@export var line_length_x: float = 64.0 : set = set_line_length_x

@export_category("Inner nodes")
@export var population_size_label: Label
@export var income_money_label: Label
@export var buy_fortress_button: Button
@export var recruit_button: Button

@export var left_side_nodes: Array[Control]
@export var right_side_nodes: Array[Control]

var _province: Province
var _fortress_buy_conditions: FortressBuyConditions
var _army_recruitment_limit: ArmyRecruitmentLimit


func _ready() -> void:
	_update_side_nodes()


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


func _on_buy_fortress_button_pressed() -> void:
	button_pressed.emit(0)


func _on_recruit_button_pressed() -> void:
	button_pressed.emit(1)


func _on_population_size_changed(new_value: int) -> void:
	_update_population_size_label(new_value)


func _on_income_money_changed(new_value: int) -> void:
	_update_income_money_label(new_value)


func _on_fortress_can_buy_changed(can_buy: bool) -> void:
	buy_fortress_button.disabled = not can_buy


func _on_army_maximum_changed(maximum: int) -> void:
	recruit_button.disabled = maximum == 0


## To be called when creating this node.
func init(province: Province) -> void:
	_province = province
	
	_update_population_size_label(province.population.population_size)
	province.population.size_changed.connect(_on_population_size_changed)
	
	_update_income_money_label(province.income_money().total())
	province.income_money().changed.connect(_on_income_money_changed)
	
	var node0: Control = left_side_nodes[0]
	var node1: Control = left_side_nodes[1]
	left_side_nodes = []
	
	var your_id: int = _province.game._your_id
	var you: Player = _province.game.players.player_from_id(your_id)
	if province.game.rules.can_buy_fortress:
		_fortress_buy_conditions = FortressBuyConditions.new(
				you.playing_country, _province
		)
		_fortress_buy_conditions.can_buy_changed.connect(
				_on_fortress_can_buy_changed
		)
		buy_fortress_button.disabled = not _fortress_buy_conditions.can_buy()
		left_side_nodes.append(node0)
	else:
		node0.hide()
	
	if province.game.rules.recruitment_enabled:
		_army_recruitment_limit = ArmyRecruitmentLimit.new(
				you.playing_country, _province
		)
		_army_recruitment_limit.changed.connect(_on_army_maximum_changed)
		recruit_button.disabled = _army_recruitment_limit.maximum() == 0
		left_side_nodes.append(node1)
	else:
		node1.hide()
	
	_update_left_side_nodes()


func set_line_top(value: float) -> void:
	line_top = value
	_update_side_nodes()
	queue_redraw()


func set_line_bottom(value: float) -> void:
	line_bottom = value
	_update_side_nodes()
	queue_redraw()


func set_line_length_x(value: float) -> void:
	line_length_x = value
	_update_side_nodes()
	queue_redraw()


func _update_population_size_label(value: int) -> void:
	population_size_label.text = str(value)


func _update_income_money_label(value: int) -> void:
	income_money_label.text = str(value)


func _update_side_nodes() -> void:
	_update_left_side_nodes()
	_update_right_side_nodes()


func _update_left_side_nodes() -> void:
	var offset_y: float = 64.0
	for i in left_side_nodes.size():
		left_side_nodes[i].position.x = (
				-line_length_x - left_side_nodes[i].size.x * 0.5
		)
		left_side_nodes[i].position.y = line_top + offset_y
		offset_y += left_side_nodes[i].size.y


func _update_right_side_nodes() -> void:
	var offset_y: float = 64.0
	for i in right_side_nodes.size():
		right_side_nodes[i].position.x = (
				line_length_x - right_side_nodes[i].size.x * 0.5
		)
		right_side_nodes[i].position.y = line_top + offset_y
		offset_y += right_side_nodes[i].size.y
