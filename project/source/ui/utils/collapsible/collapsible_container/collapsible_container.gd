class_name CollapsibleContainer
extends Control
## [url=https://github.com/ArshvirGoraya/Godot-Collapsible-Container]
## CollapsibleContainer[/url]:
## a control node capable of hiding and revealing its children
## by folding and unfolding. The folding can be done with or without
## tweening and can be previewed in the editor.
# Note:
# The code's style was modified to suit this project.
# Some code was removed, notably, code for using this script in the editor.
# Some code was also adjusted to work better with [ScrollContainer]s.

## Emitted when [member _opened_state] is set to any of the values in the
## [enum OpenedStates] enum. It lets you know the current and previous state.
signal state_set(
		current_state: CollapsibleContainer.OpenedStates,
		previous_state: CollapsibleContainer.OpenedStates
)

# Does not emit if previous tween was an AUTO tween
# ([constant AUTO_TWEENING_OPEN] or [constant AUTO_TWEENING_CLOSE])
# and current tween is also AUTO
# ([constant AUTO_TWEENING_OPEN] or [constant AUTO_TWEENING_CLOSE])
# as this is seen as a single AUTO tween.
## Emitted when tweening has started.
signal tween_started(current_tween_state: CollapsibleContainer.TweenStates)

## Emitted when tweening has completed (i.e., when [member _tween_state] is
## set to [constant NOT_TWEENING])
signal tween_completed(previous_tween_state: CollapsibleContainer.TweenStates)

## Emitted during tweening.
## [br][b]normalized_progress[/b]: where 0.0 is no progress and 1.0 is complete.
## [br][b]time_left[/b]: time until the tween ends in seconds.
## [br][b]Note:[/b] unlike the other signals, this also emits in the editor and
## not just in game. This allows other tool scripts to know how far the
## node has progressed when previewing in the editor.
signal tweening_amount_changed(
		current_size: Vector2, normalized_progress: float, time_left: float
)

## Emitted when tweening is interrupted usually by a change in
## [member _opened_state] or [member _tween_state].
## Gives all information of what tween was running and the current states.
signal tween_interrupted(
		previous_tween_state: CollapsibleContainer.TweenStates,
		current_tween_state: CollapsibleContainer.TweenStates,
		current_opened_state: CollapsibleContainer.OpenedStates
)

## Options used by [member sizing_constraint].
enum SizingConstraintOptions {
	## Change both width and height when (un)folding.
	BOTH,
	## Change only width when (un)folding.
	ONLY_HEIGHT,
	## Change only height when (un)folding.
	ONLY_WIDTH,
}

# Option used by [member _preview_auto_update_size]
## Options used by [member auto_update_size]
enum AutoUpdateSizeOptions {
	## Disables AUTO sizing.
	DISABLED,
	## Automatically tweens to the full open
	## or full close size if the size changes.
	WITH_TWEEN,
	## Automatically sets to the full open
	## or full close size if the size changes.
	WITHOUT_TWEEN,
}

## States used by [member _opened_state].
enum OpenedStates {
	## Node is opened.
	OPENED,
	## Node is closed.
	CLOSED,
	## Node sized to a forced value.
	## See, [method force_size] or [method force_tween].
	FORCE_SIZED,
	## Node is automatically setting to a new open size.
	## Can precede [constant AUTO_TWEENING_OPEN]
	## and [constant AUTO_TWEENING_CLOSE].
	UPDATING_OPENED,
	## Node's size is not set to the full open size
	## (e.g., when auto sizing is disabled).
	NOT_FULLY_OPENED,
	## Node is tweening.
	TWEENING,
}

## States used by [member _tween_state].
enum TweenStates {
	## Node is tweening to the open size.
	OPENING,
	## Node is tweening to the close size.
	CLOSING,
	## Node is forcibly tweening to a size.
	FORCE_TWEENING,
	## Node is AUTO tweening to the open size.
	AUTO_TWEENING_OPEN,
	## Node is AUTO tweening to the close size.
	AUTO_TWEENING_CLOSE,
	## Node is not tweening.
	NOT_TWEENING,
}

## States used by [member folding_direction_preset]
enum FoldingPreset {
	PRESET_TOP_LEFT,
	PRESET_TOP_RIGHT,
	PRESET_BOTTOM_LEFT,

	PRESET_BOTTOM_RIGHT,
	PRESET_CENTER_LEFT,
	PRESET_CENTER_TOP,

	PRESET_CENTER_RIGHT,
	PRESET_CENTER_BOTTOM,
	PRESET_CENTER,

	PRESET_LEFT_WIDE,
	PRESET_TOP_WIDE,
	PRESET_RIGHT_WIDE,
	PRESET_BOTTOM_WIDE,

	PRESET_VCENTER_WIDE,
	PRESET_HCENTER_WIDE,

	UNDEFINED,
}

## Determines if starts opened/closed in game.
@export var starts_opened: bool = false

## Automatically sets [member Control.clip_contents] to true/false
## when node is loaded in editor or in game.
@export var start_with_clip_contents: bool = true:
	set = set_start_with_clip_contents, get = get_start_with_clip_contents

# Uses _folding_direction_preset as a
# private variable to avoid infinite recursion.
## Sets the [member sizing_constraint], [member Control.size_flags_vertical]
## and [member Control.size_flags_horizontal]
## in order to quickly set the folding direction.
@export var folding_direction_preset := FoldingPreset.PRESET_TOP_LEFT:
	set(value):
		_folding_direction_preset = value
		set_folding_direction_preset(_folding_direction_preset)
	get:
		return _folding_direction_preset

## Controls which direction the collapsible can folds/unfold.
@export var sizing_constraint := SizingConstraintOptions.BOTH:
	set = set_sizing_constraint, get = get_sizing_constraint

# Separate from [member _preview_auto_update_size] which controls
# preview auto sizing, not in-game auto sizing.
## Option to update the size automatically to the opened size value or the
## closed size value when they change. For example, if opened, and
## open size changes, the node will size itself to that new open size.
## [br][br][b]Note[/b]: If already tweening and a new open size is detected,
## this will interrupt the current tween (with a warning) if the tween's
## target size is different from the new, auto-detected size change.
@export var auto_update_size := AutoUpdateSizeOptions.WITHOUT_TWEEN:
	set = set_auto_update_size, get = get_auto_update_size

