class_name ActionCostNode
extends Control
## Displays the costs of some action.

const _ELEMENT_SCENE := preload("uid://bccw0ghti6cmf") as PackedScene

@export var number_to_buy: int = 1:
	set(value):
		number_to_buy = value
		if _is_setup and is_node_ready():
			_update()

var _is_setup: bool = false
var _resource_costs: Array[ResourceCost] = []
var _nodes: Dictionary[ResourceCost, ActionCostElement] = {}
var _visible_nodes: Dictionary[ResourceCost, bool] = {}

@onready var _element_container_node := %ElementContainer as Node
@onready var _no_costs_node := %NoCosts as Control


func _ready() -> void:
	if _is_setup:
		_update()


func setup(resource_costs: Array[ResourceCost]) -> void:
	_resource_costs = resource_costs
	_is_setup = true
	if is_node_ready():
		_update()


func _update() -> void:
	for resource_cost in _resource_costs:
		_update_resource_cost(resource_cost)


func _create_node(resource_cost: ResourceCost) -> void:
	var element_node := _ELEMENT_SCENE.instantiate() as ActionCostElement
	element_node.setup(resource_cost)
	_element_container_node.add_child(element_node)

	_nodes[resource_cost] = element_node
	_visible_nodes[resource_cost] = true
	_no_costs_node.hide()


func _update_resource_cost(resource_cost: ResourceCost) -> void:
	if not _nodes.has(resource_cost):
		_create_node(resource_cost)

	_nodes[resource_cost].update(number_to_buy)

	if _nodes[resource_cost].visible:
		_visible_nodes[resource_cost] = true
		_no_costs_node.hide()
	else:
		_visible_nodes.erase(resource_cost)
		if _visible_nodes.is_empty():
			_no_costs_node.show()


func _on_slider_value_changed(_value: float) -> void:
	_update()
