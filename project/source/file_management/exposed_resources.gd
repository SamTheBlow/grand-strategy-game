class_name ExposedResources
extends Resource
## Exposes internal resources to the user.
## The user can obtain an internal resource using its unique keyword.

## When this prefix is present in a file path, it means
## it's a keyword for an internal resource, not a file path.
const INTERNAL_PREFIX: String = "%"

## Each key is a unique keyword the user may use to obtain a texture.
## It should be easy to read and understand by humans.
@export var _exposed_textures: Dictionary[String, Texture2D] = {}

var _base_textures: Array[String] = []
var _openmoji_textures: Array[String] = []


## Returns null if there is no texture with given keyword.
func texture_with_keyword(keyword: String) -> Texture2D:
	var trimmed_keyword: String = keyword.trim_prefix(INTERNAL_PREFIX)
	if _exposed_textures.has(trimmed_keyword):
		return _exposed_textures[trimmed_keyword]
	return null


## Procedurally adds specific resources to the list of exposed resources.
## Meant to be run only once, right when the app is launched.
func initialize() -> void:
	_base_textures = _exposed_textures.keys()

	# Add all the openmoji textures.
	const OPENMOJI_PATH: String = "res://assets/openmoji/images"
	var dir_access: DirAccess = DirAccess.open(OPENMOJI_PATH)
	if dir_access == null:
		push_error("Failed to open openmoji directory.")
		return
	for file_name in dir_access.get_files():
		if file_name.get_extension().to_lower() != "svg":
			continue

		# NOTICE: files that share the same base name are discarded.
		var keyword: String = "openmoji_" + file_name.get_basename().to_lower()
		_exposed_textures.get_or_add(
				keyword,
				load(OPENMOJI_PATH.path_join(file_name))
		)

		if not _openmoji_textures.has(keyword):
			_openmoji_textures.append(keyword)


func base_textures() -> Array[String]:
	return _base_textures


func openmoji_textures() -> Array[String]:
	return _openmoji_textures
