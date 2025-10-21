class_name ActionCostElement
extends HBoxContainer

var _is_setup: bool = false
var _resource_cost: ResourceCost

@onready var _title_label := %Title as Label
@onready var _cost_label := %Cost as Label


func _ready() -> void:
	if _is_setup:
		update()


func setup(resource_cost: ResourceCost) -> void:
	_resource_cost = resource_cost
	_is_setup = true
	if is_node_ready():
		update()


func update(amount_to_buy: int = 1) -> void:
	if not (_is_setup and is_node_ready()):
		return
	var cost: int = _resource_cost.cost_fori(amount_to_buy)
	visible = cost > 0
	_title_label.text = _resource_cost.resource_name() + " cost: "
	_cost_label.text = str(cost)
