extends Node
class_name WorldViewState

signal request_change(current_state: WorldViewState, new_state_id: String)

@export var scene: PackedScene
@export var actor : Node2D
var instance : Control

var world : WorldMap

func enter() -> void:
	pass

func exit() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
