class_name CustomRulesFromFiles
## All custom rules loaded from a given file path.
## Currently unused and WIP; meant for saving/loading data in binary format.


var _provinces_blueprints: Array[ProvincesBlueprintFromData] = []


func _init(directory_global_path: String) -> void:
	var files: Array[PackedByteArray] = (
			_get_files_as_bytes_recursive(directory_global_path)
	)
	
	for file in files:
		# Binary and text files must be at least 4 bytes large
		if file.size() < 4:
			continue
		
		# Binary files must start with these magic bytes
		# (the last three bytes were taken from a random number generator)
		if (
				file[0] == 0xFF
				and file[1] == 0xEF
				and file[2] == 0xC8
				and file[3] == 0xDA
			):
			# It's a binary file
			var bit_array := BitArray.new(file)
			var cursor := BitArrayCursor.new(bit_array)
			cursor.next_bits(32) # Skip the magic bytes
			var uint31_from_bits := UInt31FromBits.new()
			if uint31_from_bits.read(cursor):
				# If you can't read the type, then ignore this file
				continue
			var file_type: int = uint31_from_bits.value()
			
			match file_type:
				CustomFileTypes.PROVINCES_BLUEPRINT:
					_provinces_blueprints.append(
							ProvincesBlueprintFromBinary.new(cursor)
					)
				_:
					# The file type is invalid, so we ignore this file
					pass
			
			# Move on to the next file
			continue
		
		# Text files must start with a magic string
		var file_string: String = file.get_string_from_utf8()
		if not file_string.begins_with("Text: "):
			continue
		
		# It's a text file
		var text_file_type: String = (
				file_string.get_slice("\n", 0).trim_prefix("Text: ")
		)
		match text_file_type:
			CustomFileTypes.TITLE[CustomFileTypes.PROVINCES_BLUEPRINT]:
				_provinces_blueprints.append(
						ProvincesBlueprintFromText.new(file_string)
				)
			_:
				# The data is invalid, so we ignore this file
				pass


func _get_files_as_bytes_recursive(
		directory_global_path: String
) -> Array[PackedByteArray]:
	var files: Array[PackedByteArray] = []
	
	var file_names: PackedStringArray = (
			DirAccess.get_files_at(directory_global_path)
	)
	var directory_names: PackedStringArray = (
			DirAccess.get_directories_at(directory_global_path)
	)
	
	for file_name in file_names:
		files.append(FileAccess.get_file_as_bytes(
				directory_global_path + "/" + file_name
		))
	
	for directory_name in directory_names:
		files.append_array(_get_files_as_bytes_recursive(
				directory_global_path + "/" + directory_name
		))
	
	return files


static func _unit_test() -> void:
	# Can't really make a unit test for loading files
	pass
