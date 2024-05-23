class_name Action
## An abstract class for actions.
## Actions are the things players do that affect the game state.


enum {
	END_TURN = 0,
	ARMY_SPLIT = 1,
	ARMY_MOVEMENT = 2,
	BUILD = 3,
	RECRUITMENT = 4,
}


## Takes in the current game as well as the player trying to apply the action.
func apply_to(_game: Game, _player: GamePlayer) -> void:
	pass


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> Action:
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
		_:
			return null
