extends WorldViewState

var current_level_instance : Node = null

func enter() -> void:
	# GameSession.update_mouse_visibility(true)
	# if GameSession.is_joypad_connected:
	# 	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# else:
	# 	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	var request = GameSession.consume_level_request()
	if request["path"] != "":
		_load_level(request["path"], request["id"])
	if not EventBus.level_quit_requested.is_connected(_on_quit_level_received):
		EventBus.level_quit_requested.connect(_on_quit_level_received)
	if not EventBus.level_restart_requested.is_connected(_on_restart_level_received):
		EventBus.level_restart_requested.connect(_on_restart_level_received)


func exit() -> void:
	_unload_level()
	if EventBus.level_quit_requested.is_connected(_on_quit_level_received):
		EventBus.level_quit_requested.disconnect(_on_quit_level_received)
	if EventBus.level_restart_requested.is_connected(_on_restart_level_received):
		EventBus.level_restart_requested.disconnect(_on_restart_level_received)


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
	# GameSession.update_mouse_visibility(false)
	request_change.emit(self, "LevelPickMenu")

func _on_restart_level_received() -> void:
	# GameSession.update_mouse_visibility(true)
	request_change.emit(self, "Level")
	#FadeScreen.fade_out()
