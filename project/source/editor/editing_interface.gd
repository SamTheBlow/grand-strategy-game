class_name EditingInterface
extends Control
## Hides itself when the interface is closed,
## shows itself when the interface is open.

signal province_interface_opened(province: Province)
signal province_interface_closed()

enum InterfaceType {
	WORLD_LIMITS = 0,
	BACKGROUND_COLOR = 1,
	DECORATION_LIST = 2,
	PROVINCE_LIST = 3,
	COUNTRY_LIST = 4,
}

## The root node of each scene is an [AppEditorInterface].
const _INTERFACE_SCENES: Dictionary[InterfaceType, PackedScene] = {
	InterfaceType.WORLD_LIMITS: preload("uid://cyspbdausxgwr"),
	InterfaceType.BACKGROUND_COLOR: preload("uid://bb53mhx3u8ho8"),
	InterfaceType.DECORATION_LIST: preload("uid://bql3bs1c3rgo3"),
	InterfaceType.PROVINCE_LIST: preload("uid://bluif37tipwg7"),
	InterfaceType.COUNTRY_LIST: preload("uid://pns3cw110b6w"),
}

var _current_interface: Node:
	set(value):
		_current_interface = value
		_update_visibility()

@onready var _contents_container: Node = %Contents


func _ready() -> void:
	_update_visibility()


## Opens a new interface of given type.
func open_new_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	open_interface(_new_interface_of_type(type, project, editor_settings))


## Opens given interface.
## Closes the already open interface if applicable.
## No effect if the input is null.
func open_interface(new_interface: AppEditorInterface) -> void:
	if new_interface == null:
		return
	_remove_existing_interface()
	_contents_container.add_child(new_interface)
	_current_interface = new_interface


## Has no effect if there is no interface open.
func close_interface() -> void:
	if _current_interface == null:
		return
	elif _current_interface is InterfaceProvinceEdit:
		_remove_existing_interface()
		province_interface_closed.emit()
	else:
		_remove_existing_interface()


## Opens the interface for editing given province.
func open_province_edit_interface(
		province_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var province: Province = (
			project.game.world.provinces.province_from_id(province_id)
	)
	if province == null:
		push_error("Province doesn't exist.")
		return

	var province_interface := _new_interface(
			preload("uid://bafpj3jqosje7"), project, editor_settings
	) as InterfaceProvinceEdit
	province_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.PROVINCE_LIST, project, editor_settings
	))
	province_interface.delete_pressed.connect(
			_on_province_deleted.bind(project, editor_settings)
	)
	province_interface.duplicate_pressed.connect(
			_on_province_duplicated.bind(project, editor_settings)
	)
	province_interface.province = province
	open_interface(province_interface)
	province_interface_opened.emit(province)


func _remove_existing_interface() -> void:
	if _current_interface == null:
		return
	NodeUtils.delete_node(_current_interface)
	_current_interface = null


