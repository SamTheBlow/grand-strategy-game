class_name NodeUtils
## Provides general utility functions that are not already built-in.


## Removes, but does not delete, all of given node's children.
static func remove_all_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)


## Removes and deletes all of given node's children.
static func delete_all_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## Removes from the scene tree, but does not delete, all given nodes.
static func remove_nodes(nodes: Array) -> void:
	for node: Node in nodes:
		if node.get_parent() != null:
			node.get_parent().remove_child(node)


# NOTE: it would be great if we could made the argument an Array[Node],
# but then the function crashes when you give it an Array[Node2D] for example.
## Removes from the scene tree and deletes all given nodes.
static func delete_nodes(nodes: Array) -> void:
	for node: Node in nodes:
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.queue_free()


## Removes from the scene tree and deletes given node.
static func delete_node(node: Node) -> void:
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.queue_free()
