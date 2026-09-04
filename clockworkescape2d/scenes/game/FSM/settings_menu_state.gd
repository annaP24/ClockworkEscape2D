extends WorldViewState

func enter() -> void:
	if not EventBus.button_pressed.is_connected(_on_button_pressed):
		EventBus.button_pressed.connect(_on_button_pressed)
	instance = scene.instantiate()
	actor.add_child(instance)

func exit() -> void:
	instance.queue_free()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func _on_button_pressed(button : TextureButton) -> void:
	if not instance:
		return
	if button == instance.default_button:
		instance.set_defaults()
	elif button == instance.back_button:
		instance.update_settings()
		request_change.emit(self, "startmenu")
