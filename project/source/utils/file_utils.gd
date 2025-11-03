class_name FileUtils


## Returns the second file path made relative to the first one.
static func path_made_relative(path_1: String, path_2: String) -> String:
	if path_1 == "":
		return path_2

	var parts_1: PackedStringArray = path_1.split("/")
	var parts_2: PackedStringArray = path_2.split("/")

	var common_length: int = 0
	while (
			common_length < parts_1.size()
			and common_length < parts_2.size()
			and parts_1[common_length] == parts_2[common_length]
	):
		common_length += 1

	var steps_up: int = parts_1.size() - common_length - 1

	var output: String = ""
	for i in steps_up:
		output += ".." + "/"
	for i in range(common_length, parts_2.size()):
		output += parts_2[i] + "/"

	if output == "":
		return "."
	return output.trim_suffix("/")
