extends WorldViewState

func enter() -> void:
	pass
	#instance = scene.instantiate()
	#actor.add_child(instance)

func exit() -> void:
	instance.queue_free()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
