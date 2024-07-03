class_name DiplomacyAction
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
## The relationship's preset will change to this one.
## Has no effect if the preset is not registered in the [GameRules].
@export var outcome_preset: DiplomacyPreset = DiplomacyPreset.new()
## Add changes to the relationship here (see [DiplomacyRelationship]).
@export var outcome_data: Dictionary = {}
