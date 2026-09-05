extends Node
## Sequences level_start's tutorial arrows: first collectable, wall climb, then the wall-jump (up-right, then left) cue.
@export var player : PlayerFsmCustomDataLayer
@onready var arrow_collectable: Sprite2D = %ArrowToCollectable
@onready var arrow_to_walkable_wall: Sprite2D = %ArrowToWalkableWall
@onready var arrow_wall_jump_up_right: Sprite2D =%ArrowWallJumpUpRight
@onready var hint_layer: Node2D = %TutorialHints
@onready var label_jump: Label = %LabelJump
@onready var label_collect: Label = %LabelCollect
@onready var label_press_arrow: Label = %LabelPressArrow
@onready var label_double_jump: Label = %LabelDoubleJump
@onready var collectable_2: StaticBody2D = $"../Collectables/Collectable2"

@onready var wall_double_jump_hint_zone_exit: Area2D = %WallDoubleJumpHintZoneExit
@onready var wall_jump_hint_zone_enter: Area2D = %WallJumpHintZoneEnter
@onready var wall_jump_hint_zone_exit: Area2D = %WallJumpHintZoneExit
@onready var walkable_wall_hint_zone_exit: Area2D = %WalkableWallHintZoneExit
@onready var walkable_wall_hint_zone_enter: Area2D = %WalkableWallHintZoneEnter

var _wall_climb_connected := false
var _wall_climbed := false
var is_walkable_finished : bool = false
var is_wall_jump_finished : bool = false

func _ready() -> void:
	# Establish a known starting state in code so scene edits/exports can't silently break the sequence.
	hint_layer.visible = true
	label_jump.visible = false
	label_collect.visible = false
	label_press_arrow.visible = false
	arrow_collectable.visible = false
	arrow_to_walkable_wall.visible = false
	arrow_wall_jump_up_right.visible = false
	label_double_jump.visible = true
	wall_double_jump_hint_zone_exit.body_entered.connect(_on_double_jump_entered)

	collectable_2.collected.connect(_on_collectable_collected)

	walkable_wall_hint_zone_enter.body_entered.connect(_on_walkable_wall_hint_zone_enter_body_entered)
	walkable_wall_hint_zone_exit.body_entered.connect(_on_walkable_wall_hint_zone_exit_body_entered)
	wall_jump_hint_zone_enter.body_entered.connect(_on_wall_jump_hint_zone_enter_body_entered)
	wall_jump_hint_zone_exit.body_entered.connect(_on_wall_jump_hint_zone_exit_body_entered)
	FadeScreen.fade_in_finished.connect(_on_fade_in_finished, CONNECT_DEFERRED)

func _on_double_jump_entered(body: Node2D)-> void:
	if body.is_in_group("player"):
		label_double_jump.visible = false
		label_collect.visible = true
		arrow_collectable.visible = true

func _on_collectable_collected() -> void:
	label_collect.visible = false
	arrow_collectable.visible = false
	label_jump.visible = true

func _on_walkable_wall_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_walkable_finished:
		label_press_arrow.visible = true
		arrow_to_walkable_wall.visible = true
		label_jump.visible = false


func _on_walkable_wall_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label_press_arrow.visible = false
		arrow_to_walkable_wall.visible = false
		is_walkable_finished = true

func _on_wall_jump_hint_zone_enter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_jump_finished:
		arrow_wall_jump_up_right.visible = true

func _on_wall_jump_hint_zone_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_wall_jump_up_right.visible = false
		is_wall_jump_finished = true


func _on_fade_in_finished() -> void:
	if _wall_climb_connected:
		return
	if player:
		_wall_climb_connected = true
