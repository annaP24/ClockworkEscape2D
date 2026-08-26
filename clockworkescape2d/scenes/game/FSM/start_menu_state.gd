extends WorldViewState

func enter() -> void:
	if not EventBus.button_pressed.is_connected(_on_button_pressed):
		EventBus.button_pressed.connect(_on_button_pressed)
	instance = scene.instantiate()
	actor.add_child(instance)
	pass

func exit() -> void:
	instance.queue_free()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func _on_button_pressed(button : TextureButton) -> void:
	if not instance:
		return
	if button == instance.start_button:
		request_change.emit(self, "slotsmenu")
	elif button == instance.settings_button:
		request_change.emit(self, "settingsmenu")
	elif button == instance.quit_button:
		EventBus.menu_quit_game.emit()
