class_name EditorWorldBridge
extends Node
## Bridges the game world and the editing interface.

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _COUNTRY_SELECT_POPUP_SCENE: PackedScene = preload("uid://gfcp3xbnck52")

var editor_settings: AppEditorSettings

@onready var _editor_adjacency := %EditorAdjacency as MapModeEditorAdjacency
@onready var _country_giver := %CountryOwnershipGiver as CountryOwnershipGiver
@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _popup_container := %PopupContainer as Control

var _world_visuals: WorldVisuals2D = null
var _army_visuals_input: ArmyVisualsInput = null


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_world_visuals = world_visuals

	# Connect signals
	_world_visuals.province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)

	# Setup army input
	_army_visuals_input = ArmyVisualsInput.new()
	_army_visuals_input.army_selected.connect(
			_editing_interface.open_army_edit_interface.bind(
					_world_visuals.project, editor_settings
			)
	)
	_army_visuals_input.army_deselected.connect(
			_editing_interface.close_interface
	)
	_world_visuals.add_child(_army_visuals_input)

	# Setup the adjacency editor tool
	_editor_adjacency.setup(
			_world_visuals.province_visuals,
			_world_visuals.province_selection,
			PolygonEditEdgeCase.new(_world_visuals.world)
	)
	_world_visuals.province_visuals.province_right_clicked.connect(
			_editor_adjacency._on_province_right_clicked
	)
	_world_visuals.province_input.province_unhovered.connect(
			_editor_adjacency.refresh_highlight_links.unbind(1)
	)

	# Setup the country ownership tool
	_world_visuals.map_mode_setup.country_giver = _country_giver
	_world_visuals.province_visuals.province_clicked.connect(
			_country_giver.apply_to_province
	)


func _on_selected_province_changed(province: Province) -> void:
	if province == null:
		_editing_interface.close_interface()
		return
	_editing_interface.open_province_edit_interface(
			province.id, _world_visuals.project, editor_settings
	)


func _on_province_interface_opened(province: Province) -> void:
	# Select province
	_world_visuals.province_selection.select(province.id)

	# Show adjacencies on world map
	_world_visuals.map_mode_setup.political.is_enabled = false
	_editor_adjacency.is_enabled = true


func _on_province_interface_closed() -> void:
	# Deselect province
	_world_visuals.province_selection.deselect()

	# Revert the map mode to normal
	_editor_adjacency.is_enabled = false
	_world_visuals.map_mode_setup.political.is_enabled = true


func _on_country_select_pressed(item_country: ItemCountry) -> void:
	# Open popup that lets you choose a country
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var country_select_popup := (
			_COUNTRY_SELECT_POPUP_SCENE.instantiate() as CountrySelectPopup
	)
	country_select_popup.setup(
			_world_visuals.project.game.countries, item_country.may_be_null()
	)
	country_select_popup.country_selected.connect(item_country.set_value)
	popup.contents_node = country_select_popup
	_popup_container.add_child(popup)


func _on_country_interface_opened(country: Country) -> void:
	# Change map mode
	_world_visuals.map_mode_setup.set_map_mode_editor_country(country)


func _on_country_interface_closed() -> void:
	# Revert the map mode to normal
	_world_visuals.map_mode_setup.set_map_mode(MapModeSetup.MapMode.POLITICAL)


func _on_army_interface_opened(army: Army) -> void:
	_army_visuals_input.set_selected_army(army)


func _on_army_interface_closed() -> void:
	_army_visuals_input.set_selected_army(null)


func _on_army_list_item_hovered(army: Army) -> void:
	_army_visuals_input.set_hovered_army(army)


func _on_army_list_item_unhovered() -> void:
	_army_visuals_input.set_hovered_army(null)


func _on_province_list_item_hovered(province: Province) -> void:
	_world_visuals.province_input.set_hovered_province(province)


func _on_province_list_item_unhovered() -> void:
	_world_visuals.province_input.set_hovered_province(null)
