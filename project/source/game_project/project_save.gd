class_name ProjectSave
## Class responsible for saving a [GameProject] using any given file format.
## (JSON is currently the only supported format)
##
## In the future, when more file formats are supported,
## you will be able to provide a specific file format.

## False if saving was successful, otherwise true.
var error: bool = true

## Gives human-friendly information on why saving failed.
var error_message: String = ""


func save_project(project: GameProject) -> void:
	var file_access := FileAccess.open(
			project.metadata.file_path, FileAccess.WRITE
	)

	if not file_access:
		# Maybe use this to make more detailed error messages
		#var error: Error = FileAccess.get_open_error()

		error = true
		error_message = "Failed to open the file for writing."
		return

	var project_to_raw := ProjectToRawDict.new()
	project_to_raw.convert_project(project)
	file_access.store_string(JSON.stringify(project_to_raw.result, "\t"))
	file_access.close()
	error = false
