class_name IncomeMoneyLabelUpdate
extends Node
## Displays information about given [IncomeMoney] amount.
## Automatically updates when the amount changes.
##
## See also: [PopulationSizeLabelUpdate], [ComponentUI]

@export var label: Label

## May be null.
var income_money: IncomeMoney = null:
	set(value):
		_disconnect_signals()
		income_money = value
		_connect_signals()
		if is_node_ready():
			_update()


func _ready() -> void:
	_update()


func _update() -> void:
	label.text = str(income_money.amount()) if income_money != null else ""


func _connect_signals() -> void:
	if income_money == null:
		return

	if not income_money.amount_changed.is_connected(_on_income_money_changed):
		income_money.amount_changed.connect(_on_income_money_changed)


func _disconnect_signals() -> void:
	if income_money == null:
		return

	if income_money.amount_changed.is_connected(_on_income_money_changed):
		income_money.amount_changed.disconnect(_on_income_money_changed)


func _on_income_money_changed(_new_value: int) -> void:
	_update()
