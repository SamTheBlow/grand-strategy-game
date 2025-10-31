class_name GamePopup
extends Control
## Class responsible for popups that may appear during a game.
##
## You set up this class by setting the "contents_node"
## property with a node of your choice.
##
## The given node may be any node. The node will be added to the scene
## and its contents will appear inside the popup.
##
## The popup may have buttons at the bottom.
## Those buttons will always close the popup when pressed,
## but you may also add custom behavior to each of them.
##
## To add buttons to the bottom of the popup,
## give your node a method "buttons" that returns an array of strings.
## Each string is the name of the button: it will appear on the button.
## If no buttons are provided, the popup will have a "OK" button by default.
##
## To know when a button is pressed,
## give your node a method "_on_button_pressed" that takes one int argument.
## That argument is the button's index in the list of buttons that you gave.
##
## In your node, you may add a signal named "invalidated" with no arguments.
## When emitted, the popup immediately closes with no effect.

var contents_node: Node

@onready var _contents_root := %Contents as Control
@onready var _popup_buttons := %Buttons as PopupButtons


func _ready() -> void:
	if contents_node == null:
		return

	_contents_root.add_child(contents_node)

	var button_names: Array[String] = ["OK"]

	const BUTTONS_METHOD_NAME: StringName = &"buttons"
	if contents_node.has_method(BUTTONS_METHOD_NAME):
		button_names = contents_node.call(BUTTONS_METHOD_NAME)

	_popup_buttons.setup_buttons(button_names)
	_popup_buttons.pressed.connect(_on_button_pressed)

	const BUTTON_PRESSED_METHOD_NAME: StringName = &"_on_button_pressed"
	if contents_node.has_method(BUTTON_PRESSED_METHOD_NAME):
		_popup_buttons.pressed.connect(
				Callable(contents_node, BUTTON_PRESSED_METHOD_NAME)
		)

	const INVALIDATED_SIGNAL_NAME: StringName = &"invalidated"
	if contents_node.has_signal(INVALIDATED_SIGNAL_NAME):
		contents_node.connect(INVALIDATED_SIGNAL_NAME, _on_popup_invalidated)


func _on_button_pressed(_button_id: int) -> void:
	# It's important to only delete the popup at the end of the frame,
	# so that the popup can still stop propagation of input during this frame.
	queue_free()


func _on_popup_invalidated() -> void:
	queue_free()
