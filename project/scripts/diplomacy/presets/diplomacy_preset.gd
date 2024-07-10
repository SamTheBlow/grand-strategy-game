class_name DiplomacyPreset
extends Resource
## Describes a state for a relationship between two countries
## and the actions that can be performed to change it.


## This preset's unique id. All presets must have their own unique id.
@export var id: int = -1

## The name of this preset. This may be shown to the user.
@export var name: String = "None"

## The relationship data associated with this preset.
## The keys should be a String (see [DiplomacyRelationship]).
## The values may be anything depending on the key.
## Invalid settings will be ignored.
@export var settings: Dictionary = {}

## A list of all the diplomatic actions a country can perform
## with the other country while under this preset (passed by id).
@export var actions: Array[int] = []
