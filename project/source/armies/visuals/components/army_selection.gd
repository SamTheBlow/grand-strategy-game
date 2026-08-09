class_name ArmySelection
extends Node
## - Enables input on all army visuals.
## - Keeps track of which army is currently selected
##   and which army is currently hovered.
## - Adds or removes highlight on army visuals accordingly.
## - Emits a signal when an army is selected or deselected.

signal selected(army: Army)
signal deselected()

## This is used to apply highlights
@export var _army_visuals_setup: ArmyVisualsSetup

## May be null.
var _selected_army: Army = null
## May be null.
var _hovered_army: Army = null


## Returns null if none are selected.
func selected_army() -> Army:
	return _selected_army


## Deselects army if input is empty or null.
## No effect if army is already selected.
func set_selected_army(army: Army = null) -> void:
	if army == _selected_army:
		return

	if _selected_army != null:
		if _selected_army == _hovered_army:
			_army_visuals_setup.visuals_of(_selected_army).highlight()
		else:
			var visuals: ArmyVisuals2D = (
					_army_visuals_setup.visuals_of(_selected_army)
			)
			if visuals != null:
				visuals.remove_highlight()
		_selected_army = null
		deselected.emit()

	if army == null:
		return

	_selected_army = army
	_army_visuals_setup.visuals_of(army).highlight_selected()
	selected.emit(army)


## Returns null if none are hovered.
func hovered_army() -> Army:
	return _hovered_army


## Sets it to none if input is empty or null.
## No effect if army is already the hovered one.
func set_hovered_army(army: Army = null) -> void:
	if army == _hovered_army:
		return

	if _hovered_army != null:
		if _hovered_army != _selected_army:
			var visuals: ArmyVisuals2D = (
					_army_visuals_setup.visuals_of(_hovered_army)
			)
			if visuals != null:
				visuals.remove_highlight()
		_hovered_army = null

	if army == null:
		return

	_hovered_army = army
	if army != _selected_army:
		_army_visuals_setup.visuals_of(army).highlight()


func _setup_visuals(army_visuals: ArmyVisuals2D) -> void:
	army_visuals.is_input_enabled = true

	if army_visuals.army == _selected_army:
		army_visuals.highlight_selected()
	elif army_visuals.army == _hovered_army:
		army_visuals.highlight()

	army_visuals.clicked.connect(_on_army_clicked.bind(army_visuals.army))
	army_visuals.mouse_entered.connect(set_hovered_army.bind(army_visuals.army))
	army_visuals.mouse_exited.connect(_unset_hovered_army.bind(army_visuals))
	army_visuals.tree_exited.connect(_unset_hovered_army.bind(army_visuals))


## We use this and not set_hovered_army(null),
## because if a different army got hovered and got their
## mouse_entered signal to trigger first, then they'd set the
## hovered army to the new army, and then the previous army visuals
## would trigger mouse_exited and set it back to null.
func _unset_hovered_army(army_visuals: ArmyVisuals2D) -> void:
	if _hovered_army == army_visuals.army:
		_hovered_army = null

	if army_visuals.army != _selected_army:
		army_visuals.remove_highlight()


func _on_army_clicked(army: Army) -> void:
	if _selected_army == army:
		set_selected_army(null)
	else:
		set_selected_army(army)