## Node whose size will be used to set the "open size."
## Must point to a [Control] node or any that inherit from it.
## An alternative to [member custom_open_size] and [member custom_close_size]
## [br][br][b]Note[/b]: ignored if using [member custom_open_size].
@export_node_path("Control") var sizing_node: NodePath:
	set = set_sizing_node_path, get = get_sizing_node_path

@export_group("Sizing")
## Enables using [member custom_open_size].
@export var use_custom_open_size := false:
	set = set_use_custom_open_size, get = get_use_custom_open_size

# Appears in inspector if [member use_custom_open_size] is true.
## Used as an alternative to [member sizing_node]'s size to set the "open size."
@export var custom_open_size := Vector2(0,0):
	set = set_custom_open_size, get = get_custom_open_size

## Enables using [member custom_open_size].
@export var use_custom_close_size := false:
	set = set_use_custom_close_size, get = get_use_custom_close_size

# Appears in inspector if [member use_custom_close_size].
## Used as an alternative to the default [constant Vector2.ZERO]
## to set the "close size."
@export var custom_close_size := Vector2(0, 0):
	set = set_custom_close_size, get = get_custom_close_size

@export_group("Tween Settings", "tween_")
## If true: runs tween in [method Node._physics_process]
## instead of [method Node._process].
@export var tween_in_physics_process := false

## Sets the duration of the tween in seconds.
@export_range(0.1, 1.0, 0.01, "or_greater") var tween_duration_sec := 0.5

## Sets the tween's transition type.
@export var tween_transition_type := Tween.TRANS_SINE

## Sets the tween's ease type. Does nothing if
## [member tween_transition_type] is set to [constant Tween.TRANS_LINEAR].
@export var tween_ease_type := Tween.EASE_OUT

@export_group("Process")
## Sets the [member Node.process_mode] when entering game.
@export var starts_with_process_mode: ProcessMode = PROCESS_MODE_INHERIT:
	set(value):
		starts_with_process_mode = value
		process_mode = starts_with_process_mode

## The current opened state (see [enum OpenedStates]).
var _opened_state := OpenedStates.OPENED

## The current tween state (see [enum TweenStates]).
var _tween_state := TweenStates.NOT_TWEENING

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# How much time has elapsed in the current tween.
var _tween_elapsed_time := 0.0

# Calculated inside of [member _increment_tween].
# Emitted on each [member _emit_tween_amount_changed]
# Used by [signal tweening_amount_changed]
var _tween_time_left := 0.0

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# What the initial size value was before tween.
var _tween_initial_value := Vector2.ZERO

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# The delta value used in [method Tween.interpolate_value].
var _tween_delta_value := Vector2.ZERO

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# The size the tween is tweening towards.
var _tween_final_value := Vector2.ZERO

# Using private variable with [member folding_direction_preset]
# to avoid infinite recursion. [folding_direction_preset] sets flags
# and sizing_constraint, which, themselves set [_folding_direction_preset].
# If they were to set [folding_direction_preset] instead,
# there would be an infinite recursion.
var _folding_direction_preset := FoldingPreset.PRESET_TOP_LEFT:
	set(value):
		if value == _folding_direction_preset:
			return

		_folding_direction_preset = value
		_update_inspector()


func _init() -> void:
	process_mode = starts_with_process_mode
	minimum_size_changed.connect(_emit_tween_amount_changed)
	set_clip_contents(start_with_clip_contents)
	size_flags_changed.connect(_update_folding_direction)


func _ready() -> void:
	# If starts_opened: open. If not starts_opened: close
	# Does/should not emit any signals.
	# Just sets the appropriate states and size.
	# If size can't be acquired (i.e., [member sizing_node] is null),
	# prints an error.
	var start_open_or_closed: Callable = func() -> void:
		if starts_opened:
			var target_size: Vector2OrNull = get_opened_size_or_null()
			if target_size == null:
				_print_warning("can't start opened: sizing_node is null.")
			else:
				_opened_state = OpenedStates.OPENED
				_tween_state = TweenStates.NOT_TWEENING
				_set_to_size(target_size.value)
		else:
			var target_size: Vector2OrNull = get_closed_size_or_null()
			if target_size == null:
				_print_warning("can't start closed: sizing_node is null.")
			else:
				_opened_state = OpenedStates.CLOSED
				_tween_state = TweenStates.NOT_TWEENING
				_set_to_size(target_size.value)

	# Must use call_deferred or sizing_node is seen as null when it isn't.
	start_open_or_closed.call_deferred()


## Calls [method _increment_tween] when tweening if
## [member tween_in_physics_process] is false.
func _process(delta: float) -> void:
	if not tween_in_physics_process and is_tweening():
		_increment_tween(delta)


## Calls [method _increment_tween] when tweening if
## [member tween_in_physics_process] is true.
func _physics_process(delta: float) -> void:
	if tween_in_physics_process and is_tweening():
		_increment_tween(delta)


