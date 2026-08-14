extends Node
## Loads editor settings from given file path.
## Automatically saves settings to file when a setting is changed.
## Automatically reloads settings when the file is modified.

## Checks for external file changes at this interval, in seconds.
const _POLL_INTERVAL: float = 0.5

## How long a file change must stay stable before it is applied, in seconds.
## Guards against partial writes (temp-file rename, truncate-then-write).
const _STABILITY_CHECK_WAIT_TIME: float = 0.2

## Relative to "user://". Do not include file extension.
@export var _file_path: String

@export var _editor_settings: AppEditorSettings

var _last_modified_time: int = 0


func _ready() -> void:
	_editor_settings.changed.connect(_save)
	_load()
	_last_modified_time = _get_modified_time()

	var timer := Timer.new()
	timer.autostart = true
	timer.wait_time = _POLL_INTERVAL
	timer.timeout.connect(_poll_for_changes)
	add_child(timer)


func _get_file_path() -> String:
	return "user://%s.json" % _file_path


## Returns 0 if an error occurs (e.g. file doesn't exist).
func _get_modified_time() -> int:
	return FileAccess.get_modified_time(_get_file_path())


func _poll_for_changes() -> void:
	var current_modified_time: int = _get_modified_time()

	# Edge case where there was an error (e.g. file didn't exist)
	if _last_modified_time == 0:
		_last_modified_time = current_modified_time
		return

	# Return if file wasn't modified since last poll
	elif current_modified_time == _last_modified_time:
		return

	_last_modified_time = current_modified_time

	# Change detected
	# Wait a little bit to ensure the file change is stable
	await get_tree().create_timer(_STABILITY_CHECK_WAIT_TIME).timeout

	if _get_modified_time() == _last_modified_time:
		_load()


func _save() -> void:
	var file_path: String = _get_file_path()
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save editor settings. File path: %s" % file_path)
		return
	file.store_string(JSON.stringify(_editor_settings.to_raw_data(), "\t"))
	file.close()

	# Avoid reloading the file
	_last_modified_time = _get_modified_time()


func _load() -> void:
	var file_path: String = _get_file_path()

	# If the file doesn't exist, return with no errors.
	if not FileAccess.file_exists(file_path):
		return

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load editor settings. File path: %s" % file_path)
		return

	var file_text: String = file.get_as_text()
	file.close()

	_editor_settings.changed.disconnect(_save)
	_editor_settings.load_raw_data(JSON.parse_string(file_text))
	_editor_settings.changed.connect(_save)
