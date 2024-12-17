class_name EditorProject

const DEFAULT_PROJECT_NAME: String = "(Unnamed project)"

## Fake variable. Gets and sets the name that's stored in the metadata.
var name: String:
	get:
		return _meta.map_name
	set(value):
		_meta.map_name = value

var _game: Game
var _meta: MapMetadata


func _init() -> void:
	_game = Game.new()
	_meta = MapMetadata.new()
	_meta.map_name = DEFAULT_PROJECT_NAME