## A warning that shows on the node in the editor's scene tree
## given that the condition is true:
## if sizing_node is set to nothing and not using open or closed size.
func _get_configuration_warnings() -> PackedStringArray:
	if (
			sizing_node == NodePath("")
			and (not use_custom_open_size or not use_custom_close_size)
	):
		return ["A sizing_node or the custom_open and custom_close values must \
				be assigned for CollapsibleContainer to open/close as intended.
				In the inspector, please assign sizing_node (a Control or \
				anything that inherits from Control) or use the custom \
				open/close sizing options."]
	return []


## Returns the current [member _opened_state] value.
func get_opened_state() -> OpenedStates:
	return _opened_state


## Returns the current [member _tween_state] value.
func get_tween_state() -> TweenStates:
	return _tween_state


## Returns the current [member sizing_node] value.
func get_sizing_node_path() -> NodePath:
	return sizing_node


## Calculates and returns what the
## [member folding_direction_preset] is currently set to.
func get_folding_direction_preset() -> FoldingPreset:
	var folding_direction: FoldingPreset
	var sizing_constraint_match: bool = false

	var container_sizing_flags: Array[SizeFlags] = [
			get_v_size_flags() as SizeFlags,
			get_h_size_flags() as SizeFlags
	]

	match container_sizing_flags:
		# Tops
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_TOP_LEFT
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER_TOP
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_TOP_RIGHT

		# Centers
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_CENTER_LEFT
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_CENTER_RIGHT

		# Bottoms
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_LEFT
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER_BOTTOM
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_RIGHT

		# Side Wides:
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_LEFT_WIDE
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_RIGHT_WIDE
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_EXPAND_FILL]:
			folding_direction = FoldingPreset.PRESET_TOP_WIDE
		[Control.SIZE_SHRINK_END, Control.SIZE_EXPAND_FILL]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_WIDE

		# Center Wides:
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_VCENTER_WIDE
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_EXPAND_FILL]:
			folding_direction = FoldingPreset.PRESET_HCENTER_WIDE

	# Check if sizing_constraint is matching. Set from false to true if it is.
	match folding_direction:
		FoldingPreset.PRESET_LEFT_WIDE, FoldingPreset.PRESET_RIGHT_WIDE, FoldingPreset.PRESET_VCENTER_WIDE:
			if sizing_constraint == SizingConstraintOptions.ONLY_WIDTH:
				sizing_constraint_match = true
		FoldingPreset.PRESET_TOP_WIDE, FoldingPreset.PRESET_BOTTOM_WIDE, FoldingPreset.PRESET_HCENTER_WIDE:
			if sizing_constraint == SizingConstraintOptions.ONLY_HEIGHT:
				sizing_constraint_match = true
		_:
			if sizing_constraint == SizingConstraintOptions.BOTH:
				sizing_constraint_match = true

	if not sizing_constraint_match:
		folding_direction = FoldingPreset.UNDEFINED

	return folding_direction


## Uses [enum FoldingPreset] to set the [member Control.size_flags_vertical]
## and [member Control.size_flags_horizontal].
## For some folding presets a parent container may be required. In these cases,
## if called when there is no [Container] as a parent, it will print an error
## and do nothing.
## [br][br]Presets that [b]do not[/b] require a parent container:
## [constant PRESET_TOP_LEFT],
## [constant PRESET_TOP_WIDE], [constant PRESET_LEFT_WIDE]
## [br][br][param change_sizing_constraint]: sets [member sizing_constraint]
## based on the direction.
## If the layout is filled in one direction, the [member sizing_constraint]
## will constrain that direction.
## For example, if it is set to PRESET_LEFT_WIDE where the vertical
## is completely filled, [member sizing_constraint] is set to
## [constant ONLY_HEIGHT]. Hence, only the needed direction will open/close.
func set_folding_direction_preset(
		direction: FoldingPreset, change_sizing_constraint: bool = true
) -> void:
	if not is_node_ready():
		return

	if direction == FoldingPreset.UNDEFINED:
		return

	# If not parent container,
	# return if selected direction requires a parent container.
	if not _has_parent_container():
		if (
				not direction == Control.PRESET_TOP_LEFT
				and not direction == Control.PRESET_TOP_WIDE
				and not direction == Control.PRESET_LEFT_WIDE
		):
			_print_error(
					"cannot SET folding_direction_preset to "
					+ str(FoldingPreset.keys()[direction])
					+ ": parent is not Container"
			)
			return

	match direction:
		Control.PRESET_TOP_LEFT:
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) #top
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER_TOP:
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_TOP_RIGHT:
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_SHRINK_END) # right

		Control.PRESET_CENTER_LEFT:
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER, Control.PRESET_FULL_RECT:
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_CENTER_RIGHT:
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_END) # right

		Control.PRESET_BOTTOM_LEFT:
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER_BOTTOM:
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_BOTTOM_RIGHT:
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_END) # right

		Control.PRESET_LEFT_WIDE:
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) # left
		Control.PRESET_RIGHT_WIDE:
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_END) # right
		Control.PRESET_TOP_WIDE:
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide
		Control.PRESET_BOTTOM_WIDE:
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide

		Control.PRESET_VCENTER_WIDE:
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_HCENTER_WIDE:
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide
		_:
			_print_error(
					"cannot SET folding_direction_preset: "
					+ "unsupported LayoutPreset: " + str(direction)
			)
			return

	if change_sizing_constraint:
		match direction:
			Control.PRESET_LEFT_WIDE, Control.PRESET_RIGHT_WIDE, Control.PRESET_VCENTER_WIDE:
				sizing_constraint = SizingConstraintOptions.ONLY_WIDTH
			Control.PRESET_TOP_WIDE, Control.PRESET_BOTTOM_WIDE, Control.PRESET_HCENTER_WIDE:
				sizing_constraint = SizingConstraintOptions.ONLY_HEIGHT
			_:
				sizing_constraint = SizingConstraintOptions.BOTH


# When [setting_node] changes,
# sets the [member sizing_node]'s [tree_exiting] to [_sizing_node_exiting],
# and sets the [member sizing_node]'s [resized] to [_sizing_node_resized].
func _connect_sizing_node_signals(node_path: NodePath) -> void:
	if not is_node_ready():
		await ready

	if node_path != NodePath(""):
		var new_sizing_node: Node = get_node(node_path)
		new_sizing_node.connect("tree_exiting", _sizing_node_exiting)
		new_sizing_node.connect("resized", _sizing_node_resized)


