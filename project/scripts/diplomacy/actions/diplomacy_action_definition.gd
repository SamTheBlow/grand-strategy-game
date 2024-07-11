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
