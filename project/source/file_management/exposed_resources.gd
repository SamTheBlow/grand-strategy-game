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
## OpenMoji textures must be explicitly listed here,
## otherwise they will not be present in the release build.
@export var _openmoji_textures: Dictionary[String, Texture2D] = {}


## Returns null if there is no texture with given keyword.
func texture_with_keyword(keyword: String) -> Texture2D:
	var trimmed_keyword: String = keyword.trim_prefix(INTERNAL_PREFIX)
	if _exposed_textures.has(trimmed_keyword):
		return _exposed_textures[trimmed_keyword]
	if _openmoji_textures.has(trimmed_keyword):
		return _openmoji_textures[trimmed_keyword]
	return null


func base_textures() -> Array[String]:
	return _exposed_textures.keys() as Array[String]


func openmoji_textures() -> Array[String]:
	return _openmoji_textures.keys() as Array[String]