# Connects sizing_nodes resized signal to [method _auto_size_to_full].
# Connects its tree_exiting signal to [method _sizing_node_exiting]
# Disconnects previous sizing_node's signals.
# [br]Calls [method _update_inspector] to allow revert value of
# custom_open_size to set to the new node's size.
## Set's the [member sizing_node].
## Can auto resize if [member auto_update_size] is enabled.
func set_sizing_node_path(node_path: NodePath) -> void:
	var previous_sizing_node := get_node_or_null(sizing_node) as Control

	if not is_node_ready():
		# Node just entered tree in-game
		_connect_sizing_node_signals(node_path)
	else:
		# Do nothing if the same node
		if node_path == sizing_node:
			return

		# Disconnect previous sizing_nodes resized signal.
		if previous_sizing_node != null:
			# If resized is connected, likely that tree_exiting is also
			# connected so no need to check that one.
			if previous_sizing_node.resized.is_connected(_sizing_node_resized):
				previous_sizing_node.resized.disconnect(_sizing_node_resized)
				previous_sizing_node.tree_exiting.disconnect(
						_sizing_node_exiting
				)

		if node_path == NodePath(""):
			# New node is set to nothing
			pass
		else:
			# New node is set to something
			if not get_node(node_path) is Control:
				# New Node is not set to a Control
				# (will not set the sizing_node in this case)
				_print_error(
						"sizing_node must be Control or inherit from Control."
				)
				return
			else:
				# New Node is a control
				# Connect new sizing_nodes resized signal.
				_connect_sizing_node_signals(node_path)

				# Set to full size!
				_auto_size_to_full.call_deferred()

	sizing_node = node_path
	update_configuration_warnings()
	_update_inspector()


## Gets the [member sizing_node] if it exists or null if it doesn't.
func get_sizing_node_or_null() -> Control:
	if sizing_node == NodePath(""):
		return null
	else:
		return get_node(sizing_node) as Control


## Gets the opened size Vector. This could be the [member sizing_node]'s
## size or the [member custom_open_size], depending on which one is used.
## Returns null if using sizing_node and sizing_node is not set to anything.
## Importantly, will take [member sizing_constraint] into consideration.
func get_opened_size_or_null() -> Vector2OrNull:
	if use_custom_open_size:
		return Vector2OrNull.new(custom_open_size)

	var target_node: Control = get_sizing_node_or_null()
	if target_node == null:
		return null

	var full_size: Vector2 = target_node.get_size()
	var largest_size_value: Vector2 = _get_largest_size_value()

	# Ensure size follows the sizing constraint.
	match sizing_constraint:
		SizingConstraintOptions.ONLY_WIDTH:
			# Leave height as is.
			full_size = Vector2(full_size.x, largest_size_value.y)
		SizingConstraintOptions.ONLY_HEIGHT:
			# Leave width as is.
			full_size = Vector2(largest_size_value.x, full_size.y)

	return Vector2OrNull.new(full_size)


## Returns the closed size Vector.
## This could the be the either [constant Vector2.ZERO]
## or the [member custom_close_size] if custom close is used.
## Returns null if using sizing_node and sizing_node is not set to anything.
## Importantly, will take [member sizing_constraint] into consideration.
func get_closed_size_or_null() -> Vector2OrNull:
	if use_custom_close_size:
		return Vector2OrNull.new(custom_close_size)

	var target_node: Control = get_sizing_node_or_null()
	if target_node == null:
		return null

	var full_size := Vector2.ZERO
	var largest_size_value: Vector2 = _get_largest_size_value()

	# Ensure size follows the sizing constraint.
	match sizing_constraint:
		# Leave height as is.
		SizingConstraintOptions.ONLY_WIDTH:
			full_size = Vector2(full_size.x, largest_size_value.y)
		# Leave width as is.
		SizingConstraintOptions.ONLY_HEIGHT:
			full_size = Vector2(largest_size_value.x, full_size.y)

	return Vector2OrNull.new(full_size)


## Enables usage of [member custom_open_size].
## Can auto resize if [member auto_update_size] is enabled.
func set_use_custom_open_size(use_custom: bool) -> void:
	use_custom_open_size = use_custom
	_auto_size_to_full.call_deferred()
	# Update's inspector to show the [member custom_open_size] vector option.
	_update_inspector()
	update_configuration_warnings()


## Enables usage of [member custom_close_size].
## Can auto resize if [member auto_update_size] is enabled.
func set_use_custom_close_size(use_custom: bool) -> void:
	use_custom_close_size = use_custom
	_auto_size_to_full.call_deferred()
	# Update's inspector to show the [member custom_close_size] vector option.
	_update_inspector()
	update_configuration_warnings()


## Sets [member custom_open_size].
## Can auto resize if [member auto_update_size] is enabled.
func set_custom_open_size(custom_open: Vector2) -> void:
	custom_open_size = custom_open
	_auto_size_to_full.call_deferred()


## Sets [member custom_close_size].
## Can auto resize if [member auto_update_size] is enabled.
func set_custom_close_size(custom_close: Vector2) -> void:
	custom_close_size = custom_close
	_auto_size_to_full.call_deferred()


## Sets [member sizing_constraint].
## Can auto resize if [member auto_update_size] is enabled.
## Also updates [member update_folding_direction].
func set_sizing_constraint(constraint_option: SizingConstraintOptions) -> void:
	if not is_node_ready(): # Just entered scene tree:
		sizing_constraint = constraint_option
		return

	sizing_constraint = constraint_option
	_update_folding_direction()

	_auto_size_to_full.call_deferred()


## Sets [member auto_update_size].
## Can auto resize if [member auto_update_size] is enabled.[br]
## If disabled and tweening, will interrupt tweening
## and set [member _opened_state] to [constant NOT_FULLY_OPENED].
func set_auto_update_size(auto_size_option: AutoUpdateSizeOptions) -> void:
	auto_update_size = auto_size_option
	_auto_update_size_changed(auto_update_size)


## Force the size of the node to the desired amount.
## Sets [member _opened_state] to [constant FORCE_SIZED].
## Interrupts any tweening happening.
func force_size(target_size: Vector2) -> void:
	var previous_opened_state: OpenedStates = _opened_state
	_opened_state = OpenedStates.FORCE_SIZED
	if is_tweening():
		var previous_tween_state: TweenStates = _tween_state
		_tween_state = TweenStates.NOT_TWEENING
		_emit_tween_interrupted(
				previous_tween_state, _tween_state, _opened_state
		)

	_set_to_size(target_size)

	_emit_opened_state_signal(previous_opened_state, _opened_state)


