extends StaticBody2D
class_name Projectile

var speed : float = 2.0
@export var current_direction : Vector2 = Vector2.ZERO
@export var rotation_angle : float = 200.0
var is_first_collision : bool = true

func _ready() -> void:
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.name = "VisibleOnScreenNotifier2D"
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	add_child(notifier)

func _process(_delta: float) -> void:
	pass

func _on_damage_area_body_entered(_body: Node2D) -> void:
	if is_first_collision:
		is_first_collision = false
		return
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
