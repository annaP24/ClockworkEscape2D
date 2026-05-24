@tool
extends StaticBody2D
@export var length: float = 100.0:
	set(value):
		length = value
		_update_lightning()
@export var on_time : float = 1.0
@export var off_time : float = 1.2
@export var warrning_time : float = 0.5

@onready var lower: Sprite2D = $LowerGuard
@onready var upper: Sprite2D = $UpperGuard
@onready var sparks_upper: GPUParticles2D = $Sparks/SparksUpper
@onready var sparks_lower: GPUParticles2D = $Sparks/SparksLower
@onready var sparks: Node2D = $Sparks

@onready var line: Line2D = $BlitzLine
@onready var comp_2d_hitbox: Comp2dHitbox = $Comp2dHitbox
@onready var off_timer: Timer = $OffTimer
@onready var on_timer: Timer = $OnTimer
@onready var warrning_timer: Timer = $WarrningTimer
@onready var collision_shape_2d: CollisionShape2D = $Comp2dHitbox/CollisionShape2D

enum State {OFF, ON, WARR, DEFAULT}

var current_state : State = State.OFF

func _ready():
	_update_lightning()

func _update_lightning():
	if not (upper and lower and line):
		return

	# compute offset based on direction
	var offset : Vector2 = Vector2.ZERO

	offset = Vector2(0, length)

	# position lower node
	lower.position = upper.position + offset
	sparks_lower.position = sparks_upper.position + offset - Vector2(0, 50)
	# update line points
	line.clear_points()
	line.add_point(upper.position + Vector2(0.0,10.0))
	line.add_point(lower.position - Vector2(0.0,10.0))

	# --- Update CollisionShape2D ---
	var shape := collision_shape_2d.shape
	if shape is RectangleShape2D:
		# make it narrow and as long as the lightning
		var rec_length := 52.0
		shape.size = Vector2(rec_length, length)

		# center it between upper and lower
		collision_shape_2d.position = upper.position + offset * 0.5

func _physics_process(_delta: float) -> void:
	match current_state:
		State.WARR:
			sparks.visible = true
			warrning_timer.start(warrning_time)
			current_state = State.DEFAULT
		State.ON:
			sparks.visible = false
			on_timer.start(on_time)
			_on()
			current_state = State.DEFAULT
		State.OFF:
			_off()
			off_timer.start(off_time)
			current_state = State.DEFAULT
		State.DEFAULT:
			pass

func _on_off_timer_timeout() -> void:
	current_state = State.WARR

func _on_on_timer_timeout() -> void:
	current_state = State.OFF

func _on_warrning_timer_timeout() -> void:
	current_state = State.ON

func _on():
	comp_2d_hitbox.is_enable = true
	comp_2d_hitbox.monitorable = true
	comp_2d_hitbox.monitoring = true
	line.visible = true

func _off():
	line.visible = false
	comp_2d_hitbox.monitorable = false
	comp_2d_hitbox.monitoring = false
	comp_2d_hitbox.is_enable = false