## Forces a tween towards the desired size.
## [br]Sets [member _tween_state] to [constant FORCE_TWEENING].
## [br]Sets [member _opened_state] to [constant TWEENING].
## [br]Interrupts any tweening happening.
func force_tween(target_size: Vector2) -> void:
	var previous_opened_state: OpenedStates = _opened_state
	_opened_state = OpenedStates.TWEENING
	var previous_tween_state: TweenStates = _tween_state

	# Stop current tween and emit interrupted if necessary.
	if is_tweening():
		_tween_state = TweenStates.NOT_TWEENING
		_emit_tween_interrupted(
				previous_tween_state, TweenStates.FORCE_TWEENING, _opened_state
		)

	# Start force tween.
	_set_tween_variables(target_size)
	_tween_state = TweenStates.FORCE_TWEENING

	# Emit necessary signals.
	_emit_tween_started(_tween_state)
	_emit_opened_state_signal(previous_opened_state, _opened_state)


## Checks if tweening and if so, forces any tweens happening to stop.
## [br]Sets [member _opened_state] to [constant FORCE_SIZED].
## [br]Sets [member _tween_state] to [constant NOT_TWEENING].
func force_stop_tween() -> void:
	if is_tweening():
		var previous_opened_state: OpenedStates = _opened_state
		_opened_state = OpenedStates.FORCE_SIZED

		var previous_tween_state: TweenStates = _tween_state
		_tween_state = TweenStates.NOT_TWEENING

		_emit_tween_interrupted(
				previous_tween_state, _tween_state, _opened_state
		)
		_emit_opened_state_signal(previous_opened_state, _opened_state)


## If tweening, will set the size to the final tween value and emit the
## appropriate signals.
## [br][br][b]Note:[/b] If the argument provided is false will emit the
## [signal tween_completed] signal. Otherwise, will emit
## [signal tween_interrupted].
func set_to_end_tween(interrupted_tween: bool =  true) -> void:
	if is_tweening():
		var previous_tween_state: TweenStates = _tween_state
		var previous_opened_state: OpenedStates = _opened_state

		_opened_state = _get_target_opened_state(previous_tween_state)

		if interrupted_tween and is_tweening():
			_emit_tween_interrupted(
					previous_tween_state, _tween_state, _opened_state
			)
		elif not interrupted_tween:
			_emit_tween_completed(previous_tween_state)

		_tween_state = TweenStates.NOT_TWEENING

		_set_to_size(_tween_final_value)
		# Set appropriate opened_state:
		_emit_opened_state_signal(previous_opened_state, _opened_state)
	else:
		_print_warning(
				"attempt to call set_to_end_tween when no tween is playing."
		)


## Immediately opens to the opened size, which can be the size of the
## [member sizing_node] or the [member custom_open_size].
func open() -> void:
	_change(true, false)


## Immediately closes to the closed size, which can be the size of
## [constant Vector2.ZERO] or the [member custom_close_size].
func close() -> void:
	_change(false, false)


## Begins tweening towards the opened size, which can be the size of the
## [member sizing_node] or the [member custom_open_size].
func open_tween() -> void:
	_change(true, true)


## Begins tweening towards closed size, which can be the size of
## [constant Vector2.ZERO] or the [member custom_close_size].
func close_tween() -> void:
	_change(false, true)


## If is already opened, will be set to close. Otherwise, will be set to open.
func open_toggle() -> void:
	if is_opened():
		close()
	else:
		open()


## If is already opened or opening, will begin closing.
## Otherwise, will begin opening.
func open_tween_toggle() -> void:
	if is_opened() or is_opening():
		close_tween()
	else:
		open_tween()


## Returns if [member _opened_state] is [constant OPENED].
func is_opened() -> bool:
	return _opened_state == OpenedStates.OPENED


## Returns if [member _opened_state] is [constant CLOSED].
func is_closed() -> bool:
	return _opened_state == OpenedStates.CLOSED


## Returns if [member _tween_state] is [constant OPENING].
func is_opening() -> bool:
	return _tween_state == TweenStates.OPENING


## Returns if [member _tween_state] is [constant CLOSING].
func is_closing() -> bool:
	return _tween_state == TweenStates.CLOSING


## Returns if [member _tween_state] is not [constant NOT_TWEENING].
func is_tweening() -> bool:
	return _tween_state != TweenStates.NOT_TWEENING


## Returns a normalized version (0 - 1) of the current size value between
## the opened size and closed size range, or 1.0 if it failed.
func get_normalized_size_or_null() -> float:
	var closed_size: Vector2OrNull = get_closed_size_or_null()
	var opened_size: Vector2OrNull = get_opened_size_or_null()

	if opened_size == null:
		_print_error(
				"attempt to call get_normalized_size() but opened and "
				+ "closed size return null. Likely that sizing_node is null."
		)
		return 1.0

	var current_size: Vector2 = get_custom_minimum_size()
	var initial_size: Vector2 = closed_size.value
	var target_size: Vector2 = opened_size.value

	var current_distance: float = (current_size - initial_size).length()
	var total_distance: float = (target_size - initial_size).length()
	var normalized_progress: float = current_distance / total_distance
	return normalized_progress


## Returns [member use_custom_open_size]
func get_use_custom_open_size() -> bool:
	return use_custom_open_size


## Returns [member custom_open_size]
func get_custom_open_size() -> Vector2:
	return custom_open_size


## Returns [member use_custom_close_size]
func get_use_custom_close_size() -> bool:
	return use_custom_close_size


## Returns [member custom_close_size]
func get_custom_close_size() -> Vector2:
	return custom_close_size


## Returns [member sizing_constraint]
func get_sizing_constraint() -> SizingConstraintOptions:
	return sizing_constraint


## Returns [member auto_update_size]
func get_auto_update_size() -> AutoUpdateSizeOptions:
	return auto_update_size


## Returns [member start_with_clip_contents]
func get_start_with_clip_contents() -> bool:
	return start_with_clip_contents


## Returns [member tween_in_physics_process]
func get_tween_in_physics_process() -> bool:
	return tween_in_physics_process


