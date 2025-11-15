extends StaticBody2D
@export var switch_1: Switch
@export var switch_2: Switch

var offset : float = 192.0
var init_position : Vector2 = Vector2.ZERO
var is_door_opening : bool = false
var is_door_closing : bool = false
var move_up_delta : float = 5.0
var move_down_delta : float = 1.0

func _ready() -> void:
	init_position = position
	switch_1.is_active.connect(_on_switch_is_active)
	switch_1.is_not_active.connect(_on_switch_is_not_active)
	if switch_2:
		switch_2.is_active.connect(_on_switch_is_active)
		switch_2.is_not_active.connect(_on_switch_is_not_active)
	
func _process(_delta: float) -> void:
	if is_door_opening:
		move_up()
	elif is_door_closing:
		move_down()
			
func move_up():
	if global_position.y < init_position.y - offset:
		return
	global_position.y = global_position.y - move_up_delta
		
func move_down():
	if global_position.y > init_position.y:
		return
	global_position.y = global_position.y + move_down_delta

func _on_switch_is_active():
	is_door_opening = true
	is_door_closing = false

func _on_switch_is_not_active():
	is_door_closing = true
	is_door_opening = false
