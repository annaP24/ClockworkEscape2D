extends StaticBody2D
@export var line_height : float = 100.0
@export var on_time : float = 1.0
@export var off_time : float = 1.0
@onready var on_timer: Timer = $OnTimer
@onready var off_timer: Timer = $OffTimer
@onready var blitz_line: Line2D = $BlitzLine
@onready var lower_guard: Sprite2D = $LowerGuard

func _ready() -> void:
	blitz_line.points[1].y = blitz_line.points[0].y  + line_height
	lower_guard.position.y = blitz_line.points[1].y
	on_timer.wait_time = on_time
	off_timer.wait_time = off_time
	on_timer.start()
	blitz_line.visible = true
	
func _process(delta: float) -> void:
	blitz_line.points[1].y =  blitz_line.points[0].y  + line_height
	lower_guard.position.y = blitz_line.points[1].y

func _on_on_timer_timeout() -> void:
	blitz_line.visible = false
	off_timer.start()

func _on_off_timer_timeout() -> void:
	blitz_line.visible = true
	on_timer.start()