## Returns [member tween_duration_sec]
func get_tween_duration_sec() -> float:
	return tween_duration_sec


## Returns [member tween_transition_type]
func get_tween_transition_type() -> Tween.TransitionType:
	return tween_transition_type


## Returns [member tween_ease_type]
func get_tween_ease_type() -> Tween.EaseType:
	return tween_ease_type


## Setter for [member starts_opened].
func set_starts_opened(opened: bool) -> void:
	starts_opened = opened


## Setter for [member start_with_clip_contents].
func set_start_with_clip_contents(start_clip: bool) -> void:
	start_with_clip_contents = start_clip


## Setter for [member tween_in_physics_process].
func set_tween_in_physics_process(in_physics: bool) -> void:
	tween_in_physics_process = in_physics


## Setter for [member tween_duration_sec].
func set_tween_duration_sec(tween_dur: float) -> void:
	tween_duration_sec = tween_dur


## Setter for [member tween_transition_type].
func set_tween_transition_type(transition_type: Tween.TransitionType) -> void:
	tween_transition_type = transition_type


## Setter for [member set_tween_ease_type].
func set_tween_ease_type(ease_type: Tween.EaseType) -> void:
	tween_ease_type = ease_type


## Main function used for opening/closing the node.
## Gets the target size (closed or opened size depending on parameter value).
## Tweens towards it or set the size to it immediately (depending on parameter).
## Emits any necessary signals: [signal tween_started],
## [signal opened_state_signal] and [signal tween_interrupted].
func _change(is_open: bool, is_tweening_enabled: bool) -> void:
	# Get closed or opened target size.
	var target_size: Vector2OrNull = (
			get_opened_size_or_null() if is_open else get_closed_size_or_null()
	)

	# Handle error if sizing node is null.
	if target_size == null:
		_print_error("can't open/close: sizing_node is null.")
		return

	# Do nothing if already opened/closed. Just emit the set signal.
	if (
			(is_open and _opened_state == OpenedStates.OPENED)
			or (not is_open and _opened_state == OpenedStates.CLOSED)
	):
		_emit_opened_state_signal(_opened_state, _opened_state)
		return

	var previous_opened_state: OpenedStates = _opened_state
	var previous_tween_state: TweenStates = _tween_state

	# Tween to open/close if tweening is enabled.
	if is_tweening_enabled:
		# If already tweening and
		# final_value is the same as target_size, do nothing.
		if is_tweening() and (_tween_final_value == target_size.value):
			return

		_opened_state = OpenedStates.TWEENING
		var target_tween_state: TweenStates = (
				TweenStates.OPENING if is_open else TweenStates.CLOSING
		)

		# If already tweening, interrupt previous tween.
		if is_tweening():
			_tween_state = TweenStates.NOT_TWEENING
			_emit_tween_interrupted(
					previous_tween_state, target_tween_state, _opened_state
			)

		_set_tween_variables(target_size.value)
		_tween_state = target_tween_state

		# Start tween emit:
		_emit_tween_started(_tween_state)
		_emit_opened_state_signal(previous_opened_state, _opened_state)
	else:
		_opened_state = OpenedStates.OPENED if is_open else OpenedStates.CLOSED

		# If is tweening, interrupt and stop.
		if is_tweening():
			_tween_state = TweenStates.NOT_TWEENING
			_emit_tween_interrupted(
					previous_tween_state, _tween_state, _opened_state
			)

		# Set size and emit signal.
		_set_to_size(target_size.value)
		_emit_opened_state_signal(previous_opened_state, _opened_state)


# Automatically sizes the node to the current full size,
# which may be the open size or the close size, depending on which states
# ([member _opened_state] and [member _tween_state]) are currently set.
# Useful only if [member auto_update_size] is not disabled.
func _auto_size_to_full() -> void:
	if not is_node_ready():
		return

	# Only perform function if not disabled.
	if auto_update_size == AutoUpdateSizeOptions.DISABLED:
		return

	# Get full size and what opened state will be after set to full size.
	var target_values: Array = _get_full_size_or_null_and_target_opened()
	var full_size: Vector2OrNull = target_values[0]
	var target_opened_state: OpenedStates = target_values[1]

	# For signals:
	var previous_opened_state: OpenedStates = _opened_state
	var previous_tween_state: TweenStates = _tween_state

	# If sizing_node is null and using it to set the size.
	if full_size == null:
		_print_warning("can't update size automatically: sizing_node is null.")
		return

	# If already at the full size, no need to continue.
	if full_size.value == get_size():
		return

	# If already tweening and the tween's target size is the same as full_size,
	# simply continue tweening. Instead of auto tweening. Otherwise,
	# print a warning and then interrupt the tween with the auto tween.
	if (
			previous_tween_state == TweenStates.OPENING
			or previous_tween_state == TweenStates.CLOSING
	):
		if full_size.value == _tween_final_value:
			return
		else:
			_print_warning(
					"NON-AUTO tween was interrupted by AUTO_SIZE: "
					+ "sizing_node changed size during a NON-AUTO_SIZE tween"
			)

	# If previous tweening was not AUTO Tweening,
	# then set _opened_state to UPDATING_OPENED and emit signal.
	# Do not want it to set to UPDATING_OPENED if was already AUTO tweening.
	# Repeated AUTO tweening should always be seen as a single AUTO tween.
	# Since sizing_node's resized events set to AUTO tween each time it emits.
	# Resized may happen multiple times in a row...
	if (previous_tween_state != TweenStates.AUTO_TWEENING_OPEN
		and previous_tween_state != TweenStates.AUTO_TWEENING_CLOSE
	):
		_opened_state = OpenedStates.UPDATING_OPENED
		_emit_opened_state_signal(previous_opened_state, _opened_state)

	match auto_update_size:
		# Update without tween.
		AutoUpdateSizeOptions.WITHOUT_TWEEN:
			# Stop tweening if tweening.
			_tween_state = TweenStates.NOT_TWEENING

			# Set to new _opened_state.
			previous_opened_state = _opened_state
			_opened_state = target_opened_state

			# Emit tween interrupted signal if necessary.
			if previous_tween_state != TweenStates.NOT_TWEENING:
				_emit_tween_interrupted(
						previous_tween_state, _tween_state, _opened_state
				)

			# Sets to the full size.
			_set_to_size(full_size.value)

			# Emits necessary _opened_state signals.
			_emit_opened_state_signal(previous_opened_state, _opened_state)

		# Update with tween.
		AutoUpdateSizeOptions.WITH_TWEEN:
			# Get if AUTO_TWEENING_OPEN or AUTO_TWEENING_CLOSE.
			var target_tween_state: TweenStates = (
					TweenStates.AUTO_TWEENING_OPEN
					if target_opened_state == OpenedStates.OPENED
					else TweenStates.AUTO_TWEENING_CLOSE
			)

			# Set to new _opened_state.
			_opened_state = OpenedStates.TWEENING

			# Stop tweening and emit tween interrupted signal if necessary.
			if previous_tween_state != TweenStates.NOT_TWEENING:
				_tween_state = TweenStates.NOT_TWEENING
				_emit_tween_interrupted(
						previous_tween_state, target_tween_state, _opened_state
				)

			# Set tween variables for upcoming AUTO tween.
			_set_tween_variables(full_size.value)

			# Set to new _tween_state.
			_tween_state = target_tween_state

			# Emit tween started signal.
			_emit_tween_started(_tween_state)

			# Emits necessary _opened_state signals.
			_emit_opened_state_signal(previous_opened_state, _opened_state)


