class_name RecruitButton
extends Button
## Automatically disables itself when given player
## is unable to recruit armies in given province.
## (Or if given data is null.)
##
## See also: [BuildFortressButton], [ComponentUI]

## May be null.
var game: Game = null:
	set(value):
		if game == value:
			return
		game = value
		_setup_recruitment_limits()
		_update_is_disabled()

## May be null.
var province: Province = null:
	set(value):
		if province == value:
			return
		province = value
		_setup_recruitment_limits()
		_update_is_disabled()

## May be null.
var player: GamePlayer = null:
	set(value):
		if player == value:
			return

		# Disconnect signals
		if player != null:
			player.playing_country_changed.disconnect(
					_on_playing_country_changed
			)

		player = value

		# Connect signals
		if player != null:
			player.playing_country_changed.connect(
					_on_playing_country_changed
			)

		_setup_recruitment_limits()
		_update_is_disabled()

## May be null.
var _army_recruit_limits: ArmyRecruitmentLimits = null:
	set(value):
		if _army_recruit_limits == value:
			return

		# Disconnect signals
		if _army_recruit_limits != null:
			_army_recruit_limits.maximum_changed.disconnect(
					_on_army_maximum_changed
			)

		_army_recruit_limits = value

		# Connect signals
		if _army_recruit_limits != null:
			_army_recruit_limits.maximum_changed.connect(
					_on_army_maximum_changed
			)


func _ready() -> void:
	_update_is_disabled()


func _setup_recruitment_limits() -> void:
	if (
			game == null
			or province == null
			or player == null
			or player.playing_country == null
	):
		_army_recruit_limits = null
		return

	_army_recruit_limits = (
			ArmyRecruitmentLimits.new(game, player.playing_country, province)
	)


func _update_is_disabled() -> void:
	if not is_node_ready():
		return

	disabled = (
			_army_recruit_limits == null
			or not MultiplayerUtils.has_gameplay_authority(multiplayer, player)
			or _army_recruit_limits.maximum()
			< game.rules.minimum_army_size.value
	)


func _on_army_maximum_changed(_new_maximum: int) -> void:
	_update_is_disabled()


func _on_playing_country_changed() -> void:
	_setup_recruitment_limits()
