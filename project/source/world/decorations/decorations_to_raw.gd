class_name WorldDecorationsToRaw
## Converts [WorldDecoration]s into raw data.
##
## See also: [WorldDecorationsFromRaw]


## Always succeeds.
static func result(world_decorations: WorldDecorations) -> Array:
	var output: Array = []

	for world_decoration in world_decorations.list():
		output.append(_decoration_raw_dict(world_decoration))

	return output


## Always succeeds.
static func _decoration_raw_dict(decoration: WorldDecoration) -> Dictionary:
	var output: Dictionary = {
		WorldDecorationsFromRaw.TEXTURE_KEY: decoration.texture_file_path
	}

	# We use an empty decoration to check for default values
	var default_decoration := WorldDecoration.new()

	if decoration.flip_h != default_decoration.flip_h:
		output.merge({
			WorldDecorationsFromRaw.FLIP_H_KEY: decoration.flip_h
		})

	if decoration.flip_v != default_decoration.flip_v:
		output.merge({
			WorldDecorationsFromRaw.FLIP_V_KEY: decoration.flip_v
		})

	if decoration.position != default_decoration.position:
		var position_dict: Dictionary = {}
		if decoration.position.x != default_decoration.position.x:
			position_dict.merge({ "x": decoration.position.x })
		if decoration.position.y != default_decoration.position.y:
			position_dict.merge({ "y": decoration.position.y })
		output.merge({ WorldDecorationsFromRaw.POSITION_KEY: position_dict })

	if decoration.rotation_degrees != default_decoration.rotation_degrees:
		output.merge({
			WorldDecorationsFromRaw.ROTATION_KEY: decoration.rotation_degrees
		})

	if decoration.scale != default_decoration.scale:
		if decoration.scale.x == decoration.scale.y:
			output.merge({
				WorldDecorationsFromRaw.SCALE_KEY: decoration.scale.x
			})
		else:
			var scale_dict: Dictionary = {}
			if decoration.scale.x != default_decoration.scale.x:
				scale_dict.merge({ "x": decoration.scale.x })
			if decoration.scale.y != default_decoration.scale.y:
				scale_dict.merge({ "y": decoration.scale.y })
			output.merge({ WorldDecorationsFromRaw.SCALE_KEY: scale_dict })

	if decoration.color != default_decoration.color:
		output.merge({
			WorldDecorationsFromRaw.COLOR_KEY: decoration.color.to_html()
		})

	return output
