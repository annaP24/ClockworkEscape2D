extends Node
class_name CompFsmNode

@export var initial_state: FsmNodeState
@onready var platformer : PlayerFsmCustomDataLayer = $".."

var states_dict: Dictionary = {}
var current_state: FsmNodeState
var state_change_timer : Timer
var state_changed : bool = false

func start():
	for child in get_children():
		if child is FsmNodeState:
			states_dict[child.name.to_lower()] = child

	if initial_state:
		initial_state.Enter(platformer)
		current_state = initial_state
	state_change_timer = Timer.new()
	state_change_timer.wait_time = 0.2
	state_change_timer.one_shot = true
	state_change_timer.connect("timeout", _on_timer_state_changed_timeouted)
	add_child(state_change_timer)

func _ready():
	pass
	#for child in get_children():
		#if child is FsmNodeState:
			#states_dict[child.name.to_lower()] = child
			##child.Transitioned.connect(on_child_transition)
			#
	#if initial_state:
		#initial_state.Enter(platformer)
		#current_state = initial_state
	#state_change_timer = Timer.new()
	#state_change_timer.wait_time = 0.2
	#state_change_timer.one_shot = true
	#state_change_timer.connect("timeout", _on_timer_state_changed_timeouted)
	#add_child(state_change_timer)
	#
func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func change_state(state : FsmNodeState , new_state_name : String):
	if state != current_state:
		return
	if !state_changed:
		var new_state = states_dict.get(new_state_name.to_lower())
		if !new_state:
			return

		if current_state:
			current_state.Exit()

		new_state.Enter(platformer)
		current_state = new_state
		#state_change_timer.start()
		#state_changed = true

func _on_timer_state_changed_timeouted():
	state_changed = false
