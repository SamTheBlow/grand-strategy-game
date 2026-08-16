class_name BuildFortressButton
extends ProvinceActionButton

## May be null.
var _conditions: FortressBuildConditions = null:
	set(value):
		if _conditions == value:
			return

		if _conditions != null:
			_conditions.can_build_changed.disconnect(_refresh_disabled)

		_conditions = value
		if is_node_ready():
			_refresh_disabled()

		if _conditions != null:
			_conditions.can_build_changed.connect(_refresh_disabled.unbind(1))


func _refresh_conditions() -> void:
	if (
			game == null
			or province == null
			or player == null
			or player.playing_country == null
	):
		_conditions = null
		return

	_conditions = (
			FortressBuildConditions.new(player.playing_country, province, game)
	)


func _can_perform_action() -> bool:
	return _conditions != null and _conditions.can_build()
