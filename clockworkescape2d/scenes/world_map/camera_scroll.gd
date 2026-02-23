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
	if event is InputEventMouseButton and \
	(event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			dragging = true
			drag_start_pos = event.position
			camera_start_pos = position
		else:
			dragging = false

	# Move camera while dragging
	if dragging:
		var delta = (drag_start_pos - event.position) * drag_sensitivity
		position = (camera_start_pos + delta).clamp(
			Vector2(min_x, min_y),
			Vector2(max_x, max_y)
		)

func move_camera_with_selection(new_node : Vector2):
	# Zielposition berechnen (und innerhalb der Grenzen halten)
	var target_y = clamp(new_node.y - 250, min_y, max_y)

	# Distanz zwischen aktueller Position und Ziel berechnen
	var distance = abs(self.position.y - target_y)

	# Zeit basierend auf Distanz (z.B. 500 Pixel pro Sekunde)
	var speed = 600.0
	var duration = distance / speed

	# Dauer begrenzen, damit es bei Minibewegungen nicht zu langsam ist
	duration = clamp(duration, 0.2, 0.7)

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", target_y, duration)
