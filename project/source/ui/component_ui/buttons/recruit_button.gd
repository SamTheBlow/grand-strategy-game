class_name RecruitButton
extends ProvinceActionButton

## May be null.
var _limits: ArmyRecruitmentLimits = null:
	set(value):
		if _limits == value:
			return

		if _limits != null:
			_limits.maximum_changed.disconnect(_refresh_disabled)

		_limits = value
		if is_node_ready():
			_refresh_disabled()

		if _limits != null:
			_limits.maximum_changed.connect(_refresh_disabled.unbind(1))


func _refresh_conditions() -> void:
	if (
			game == null
			or province == null
			or player == null
			or player.playing_country == null
	):
		_limits = null
		return

	_limits = (
			ArmyRecruitmentLimits.new(game, player.playing_country, province)
	)


func _can_perform_action() -> bool:
	return (
			_limits != null
			and _limits.maximum() >= game.world.army_data.minimum_size
	)
