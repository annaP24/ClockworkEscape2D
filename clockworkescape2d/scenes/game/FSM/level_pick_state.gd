extends WorldViewState

@export var node_scene : PackedScene
var node : Node2D

func enter() -> void:
	node = node_scene.instantiate() as LevelPick
	actor.add_child(node)
	node.load_level.connect(_on_load_level)

func exit() -> void:
	node.queue_free()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		request_change.emit(self, "StartMenu")

func _on_load_level(path_to_level: String, level_id: int) -> void:
	GameSession.set_level_request(path_to_level, level_id)
	request_change.emit(self, "Level")
