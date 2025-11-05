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

var project_absolute_path := StringRef.new()

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

	for file in IMPORTED_TEXTURES.list:
		_add_file(Tab.IMPORTED_TEXTURES,  file)


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _add_file(tab: Tab, file: String) -> void:
	var project_texture: ProjectTexture
	var texture: Texture2D

	if file.begins_with(ExposedResources.INTERNAL_PREFIX):
		project_texture = TextureInternal.new(file)
		texture = project_texture.texture(null)
	else:
		project_texture = TextureFromFilePath.new(file, project_absolute_path)
		texture = ProjectTextures.texture_from_path(file)

	_map[tab].add(project_texture)
	_tab_item_list(tab).add_item("", texture)


func _tab_item_list(tab: Tab) -> ItemList:
	match tab:
		Tab.BASE_TEXTURES:
			return _base_textures_list
		Tab.OPENMOJI:
			return _openmoji_list
		_:
			return _imported_textures_list


## May return null.
func _texture(tab: Tab, index: int) -> ProjectTexture:
	return _map[tab].texture_with_index(index)


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

	var selected_texture: ProjectTexture = (
			_texture(current_tab, selected_texture_index)
	)
	if selected_texture == null:
		return

	texture_selected.emit(selected_texture)


func _on_texture_imported(path: String, texture: Texture2D) -> void:
	var imported_textures: ImportedTextures = preload("uid://cc4p22tibbgcx")

	# Discard duplicates.
	if imported_textures.list.has(path):
		return

	imported_textures.list[path] = texture
	_map[Tab.IMPORTED_TEXTURES].add(
			TextureFromFilePath.new(path, project_absolute_path)
	)
	_tab_item_list(Tab.IMPORTED_TEXTURES).add_item("", texture)


func _on_item_activated(index: int, tab: Tab) -> void:
	var project_texture: ProjectTexture = _texture(tab, index)
	if project_texture != null:
		texture_selected.emit(project_texture)
		invalidated.emit()


class IndexedTextures:
	var _list: Array[ProjectTexture] = []

	## May return null.
	func texture_with_index(index: int) -> ProjectTexture:
		if index < 0 or index >= _list.size():
			return null
		return _list[index]

	func add(texture: ProjectTexture) -> void:
		_list.append(texture)

	func has(path: String) -> bool:
		for project_texture in _list:
			if project_texture is not TextureFromFilePath:
				continue
			var texture_from_file_path := (
					project_texture as TextureFromFilePath
			)
			if texture_from_file_path.absolute_path() == path:
				return true
		return false
