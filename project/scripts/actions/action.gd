class_name Action
## The base class for actions.
## This base class does nothing: use subclasses to create and use actions.
##
## Actions are the things players do that affect the game state.


## Each action has its own identifier.
## This is necessary for sending info between clients in online multiplayer.
enum {
	END_TURN = 0,
	ARMY_SPLIT = 1,
	ARMY_MOVEMENT = 2,
	BUILD = 3,
	RECRUITMENT = 4,
	DIPLOMACY = 5,
}


## Takes in the current game as well as the player trying to apply the action.
func apply_to(_game: Game, _player: GamePlayer) -> void:
	pass


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {}


## Returns an action built with given raw data.
## This may return null if an error occurs.
static func from_raw_data(data: Dictionary) -> Action:
	if not data.has("id"):
		push_error("Action data does not have an id.")
		return null
	
	match data["id"]:
		END_TURN:
			return ActionEndTurn.from_raw_data(data)
		ARMY_SPLIT:
			return ActionArmySplit.from_raw_data(data)
		ARMY_MOVEMENT:
			return ActionArmyMovement.from_raw_data(data)
		BUILD:
			return ActionBuild.from_raw_data(data)
		RECRUITMENT:
			return ActionRecruitment.from_raw_data(data)
		DIPLOMACY:
			return ActionDiplomacy.from_raw_data(data)
		_:
			push_error("Unrecognized action type.")
			return null
