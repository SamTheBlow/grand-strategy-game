class_name ActionArmyMovement
extends Action
## Moves a given [Army] to a given [Province].

const ARMY_ID_KEY: String = "army_id"
const DEST_PROVINCE_ID_KEY: String = "destination_province_id"

var _army_id: int
var _destination_province_id: int


func _init(army_id: int, destination_province_id: int) -> void:
	_army_id = army_id
	_destination_province_id = destination_province_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var army: Army = game.world.armies.army_from_id(_army_id)
	if not army:
		# Note that this may sometimes be triggered by
		# the AI making invalid moves. (See [AIDecisionUtils])

		push_warning("Tried to move an army that doesn't exist!")
		return

	if army.owner_country != player.playing_country:
		push_warning(
				"Tried to move an army, "
				+ "but the army is not under the player's control!"
		)
		return

	var destination_province: Province = (
			game.world.provinces.province_from_id(_destination_province_id)
	)
	if not destination_province:
		push_warning(
				"Tried to move an army to a province that doesn't exist!"
		)
		return

	if not army.is_able_to_move():
		push_warning(
				"Tried to move an army, "
				+ "but that army is currently unable to move!"
		)
		return

	if not army.can_move_to(destination_province):
		# Note that the reason why this is commented out is because
		# the AI still makes many invalid moves. (See [AIDecisionUtils])

		#push_warning("Tried to move an army to an invalid destination!")
		return

	army.move_to_province(destination_province)


func raw_data() -> Dictionary:
	return {
		ID_KEY: ARMY_MOVEMENT,
		ARMY_ID_KEY: _army_id,
		DEST_PROVINCE_ID_KEY: _destination_province_id,
	}


static func from_raw_data(data: Dictionary) -> ActionArmyMovement:
	if not (
			ParseUtils.dictionary_has_number(data, ARMY_ID_KEY)
			and ParseUtils.dictionary_has_number(data, DEST_PROVINCE_ID_KEY)
	):
		return null

	return ActionArmyMovement.new(
			ParseUtils.dictionary_int(data, ARMY_ID_KEY),
			ParseUtils.dictionary_int(data, DEST_PROVINCE_ID_KEY)
	)
