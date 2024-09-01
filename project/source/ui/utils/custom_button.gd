extends Button
## Utility class.
## Provides signals for when left click or right click
## is just pressed/released on the button.
## Also grabs focus when right clicked, if enabled.
##
## Source: https://stackoverflow.com/questions/66090893/how-can-i-extend-godots-button-to-distinguish-left-click-vs-right-click-events


signal left_click_just_pressed()
signal right_click_just_pressed()
signal left_click_just_released()
signal right_click_just_released()

## If true, this button grabs focus when right clicked.
@export var grab_focus_on_right_click: bool = false


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	if not get_global_rect().has_point(get_global_mouse_position()):
		return
	
	var event_mouse_button := event as InputEventMouseButton
	match event_mouse_button.button_index:
		MOUSE_BUTTON_LEFT:
			if event_mouse_button.pressed:
				left_click_just_pressed.emit()
			else:
				left_click_just_released.emit()
		MOUSE_BUTTON_RIGHT:
			if event_mouse_button.pressed:
				if grab_focus_on_right_click:
					grab_focus()
				
				right_click_just_pressed.emit()
			else:
				right_click_just_released.emit()
