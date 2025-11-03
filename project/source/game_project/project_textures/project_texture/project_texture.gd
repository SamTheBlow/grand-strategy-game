@abstract
class_name ProjectTexture
## A project's texture can take many forms.
## Provides a [Texture2D] taken from some [ProjectTextures].
## Provides itself as raw data.


## Returns the texture retrieved from given [ProjectTextures].
## If it were to return null, returns given fallback texture instead.
@abstract func texture(
		textures: ProjectTextures, fallback_texture: Texture2D = null
) -> Texture2D


## Returns this texture as raw data. May return null.
@abstract func to_raw_data() -> Variant


## For when there is just no texture.
static func none() -> ProjectTexture:
	return TextureNone.new()


class TextureNone extends ProjectTexture:
	func texture(
			_textures: ProjectTextures, fallback_texture: Texture2D = null
	) -> Texture2D:
		return fallback_texture
	func to_raw_data() -> Variant:
		return null
