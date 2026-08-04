class_name DecorationVisualsInput
extends Node
## - Enables input on all decoration visuals.
## - Keeps track of which decoration is currently selected
##   and which decoration is currently hovered.
## - Adds or removes highlight on decoration visuals accordingly.
## - Opens/closes editor interface when a decoration is selected or deselected.

## This is needed to open the editor interface
var editor_settings: AppEditorSettings
var _project: GameProject

## May be null.
var _selected_decoration: WorldDecoration = null
## May be null.
var _hovered_decoration: WorldDecoration = null

## This is used to apply highlights
var _decoration_container: DecorationVisualsContainer2D

## This is used to open/close editor interface
@onready var _editing_interface := %EditingInterface as EditingInterface


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	# Reset internal state
	_selected_decoration = null
	_hovered_decoration = null

	# Enable input and connect signals
	_decoration_container = (
			world_visuals.get_node("Decorations")
			as DecorationVisualsContainer2D
	)
	for decoration_visuals in _decoration_container.all_visuals():
		_setup_visuals(decoration_visuals)
	_decoration_container.decoration_visuals_created.connect(_setup_visuals)

	# Needed for opening editor interface
	_project = world_visuals.project

	# Connect signal for deselecting when background clicked
	var background := world_visuals.get_node("Background") as WorldBackground
	background.clicked.connect(set_selected_decoration.bind(null))


## Deselects the decoration if input is null.
## No effect if the decoration is already selected.
func set_selected_decoration(decoration: WorldDecoration) -> void:
	if decoration == _selected_decoration:
		return

	if _selected_decoration != null:
		var visuals: DecorationVisuals2D = (
				_decoration_container.visuals_of(_selected_decoration)
		)
		if visuals != null:
			if _selected_decoration == _hovered_decoration:
				visuals.highlight()
			else:
				visuals.remove_highlight()
		_selected_decoration = null
		_editing_interface.close_interface()

	if decoration == null:
		return

	_selected_decoration = decoration
	_decoration_container.visuals_of(decoration).highlight_selected()
	_editing_interface.open_decoration_edit_interface(
			decoration, _project, editor_settings
	)


## Sets it to none if input is null.
## No effect if the decoration is already the hovered one.
func set_hovered_decoration(decoration: WorldDecoration) -> void:
	if decoration == _hovered_decoration:
		return

	if _hovered_decoration != null:
		if _hovered_decoration != _selected_decoration:
			var visuals: DecorationVisuals2D = (
					_decoration_container.visuals_of(_hovered_decoration)
			)
			if visuals != null:
				visuals.remove_highlight()
		_hovered_decoration = null

	if decoration == null:
		return

	_hovered_decoration = decoration
	if decoration != _selected_decoration:
		_decoration_container.visuals_of(decoration).highlight()


func _on_interface_closed() -> void:
	set_selected_decoration(null)


func _on_item_unhovered() -> void:
	set_hovered_decoration(null)


func _setup_visuals(decoration_visuals: DecorationVisuals2D) -> void:
	decoration_visuals.is_input_enabled = true
	decoration_visuals.clicked.connect(
			_on_decoration_clicked.bind(decoration_visuals.world_decoration)
	)
	decoration_visuals.mouse_entered.connect(
			set_hovered_decoration.bind(decoration_visuals.world_decoration)
	)
	decoration_visuals.mouse_exited.connect(
			_unset_hovered_decoration.bind(decoration_visuals)
	)
	decoration_visuals.tree_exited.connect(
			_unset_hovered_decoration.bind(decoration_visuals)
	)


func _on_decoration_clicked(decoration: WorldDecoration) -> void:
	if _selected_decoration == decoration:
		set_selected_decoration(null)
	else:
		set_selected_decoration(decoration)


## We use this and not set_hovered_decoration(null),
## because if a different decoration got hovered and got their
## mouse_entered signal to trigger first, then they'd set the
## hovered decoration to the new decoration, and then the previous
## decoration visuals would trigger mouse_exited and set it back to null.
func _unset_hovered_decoration(decoration_visuals: DecorationVisuals2D) -> void:
	if _hovered_decoration == decoration_visuals.world_decoration:
		_hovered_decoration = null

	if decoration_visuals.world_decoration != _selected_decoration:
		decoration_visuals.remove_highlight()
