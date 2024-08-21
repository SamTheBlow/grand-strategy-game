class_name RecruitButton
extends Button
## Automatically disables itself when given player
## is unable to recruit armies in given province.
## Also disables itself if either the province or the player is null.
##
## See also: [BuildFortressButton], [ComponentUI]


var province: Province:
	set(value):
		if province == value:
			return
		province = value
		_setup_recruitment_limits()
		_refresh_is_disabled()

var player: GamePlayer:
	set(value):
		if player == value:
			return
		player = value
		_setup_recruitment_limits()
		_refresh_is_disabled()

var _army_recruit_limits: ArmyRecruitmentLimits:
	set(value):
		if _army_recruit_limits == value:
			return
		_disconnect_signals()
		_army_recruit_limits = value
		_connect_signals()


func _ready() -> void:
	_refresh_is_disabled()


func _setup_recruitment_limits() -> void:
	if not province or not player:
		_army_recruit_limits = null
		return
	
	_army_recruit_limits = (
			ArmyRecruitmentLimits.new(player.playing_country, province)
	)


func _refresh_is_disabled() -> void:
	if not is_node_ready():
		return
	
	if not province or not player or not _army_recruit_limits:
		disabled = true
		return
	
	disabled = not (
			MultiplayerUtils.has_gameplay_authority(multiplayer, player)
			and _army_recruit_limits.maximum()
			>= province.game.rules.minimum_army_size.value
	)


func _connect_signals() -> void:
	if not _army_recruit_limits:
		return
	
	if not (
			_army_recruit_limits.maximum_changed
			.is_connected(_on_army_maximum_changed)
	):
		_army_recruit_limits.maximum_changed.connect(_on_army_maximum_changed)


func _disconnect_signals() -> void:
	if not _army_recruit_limits:
		return
	
	if (
			_army_recruit_limits.maximum_changed
			.is_connected(_on_army_maximum_changed)
	):
		_army_recruit_limits.maximum_changed.disconnect(
				_on_army_maximum_changed
		)


func _on_army_maximum_changed(_new_maximum: int) -> void:
	_refresh_is_disabled()
