class_name IncomeMoneyLabelUpdate
extends Node
## Updates given [Label]'s text so that it always shows
## given [Province]'s [IncomeMoney] even after it changes.
##
## See also: [PopulationSizeLabelUpdate], [ComponentUI]


@export var label: Label

var province: Province:
	set(value):
		if province == value:
			return
		_disconnect_signals()
		province = value
		_connect_signals()
		_refresh()


func _refresh() -> void:
	label.text = str(province.income_money().total()) if province else ""


func _connect_signals() -> void:
	if province == null:
		return
	
	if not (
			province.income_money().changed
			.is_connected(_on_income_money_changed)
	):
		province.income_money().changed.connect(_on_income_money_changed)


func _disconnect_signals() -> void:
	if province == null:
		return
	
	if (
			province.income_money().changed
			.is_connected(_on_income_money_changed)
	):
		province.income_money().changed.disconnect(_on_income_money_changed)


func _on_income_money_changed(_new_value: int) -> void:
	_refresh()