## May return null if the interface scene could not be found.
func _new_interface_of_type(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> AppEditorInterface:
	if not _INTERFACE_SCENES.has(type):
		push_error("Can't find the scene for this interface type.")
		return null
	return _new_interface(_INTERFACE_SCENES[type], project, editor_settings)


func _new_interface(
		interface_scene: PackedScene,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> AppEditorInterface:
	var new_interface := interface_scene.instantiate() as AppEditorInterface
	new_interface.editor_settings = editor_settings

	if new_interface is InterfaceWorldLimits:
		(new_interface as InterfaceWorldLimits).setup(
				project.game.world.limits()
		)
	if new_interface is InterfaceBackgroundColor:
		(new_interface as InterfaceBackgroundColor).setup(project.game.world)
	elif new_interface is InterfaceDecorationList:
		var list_interface := new_interface as InterfaceDecorationList
		list_interface.decorations = project.game.world.decorations
		list_interface.item_selected.connect(
				_open_new_decoration_edit_interface.bind(
						project, editor_settings
				)
		)
	elif new_interface is InterfaceProvinceList:
		var list_interface := new_interface as InterfaceProvinceList
		list_interface.setup(project.game.world.provinces)
		list_interface.item_selected.connect(
				open_province_edit_interface.bind(project, editor_settings)
		)
	elif new_interface is InterfaceCountryList:
		var list_interface := new_interface as InterfaceCountryList
		list_interface.setup(
				project.game.countries, Country.Factory.new(project.game)
		)
		list_interface.item_selected.connect(
				_open_country_edit_interface.bind(project, editor_settings)
		)

	return new_interface


func _open_new_decoration_edit_interface(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := _new_interface(
			preload("uid://bfpg282qeb0rx"), project, editor_settings
	) as InterfaceWorldDecorationEdit
	new_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.DECORATION_LIST, project, editor_settings
	))
	new_interface.delete_pressed.connect(
			_on_world_decoration_deleted.bind(project, editor_settings)
	)
	new_interface.duplicate_pressed.connect(
			_on_world_decoration_duplicated.bind(project, editor_settings)
	)
	new_interface.world_decoration = world_decoration
	open_interface(new_interface)


func _open_country_edit_interface(
		country_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var country: Country = (
			project.game.countries.country_from_id(country_id)
	)
	if country == null:
		push_error("Country doesn't exist.")
		return

	var edit_interface := _new_interface(
			preload("uid://ck6hme0uj2nuu"), project, editor_settings
	) as InterfaceCountryEdit
	edit_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.COUNTRY_LIST, project, editor_settings
	))
	#edit_interface.delete_pressed.connect(
			#_on_country_deleted.bind(project, editor_settings)
	#)
	edit_interface.duplicate_pressed.connect(
			_on_country_duplicated.bind(project, editor_settings)
	)
	edit_interface.country = country
	open_interface(edit_interface)


func _update_visibility() -> void:
	visible = _current_interface != null


func _on_world_decoration_deleted(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	project.game.world.decorations.remove(world_decoration)
	open_new_interface(InterfaceType.DECORATION_LIST, project, editor_settings)


func _on_world_decoration_duplicated(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	const _DUPLICATE_DECORATION_OFFSET = Vector2(64.0, 64.0)

	var new_decoration := WorldDecoration.new()
	new_decoration.texture = world_decoration.texture
	new_decoration.flip_h = world_decoration.flip_h
	new_decoration.flip_v = world_decoration.flip_v
	new_decoration.position = (
			world_decoration.position + _DUPLICATE_DECORATION_OFFSET
	)
	new_decoration.rotation_degrees = world_decoration.rotation_degrees
	new_decoration.scale = world_decoration.scale
	new_decoration.color = world_decoration.color

	project.game.world.decorations.add(new_decoration)
	_open_new_decoration_edit_interface(
			new_decoration, project, editor_settings
	)


func _on_province_deleted(
		province: Province,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	close_interface()
	project.game.world.provinces.remove(province.id)
	open_new_interface(InterfaceType.PROVINCE_LIST, project, editor_settings)


func _on_province_duplicated(
		province: Province,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	const _DUPLICATE_PROVINCE_OFFSET = Vector2(64.0, 64.0)

	var new_province := Province.new()
	new_province.polygon().array = province.polygon().array.duplicate()
	new_province.position_army_host = province.position_army_host
	new_province.move_relative(_DUPLICATE_PROVINCE_OFFSET)
	new_province.owner_country = province.owner_country
	new_province.population().value = province.population().value
	new_province.base_money_income().value = province.base_money_income().value

	for building in province.buildings.list():
		new_province.buildings.add(Fortress.new(province.id))

	project.game.world.provinces.add(new_province)
	open_province_edit_interface(new_province.id, project, editor_settings)


func _on_country_duplicated(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	# Copies everything except notifications
	var new_country := Country.new()
	new_country.country_name = country.country_name + " (Copy)"
	new_country.color = country.color
	new_country.money = country.money
	# Create a deep duplicate by parsing to raw data and back into a new object
	new_country.relationships = DiplomacyRelationshipsFromRaw.parsed_from(
			DiplomacyRelationshipsToRaw.result(country.relationships),
			project.game,
			new_country
	)
	new_country.auto_arrows = (
			AutoArrows.from_raw_data(country.auto_arrows.to_raw_data())
	)

	project.game.countries.add(new_country)
	_open_country_edit_interface(new_country.id, project, editor_settings)
