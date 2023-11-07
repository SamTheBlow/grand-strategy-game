class_name ProvinceShapeFromVertices
extends ProvinceShape
## [Immutable]
## Defines a province shape using a system of vertices.
## Each vertex has a position on the world map.


var _vertices_x: PackedInt32Array
var _vertices_y: PackedInt32Array


## The size of both arrays must be the same.
## Values in the arrays must all be positive or zero.
func _init(vertices_x: PackedInt32Array, vertices_y: PackedInt32Array) -> void:
	_vertices_x = vertices_x
	_vertices_y = vertices_y
