extends Node
class_name TutorialManager
## Sequences level_start's tutorial arrows: first collectable, wall climb, then the wall-jump (up-right, then left) cue.
## Also shows a screen-space tutorial banner at each phase; banner pauses the game until confirmed.

const TUTORIAL_BANNER = preload("res://scenes/game/tutorial_banner/tutorial_banner_new.tscn")

@export var player : PlayerFsmCustomDataLayer
@onready var arrow_to_collectable: Sprite2D = %ArrowToCollectable
@onready var arrow_to_walkable_wall: Sprite2D = %ArrowToWalkableWall
@onready var arrow_wall_jump_up_right: Sprite2D =%ArrowWallJumpUpRight
@onready var collectable_2: StaticBody2D = %Collectable2
@onready var arrow_to_double_jump: Sprite2D = %ArrowToDoubleJump

@onready var collectable_zone_enter: Area2D = %CollectableZoneEnter
@onready var wall_double_jump_hint_zone_enter: Area2D = %WallDoubleJumpHintZoneEnter
@onready var wall_double_jump_hint_zone_exit: Area2D = %WallDoubleJumpHintZoneExit
@onready var jump_hint_zone_enter: Area2D = %JumpHintZoneEnter
@onready var jump_hint_zone_exit: Area2D = %JumpHintZoneExit
@onready var wall_jump_hint_zone_enter: Area2D = %WallJumpHintZoneEnter
@onready var wall_jump_hint_zone_exit: Area2D = %WallJumpHintZoneExit
@onready var walkable_wall_hint_zone_exit: Area2D = %WalkableWallHintZoneExit
@onready var walkable_wall_hint_zone_enter: Area2D = %WalkableWallHintZoneEnter

var is_double_jump_finished : bool = false
var is_collect_finished : bool = false
var is_walkable_finished : bool = false
var is_wall_climb_finished : bool = false
var is_jump_finished : bool = false
var is_wall_jump_finished : bool = false
var banner : Control
var current_banner_base_text : Array[String] = []

func _ready() -> void:
	# Establish a known starting state in code so scene edits/exports can't silently break the sequence.
	arrow_to_walkable_wall.visible = false
	arrow_wall_jump_up_right.visible = false
	arrow_to_double_jump.visible = false
	arrow_to_collectable.visible = true
	collectable_2.collected.connect(_on_collectable_collected)
	wall_double_jump_hint_zone_enter.body_entered.connect(_on_wall_double_jump_hint_zone_enter_body_entered)
	wall_double_jump_hint_zone_enter.body_exited.connect(_on_wall_double_jump_hint_zone_enter_body_exited)
	collectable_zone_enter.body_entered.connect(_on_collectable_zone_enter_body_entered)
	collectable_zone_enter.body_exited.connect(_on_collectable_zone_enter_body_exited)

	wall_double_jump_hint_zone_exit.body_entered.connect(_on_wall_double_jump_hint_zone_exit_body_entered)
	jump_hint_zone_enter.body_entered.connect(_on_jump_entered)
	jump_hint_zone_exit.body_entered.connect(_on_jump_exited)
	walkable_wall_hint_zone_enter.body_entered.connect(_on_walkable_wall_hint_zone_enter_body_entered)
	walkable_wall_hint_zone_exit.body_entered.connect(_on_walkable_wall_hint_zone_exit_body_entered)
	wall_jump_hint_zone_enter.body_entered.connect(_on_wall_jump_hint_zone_enter_body_entered)
	wall_jump_hint_zone_exit.body_entered.connect(_on_wall_jump_hint_zone_exit_body_entered)

	_setup_banner()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_show_banner_for_phase(Phase.WALL_CLIMB)

func _setup_banner() -> void:
	# Separate screen-space layer so the banner stays glued to the top-center viewport unlike the world-space hint nodes.
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	banner = TUTORIAL_BANNER.instantiate()
	layer.add_child(banner)

enum Phase {DOUBLE_JUMP, COLLECT, JUMP, WALL_CLIMB, WALL_JUMP, IDLE}