# Called by [member set_auto_update_size]
# and [member _set_preview_auto_update_size].
# If disabled, sets states to correct values and stops any AUTO tweening.
func _auto_update_size_changed(
		auto_size_option: AutoUpdateSizeOptions
) -> void:
	if auto_size_option == AutoUpdateSizeOptions.DISABLED:
		if (
				_tween_state == TweenStates.AUTO_TWEENING_OPEN
				or _tween_state == TweenStates.AUTO_TWEENING_CLOSE
		):
			# If disabled, set to not tweening
			# and set _opened_state to NOT_FULLY_OPENED
			# or set _opened_state to target_opened_state
			# if sizes to the full size already.
			var target_values: Array = (
					_get_full_size_or_null_and_target_opened()
			)
			var full_size: Vector2OrNull = target_values[0]
			var target_opened_state: OpenedStates = target_values[1]
			var previous_opened_state: OpenedStates = _opened_state
			var previous_tween_state: TweenStates = _tween_state

			if full_size == null:
				_print_warning(
						"can't update size automatically: sizing_node is null."
				)
				return

			_tween_state = TweenStates.NOT_TWEENING

			if full_size.value == get_size():
				_opened_state = target_opened_state
			else:
				_opened_state = OpenedStates.NOT_FULLY_OPENED

			_emit_tween_interrupted(
					previous_tween_state, _tween_state, _opened_state
			)
			_emit_opened_state_signal(previous_opened_state, _opened_state)
	else:
		_auto_size_to_full.call_deferred()


## Called each [method _process] or [method _physics_process] function
## depending on value of [member tween_in_physics_process] when tweening.
## Uses [method Tween.interpolate_value] to increment the tween.
func _increment_tween(delta: float) -> void:
	_tween_elapsed_time += delta
	_tween_time_left = tween_duration_sec - _tween_elapsed_time

	if _tween_time_left <= 0:
		# Tween is over
		set_custom_minimum_size(_tween_final_value)
		set_size(_tween_final_value)
		set_to_end_tween(false)
	else:
		# Tween is not over
		var interpolated_size: Variant = Tween.interpolate_value(
				_tween_initial_value,
				_tween_delta_value,
				_tween_elapsed_time,
				tween_duration_sec,
				tween_transition_type,
				tween_ease_type
		)
		#print("CMS: ", custom_minimum_size)
		#print("TIV: ", _tween_initial_value)
		#print("TDV: ", _tween_delta_value)
		#print("IPS: ", interpolated_size)

		set_custom_minimum_size(interpolated_size)
		set_size(interpolated_size)


# Called before starting any tween.
# Sets up all variables to be used with [method Tween.interpolate_value]
# which is used within [member _increment_tween].
# Includes: [member _tween_elapsed_time], [member _tween_initial_value],
# [member _tween_final_value] and [member _tween_delta_value].
func _set_tween_variables(tween_target: Vector2, restart: bool = true) -> void:
	if restart:
		_tween_elapsed_time = 0.0

	_tween_initial_value = custom_minimum_size
	_tween_final_value = tween_target
	_tween_delta_value = _tween_final_value - _tween_initial_value

	match sizing_constraint:
		SizingConstraintOptions.ONLY_HEIGHT:
			_tween_delta_value.x = 0.0
			_tween_final_value.x = _tween_initial_value.x
		SizingConstraintOptions.ONLY_WIDTH:
			_tween_delta_value.y = 0.0
			_tween_final_value.y = _tween_initial_value.y


# Called when the sizing node is resized.
# Can auto resize if [member auto_update_size] is enabled.
func _sizing_node_resized() -> void:
	_auto_size_to_full.call_deferred()


# Returns a constant from the [enum OpenedStates] enum, which
# will be what the [member _opened_state] is set to after the current
# tween is over.
# Prints warning if this function is used when no tween is running.
# [br][br] Can be used externally without any problems (won't break something).
func _get_target_opened_state(current_tween_state: TweenStates) -> OpenedStates:
	match current_tween_state:
		TweenStates.OPENING, TweenStates.AUTO_TWEENING_OPEN:
			return OpenedStates.OPENED
		TweenStates.CLOSING, TweenStates.AUTO_TWEENING_CLOSE:
			return OpenedStates.CLOSED
		TweenStates.FORCE_TWEENING: # equivalent to: TweenStates.FORCE_TWEENING:
			return OpenedStates.FORCE_SIZED
		_:
			_print_warning(
					"attempt to get target opened state when not tweening."
			)
			return _opened_state


