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

@onready var _population_container := %PopulationContainer as Control
@onready var _population_cost_label := %PopulationCostLabel as Label
@onready var _money_container := %MoneyContainer as Control
@onready var _money_cost_label := %MoneyCostLabel as Label


func _ready() -> void:
	_update_costs()


func _update_costs() -> void:
	_update_population_cost()
	_update_money_cost()


func _update_population_cost() -> void:
	_population_container.visible = population_cost != null
	_update_resource_cost(_population_cost_label, population_cost)


func _update_money_cost() -> void:
	_money_container.visible = money_cost != null
	_update_resource_cost(_money_cost_label, money_cost)


func _update_resource_cost(label: Label, resource_cost: ResourceCost) -> void:
	if label == null or resource_cost == null:
		return
	
	label.text = str(resource_cost.cost_fori(number_to_buy))
	label.show()


func _on_slider_value_changed(_value: float) -> void:
	_update_costs()
