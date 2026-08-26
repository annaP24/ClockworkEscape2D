extends Node
class_name StateMachine

@export var initial_state : WorldViewState

var current_state : WorldViewState
var states : Dictionary[String, WorldViewState] = {}


func _ready() -> void:
	for child in get_children():
		if child is WorldViewState:
			states[child.name.to_lower()] = child
			child.request_change.connect(_on_request_change)

	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state._process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_process(delta)

func _on_request_change(source_state: WorldViewState, new_state_id: String) -> void:
	if source_state != current_state:
		return
	var new_state : WorldViewState = states.get(new_state_id.to_lower())

	if not new_state:
		return

	current_state.exit()
	new_state.enter()
	current_state = new_state