# Note: this method may be doing too much or should be renamed.
#
# Should add return [Vector2, OpenedStates] once the following is merged:
# Ideally, can return a null even if have "-> [Vector2, OpenedStates]".
# https://github.com/godotengine/godot/pull/76843
#
# Gets the full size, which may be the open size or the close size, depending
# on which states ([member _opened_state] and [member _tween_state]) are
# currently set.
# [br]Also returns the target opened state: what the the [member _opened_state]
# value will be after the current potentially occurring tween.
# [br][br] Return value is: [Vector2, OpenedStates] where Vector2 may be null
# if the sizing_node is used but is not set to anything.
# [br][br] Can be used externally without any problems (won't break something).
func _get_full_size_or_null_and_target_opened() -> Array:
	var full_size: Vector2OrNull
	var target_opened_state: OpenedStates
	if is_tweening():
		match _tween_state: # Will not be NOT_TWEENING.
			TweenStates.CLOSING, TweenStates.AUTO_TWEENING_CLOSE:
				full_size = get_closed_size_or_null()
				target_opened_state = OpenedStates.CLOSED
			_:
				full_size = get_opened_size_or_null()
				target_opened_state = OpenedStates.OPENED
	else:
		match _opened_state: # Will not be TWEENING.
			OpenedStates.CLOSED:
				full_size = get_closed_size_or_null()
				target_opened_state = OpenedStates.CLOSED
			_:
				full_size = get_opened_size_or_null()
				target_opened_state = OpenedStates.OPENED

	return [full_size, target_opened_state]


# Called by [signal Control.tree_exiting] on the [member _sizing_node].
# Sets the [member sizing_node_path] to an empty NodePath.
# Calls the [method set_sizing_node_path]
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something).
func _sizing_node_exiting() -> void:
	set_sizing_node_path(NodePath(""))


# Emits necessary _opened_state signals ([signal state_set] and
# [signal state_changed]). Only in game.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something).
func _emit_opened_state_signal(
		previous_state: OpenedStates, new_state: OpenedStates
) -> void:
	state_set.emit(new_state, previous_state)


## Checks if in game before emitting [signal tween_started].
func _emit_tween_started(current_tween_state: TweenStates) -> void:
	tween_started.emit(current_tween_state)


## Sends [signal tween_interrupted] signal if needed. Only in game.
## Does not emit if next_state is an AUTO_TWEEN.
func _emit_tween_interrupted(
		previous_tween_state: TweenStates,
		next_tween_state: TweenStates,
		next_opened_state: OpenedStates
) -> void:
	# If same AUTO_TWEEN, then does not count as an interruption.
	if (
			(
					previous_tween_state == TweenStates.AUTO_TWEENING_OPEN
					and next_tween_state == TweenStates.AUTO_TWEENING_OPEN
			)
			or (
					previous_tween_state == TweenStates.AUTO_TWEENING_CLOSE
					and next_tween_state == TweenStates.AUTO_TWEENING_CLOSE
			)
	):
		return

	tween_interrupted.emit(
			previous_tween_state, next_tween_state, next_opened_state
	)


## Checks if in game before emitting [signal tween_completed].
func _emit_tween_completed(previous_tween_state: TweenStates) -> void:
	tween_completed.emit(previous_tween_state)


## Called on [signal Control.minimum_size_changed] on this node.
## Emits the [signal tweening_amount_changed] signal if tweening.
## Can also emit in editor.
func _emit_tween_amount_changed() -> void:
	if not is_tweening():
		return

	var current_size: Vector2 = get_custom_minimum_size()
	var initial_size: Vector2 = _tween_initial_value
	var target_size: Vector2 = _tween_final_value

	var current_distance: float = (current_size - initial_size).length()
	var total_distance: float = (target_size - initial_size).length()
	var normalized_progress: float = current_distance / total_distance

	tweening_amount_changed.emit(
			get_custom_minimum_size(), normalized_progress, _tween_time_left
	)


# Returns largest x and y values from sizing_node.get_size() and
# sizing_node.get_custom_minimum_size().
# For example if get_custom_minimum_size().x is larger than get_size().x
# and get_size().y is larger than get_custom_minimum_size().y
# will return Vector2(get_custom_minimum_size().x, get_size().y).
# Prints warning if sizing_node is null as it cannot get its sizes.
# [br][br] Can be used externally without any problems (won't break something).
func _get_largest_size_value() -> Vector2:
	var target_node: Control = get_sizing_node_or_null()

	var biggest: Vector2

	if target_node != null:
		if target_node.get_size().x > target_node.get_custom_minimum_size().x:
			biggest.x = target_node.get_size().x
		else:
			biggest.x = target_node.get_custom_minimum_size().x

		if target_node.get_size().y > target_node.get_custom_minimum_size().y:
			biggest.y = target_node.get_size().y
		else:
			biggest.y = target_node.get_custom_minimum_size().y
	else:
		_print_error("can't get largest size, sizing_node is null.")

	return biggest


## Called when [member sizing_constraint] or sizing flags
## ([member Control.size_flags_horizontal] and
## [member Control.size_flags_vertical]) are changed changed.
func _update_folding_direction() -> void:
	var direction: FoldingPreset = get_folding_direction_preset()
	_folding_direction_preset = direction


## Returns true if parent is a container or inherits from it.
func _has_parent_container() -> bool:
	return get_parent() is Container


## Uses both [method Control.set_custom_minimum_size]
## and [Control.method set_size] to set the size of the this node.
func _set_to_size(target_size: Vector2) -> void:
	set_custom_minimum_size(target_size)
	set_size(target_size)


## Calls [member Object.notify_property_list_changed]. Improves readability.
func _update_inspector() -> void:
	notify_property_list_changed()


# Uses [method print_rich] to print a string
# in yellow color into the editor's output.
func _print_warning(string: String) -> void:
	print_rich("[color=yellow]" + str(self, ": ", string) + "[/color]")


# Calls [method printerr].
func _print_error(message: String) -> void:
	printerr(str(self, ": ", message))


class Vector2OrNull:
	var value := Vector2.ZERO

	func _init(value_ := Vector2.ZERO) -> void:
		value = value_
