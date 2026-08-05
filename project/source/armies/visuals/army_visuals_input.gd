class_name ArmyVisualsInput
extends Node
## - Enables input on all army visuals.
## - Keeps track of which army is currently selected
##   and which army is currently hovered.
## - Adds or removes highlight on army visuals accordingly.
## - Opens/closes editor interface when an army is selected or deselected.

## This is needed to open the editor interface
var editor_settings: AppEditorSettings
var _project: GameProject

## May be null.
var _selected_army: Army = null
## May be null.
var _hovered_army: Army = null

## This is used to apply highlights
var _army_visuals_setup: ArmyVisualsSetup

## This is used to open/close the editor interface
@onready var _editing_interface := %EditingInterface as EditingInterface


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	# Reset internal state
	_selected_army = null
	_hovered_army = null

	# Enable input and connect signals
	_army_visuals_setup = (
			world_visuals.get_node("ArmyVisualsSetup") as ArmyVisualsSetup
	)
	for army_visuals in _army_visuals_setup.all_visuals():
		_setup_visuals(army_visuals)
	_army_visuals_setup.army_visuals_created.connect(_setup_visuals)

	# Needed for opening editor interface
	_project = world_visuals.project

	# Connect signal for deselecting when background clicked
	var background := world_visuals.get_node("Background") as WorldBackground
	background.clicked.connect(set_selected_army.bind(null))


## Deselects army if input is null.
## No effect if army is already selected.
func set_selected_army(army: Army) -> void:
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
		_editing_interface.close_interface()

	if army == null:
		return

	_selected_army = army
	_army_visuals_setup.visuals_of(army).highlight_selected()
	_editing_interface.open_army_edit_interface(
			army, _project, editor_settings
	)


## Sets it to none if input is null.
## No effect if army is already the hovered one.
func set_hovered_army(army: Army) -> void:
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


func _on_interface_closed() -> void:
	set_selected_army(null)


func _on_item_unhovered() -> void:
	set_hovered_army(null)


func _setup_visuals(army_visuals: ArmyVisuals2D) -> void:
	army_visuals.is_input_enabled = true
	army_visuals.clicked.connect(_on_army_clicked.bind(army_visuals.army))
	army_visuals.mouse_entered.connect(set_hovered_army.bind(army_visuals.army))
	army_visuals.mouse_exited.connect(_unset_hovered_army.bind(army_visuals))
	army_visuals.tree_exited.connect(_unset_hovered_army.bind(army_visuals))


func _on_army_clicked(army: Army) -> void:
	if _selected_army == army:
		set_selected_army(null)
	else:
		set_selected_army(army)


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
