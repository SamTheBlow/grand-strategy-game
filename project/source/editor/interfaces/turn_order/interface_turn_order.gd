class_name InterfaceTurnOrder
extends AppEditorInterface
## Editor interface for configuring the turn order.

const _ELEMENT_SCENE := preload("uid://dc67eps16xpfs") as PackedScene

var countries: Countries
var item_random_turn_order: ItemBool

var _country_nodes: Dictionary[int, EditorTurnOrderElement] = {}

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode
@onready var _info_label := %InfoLabel as Control
@onready var _list_container := %ListContainer as Control
@onready var _element_container := %ElementContainer as InterpolatedBoxContainer


func _ready() -> void:
	countries.added.connect(_on_country_added)
	countries.removed.connect(_on_country_removed)
	countries.order_changed.connect(_on_country_order_changed)

	item_random_turn_order.value_changed.connect(_on_item_value_changed)
	_update_visibility()
	_game_settings_node.item.child_items = [item_random_turn_order]
	_game_settings_node.refresh()

	_element_container.drag_ended.connect(_on_drag_ended)

	# Setup the list nodes
	if countries.size() == 0:
		_add_empty_list_label()
	else:
		for country in countries.list():
			_add_element(country)
		# Now that all the elements are in, refresh their arrows
		_refresh_arrows()


func _update_visibility() -> void:
	_info_label.visible = item_random_turn_order.value
	_list_container.visible = not item_random_turn_order.value


func _add_element(country: Country) -> void:
	var element := _ELEMENT_SCENE.instantiate() as EditorTurnOrderElement
	element.country = country
	element.label_text = country.name_or_default()
	element.up_pressed.connect(_on_element_up_pressed.bind(element))
	element.down_pressed.connect(_on_element_down_pressed.bind(element))
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
	var old_index: int = countries.position_of(country_id)

	if old_index == new_index:
		return

	undo_redo.create_action("Edit country order")
	undo_redo.add_do_method(countries.reorder.bind(country_id, new_index))
	undo_redo.add_undo_method(countries.reorder.bind(country_id, old_index))
	undo_redo.commit_action()


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


## Disconnects signals to avoid creating another undo_redo action
func _set_item_value_no_signal(value: bool) -> void:
	item_random_turn_order.value_changed.disconnect(_on_item_value_changed)
	item_random_turn_order.value = value
	item_random_turn_order.value_changed.connect(_on_item_value_changed)

	_update_visibility()


func _on_item_value_changed(_item: PropertyTreeItem) -> void:
	_update_visibility()

	var value: bool = item_random_turn_order.value
	undo_redo.create_action("Toggle random turn order")
	undo_redo.add_do_method(_set_item_value_no_signal.bind(value))
	undo_redo.add_undo_method(_set_item_value_no_signal.bind(not value))
	undo_redo.commit_action(false)


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
			_country_nodes[country.id], countries.position_of(country.id)
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
