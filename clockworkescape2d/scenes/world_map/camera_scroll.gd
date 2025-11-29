extends Camera2D

var dragging := false
var drag_start_pos := Vector2.ZERO
var camera_start_pos := Vector2.ZERO

@export var drag_sensitivity: float = 1.0
@export var min_x := -5000
@export var max_x :=  5000
@export var min_y := -5000
@export var max_y :=  5000


func _input(event):
	# Start dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_pos = event.position
			camera_start_pos = position
		else:
			dragging = false

	# Move camera while dragging
	if event is InputEventMouseMotion and dragging:
		var delta = (drag_start_pos - event.position) * drag_sensitivity
		position = (camera_start_pos + delta).clamp(
			Vector2(min_x, min_y),
			Vector2(max_x, max_y)
		)
