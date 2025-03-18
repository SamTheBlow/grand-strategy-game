class_name GameSettings
## Information about a [GameProject] that has no effect on the game's
## internal logic, but still affects the user experience (e.g. visuals).

var world_limits := WorldLimits.new()

var custom_settings: Dictionary


func to_dict() -> Dictionary:
	return custom_settings
