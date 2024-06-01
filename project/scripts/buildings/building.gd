class_name Building
extends Node
## Abstract class.
## A building is usually, but not always, associated with a [Province].
## There may or may not be more than one building
## of the same type in a province.
## It may or may not have effects on the gameplay,
## and it may or may not be visible on the world map.


enum Type {
	NONE = 0,
	FORTRESS = 1,
}


## For the purposes of saving/loading.
func type() -> Type:
	if self is Fortress:
		return Type.FORTRESS
	return Type.NONE
