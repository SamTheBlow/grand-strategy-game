@tool
class_name CircleButtons
extends ListContainer

## Hides itself when the mouse is not inside given node.
@export var _visibility_container: Control

## When true, this node stays visible at all times.
var always_show: bool = false:
	set(value):
		always_show = value
		_refresh_visibility()

var _is_button_pressed: bool = false


func _ready() -> void:
	super()

	if _visibility_container == null:
		set_process(false)
		return

	_refresh_visibility()

	_visibility_container.mouse_entered.connect(_refresh_visibility)

	for child in get_children():
		if child is not BaseButton:
			continue
		var child_button := child as BaseButton
		child_button.button_down.connect(_on_button_down)
		child_button.button_up.connect(_on_button_up)
		child_button.mouse_entered.connect(_refresh_visibility)


func _process(_delta: float) -> void:
	# Refresh every frame while this node is visible
	# so that we always catch when the mouse exits the container
	# (the mouse_exited signal is unreliable when cursor is moving very fast)
	_refresh_visibility()


func _refresh_visibility() -> void:
	visible = (
			always_show
			or _is_button_pressed
			or (
					_visibility_container.get_global_rect()
					.has_point(get_global_mouse_position())
			)
	)
	set_process(visible)


func _on_button_down() -> void:
	_is_button_pressed = true
	_refresh_visibility()


func _on_button_up() -> void:
	_is_button_pressed = false
	_refresh_visibility()
