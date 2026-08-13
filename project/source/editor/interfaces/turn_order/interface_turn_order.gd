class_name InterfaceTurnOrder
extends AppEditorInterface
## Editor interface for configuring the turn order.

const _ELEMENT_SCENE := preload("uid://dc67eps16xpfs") as PackedScene

## Maps each country to its associated node, for quick access.
var _country_nodes: Dictionary[int, EditorTurnOrderElement] = {}

@onready var _item_random_order := (
		(%GameSettingsCategory as ItemVoidNode).item.child_items[0] as ItemBool
)

@onready var _info_label := %InfoLabel as Control
@onready var _list_container := %ListContainer as Control
@onready var _element_container := %ElementContainer as InterpolatedBoxContainer


func _ready() -> void:
	project.game.countries.added.connect(_on_country_added)
	project.game.countries.removed.connect(_on_country_removed)
	project.game.countries.order_changed.connect(_on_country_order_changed)

	_item_random_order.value = _is_random_turn_order_enabled()
	_item_random_order.value_changed.connect(_on_item_value_changed)
	_update_visibility()

	_element_container.drag_ended.connect(_on_drag_ended)

	# Setup the list nodes
	if project.game.countries.size() == 0:
		_add_empty_list_label()
	else:
		for country in project.game.countries.list():
			_add_element(country)
		# Now that all the elements are in, refresh their arrows
		_refresh_arrows()

	closed.connect(navigator.close_interface)


func _update_visibility() -> void:
	var is_enabled: bool = _is_random_turn_order_enabled()
	_info_label.visible = is_enabled
	_list_container.visible = not is_enabled


func _is_random_turn_order_enabled() -> bool:
	return project.game.setup_components.has(TurnOrderRandomization.KEY)


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


func _reorder(country_id: int, new_index: int) -> void:
	var old_index: int = project.game.countries.position_of(country_id)

	if old_index == new_index:
		return

	_apply_undo_redo_method(
			"Edit country order",
			project.game.countries.reorder.bind(country_id, new_index),
			project.game.countries.reorder.bind(country_id, old_index)
	)


func _add_empty_list_label() -> void:
	var empty_list_label := Label.new()
	empty_list_label.text = "(List is empty!)"
	empty_list_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_list_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_element_container.add_child(empty_list_label)


func _remove_empty_list_label() -> void:
	# Uhh yeah if we're removing the empty list label it's because
	# it's the only child and we're about to add the 1st actual element
	NodeUtils.remove_all_children(_element_container)


func _on_item_value_changed(is_enabled: bool) -> void:
	undo_redo.create_action("Toggle random turn order")
	undo_redo.add_do_method(_set_setting_no_signal.bind(
			_item_random_order, _on_item_value_changed, is_enabled
	))
	undo_redo.add_do_method(_set_random_turn_order.bind(is_enabled))
	undo_redo.add_do_method(_update_visibility)
	undo_redo.add_undo_method(_set_setting_no_signal.bind(
			_item_random_order, _on_item_value_changed, not is_enabled
	))
	undo_redo.add_undo_method(_set_random_turn_order.bind(not is_enabled))
	undo_redo.add_undo_method(_update_visibility)
	undo_redo.commit_action()


## Adds or removes the [TurnOrderRandomization] setup component.
func _set_random_turn_order(is_enabled: bool) -> void:
	if is_enabled:
		project.game.setup_components[TurnOrderRandomization.KEY] = (
				TurnOrderRandomization.new()
		)
	else:
		project.game.setup_components.erase(TurnOrderRandomization.KEY)


func _on_drag_ended(moved_node: Node) -> void:
	var element := moved_node as EditorTurnOrderElement
	_reorder(element.country.id, element.get_index())


func _on_element_up_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.country.id, element.get_index() - 1)


func _on_element_down_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.country.id, element.get_index() + 1)


func _on_country_added(country: Country) -> void:
	if _country_nodes.is_empty():
		_remove_empty_list_label()

	_add_element(country)
	_element_container.move_child(
			_country_nodes[country.id],
			project.game.countries.position_of(country.id)
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
