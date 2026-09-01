extends Node

signal texture_imported(path: String, texture: Texture2D)

const _SUPPORTED_EXTENSIONS: Array[String] = [
	"bmp", "dds", "ktx", "exr", "hdr",
	"jpg","jpeg", "png", "tga", "svg", "webp"
]

@export var _imported_textures_tab: Control


## Recursively scans all files in given directory path.
func _scan_dir(dir_path: String) -> void:
	var dir_access := DirAccess.open(dir_path)

	for file in dir_access.get_files():
		_scan_file(dir_path.path_join(file))

	# Scan all the inner folders recursively
	for subdir in dir_access.get_directories():
		_scan_dir(dir_path.path_join(subdir))


func _scan_files(paths: PackedStringArray) -> void:
	for path in paths:
		_scan_file(path)


func _scan_file(path: String) -> void:
	if path.get_extension().to_lower() not in _SUPPORTED_EXTENSIONS:
		return
	var texture: Texture2D = ProjectTextures.texture_from_path(path)
	if texture == null:
		return
	texture_imported.emit(path, texture)
	_imported_textures_tab.show()
