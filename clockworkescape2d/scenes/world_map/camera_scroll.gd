extends Camera2D

var dragging := false
var drag_start_pos := Vector2.ZERO
var camera_start_pos := Vector2.ZERO

@export var drag_sensitivity: float = 1.0
@export var min_x := 0.0
@export var max_x := 0.0
@export var min_y := 0.0
@export var max_y := 2400.0
var init_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	position = Vector2(max_x, max_y)
	init_position = position

func _input(event):
	# Start dragging
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_LEFT):
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

func move_camera_with_selection(new_node : LevelNode):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if new_node.position.y < init_position.y:
		# Scroll the camera to the new node
		#var new_pos = new_node.global_position.clamp(Vector2(min_x, min_y), Vector2(max_x, max_y))
		#print(new_node.global_position)
		#print(new_pos)
		tween.tween_property(self, "position:y", new_node.position.y - 250, 0.5)
	else:
		var new_pos = new_node.position.clamp(Vector2(min_x, min_y),
			Vector2(max_x, max_y)
		)
		tween.tween_property(self, "position:y",new_pos.y, 0.5)
