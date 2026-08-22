class_name ComponentEditor
extends VBoxContainer
## Node that allows the user to add/remove/edit one given [GameComponent].

var _component: GameComponent
var _project: GameProject
var _undo_redo: UndoRedoResource


func setup(
		component: GameComponent,
		project: GameProject,
		undo_redo: UndoRedoResource
) -> void:
	_component = component
	_project = project
	_undo_redo = undo_redo

	var name_label := %NameLabel as Label
	name_label.text = component.TITLE

	var check_box := %CheckBox as CheckBox
	check_box.button_pressed = _project.game.components.has(component.KEY)
	check_box.toggled.connect(_on_checkbox_toggled)

	var description_label := %DescriptionLabel as Label
	description_label.text = component.DESCRIPTION

	var item_node := %ItemNode as ItemVoidNode
	# Create new instance to avoid sharing the same instance
	var item := PropertyTreeItem.new()
	item.child_items = _new_setting_items(component)
	item_node.item = item


func _new_setting_items(component: GameComponent) -> Array[PropertyTreeItem]:
	var output: Array[PropertyTreeItem] = []
	for setting: Dictionary in component.SETTINGS:
		var setting_name: String = setting["property_name"]
		var setting_label: String = setting["text"]
		var setting_type: String = setting["type"]
		match setting_type:
			"int":
				var item_int := ItemInt.new()
				item_int.text = setting_label
				item_int.value = component.get(setting_name)
				if setting.has("min"):
					item_int.has_minimum = true
					item_int.minimum = setting["min"]
				if setting.has("max"):
					item_int.has_maximum = true
					item_int.maximum = setting["max"]
				item_int.value_changed.connect(
						_on_setting_changed.bind(setting_name)
				)
				output.append(item_int)
			"float":
				var item_float := ItemFloat.new()
				item_float.text = setting_label
				item_float.value = component.get(setting_name)
				if setting.has("min"):
					item_float.has_minimum = true
					item_float.minimum = setting["min"]
				if setting.has("max"):
					item_float.has_maximum = true
					item_float.maximum = setting["max"]
				item_float.value_changed.connect(
						_on_setting_changed.bind(setting_name)
				)
				output.append(item_float)
			"bool":
				var item_bool := ItemBool.new()
				item_bool.text = setting_label
				item_bool.value = component.get(setting_name)
				item_bool.value_changed.connect(
						_on_setting_changed.bind(setting_name)
				)
				output.append(item_bool)
			"options":
				var item_options := ItemOptions.new()
				item_options.text = setting_label
				var option_names: Array[String] = []
				for option_name: String in setting["options"]:
					option_names.append(option_name)
				item_options.options = option_names
				var option_values: Array[int] = []
				for option_value: int in setting["option_map"]:
					option_values.append(option_value)
				item_options.option_value_map = option_values
				item_options.selected_index = item_options.index_of_value(
						component.get(setting_name)
				)
				item_options.value_changed.connect(
						_on_setting_changed.bind(setting_name)
				)
				output.append(item_options)
			"preset":
				var item_preset := ItemOptions.new()
				item_preset.text = setting_label
				var preset_names: Array[String] = [ "None" ]
				var preset_values: Array[int] = [ -1 ]
				for preset: DiplomacyPreset in (
						_project.game.diplomatic_presets.list()
				):
					preset_names.append(preset.name)
					preset_values.append(preset.id)
				item_preset.options = preset_names
				item_preset.option_value_map = preset_values
				item_preset.selected_index = item_preset.index_of_value(
						component.get(setting_name)
				)
				item_preset.value_changed.connect(
						_on_setting_changed.bind(setting_name)
				)
				output.append(item_preset)
	return output


func _on_setting_changed(value: Variant, setting_name: String) -> void:
	if _project.game.components.has(_component.KEY):
		var old_value: Variant = _component.get(setting_name)
		_undo_redo.create_action("Edit component setting")
		_undo_redo.add_do_property(_component, setting_name, value)
		_undo_redo.add_undo_property(_component, setting_name, old_value)
		_undo_redo.commit_action()
	else:
		# If the component isn't in the game,
		# then you aren't actually modifying the game, so, don't use undo/redo.
		_component.set(setting_name, value)


func _on_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_add()
	else:
		_remove()


func _add() -> void:
	if _project.game.components.has(_component.KEY):
		return
	_undo_redo.create_action("Add component")
	_undo_redo.add_do_method(_add_component)
	_undo_redo.add_undo_method(_remove_component)
	_undo_redo.commit_action()


func _remove() -> void:
	if not _project.game.components.has(_component.KEY):
		return
	_undo_redo.create_action("Remove component")
	_undo_redo.add_do_method(_remove_component)
	_undo_redo.add_undo_method(_add_component)
	_undo_redo.commit_action()


func _add_component() -> void:
	_project.game.components[_component.KEY] = _component


func _remove_component() -> void:
	_project.game.components.erase(_component.KEY)
