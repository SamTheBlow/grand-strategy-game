class_name ImportedTextures
extends Resource
## Stores a list of all imported textures.

## Maps each file path (or keyword: see [ExposedResources])
## to its associated texture.
var list: Dictionary[String, Texture2D] = {}
