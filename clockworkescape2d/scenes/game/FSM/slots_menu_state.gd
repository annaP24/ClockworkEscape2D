extends WorldViewState

var selected_slot
func enter() -> void:
	if not EventBus.button_pressed.is_connected(_on_button_pressed):
		EventBus.button_pressed.connect(_on_button_pressed)
	instance = scene.instantiate() as SlotsMenu
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
	if button == instance.back_button:
		request_change.emit(self, "startmenu")
	elif button == instance.play_button:
		pass
	elif button == instance.delete_button:
		GameSaveManager.delete_configuration(instance.selected_slot)
		instance.check_slot_data()
