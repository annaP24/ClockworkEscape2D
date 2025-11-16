@tool
extends StaticBody2D
@export var length: float = 100.0:
	set(value):
		length = value
		_update_lightning()
@export var on_time : float = 1.0
@export var off_time : float = 1.0

@onready var lower: Sprite2D = $LowerGuard
@onready var upper: Sprite2D = $UpperGuard
@onready var line: Line2D = $BlitzLine
@onready var comp_2d_hitbox: Comp2dHitbox = $Comp2dHitbox
@onready var off_timer: Timer = $OffTimer
@onready var on_timer: Timer = $OnTimer
@onready var collision_shape_2d: CollisionShape2D = $Comp2dHitbox/CollisionShape2D

func _ready():
	_update_lightning()
	on_timer.start()

func _update_lightning():
	if not (upper and lower and line):
		return

	# compute offset based on direction
	var offset : Vector2 = Vector2.ZERO

	offset = Vector2(0, length)

	# position lower node
	lower.position = upper.position + offset

	# update line points
	line.clear_points()
	line.add_point(upper.position)
	line.add_point(lower.position)
	# --- Update CollisionShape2D ---
	var shape := collision_shape_2d.shape
	if shape is RectangleShape2D:
		# make it narrow and as long as the lightning
		var rec_length := 52.0
		shape.size = Vector2(rec_length, length)

		# center it between upper and lower
		collision_shape_2d.position = upper.position + offset * 0.5

func _on_off_timer_timeout() -> void:
	comp_2d_hitbox.is_enable = true
	comp_2d_hitbox.monitorable = true
	comp_2d_hitbox.monitoring = true
	line.visible = true
	on_timer.start()

func _on_on_timer_timeout() -> void:
	line.visible = false
	comp_2d_hitbox.monitorable = false
	comp_2d_hitbox.monitoring = false
	comp_2d_hitbox.is_enable = false
	off_timer.start()
