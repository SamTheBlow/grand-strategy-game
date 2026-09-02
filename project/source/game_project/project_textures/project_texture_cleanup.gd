class_name ProjectTextureCleanup
extends Node
## Ensures that unused textures don't stay in a project.

## Maps each texture id to its number of occurences.
var _use_count: Dictionary[int, int] = {}


func connect_project(project: GameProject) -> void:
	_use_count.clear()

	# Army textures
	for army in project.game.world.armies.list():
		_on_army_added(army, project)
	project.game.world.armies.added.connect(_on_army_added.bind(project))
	project.game.world.armies.removed.connect(_on_army_removed.bind(project))

	# World decoration textures
	for decoration in project.game.world.decorations.list():
		_on_decoration_added(decoration, project)
	project.game.world.decorations.added.connect(
			_on_decoration_added.bind(project)
	)
	project.game.world.decorations.removed.connect(
			_on_decoration_removed.bind(project)
	)

	# Fortress texture
	_register_texture(project, project.game.world.fortress_data().texture)
	project.game.world.fortress_data().texture_changed.connect(
			_on_texture_changed.bind(project)
	)

	# Project icon
	_register_texture(project, project.metadata.icon)
	project.metadata.icon_changed.connect(_on_texture_changed.bind(project))


func _on_army_added(army: Army, project: GameProject) -> void:
	_register_texture(project, army.texture)
	army.texture_changed.connect(_on_texture_changed.bind(project))


func _on_army_removed(army: Army, project: GameProject) -> void:
	army.texture_changed.disconnect(_on_texture_changed)
	_unregister_texture(project, army.texture)


func _on_decoration_added(
		decoration: WorldDecoration, project: GameProject
) -> void:
	_register_texture(project, decoration.texture)
	decoration.texture_changed.connect(_on_texture_changed.bind(project))


func _on_decoration_removed(
		decoration: WorldDecoration, project: GameProject
) -> void:
	decoration.texture_changed.disconnect(_on_texture_changed)
	_unregister_texture(project, decoration.texture)


func _on_texture_changed(
		old_texture: ProjectTexture,
		new_texture: ProjectTexture,
		project: GameProject
) -> void:
	_unregister_texture(project, old_texture)
	_register_texture(project, new_texture)


func _register_texture(
		project: GameProject, project_texture: ProjectTexture
) -> void:
	# Get id
	var raw_data: Variant = project_texture.to_raw_data()
	var id: int = raw_data if raw_data is int else -1
	if id < 0:
		return

	if _use_count.has(id):
		_use_count[id] += 1
	else:
		_use_count[id] = 1

	project.textures.restore_freed(id)


func _unregister_texture(
		project: GameProject, project_texture: ProjectTexture
) -> void:
	# Get id
	var raw_data: Variant = project_texture.to_raw_data()
	var id: int = raw_data if raw_data is int else -1
	if id < 0:
		return

	_use_count[id] -= 1

	# Don't free if the texture is still used elsewhere
	if _use_count[id] > 0:
		return

	project.textures.free_external_texture(id)
