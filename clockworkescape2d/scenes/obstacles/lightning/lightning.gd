extends StaticBody2D
@export var line_height : float = 100.0
@export var on_time : float = 1.0
@export var off_time : float = 1.0
@onready var on_timer: Timer = $OnTimer
@onready var off_timer: Timer = $OffTimer
@onready var blitz_line: Line2D = $BlitzLine
@onready var lower_guard: Sprite2D = $LowerGuard
@onready var upper_guard: Sprite2D = $UpperGuard
@onready var stop_marker: Marker2D = $LowerGuard/stop
@onready var start_marker: Marker2D = $UpperGuard/start

@onready var comp_2d_hitbox: Comp2dHitbox = $Comp2dHitbox
@onready var collision_shape_2d: CollisionShape2D = $Comp2dHitbox/CollisionShape2D

func _ready() -> void:
	#lower_guard.position.y = upper_guard.position.y + line_height  #blitz_line.points[1].y + 10
	#blitz_line.points[0] = start_marker.position
	#blitz_line.points[1] = stop_marker.position
	on_timer.wait_time = on_time
	off_timer.wait_time = off_time
	on_timer.start()
	blitz_line.visible = true
	comp_2d_hitbox.is_enable = true
	#collision_shape_2d.shape.size.y = blitz_line.points[1].y
	#comp_2d_hitbox.position = upper_guard.position
func _physics_process(_delta: float) -> void:
	pass
	#lower_guard.position.y = upper_guard.position.y + line_height
	#blitz_line.points[0] = start_marker.position
	#blitz_line.points[1] = stop_marker.position
	##blitz_line.points[1].y =  lower_guard.position.y - 40
	##collision_shape_2d.shape.size.y =blitz_line.points[1].y
	#comp_2d_hitbox.position = upper_guard.position + Vector2(0,45)
	
func _on_on_timer_timeout() -> void:
	blitz_line.visible = false
	comp_2d_hitbox.is_enable = false
	off_timer.start()

func _on_off_timer_timeout() -> void:
	blitz_line.visible = true
	comp_2d_hitbox.is_enable = true
	on_timer.start()
