@abstract
class_name Action
## Base class for things players do that affect the game state.

enum {
	END_TURN = 0,
	ARMY_SPLIT = 1,
	ARMY_MOVEMENT = 2,
	BUILD = 3,
	RECRUITMENT = 4,
	DIPLOMACY = 5,
	HANDLE_NOTIFICATION = 6,
	ADVANCE_RNG = 7,
}

const _ID_KEY: String = "id"


@abstract func apply_to(_game: Game, _player: GamePlayer) -> void


## Used to transfer data between network clients.
@abstract func to_raw_dict() -> Dictionary


## Returns a new instance using given raw data.
## May return null.
static func from_raw_dict(raw_dict: Dictionary) -> Action:
	if not raw_dict.has(_ID_KEY):
		push_error("Action data does not have an id.")
		return null

	match raw_dict[_ID_KEY]:
		END_TURN:
			return ActionEndTurn.from_raw_dict(raw_dict)
		ARMY_SPLIT:
			return ActionArmySplit.from_raw_dict(raw_dict)
		ARMY_MOVEMENT:
			return ActionArmyMovement.from_raw_dict(raw_dict)
		BUILD:
			return ActionBuild.from_raw_dict(raw_dict)
		RECRUITMENT:
			return ActionRecruitment.from_raw_dict(raw_dict)
		DIPLOMACY:
			return ActionDiplomacy.from_raw_dict(raw_dict)
		HANDLE_NOTIFICATION:
			return ActionHandleNotification.from_raw_dict(raw_dict)
		ADVANCE_RNG:
			return ActionAdvanceRNG.from_raw_dict(raw_dict)
		_:
			push_error("Unrecognized action type.")
			return null
