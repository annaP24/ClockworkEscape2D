extends Node
class_name TutorialManager
## Sequences level_start's tutorial arrows: first collectable, wall climb, then the wall-jump (up-right, then left) cue.
## Also shows a screen-space tutorial banner at each phase; banner pauses the game until confirmed.


@export var player : PlayerFsmCustomDataLayer
@onready var arrow_to_collectable: Sprite2D = %ArrowToCollectable
@onready var arrow_to_walkable_wall: Sprite2D = %ArrowToWalkableWall
@onready var arrow_wall_jump_up_right: Sprite2D =%ArrowWallJumpUpRight
@onready var collectable_2: StaticBody2D = %Collectable2
@onready var arrow_to_jump: Sprite2D = %ArrowToJump

@onready var collectable_zone_enter: Area2D = %CollectableZoneEnter
@onready var jump_hint_zone_enter: Area2D = %JumpHintZoneEnter
@onready var jump_hint_zone_exit: Area2D = %JumpHintZoneExit
@onready var wall_jump_hint_zone_enter: Area2D = %WallJumpHintZoneEnter
@onready var wall_jump_hint_zone_exit: Area2D = %WallJumpHintZoneExit
@onready var walkable_wall_hint_zone_exit: Area2D = %WalkableWallHintZoneExit
@onready var walkable_wall_hint_zone_enter: Area2D = %WalkableWallHintZoneEnter
var tutorial_banner = preload("res://scenes/game/tutorial_banner/tutorial_banner.tscn")
var banner : TutorialBanner
var is_double_jump_finished : bool = false
var is_collect_finished : bool = false
var is_walkable_finished : bool = false
var is_wall_climb_finished : bool = false
var is_jump_finished : bool = false
var is_wall_jump_finished : bool = false
var current_banner_base_text : Array[String] = []
var is_tutorial_complete : bool = false
var is_walkable_in_circle_finished : bool = false
enum Phase {DOUBLE_JUMP, COLLECT, JUMP_WITH_SWORDS, WALL_CLIMB, WALL_JUMP, WALL_JUMP_CLIMB,WALK_IN_CIRCLE, IDLE}

func _ready() -> void:
	_setup_tutorial()
	_setup_connections()	
	
func _setup_tutorial() -> void:
	is_double_jump_finished = false
	is_collect_finished = false
	is_walkable_finished = false
	is_walkable_in_circle_finished = false
	is_wall_climb_finished = false
	is_jump_finished = false
	is_wall_jump_finished = false
	is_tutorial_complete = false
	arrow_to_walkable_wall.visible = false
	arrow_wall_jump_up_right.visible = false
	arrow_to_collectable.visible = true
	arrow_to_jump.visible = false
	_setup_banner()
	if is_tutorial_complete:
		banner.hide_banner()
		arrow_to_collectable.visible = true

func _setup_connections() -> void:
	collectable_2.collected.connect(_on_collectable_collected)	
	collectable_zone_enter.body_entered.connect(_on_collectable_zone_enter_body_entered)
	collectable_zone_enter.body_exited.connect(_on_collectable_zone_enter_body_exited)

	jump_hint_zone_enter.body_entered.connect(_on_jump_entered)
	jump_hint_zone_exit.body_entered.connect(_on_jump_exited)
	walkable_wall_hint_zone_enter.body_entered.connect(_on_walkable_wall_hint_zone_enter_body_entered)
	walkable_wall_hint_zone_exit.body_entered.connect(_on_walkable_wall_hint_zone_exit_body_entered)
	walkable_wall_hint_zone_exit.body_exited.connect(_on_walkable_wall_hint_zone_exit_body_exited)
	wall_jump_hint_zone_enter.body_entered.connect(_on_wall_jump_hint_zone_enter_body_entered)
	wall_jump_hint_zone_exit.body_entered.connect(_on_wall_jump_hint_zone_exit_body_entered)

	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	

