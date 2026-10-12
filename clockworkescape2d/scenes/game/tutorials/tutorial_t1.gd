extends Node

@export var player : PlayerFsmCustomDataLayer
#------------- Arrows --------------------------------
@onready var arrow_jump: Sprite2D = %ArrowJump
@onready var arrow_wall_jump: Sprite2D = %ArrowWallJump
@onready var arrow_to_collectable: Sprite2D = %ArrowToCollectable
@onready var arrow_jump_to_moving_platform: Sprite2D = %ArrowJumpToMovingPlatform
@onready var arrow_to_collectable_with_swords: Sprite2D = %ArrowToCollectableWithSwords

# ------------------ Areas -----------------------
@onready var jump_area: Area2D = %JumpArea
@onready var wall_double_jump_area: Area2D = %WallDoubleJumpArea
@onready var collectable_area: Area2D = %CollectableArea
@onready var jump_to_platform_area: Area2D = %JumpToPlatformArea
@onready var jump_to_platform_finish_area: Area2D = %JumpToPlatformFinishArea
@onready var dissapearing_platform_area: Area2D = %DissapearingPlatformArea
@onready var wall_slide_jump_area: Area2D = %WallSlideJumpArea
@onready var wall_jump_slide_jump_area_finish: Area2D = %WallJumpSlideFinishedArea
#------- Collectables -------------------------
@onready var collectable2: StaticBody2D = %Collectable2
@onready var collectable3: StaticBody2D = %Collectable3

var tutorial_banner = preload("res://scenes/game/tutorial_banner/tutorial_banner.tscn")
var banner: TutorialBanner
var current_banner_base_text: Array[String] = []
var is_jump_finished: bool = false
var is_wall_double_jump_finished: bool = false
var is_first_collectable_collected: bool = false
var is_jump_to_platform_finished: bool = false
var is_wall_slide_jump_finished: bool = false
var is_wall_jump_slide_jump_finished: bool = false
var is_dissapearing_platform_finished: bool = false

enum Phase {JUMP, WALL_JUMP, JUMP_TO_PLATFORM, WALL_SLIDE_JUMP, WALL_JUMP_SLIDE_JUMP, IDLE, COLLECTABLE, COLLECTED_EXPLANATION, DISSAPEARING_PLATFORM}

func _ready() -> void:
	_setup_tutorial()
	_setup_connections()

func _get_banner_text(phase: Phase) -> Array[String]:
	var joy = GameSession.is_joypad_connected
	match phase:
		Phase.JUMP:
			return ["Jump", "press %s" % ["(A)" if joy else "Space"]]
		Phase.WALL_JUMP:
			return ["Wall jump", "jump toward the wall and on impact press %s to jump off it" % ["(A)" if joy else "Space"]]
		Phase.JUMP_TO_PLATFORM:
			return ["Jump to the platform", "press %s to jump onto the moving platform and reach the opposite side" % ["(A)" if joy else "Space"]]
		Phase.WALL_SLIDE_JUMP:
			return ["Wall slide jump", "slide down the wall and press %s to jump off it" % ["(A)" if joy else "Space"]]
		Phase.WALL_JUMP_SLIDE_JUMP:
			return ["Wall jump and slide", "jump toward the wall, slide and jump off the wall with %s and %s" % ["(A)" if joy else "Space", "Stick right" if joy else "(D)"]]
		Phase.COLLECTABLE:
			return ["Collectable", "Collect the small gears scattered around the level"]
		Phase.COLLECTED_EXPLANATION:
			return ["Collected!", "Collect as many small gears as you can in levels to progress"]
		Phase.DISSAPEARING_PLATFORM:
			return ["Dissapearing Platform", "Be quick to move away before it disappears"]
		Phase.IDLE:
			return [""]
	return []

func _setup_banner() -> void:
	# Separate screen-space layer so the banner stays glued to the top-center viewport unlike the world-space hint nodes.
	var layer := CanvasLayer.new()
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

func _setup_tutorial() -> void:
	is_jump_finished = false
	is_wall_double_jump_finished = false
	is_jump_to_platform_finished = false
	is_wall_slide_jump_finished = false
	is_wall_jump_slide_jump_finished = false
	arrow_jump.visible = false
	arrow_wall_jump.visible = false
	arrow_to_collectable.visible = false
	arrow_jump_to_moving_platform.visible = false
	arrow_to_collectable_with_swords.visible = false
	_setup_banner()

