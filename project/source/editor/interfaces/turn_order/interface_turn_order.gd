class_name InterfaceTurnOrder
extends AppEditorInterface
## Editor interface for configuring the turn order.

const _ELEMENT_SCENE := preload("uid://dc67eps16xpfs") as PackedScene

## Maps each country to its associated node, for quick access.
var _country_nodes: Dictionary[int, EditorTurnOrderElement] = {}

@onready var _element_container := %ElementContainer as InterpolatedBoxContainer


func _ready() -> void:
	project.game.countries.added.connect(_on_country_added)
	project.game.countries.removed.connect(_on_country_removed)
	project.game.countries.order_changed.connect(_on_country_order_changed)

	_element_container.drag_ended.connect(_on_drag_ended)

	# Setup the list nodes
	if project.game.countries.list.is_empty():
		_add_empty_list_label()
	else:
		for country in project.game.countries.list:
			_add_element(country)
		# Now that all the elements are in, refresh their arrows
		_refresh_arrows()

	var components_section := %ComponentSection as ComponentSection
	components_section.setup([ TurnOrderRandomization.KEY ], project, undo_redo)

	closed.connect(navigator.close_interface)


func _add_element(country: Country) -> void:
	var element := _ELEMENT_SCENE.instantiate() as EditorTurnOrderElement
	element.country = country
	element.label_text = country.name_or_default()
	element.up_pressed.connect(
			_on_element_up_pressed, ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)
	element.down_pressed.connect(
			_on_element_down_pressed, ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)
	_element_container.order_changed.connect(element.refresh_arrows)
	_element_container.add_child(element)
	_country_nodes[country.id] = element


func _remove_element(country: Country) -> void:
	NodeUtils.delete_node(_country_nodes[country.id])
	_country_nodes.erase(country.id)


func _refresh_arrows() -> void:
	for country_id in _country_nodes:
		_country_nodes[country_id].refresh_arrows()


func _reorder(country: Country, new_index: int) -> void:
	var old_index: int = project.game.countries.list.find(country)

	if old_index < 0 or old_index == new_index:
		return

	_apply_undo_redo_method(
			"Edit country order",
			project.game.countries.reorder.bind(country.id, new_index),
			project.game.countries.reorder.bind(country.id, old_index)
	)


func _add_empty_list_label() -> void:
	var empty_list_label := Label.new()
	empty_list_label.text = "(There are no countries.)"
	empty_list_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_list_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_element_container.add_child(empty_list_label)


func _remove_empty_list_label() -> void:
	# Uhh yeah if we're removing the empty list label it's because
	# it's the only child and we're about to add the 1st actual element
	NodeUtils.remove_all_children(_element_container)


func _on_drag_ended(moved_node: Node) -> void:
	var element := moved_node as EditorTurnOrderElement
	_reorder(element.country, element.get_index())


func _on_element_up_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.country, element.get_index() - 1)


func _on_element_down_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.country, element.get_index() + 1)


func _on_country_added(country: Country) -> void:
	if _country_nodes.is_empty():
		_remove_empty_list_label()

	_add_element(country)
	_element_container.move_child(
			_country_nodes[country.id],
			project.game.countries.list.find(country)
	)

	_refresh_arrows()


func _on_country_removed(country: Country) -> void:
	_remove_element(country)
	_refresh_arrows()

	if _country_nodes.is_empty():
		_add_empty_list_label()


## Moves element nodes to match country order
func _on_country_order_changed(
		country_id: int, _old_index: int, new_index: int
) -> void:
	_element_container.move_child(_country_nodes[country_id], new_index)
	_element_container.order_changed.emit()
