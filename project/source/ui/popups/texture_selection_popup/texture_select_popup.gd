class_name TextureSelectPopup
extends VBoxContainer
## The popup that appears when the user is prompted to select a texture.
##
## See also: [GamePopup]

signal texture_selected(texture: ProjectTexture)
signal invalidated()

enum Tab {
	BASE_TEXTURES = 0,
	OPENMOJI = 1,
	IMPORTED_TEXTURES = 2,
}

var project_textures: ProjectTextures

var _map: Dictionary[Tab, IndexedTextures] = {
	Tab.BASE_TEXTURES: IndexedTextures.new(),
	Tab.OPENMOJI: IndexedTextures.new(),
	Tab.IMPORTED_TEXTURES: IndexedTextures.new(),
}

@onready var _tab_container := %TabContainer as TabContainer
@onready var _base_textures_list := %BaseTexturesList as ItemList
@onready var _openmoji_list := %OpenMojiList as ItemList
@onready var _imported_textures_list := %ImportedList as ItemList


func _ready() -> void:
	const EXPOSED_RESOURCES: ExposedResources = preload("uid://doda8npdqckhw")
	const IMPORTED_TEXTURES: ImportedTextures = preload("uid://cc4p22tibbgcx")

	for file in EXPOSED_RESOURCES.base_textures():
		_add_file(Tab.BASE_TEXTURES, ExposedResources.INTERNAL_PREFIX + file)

	for file in EXPOSED_RESOURCES.openmoji_textures():
		_add_file(Tab.OPENMOJI, ExposedResources.INTERNAL_PREFIX + file)

	# Populate the ImportedTextures resource
	# with this project's imported textures
	for file_path in project_textures.external_file_paths():
		if IMPORTED_TEXTURES.list.has(file_path):
			continue

		var texture_id: int = project_textures.new_id_from_file_path(file_path)
		var texture: Texture2D = project_textures.texture_from_id(texture_id)
		if texture != null:
			IMPORTED_TEXTURES.list.get_or_add(file_path, texture)

	for file in IMPORTED_TEXTURES.list:
		_add_file(Tab.IMPORTED_TEXTURES, file)


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _add_file(tab: Tab, file_path: String) -> void:
	var texture: Texture2D
	if file_path.begins_with(ExposedResources.INTERNAL_PREFIX):
		texture = TextureInternal.new(file_path).texture()
	else:
		texture = ProjectTextures.texture_from_path(file_path)

	_map[tab].add(file_path)
	_tab_item_list(tab).add_item("", texture)


func _tab_item_list(tab: Tab) -> ItemList:
	match tab:
		Tab.BASE_TEXTURES:
			return _base_textures_list
		Tab.OPENMOJI:
			return _openmoji_list
		_:
			return _imported_textures_list


func _on_button_pressed(button_id: int) -> void:
	if button_id != 1:
		return

	var current_tab := Tab.IMPORTED_TEXTURES
	match _tab_container.current_tab:
		0:
			current_tab = Tab.BASE_TEXTURES
		1:
			current_tab = Tab.OPENMOJI

	var selected_texture_index: int = -1
	var selected_items: PackedInt32Array = (
			_tab_item_list(current_tab).get_selected_items()
	)
	if not selected_items.is_empty():
		selected_texture_index = selected_items[0]

	var project_texture: ProjectTexture = (
			_map[current_tab].new_project_texture(
					selected_texture_index, project_textures
			)
	)
	if project_texture == null:
		return
	texture_selected.emit(project_texture)


func _on_texture_imported(path: String, texture: Texture2D) -> void:
	var imported_textures: ImportedTextures = preload("uid://cc4p22tibbgcx")

	# Discard duplicates.
	if imported_textures.list.has(path):
		return

	imported_textures.list[path] = texture
	_map[Tab.IMPORTED_TEXTURES].add(path)
	_tab_item_list(Tab.IMPORTED_TEXTURES).add_item("", texture)


func _on_item_activated(index: int, tab: Tab) -> void:
	var project_texture: ProjectTexture = (
			_map[tab].new_project_texture(index, project_textures)
	)
	if project_texture == null:
		return
	texture_selected.emit(project_texture)
	invalidated.emit()


class IndexedTextures:
	var _paths: Array[String] = []

	## Returns null if given index is invalid.
	func new_project_texture(
			index: int, project_textures: ProjectTextures
	) -> ProjectTexture:
		if index < 0 or index >= _paths.size():
			return null
		if _paths[index].begins_with(ExposedResources.INTERNAL_PREFIX):
			return TextureInternal.new(_paths[index])
		return TextureFromFilePath.new(_paths[index], project_textures)

	func add(path: String) -> void:
		_paths.append(path)