func _setup_connections() -> void:
	jump_area.body_entered.connect(_on_jump_area_body_entered)
	jump_area.body_exited.connect(_on_jump_area_body_exited)
	collectable_area.body_entered.connect(_on_collectable_area_body_entered)
	collectable_area.body_exited.connect(_on_collectable_area_body_exited)
	wall_double_jump_area.body_entered.connect(_on_wall_double_jump_area_body_entered)
	wall_double_jump_area.body_exited.connect(_on_wall_double_jump_area_body_exited)
	jump_to_platform_area.body_entered.connect(_on_jump_to_platform_area_body_entered)
	jump_to_platform_area.body_exited.connect(_on_jump_to_platform_area_body_exited)
	jump_to_platform_finish_area.body_entered.connect(_on_jump_to_platform_finish_area_body_entered)
	dissapearing_platform_area.body_entered.connect(_on_dissapearing_platform_area_body_entered)
	dissapearing_platform_area.body_exited.connect(_on_dissapearing_platform_area_body_exited)
	wall_slide_jump_area.body_entered.connect(_on_wall_slide_jump_area_body_entered)
	wall_slide_jump_area.body_exited.connect(_on_wall_slide_jump_area_body_exited)
	wall_jump_slide_jump_area_finish.body_entered.connect(_on_wall_jump_slide_jump_area_finish_body_entered)
	collectable2.collected.connect(_on_collectable2_collected)
	collectable3.collected.connect(_on_collectable3_collected)


	Input.joy_connection_changed.connect(_on_joy_connection_changed)

#------------------ Signals -----------------------
func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if banner.visible and current_banner_base_text.size() > 0:
		# Rebuild the text with the new device phrasing so the same banner refreshes in place.
		banner.show_banner(current_banner_base_text)

func _on_jump_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_jump_finished:
		_show_banner_for_phase(Phase.JUMP)
		arrow_jump.visible = true

func _on_jump_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_jump.visible = false

func _on_wall_double_jump_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_double_jump_finished:
		_show_banner_for_phase(Phase.WALL_JUMP)
		arrow_wall_jump.visible = true
		is_jump_finished = true


func _on_wall_double_jump_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_wall_jump.visible = false

func _on_collectable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_first_collectable_collected:
		arrow_to_collectable.visible = true

func _on_collectable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_collectable.visible = false
		_show_banner_for_phase(Phase.IDLE)

func _on_collectable2_collected() -> void:
	arrow_to_collectable.visible = false
	is_first_collectable_collected = true
	_show_banner_for_phase(Phase.COLLECTED_EXPLANATION)

func _on_jump_to_platform_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_jump_to_platform_finished:
		_show_banner_for_phase(Phase.JUMP_TO_PLATFORM)
		arrow_jump_to_moving_platform.visible = true

func _on_jump_to_platform_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_jump_to_moving_platform.visible = false
		arrow_to_collectable.visible = false

func _on_jump_to_platform_finish_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_jump_to_platform_finished:
		arrow_jump_to_moving_platform.visible = false
		is_jump_to_platform_finished = true
		_show_banner_for_phase(Phase.IDLE)

func _on_dissapearing_platform_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dissapearing_platform_finished:
		_show_banner_for_phase(Phase.DISSAPEARING_PLATFORM)

func _on_dissapearing_platform_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_collectable.visible = false
		is_dissapearing_platform_finished = true
		_show_banner_for_phase(Phase.IDLE)

func _on_wall_slide_jump_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_wall_slide_jump_finished:
		_show_banner_for_phase(Phase.WALL_SLIDE_JUMP)
		arrow_to_collectable_with_swords.visible = true

func _on_wall_slide_jump_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		arrow_to_collectable_with_swords.visible = false

func _on_collectable3_collected() -> void:
	is_wall_slide_jump_finished = true
	arrow_to_collectable_with_swords.visible = false

func _on_wall_jump_slide_jump_area_finish_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_show_banner_for_phase(Phase.IDLE)
		arrow_to_collectable_with_swords.visible = false
