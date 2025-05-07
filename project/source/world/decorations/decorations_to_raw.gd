class_name WorldDecorationsToRaw
## Converts [WorldDecoration]s into raw data.
##
## See also: [WorldDecorationsFromRaw]


## Always succeeds.
static func result(world_decorations: Array[WorldDecoration]) -> Array:
	var output: Array = []

	for world_decoration in world_decorations:
		output.append(_decoration_raw_dict(world_decoration))

	return output


## Always succeeds.
static func _decoration_raw_dict(decoration: WorldDecoration) -> Dictionary:
	var output: Dictionary = {
		WorldDecorationsFromRaw.TEXTURE_FILE_PATH_KEY:
			decoration._texture_file_path
	}

	# We use an empty decoration to check for default values
	var default_decoration := WorldDecoration.new()

	if decoration._flip_h != default_decoration._flip_h:
		output.merge({
			WorldDecorationsFromRaw.FLIP_H_KEY: decoration._flip_h
		})

	if decoration._flip_v != default_decoration._flip_v:
		output.merge({
			WorldDecorationsFromRaw.FLIP_V_KEY: decoration._flip_v
		})

	if decoration._position != default_decoration._position:
		var position_dict: Dictionary = {}
		if decoration._position.x != default_decoration._position.x:
			position_dict.merge({ "x": decoration._position.x })
		if decoration._position.y != default_decoration._position.y:
			position_dict.merge({ "y": decoration._position.y })
		output.merge({ WorldDecorationsFromRaw.POSITION_KEY: position_dict })

	if decoration._rotation_degrees != default_decoration._rotation_degrees:
		output.merge({
			WorldDecorationsFromRaw.ROTATION_KEY: decoration._rotation_degrees
		})

	if decoration._scale != default_decoration._scale:
		if decoration._scale.x == decoration._scale.y:
			output.merge({
				WorldDecorationsFromRaw.SCALE_KEY: decoration._scale.x
			})
		else:
			var scale_dict: Dictionary = {}
			if decoration._scale.x != default_decoration._scale.x:
				scale_dict.merge({ "x": decoration._scale.x })
			if decoration._scale.y != default_decoration._scale.y:
				scale_dict.merge({ "y": decoration._scale.y })
			output.merge({ WorldDecorationsFromRaw.SCALE_KEY: scale_dict })

	if decoration._color != default_decoration._color:
		output.merge({
			WorldDecorationsFromRaw.COLOR_KEY: decoration._color.to_html()
		})

	return output
