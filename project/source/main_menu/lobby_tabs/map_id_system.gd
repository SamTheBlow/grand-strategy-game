class_name MapIdSystem
extends Node
## Takes note of which ids are already in use.
## When you want to add a new map to the list, simply refer to this class
## to obtain a new unique id for your map.


var _counter: int = -1


func new_unique_id() -> int:
	_counter += 1
	return _counter
