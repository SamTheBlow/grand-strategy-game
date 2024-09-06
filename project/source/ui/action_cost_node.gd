class_name ActionCostNode
extends Control
## Displays the cost, in population and money, of given action.
##
## To use, make sure to set the population_cost and money_cost
## properties manually with code.


@export var number_to_buy: int = 1:
	set(value):
		number_to_buy = value
		_update_costs()

var population_cost: ResourceCost:
	set(value):
		population_cost = value
		_update_population_cost()

var money_cost: ResourceCost:
	set(value):
		money_cost = value
		_update_money_cost()

@onready var _no_costs := %NoCosts as Control
@onready var _population_container := %PopulationContainer as Control
@onready var _population_cost_label := %PopulationCostLabel as Label
@onready var _money_container := %MoneyContainer as Control
@onready var _money_cost_label := %MoneyCostLabel as Label


func _ready() -> void:
	if population_cost == null:
		push_error("Population cost is null.")
	if money_cost == null:
		push_error("Money cost is null.")
	
	_update_costs()


func _cost(resource_cost: ResourceCost) -> int:
	return resource_cost.cost_fori(number_to_buy)


func _update_costs() -> void:
	_update_population_cost()
	_update_money_cost()


func _update_population_cost() -> void:
	_update_container_visibility(_population_container, population_cost)
	_update_resource_cost(_population_cost_label, population_cost)


func _update_money_cost() -> void:
	_update_container_visibility(_money_container, money_cost)
	_update_resource_cost(_money_cost_label, money_cost)


func _update_container_visibility(
		container: Control, resource_cost: ResourceCost
) -> void:
	if container == null:
		return
	
	container.visible = resource_cost != null and _cost(resource_cost) > 0
	_update_no_costs()


func _update_resource_cost(label: Label, resource_cost: ResourceCost) -> void:
	if label == null or resource_cost == null:
		return
	
	label.text = str(_cost(resource_cost))


func _update_no_costs() -> void:
	if _population_container == null or _money_container == null:
		return
	
	_no_costs.visible = (
			not (_population_container.visible or _money_container.visible)
	)


func _on_slider_value_changed(_value: float) -> void:
	_update_costs()