func _get_banner_text(phase: Phase) -> Array[String]:
	var joy = GameSession.is_joypad_connected
	match phase:
		Phase.DOUBLE_JUMP:
			return ["Double Jump", "press %s twice" % ["(A)" if joy else "Space"]]
		Phase.COLLECT:
			return ["Collect the item"]
		Phase.JUMP_WITH_SWORDS:
			return ["Jump over the spikes", "press %s while moving to jump over spikes" % ["(A)" if joy else "Space"]]
		Phase.WALL_CLIMB:
			return ["Wall climb", "hold %s while touching the wall, release to fall" % ["D-Pad/Stick Up" if joy else "W"]]
		Phase.WALL_JUMP:
			return ["Wall jump", "jump toward the wall and on impact press %s and %s to jump off it" % ["(A)" if joy else "Space", "D-Pad/Stick Left" if joy else "A"]]
		Phase.WALL_JUMP_CLIMB:
			return ["Wall jump and climb", "jump toward the wall and press %s while touching it" % ["D-Pad/Stick Up" if joy else "W"]]
		Phase.WALK_IN_CIRCLE:
			return ["Walk in a circle", "use the movement controls %s or %s to walk in a circle" % ["(Left Stick)" if joy else "A", "(Right Stick)" if joy else "D"]]
		Phase.IDLE:
			return [""]
	return []

func _setup_banner() -> void:
	# Separate screen-space layer so the banner stays glued to the top-center viewport unlike the world-space hint nodes.
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	banner = tutorial_banner.instantiate()
	layer.add_child(banner)	

func _show_banner_for_phase(phase: Phase) -> void:
	current_banner_base_text = _get_banner_text(phase)
	if current_banner_base_text.size() > 0:
		banner.show_banner(current_banner_base_text)
	if phase == Phase.IDLE:
		banner.hide_banner()
#----------------------------- Signals -----------------------------------------------------
func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if banner.visible and current_banner_base_text.size() > 0:
		# Rebuild the text with the new device phrasing so the same banner refreshes in place.
		banner.show_banner(current_banner_base_text)

# Collectable Zone Enter
func _on_collectable_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_collect_finished:
		_show_banner_for_phase(Phase.WALL_CLIMB)
		arrow_to_collectable.visible = true
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
	else:
		_show_banner_for_phase(Phase.IDLE)
		
# Collectable Zone Exit
func _on_collectable_zone_enter_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_collectable.visible = false
		_show_banner_for_phase(Phase.IDLE)


# Collectable Collected
func _on_collectable_collected() -> void:
	is_collect_finished = true
	arrow_to_collectable.visible = false
	arrow_wall_jump_up_right.visible = false
	arrow_to_walkable_wall.visible = false
	_show_banner_for_phase(Phase.IDLE)

# Jump Zone Enter
func _on_jump_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_jump_finished:
		_show_banner_for_phase(Phase.JUMP_WITH_SWORDS)
		arrow_to_jump.visible = true
		arrow_to_collectable.visible = false
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false


# Jump Zone Exit
func _on_jump_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_jump_finished = true
		arrow_to_jump.visible = false
		# if not is_walkable_finished:
		# 	arrow_to_walkable_wall.visible = true
		# 	arrow_to_collectable.visible = false
		# 	arrow_wall_jump_up_right.visible = false
		# 	_show_banner_for_phase(Phase.WALL_JUMP_CLIMB)

# Walkable Wall Hint Zone Enter
func _on_walkable_wall_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_walkable_finished:
		arrow_to_walkable_wall.visible = true
		arrow_to_collectable.visible = false
		arrow_wall_jump_up_right.visible = false
		_show_banner_for_phase(Phase.WALL_JUMP_CLIMB)


# Walkable Wall Hint Zone Exit
func _on_walkable_wall_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_walkable_in_circle_finished:
		arrow_to_walkable_wall.visible = false
		is_walkable_finished = true
		_show_banner_for_phase(Phase.WALK_IN_CIRCLE)

# Walkable Wall Hint Zone Exit
func _on_walkable_wall_hint_zone_exit_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_walkable_wall.visible = false
		is_walkable_in_circle_finished = true
		_show_banner_for_phase(Phase.IDLE)


# Wall Jump Hint Zone Enter
func _on_wall_jump_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_jump_finished:
		arrow_wall_jump_up_right.visible = true
		arrow_to_walkable_wall.visible = false
		_show_banner_for_phase(Phase.WALL_JUMP)

# Wall Jump Hint Zone Exit
func _on_wall_jump_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
		is_wall_jump_finished = true
		_show_banner_for_phase(Phase.IDLE)
