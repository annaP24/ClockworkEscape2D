extends Node
## Sequences level_start's tutorial arrows: first collectable, wall climb, then the wall-jump (up-right, then left) cue.
## Also shows a screen-space tutorial banner at each phase; banner pauses the game until confirmed.

const TUTORIAL_BANNER = preload("res://scenes/game/tutorial_banner/tutorial_banner.tscn")

@export var player : PlayerFsmCustomDataLayer
@onready var arrow_collectable: Sprite2D = %ArrowToCollectable
@onready var arrow_to_walkable_wall: Sprite2D = %ArrowToWalkableWall
@onready var arrow_wall_jump_up_right: Sprite2D =%ArrowWallJumpUpRight
@onready var hint_layer: Node2D = %TutorialHints
@onready var label_jump: Label = %LabelJump
@onready var label_collect: Label = %LabelCollect
@onready var label_press_arrow: Label = %LabelPressArrow
@onready var label_double_jump: Label = %LabelDoubleJump
@onready var collectable_2: StaticBody2D = %Collectable2

@onready var wall_double_jump_hint_zone_exit: Area2D = %WallDoubleJumpHintZoneExit
@onready var wall_jump_hint_zone_enter: Area2D = %WallJumpHintZoneEnter
@onready var wall_jump_hint_zone_exit: Area2D = %WallJumpHintZoneExit
@onready var walkable_wall_hint_zone_exit: Area2D = %WalkableWallHintZoneExit
@onready var walkable_wall_hint_zone_enter: Area2D = %WalkableWallHintZoneEnter

var is_walkable_finished : bool = false
var is_wall_jump_finished : bool = false
var _banner : PanelContainer
var _current_banner_base_text := ""

func _ready() -> void:
	# Establish a known starting state in code so scene edits/exports can't silently break the sequence.
	hint_layer.visible = true
	label_jump.visible = false
	label_collect.visible = false
	label_press_arrow.visible = false
	arrow_collectable.visible = true
	arrow_to_walkable_wall.visible = false
	arrow_wall_jump_up_right.visible = false
	label_double_jump.visible = false
	wall_double_jump_hint_zone_exit.body_entered.connect(_on_double_jump_entered)

	collectable_2.collected.connect(_on_collectable_collected)

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
	_banner = TUTORIAL_BANNER.instantiate()
	layer.add_child(_banner)

enum Phase {DOUBLE_JUMP, COLLECT, JUMP, WALL_CLIMB, WALL_JUMP}

func _get_banner_text(phase: Phase) -> String:
	var joy = GameSession.is_joypad_connected
	match phase:
		Phase.DOUBLE_JUMP:
			return "Double Jump - press %s twice" % ["(A)" if joy else "Space"]
		Phase.COLLECT:
			return "Collect the item"
		Phase.JUMP:
			return "Jump - press %s" % ["(A)" if joy else "Space"]
		Phase.WALL_CLIMB:
			return "Wall climb - hold %s while touching the wall" % ["D-Pad/Stick Up" if joy else "↑ / W"]
		Phase.WALL_JUMP:
			return "Wall jump - press %s while on a wall" % ["(A)" if joy else "Space"]
	return ""

func _show_banner_for_phase(phase: Phase) -> void:
	_current_banner_base_text = _get_banner_text(phase)
	if _current_banner_base_text != "":
		_banner.show_banner(_current_banner_base_text)

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if _banner.visible and _current_banner_base_text != "":
		# Rebuild the text with the new device phrasing so the same banner refreshes in place.
		_banner.show_banner(_current_banner_base_text)

func _on_double_jump_entered(body: Node2D)-> void:
	if body.is_in_group("player"):
		label_double_jump.visible = false
		label_jump.visible = true
		_show_banner_for_phase(Phase.JUMP)

func _on_collectable_collected() -> void:
	label_collect.visible = false
	arrow_collectable.visible = false
	label_double_jump.visible = true

	_show_banner_for_phase(Phase.DOUBLE_JUMP)

func _on_walkable_wall_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_walkable_finished:
		label_press_arrow.visible = true
		arrow_to_walkable_wall.visible = true
		label_jump.visible = false
		_show_banner_for_phase(Phase.WALL_CLIMB)

func _on_walkable_wall_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label_press_arrow.visible = false
		arrow_to_walkable_wall.visible = false
		is_walkable_finished = true
		_banner.hide_banner()

func _on_wall_jump_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_jump_finished:
		arrow_wall_jump_up_right.visible = true
		_show_banner_for_phase(Phase.WALL_JUMP)

func _on_wall_jump_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_wall_jump_up_right.visible = false
		is_wall_jump_finished = true
		_banner.hide_banner()
