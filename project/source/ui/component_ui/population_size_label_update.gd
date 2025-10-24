class_name PopulationSizeLabelUpdate
extends Node
## Updates given [Label]'s text so that it always shows
## given [Province]'s [Population] size even after it changes.
##
## See also: [IncomeMoneyLabelUpdate], [ComponentUI]

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
	label.text = str(province.population().population_size) if province else ""


func _connect_signals() -> void:
	if province == null:
		return

	if not (
			province.population().size_changed
			.is_connected(_on_population_size_changed)
	):
		province.population().size_changed.connect(_on_population_size_changed)


func _disconnect_signals() -> void:
	if province == null:
		return

	if (
			province.population().size_changed
			.is_connected(_on_population_size_changed)
	):
		province.population().size_changed.disconnect(
				_on_population_size_changed
		)


func _on_population_size_changed(_new_value: int) -> void:
	_refresh()
