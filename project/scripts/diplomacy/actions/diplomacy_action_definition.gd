class_name DiplomacyActionDefinition
extends Resource
## Data structure representing something that a [Country] can do to
## change their relationship with another country.
##
## See also: [DiplomacyRelationship]


## This action's unique id. All diplomacy actions must have a unique id,
## for the purposes of saving/loading/syncing.
@export var id: int = -1

## The actions's name. May be shown to the user. It doesn't have to be unique.
@export var name: String = ""

@export_group("Conditions")
## If true, this action will only be performed
## when the other country gives consent.
@export var requires_consent: bool = false
## From the moment this action becomes available to the country,
## it cannot be used until this many turns have passed.
@export var available_after_turns: int = 0

@export_group("Outcome")
## Add changes to the relationship here (see [DiplomacyRelationship]).
## Affects the source country's relationship with the target country.
@export var your_outcome_data: Dictionary = {}
## Add changes to the relationship here (see [DiplomacyRelationship]).
## Affects the target country's relationship with the source country.
@export var their_outcome_data: Dictionary = {}


## Leave creation_turn negative if you don't know/care.
func new_notification(
		game: Game,
		relationship: DiplomacyRelationship,
		reverse_relationship: DiplomacyRelationship,
		creation_turn: int = -1
) -> GameNotification:
	var apply_function: Callable = (
			func() -> void:
				apply_action_data(
						relationship,
						reverse_relationship,
						game.turn.current_turn()
				)
	)
	
	var output_notification: GameNotification
	
	if creation_turn < 0:
		output_notification = GameNotification.new(
				game,
				relationship.source_country,
				relationship.recipient_country,
				["Accept", "Decline"],
				[apply_function, func() -> void: pass]
		)
	
	output_notification = GameNotification.new(
			game,
			relationship.source_country,
			relationship.recipient_country,
			["Accept", "Decline"],
			[apply_function, func() -> void: pass],
			creation_turn
	)
	
	# TODO bad code
	output_notification._diplomacy_action_definition = self
	return output_notification


func apply_action_data(
		relationship: DiplomacyRelationship,
		reverse_relationship: DiplomacyRelationship,
		current_turn: int
) -> void:
	relationship.apply_action_data(your_outcome_data, current_turn)
	reverse_relationship.apply_action_data(their_outcome_data, current_turn)