func _get_banner_text(phase: Phase) -> Array[String]:
	var joy = GameSession.is_joypad_connected
	match phase:
		Phase.DOUBLE_JUMP:
			return ["Double Jump", "press %s twice" % ["(A)" if joy else "Space"]]
		Phase.COLLECT:
			return ["Collect the item"]
		Phase.JUMP:
			return ["Jump", "press %s" % ["(A)" if joy else "Space"]]
		Phase.WALL_CLIMB:
			return ["Wall climb", "hold %s while touching the wall" % ["D-Pad/Stick Up" if joy else "↑ / W"]]
		Phase.WALL_JUMP:
			return ["Wall jump", "press %s while on a wall" % ["(A)" if joy else "Space"]]
		Phase.IDLE:
			return [""]
	return []

func _show_banner_for_phase(phase: Phase) -> void:
	current_banner_base_text = _get_banner_text(phase)
	if current_banner_base_text.size() > 0:
		banner.show_banner(current_banner_base_text)

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if banner.visible and current_banner_base_text.size() > 0:
		# Rebuild the text with the new device phrasing so the same banner refreshes in place.
		banner.show_banner(current_banner_base_text)
func _on_collectable_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_collect_finished:
		_show_banner_for_phase(Phase.WALL_CLIMB)
		arrow_to_collectable.visible = true
		arrow_to_double_jump.visible = false
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
	else:
		banner.hide_banner()

func _on_collectable_zone_enter_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_collectable.visible = false
		if is_collect_finished:
			banner.hide_banner()

func _on_collectable_collected() -> void:
	is_collect_finished = true
	arrow_to_collectable.visible = false
	arrow_wall_jump_up_right.visible = false
	arrow_to_walkable_wall.visible = false
	_show_banner_for_phase(Phase.IDLE)
	banner.hide_banner()

func _on_wall_double_jump_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_double_jump_finished:
		_show_banner_for_phase(Phase.DOUBLE_JUMP)
		arrow_to_double_jump.visible = true
		arrow_to_collectable.visible = false
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
	else:
		banner.hide_banner()

func _on_wall_double_jump_hint_zone_enter_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_double_jump.visible = false
		arrow_to_walkable_wall.visible = false
		arrow_wall_jump_up_right.visible = false
		if is_collect_finished:
			arrow_to_collectable.visible = false
			banner.hide_banner()
		else:
			arrow_to_collectable.visible = true
			_show_banner_for_phase(Phase.WALL_CLIMB)


func _on_wall_double_jump_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_show_banner_for_phase(Phase.IDLE)
		is_double_jump_finished = true
		arrow_to_double_jump.visible = false
		arrow_to_walkable_wall.visible = false
		arrow_wall_jump_up_right.visible = false
		arrow_to_collectable.visible = false
		banner.hide_banner()

func _on_jump_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_jump_finished:
		_show_banner_for_phase(Phase.JUMP)
		arrow_to_collectable.visible = false
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
	else:
		banner.hide_banner()
func _on_jump_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_jump_finished = true
		_show_banner_for_phase(Phase.IDLE)
		banner.hide_banner()


func _on_walkable_wall_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_walkable_finished:
		arrow_to_walkable_wall.visible = true
		arrow_to_collectable.visible = false
		arrow_wall_jump_up_right.visible = false
		_show_banner_for_phase(Phase.WALL_CLIMB)
	else:
		banner.hide_banner()
		arrow_wall_jump_up_right.visible = false

func _on_walkable_wall_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_walkable_wall.visible = false
		is_walkable_finished = true
		banner.hide_banner()

func _on_wall_jump_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_jump_finished:
		arrow_wall_jump_up_right.visible = true
		arrow_to_walkable_wall.visible = false
		_show_banner_for_phase(Phase.WALL_JUMP)

func _on_wall_jump_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_wall_jump_up_right.visible = false
		arrow_to_walkable_wall.visible = false
		is_wall_jump_finished = true
		banner.hide_banner()
