extends Node2D

@export var shoot_cooldown : float = 1.8
@export var projectile_speed : float = 2.0
@export var projectile_rotation : float = 100.0
@export var flow_direction : direction
@export var arrow : PackedScene = preload("res://scenes/obstacles/projectiles/star/throwing_star.tscn")
@onready var spawn_marker: Marker2D = $Sprite2D/SpawnMarker
@onready var cooldown: Timer = $Cooldown
@onready var sprite_2d: Sprite2D = $Sprite2D

enum direction { LEFT, RIGHT, UP, DOWN}
var projectile : PackedScene
var is_shoot : bool = false
var current_shoot_dir : Vector2 = Vector2.ZERO

func _ready() -> void:
	projectile = arrow
	if flow_direction == direction.LEFT:
		current_shoot_dir = Vector2(-1,0)
		#sprite_2d.rotation = deg_to_rad(0)
	elif flow_direction == direction.RIGHT:
		current_shoot_dir = Vector2(1,0)
		#sprite_2d.rotation = deg_to_rad(180)
	elif flow_direction == direction.UP:
		current_shoot_dir = Vector2(0,-1)
		#sprite_2d.rotation = deg_to_rad(90)
	elif flow_direction == direction.DOWN:
		current_shoot_dir = Vector2(0,1)
		#sprite_2d.rotation = deg_to_rad(-90)

	cooldown.wait_time = shoot_cooldown

func _process(_delta: float) -> void:
	if is_shoot:
		shoot_bullet()
		is_shoot = false

func shoot_bullet():
	var projectile_scene = projectile.instantiate() as Projectile
	projectile_scene.position = spawn_marker.position
	projectile_scene.current_direction = current_shoot_dir
	projectile_scene.speed = projectile_speed
	projectile_scene.show_behind_parent = true
	projectile_scene.rotation_angle = projectile_rotation
	add_child(projectile_scene)

func _on_cooldown_timeout() -> void:
	is_shoot = true
