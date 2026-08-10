class_name InterfaceBuildings
extends AppEditorInterface
## The interface in which the user can edit fortress settings.


func _ready() -> void:
	var editor_settings_node := %EditorSettings as ItemVoidNode
	editor_settings_node.item.child_items = [
		editor_settings.show_buildings
	]
	editor_settings_node.refresh()

	_setup_settings(%GameSettings as ItemVoidNode)

	closed.connect(navigator.close_interface)


func _load_settings(settings_item: PropertyTreeItem) -> void:
	var fortress_data: BuildingData = project.game.world.fortress_data()

	# Game settings -> Sprite
	var item_texture := settings_item.child_items[0] as ItemTexture
	item_texture.fallback_texture = BuildingVisuals2D.FALLBACK_TEXTURE
	item_texture.value = fortress_data.texture
	item_texture.value_changed.connect(_on_item_texture_changed)
	item_texture.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	fortress_data.texture_changed.connect(
			_on_fortress_texture_changed.bind(item_texture).unbind(1)
	)

	# Game settings -> Defense multiplier
	var item_defense := settings_item.child_items[1] as ItemFloat
	item_defense.value = fortress_data.defense_multiplier
	item_defense.value_changed.connect(_on_item_defense_changed)
	fortress_data.defense_multiplier_changed.connect(
			_on_fortress_defense_changed.bind(item_defense).unbind(1)
	)

	# Game settings -> Can be built
	var item_can_be_built := settings_item.child_items[2] as ItemBool
	item_can_be_built.value = fortress_data.can_be_built
	item_can_be_built.value_changed.connect(_on_item_can_be_built_changed)
	fortress_data.can_be_built_changed.connect(
			_on_fortress_can_be_built_changed.bind(item_can_be_built).unbind(1)
	)

	# Can be built -> Population cost
	var item_population_cost := item_can_be_built.child_items[0] as ItemInt
	item_population_cost.value = fortress_data.population_cost
	item_population_cost.value_changed.connect(
			_on_item_population_cost_changed
	)
	fortress_data.population_cost_changed.connect(
			_on_fortress_population_cost_changed
			.bind(item_population_cost).unbind(1)
	)

	# Can be built -> Money cost
	var item_money_cost := item_can_be_built.child_items[1] as ItemInt
	item_money_cost.value = fortress_data.money_cost
	item_money_cost.value_changed.connect(_on_item_money_cost_changed)
	fortress_data.money_cost_changed.connect(
			_on_fortress_money_cost_changed.bind(item_money_cost).unbind(1)
	)


func _on_item_texture_changed(new_value: ProjectTexture) -> void:
	var fortress_data := project.game.world.fortress_data()
	_apply_undo_redo_property(
			"Change fortress texture",
			fortress_data,
			&"texture",
			fortress_data.texture,
			new_value
	)


func _on_item_defense_changed(new_value: float) -> void:
	var fortress_data := project.game.world.fortress_data()
	_apply_undo_redo_property(
			"Change fortress defense multiplier",
			fortress_data,
			&"defense_multiplier",
			fortress_data.defense_multiplier,
			new_value
	)


func _on_item_can_be_built_changed(new_value: bool) -> void:
	var fortress_data := project.game.world.fortress_data()
	_apply_undo_redo_property(
			"Change fortress can be built",
			fortress_data,
			&"can_be_built",
			fortress_data.can_be_built,
			new_value
	)


func _on_item_population_cost_changed(new_value: int) -> void:
	var fortress_data := project.game.world.fortress_data()
	_apply_undo_redo_property(
			"Change fortress population cost",
			fortress_data,
			&"population_cost",
			fortress_data.population_cost,
			new_value
	)


func _on_item_money_cost_changed(new_value: int) -> void:
	var fortress_data := project.game.world.fortress_data()
	_apply_undo_redo_property(
			"Change fortress money cost",
			fortress_data,
			&"money_cost",
			fortress_data.money_cost,
			new_value
	)


func _on_fortress_texture_changed(item: ItemTexture) -> void:
	_set_setting_no_signal(
			item,
			_on_item_texture_changed,
			project.game.world.fortress_data().texture
	)


func _on_fortress_defense_changed(item: ItemFloat) -> void:
	_set_setting_no_signal(
			item,
			_on_item_defense_changed,
			project.game.world.fortress_data().defense_multiplier
	)


func _on_fortress_can_be_built_changed(item: ItemBool) -> void:
	_set_setting_no_signal(
			item,
			_on_item_can_be_built_changed,
			project.game.world.fortress_data().can_be_built
	)


func _on_fortress_population_cost_changed(item: ItemInt) -> void:
	_set_setting_no_signal(
			item,
			_on_item_population_cost_changed,
			project.game.world.fortress_data().population_cost
	)


func _on_fortress_money_cost_changed(item: ItemInt) -> void:
	_set_setting_no_signal(
			item,
			_on_item_money_cost_changed,
			project.game.world.fortress_data().money_cost
	)
