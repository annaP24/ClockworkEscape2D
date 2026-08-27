extends WorldViewState

var current_level_path : String = ""
var current_level_id : int = -1
var current_level_instance : Node = null

func enter() -> void:
	var request = GameSession.consume_level_request()
	if request.path != "":
		current_level_path = request.path
		current_level_id = request.id
		_load_level(current_level_path, current_level_id)
	EventBus.level_quit_requested.connect(_on_quit_level_received)

func exit() -> void:
	_unload_level()

func _load_level(path_to_level : String, level_id : int):
	if path_to_level == "":
		return

	_unload_level()
	var level_scene = load(path_to_level)
	if not level_scene:
		push_error("Failed to load level scene: %s" % path_to_level)
		return

	current_level_instance = level_scene.instantiate()
	if current_level_instance:
		current_level_instance.set("level_id", level_id)
		if actor:
			actor.add_child(current_level_instance)
		else:
			push_error("Level state has no actor assigned. Set actor to the Scene node.")

func _unload_level():
	if current_level_instance:
		current_level_instance.queue_free()
		current_level_instance = null

#----------------- Signals -----------------------------------------
func _on_quit_level_received() -> void:
	request_change.emit(self, "LevelPickMenu")
