class_name FileJSON
## Class responsible for loading JSON data from a file.


var error: bool = true
var error_message: String = ""

## This is where the result will be stored, if no error occured.
var result: Variant


func load_json(file_path: String) -> void:
	var file_access := FileAccess.open(file_path, FileAccess.READ)
	
	if not file_access:
		# Maybe use this to make more detailed error messages
		#var open_error: Error = FileAccess.get_open_error()
		
		error = true
		error_message = "Failed to open the file for reading."
		return
	
	var json := JSON.new()
	var json_error: Error = json.parse(file_access.get_as_text())
	file_access.close()
	if json_error != OK:
		error = true
		error_message = "Failed to parse the file as JSON."
		return
	
	error = false
	result = json.data
